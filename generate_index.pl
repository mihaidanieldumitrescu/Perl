use strict;
use warnings;

use File::Copy;

my @filelist;

sub main{
open (OUT, ">", "index.html");
print OUT "<html><body><table style=\"margin-left:200px\">";
opendir (PIC, ".");

	while (my $file = readdir(PIC)){
	    #generate($file);
		push @filelist, $file;
	}
	
closedir(PIC);

foreach my $file (@filelist){
	
	if ($file =~ /500px/){
		
			#copy ("generate.pl", $file);
		    #chdir (".\\".$file);
			#print "Line: $file\n";
			#system("cd");	
			#system("perl -w generate.pl");	
			print OUT "<tr><td><a href=\"$file\\output.html \">$file \(".countFiles("$file")."\)</a></td></tr>\n";
			}
	}

print OUT "</table></body></html>";
close (OUT);
}

sub countFiles{

	my $count=0;
	my $dirname = shift;
	print $dirname. "\n";
	opendir (DIR_NAME, ".\\$dirname");
		while (my $file = readdir(DIR_NAME)){
			if ($file =~ /jpe?g/){
				$count++;
			}
		}
	closedir(DIR_NAME);
	print "result: $count \n";
return $count;
}

sub generate{
	
	my $indir = shift;
	print "Entering function generate output.html\n\n";

	opendir (PIC, ".\\$indir\\");

	
	open (OUT, ">", ".\\$indir\\output.html");
	print OUT "<html><body><table><tr>";
	
		while (my $file = readdir(PIC)){
			if ($file =~ /\.jpg/)
			{	
				print OUT "<td><img src=\"$file\" height=\"600\"></img></td>";
			}
		}
	closedir(PIC);
	print OUT "</tr></table></body></html>";
	close (OUT);

}

main();
