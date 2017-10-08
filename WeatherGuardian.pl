use strict;
use warnings;

use Data::Dumper;
use APIXU::API::APIXU;

my $api_key      = 'undef';
my $apixu = APIXU::API::APIXU->new($api_key);

my $logfileName = "temperature.cvs";

my $api_explorer = 'Current';

my $json_decoded_hash_ref;
    
	if ($api_explorer eq 'Current') {
        my $location     = 'Bucharest';
        $json_decoded_hash_ref = $apixu->get_current($location);
    }
    elsif($api_explorer eq 'Forecast'){
        my $location     = 'Bucharest';
        my $days         = '2';   
        $json_decoded_hash_ref = $apixu->get_forecast($location, $days);
    }
	
system "echo temp_c;feelslike_c;wind_kph;humidity;pressure_mb;precip_mm;vis_km;wind_degree;wind_dir;is_day;cloud;condition;localtime;tz_id > $logfileName " unless (-e $logfileName ); 
 
open (LOG, ">>" , $logfileName);
my $row = $$json_decoded_hash_ref{'current'}{'temp_c'} 				 . ";" 
	    . $$json_decoded_hash_ref{'current'}{'feelslike_c'} 		 . ";" 
	    . $$json_decoded_hash_ref{'current'}{'wind_kph'} 			 . ";" 
	    . $$json_decoded_hash_ref{'current'}{'humidity'} 			 . ";" 
	    . $$json_decoded_hash_ref{'current'}{'pressure_mb'} 		 . ";" 
	    . $$json_decoded_hash_ref{'current'}{'precip_mm'}			 . ";" 
	    . $$json_decoded_hash_ref{'current'}{'vis_km'}			     . ";" 
	    . $$json_decoded_hash_ref{'current'}{'wind_degree'}			 . ";" 
	    . $$json_decoded_hash_ref{'current'}{'wind_dir'}			 . ";" 
	    . $$json_decoded_hash_ref{'current'}{'is_day'} 			     . ";" 
	    . $$json_decoded_hash_ref{'current'}{'cloud'} 				 . ";" 
	    . $$json_decoded_hash_ref{'current'}{'condition'}{'text'} 	 . ";" 
	    . $$json_decoded_hash_ref{'location'}{'localtime'} 			 . ";" 
		. $$json_decoded_hash_ref{'location'}{'tz_id'}				 . "\n";
		
		
		
print LOG $row;
close (LOG);

 
open (LOG, "<" , $logfileName);

my $yesterdayRecordedTemperature= -40;
my $todayRecorderTemperature= -40;

while ( my $line = <LOG>){
	my @columns = split /;/, $line;
	if ($columns[-2] =~/09:\d\d/ )
	{
		$yesterdayRecordedTemperature = $columns[0]; 
	}
}
close (LOG);

my $deltaTemp = $todayRecorderTemperature - $yesterdayRecordedTemperature;

if ( $deltaTemp >= 5 or $deltaTemp >= -5 and $deltaTemp != 0 ){
	my $string = (($deltaTemp >= 0 ) ? "Hotter: This day will be hotter than yesterday \n Today: $todayRecorderTemperature deg C vs yesterday: $yesterdayRecordedTemperature degreees Celsius" : 
									  "Colder: This day will be colder than yesterday \n Today: $todayRecorderTemperature deg C vs yesterday: $yesterdayRecordedTemperature degreees Celsius");
	print $string;
}