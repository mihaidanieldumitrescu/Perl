use strict;
use warnings;
use Data::Dumper;

use POSIX qw(strftime);
use File::Copy;
  
my @filelist;
my $heightSize = 650;
my $files_per_segment=30;

my $picture_ref = {	
						pictures =>  []	
				  };

sub generatePageHeader {

	#index html page
	my $header="<html><body>\n<h3>pictureGalleryHTML.pl generated page</h3>" .
				"<p>Generated on ". strftime ("%Y.%m.%d",localtime). " </p>\n" .
				"<ul style=\"margin-left:100px\">\n";
	return $header;
}

sub generateNavigationBar {
	my $pictureCount = shift; #non jpeg files not included => could generate an additioanal non-existant page link
	my $currentPage= shift;
	my @pages;
	
 
	my $index = $files_per_segment;
	push @pages, "output_index.html";
	while ($index <= $pictureCount ) {
		push @pages, "output_$index.html";
		$index += $files_per_segment;
	}
	#generate array of pages e.g. "output_300.html from pictures"
	
	#print Dumper \@pages;
	
	my $naviBar= '
	<div>
		<ul>
		    <li>
				<a href="../../index.html">Home</a>
			</li>
			<li>
				<a href="#">Pages:</a>
			</li>';
		foreach my $page (@pages) {
			if ($page eq $currentPage){
			    $page =~ s/index/1/; # index is page 1
				$page =~ /(\d+)/;
				if ($1 < 300){
					$naviBar .= '
						<li>
							<a class="active" ' . $1 .' </a>
						</li>';
				} elsif ($1 == 300) {
						$naviBar .= '<li>
										<a class="menu">...</a>
									</li>
								</ul>
							</div>
						<div class="hidden-menu">
							<ul>
								<li>
									<a class="active"> '. $1 . '</a>
								</li>';
				} else {
						$naviBar .= '
						<li>
							<a class="active"> ' . $1 . '</a>
						</li>';
				}
			} else {
			    $page =~ s/index/1/; # index is page 1
				$page =~ /(\d+)/;
				
				if ($1 < 300){
					$naviBar .= '
				<li>
					<a href="'. (($1 eq "1") ? "output_index.html" : $page).'"> '.$1.' </a>
				</li>';
				} elsif ($1 == 300) {
					$naviBar .= '<li>
									<a class="menu">...</a>
								</li>
							</li>
						</ul>
							</div>
							<div class="hidden-menu"><ul>
										<li><a href="'. (($1 eq "1") ? "output_index.html" : $page).'"> '.$1.'</a></li>';
				} else {
					$naviBar .= '
							<li>
								<a href="'. (($1 eq "1") ? "output_index.html" : $page).'"> '.$1.'</a>
							</li>';
					}
			}   
		}
		$naviBar.="
	        </ul>
	</div>\n";
		print $naviBar;
	
	return $naviBar;
}

sub main {

	#generating index file first, list of all picture directories
	open (OUT, ">", "index.html");
	print OUT generatePageHeader();
	
	#counting for each dir number of files
	opendir (PIC, ".") or die "Cannot open dir\n$!\n\n";
		while (my $dirs = readdir(PIC)){
			if (-d $dirs and countFiles($dirs) > 0 and not $dirs =~ /^(.|..)$/){
					push @filelist, $dirs;
					generate($dirs);
			} else {
				print "$dirs -> Rejected\n";
			}
		}
		
	closedir(PIC);
	
	if (@filelist ==0){
		die "No dirs detected!\n\n";
	}
	
	#creating li element with links to every 'output_index.html' file
	foreach my $dirs (@filelist){
		if ( $dirs =~ /.*/){
				my $numberOfFiles = countFiles("$dirs");
				print OUT "<li>
								<a href=\"$dirs\\GalleryHTML\\output_index.html \"> 
										  $dirs \( ". $numberOfFiles ." \)</a>
								<ol> <a href=\"$dirs\\GalleryHTML\\random_gallery.html \"> Random Gallery
																		  </a>
								</ol>
							</li>\n";
		}
	}
	
	print OUT "</ul>
					</body>
						</html>";
	close (OUT);
}

sub countFiles {

	my $count=0;
	my $dirname = shift;
	print $dirname. "\n";
	opendir (DIR_NAME, ".\\$dirname");
		while (my $file = readdir(DIR_NAME)){
			if ($file =~ /jpe?g/i){
				$count++;
			}
		}
	closedir(DIR_NAME);
	print "result: $count \n";
return $count;
}

sub generate {
	
	# generate each gallery file 
	my $dirname = shift;
	my $file_index= 1;
	my $file_number= 1;
	my $regex_jpeg = "\.jpe?g\$";
	
	print "Generating html gallery for \"$dirname\"\n\n";
	opendir (SUB, $dirname) or die "\n$! \n Cannot open dir\n";
	my @pictures = readdir(SUB);
	my $currentPageName = "";
	
	#dirname/picture.jpeg
	foreach my $file  (@pictures) {
		
			push @{ $picture_ref->{pictures} }, $file if $file =~ /\.jpe?g/i;
 
			if ( $file_index < $file_number * $files_per_segment) {
				if ($file_index == 1 + (($file_number - 1) * $files_per_segment) and $file =~ /\.jpe?g/i){
					print "Opening file output_$file_number.html at $file_index\n";
					if ($file_number == 1){
						(mkdir ".\\$dirname\\GalleryHTML" or warn "$!\n\n");
						(mkdir ".\\$dirname\\Resized" or warn "$!\n\n");
						open (GEN, ">", ".\\$dirname\\GalleryHTML\\output_index.html");
						$currentPageName ="output_index.html";
					} else {						
						open (GEN, ">", ".\\$dirname\\GalleryHTML\\output_".(($file_number*$files_per_segment)-$files_per_segment).".html");
						$currentPageName ="output_".(($file_number*$files_per_segment)-$files_per_segment).".html";
					}
					
					if ($file_number == 1 ) {
						print  GEN '<html><head><link rel="stylesheet" href="../../main.css" type="text/css"></head>'."\n<body>\n<table>\n<tr>\n";
					} elsif ($file_number == 2 ) {
						print  GEN '<html><head><link rel="stylesheet" href="../../main.css" type="text/css"></head>'."\n<body>\n<table>\n<tr>\n <td><div class=\"bookmarks\"> <a href=\"output_index.html#page_end\"> Prev </a></div></td>";
					} else {
						print  GEN '<html><head><link rel="stylesheet" href="../../main.css" type="text/css"></head>'."\n<body>\n<table>\n<tr>\n <td><div class=\"bookmarks\"> <a href=\"output_".(($file_number - 1) * $files_per_segment-$files_per_segment).".html#page_end\"> Prev </a></div></td>";
					}
					
					print GEN generateNavigationBar( scalar (@pictures), $currentPageName);
				}
				
				if ($file =~ /\.jpe?g/i)
				{
					print GEN resizeImage($dirname, $file);
					$file_index++;
				}
	
			} elsif ($file_index == $file_number * $files_per_segment ) { 
				
				if ($file =~ /\.jpe?g/i)
				{
					print GEN resizeImage($dirname, $file);
					$file_index++;
				}
					print GEN "<td><div class=\"bookmarks\">  <a name=\"page_end\" href=\"output_".(($file_number + 1)*$files_per_segment-$files_per_segment).".html\"> Next </a></div></td></tr>\n</table>\n</body>\n</html>\n";
					print "Closing file output_$file_number.html at $file_index\n\n";
	
					close(GEN);
					$file_number++;
			}
			
			# generating html for random gallery
			open (RAND, ">", ".\\$dirname\\GalleryHTML\\random_gallery.html");
			# HEAD
			my $buffer = '<html><head><link rel="stylesheet" href="../../main.css" type="text/css">';
			$buffer .= generateNavigationBar(30, 'random_gallery.html');
			
			my $asJSarray =  Dumper $picture_ref->{pictures};
			$asJSarray =~ s/.* = /var pictures = /;
			$buffer .=	"<script> $asJSarray 

							document.write ('<table><tr>');
							for (var i =0; i < $files_per_segment; i++){
								imageName = pictures[Math.floor(Math.random()*pictures.length)];
								document.write (\"<td><img src=\" + \"../Resized/\" + imageName + \" height=\'$heightSize\'></img></td>\");	
							}
							document.write ('</tr></table>');
			  			</script>";
			
			# BODY
			$buffer .= '</head>'."\n<body>";
			for (@{ $picture_ref->{pictures}} )
				{
					#$buffer .= '<li> ' . $_ . ' </li>'. "\n";
				}
			$buffer .= "</body></html>";
			print RAND $buffer;
			close(RAND);

	}
		
			print GEN "</tr></table></body></html>";
			close (GEN);
	closedir(SUB);
	$picture_ref->{pictures} = [];
	return $file_index;
}

sub resizeImage {
	my ($dirname, $file) = @_;
 
	unless ( -e "$dirname\\Resized\\$file" ){
		print "Resizing \"$file\" using magick.exe\n";
		system("magick \"$dirname\\$file\" -resize x$heightSize -sharpen 0x.8 \"$dirname\\Resized\\$file\""); 
	} 

	return "<td><img src=\"../Resized/$file\" height=\"$heightSize\"></img></td>\n";
}

sub debug {
 
	opendir (SUB, '.') or die "\n$! \n Cannot open dir\n";
	my @pictures =readdir(SUB);
	my $currentPageName = "";
	closedir(SUB);
	
    generateNavigationBar( scalar (@pictures),"output_index.html");
}

#debug();
main();
