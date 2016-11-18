use strict;
use warnings;

my $files_per_segment=100;
my $file_index=1;
my $file_number=1;

sub generate{
	
	my $dirname = shift;
	print "Generating html gallery for \"$dirname\"\n\n";
	opendir (PIC, $dirname) or die "\n$! \n Cannot open dir\n";
	
		while (my $file =readdir(PIC)){
			if ( $file_index < $file_number * $files_per_segment){
			
				if ($file_index == 1 + (($file_number - 1) * $files_per_segment) and $file =~ /\.jpg/){
					print "Opening file output_$file_number.html at $file_index\n";
					if ($file_number == 1){
						open (OUT, ">", ".\\$dirname\\output_index.html");	
					} else {
						open (OUT, ">", ".\\$dirname\\output_".$file_number*$files_per_segment.".html");
					}
					if ($file_number == 1 ) {
						print  OUT '<html><head><link rel="stylesheet" href="main.css" type="text/css"></head>'."\n<body>\n<table>\n<tr>\n";
					} elsif ($file_number == 2 ) {
						print  OUT '<html><head><link rel="stylesheet" href="main.css" type="text/css"></head>'."\n<body>\n<table>\n<tr>\n <td><div class=\"bookmarks\"> <a href=\"output_index.html#page_end\"> Prev </a></div></td>";
					}else {
						print  OUT '<html><head><link rel="stylesheet" href="main.css" type="text/css"></head>'."\n<body>\n<table>\n<tr>\n <td><div class=\"bookmarks\"> <a href=\"output_".($file_number - 1) * $files_per_segment.".html#page_end\"> Prev </a></div></td>";
					}
				}
				
				if ($file =~ /\.jpg/)
				{	
					print OUT "<td><img src=\"$file\" height=\"600\"></img></td>\n";
					$file_index++;
				}
	
			} elsif ($file_index == $file_number * $files_per_segment ) { 
				
				if ($file =~ /\.jpg/)
				{	
					print OUT "<td><img src=\"$file\" height=\"600\"></img></td>\n";
					$file_index++;
				}
					print OUT "<td><div class=\"bookmarks\">  <a name=\"page_end\" href=\"output_".($file_number + 1)*$files_per_segment.".html\"> Next </a></div></td></tr>\n</table>\n</body>\n</html>\n";
					print "Closing file output_$file_number.html at $file_index\n\n";
	
					close(OUT);
					$file_number++;
			}		
		}
		
			print OUT "</tr></table></body></html>";
			close (OUT);
	closedir(PIC);
}

if (@ARGV ==1 and $ARGV[0]){
	generate($ARGV[0]);
} else {
	warn "Something definetely wrong. Please check if ARGV exists and is valid";
}
