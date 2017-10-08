use strict;
use warnings;

use File::Copy;
use Data::Dumper;

$|=1;

my %paths = ( 'source' => '',
              'destination' => 'X:\Temp',
              'testSource' => 'D:\testTransfer'
             );
my $counter= 1;

sub compareFolders{
    my ($folderNameSource, $folderNameDestination )= @_;
    my (@filesSource, @filesDestination);
}

sub createParentFolder {
    my $folderName= shift;
    my @structures = ('NEF', 'XMP','Exported');
    print "Generation dir structure for \"$folderName\"\n\n";
    foreach my $name (@structures){
        `mkdir "$paths{'destination'}\\$folderName\\$name"` unless (-d "$paths{'destination'}\\$folderName\\$name");
    }
}

sub copyFiles {
    my ($folderNameSource, $folderNameExported ,$folderNameDestination )= @_;
	my %copyTest;

    system "cd";
    
    if (not -e ".\\$folderNameDestination"){
        print "Generating dir structure for \"$folderNameDestination\" ... \n\n ";
        createParentFolder("$folderNameDestination");
    }
    
   #die;
    chdir ("$paths{'destination'}") or warn "$!\n";
    print "Opening folder $folderNameSource ...\n\n";
    opendir (DIR, $folderNameSource);
    my @files = readdir(DIR);
    closedir(DIR);
    my $total = (@files);
    foreach my $file (@files){
       if ($file =~ /xmp/i){
            $total--;
       }
    }
    foreach my $file (@files){
        if ($file =~ /nef$/i and not -e ".\\$folderNameDestination\\NEF\\$file"){
            print "\r".calcProcentage($total)." Copy $file to 'NEF' folder";
            copy ("$folderNameSource\\$file", ".\\$folderNameDestination\\NEF") or warn "copyFiles: $!\n";
			push @{$copyTest{'NEF'}},  $file;
		}
    }
	print "\n";
    foreach my $file (@files){
        my $fileNewer=1;
        if ($file =~ /xmp/i and $fileNewer){
            print "\r Copy $file to 'XMP' folder";
            copy ("$folderNameSource\\$file", ".\\$folderNameDestination\\XMP") or warn "copyFiles: $!\n";
			push @{$copyTest{'XMP'}},  $file;
        }
    }
    print "\n";
    if ($folderNameExported ne "" ){
        my $fileNewer=1;
        opendir (DIR, $folderNameExported);
        while (my $file = readdir(DIR)){
                if ($file =~ /jpe?g/i and $fileNewer){
                print "\r".calcProcentage($total)." Copy $file to 'Exported' folder";
                copy ("$folderNameSource\\$file", ".\\$folderNameDestination\\Exported") or warn "copyFiles: $!\n";
				push @{$copyTest{'EXPORTED'}},  $file;
            }
        }
        closedir(DIR);
    }
	print "\n\n";
		
	print Dumper \%copyTest;

	return %copyTest;
}
 
sub calcProcentage{
    my $total=shift;
    my $procent = (++$counter / $total)*100;
    
    return $procent."%";
}

sub checkSuccess {
	my %copiedFiles = shift;
	my $folderName = shift;
	my @filesDestination;
	my $filesMatch=0;

	opendir(DIR, "$paths{'destination'}\\$folderName\\NEF");
	my @temp = readdir (DIR);
	closedir(DIR); 
	push @filesDestination, @temp;
	opendir(DIR, "$paths{'destination'}\\$folderName\\XMP");
	@temp = readdir (DIR);
	closedir(DIR); 
	push @filesDestination, @temp;
	opendir(DIR, "$paths{'destination'}\\$folderName\\Exported");
    @temp = readdir (DIR);
	closedir(DIR); 
	push @filesDestination, @temp;
		foreach my $key (keys %copiedFiles){
			foreach my $file ($copiedFiles{$key}){
				my $fileFound=0;
				foreach my $fileDest (@filesDestination){
					if ($file eq $fileDest){
						$fileFound=1;
						last;
					}
				}
			}
		}
}



sub transferFiles{

	my %copiedFiles = copyFiles( $paths{'testSource'} , "",  "testFolder");
	my %albumDetail = (
						"dateTaken" => "",
						"persons" => "",
						"location" => "Bucuresti",
						"category" => "e.g. excursie"
	);
	

	checkSuccess(%copiedFiles, "testFolder" );

}

transferFiles();