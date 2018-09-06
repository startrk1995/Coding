#!/opt/local/bin/perl

use LWP::Simple;                # From CPAN
use JSON qw( decode_json );     # From CPAN
use Data::Dumper;               # Perl core module
use strict;                     # Good practice
use warnings;                   # Good practice
# use URI;
use URI::Split qw(uri_join);
use URI::Escape;



####### EDIT SECTION ###############
my $plexpyurl="http://plex.flatiron.serveftp.net";
my $plexport = "8181";
my $baseurl = URI->new($plexpyurl);
my $apiversion = "api/v2";
my $apikey = "d1f55a2aec6149199b8f93bdbfbebd92";
my $days = "7";
my $selectedlibs = "Movies"; #Must have | between Libraries and is case sensitive.

####### END EDIT SECTION #############
my $now=time;
my $past=(time - ($days*24*60*60));
print "Now = $now\n";
print "Past = $past\n";
$baseurl->port( $plexport );
$baseurl->path( $apiversion );
$baseurl->query( "apikey=$apikey" );


################  Get Libraries ########################

my $get_libraries_url = $baseurl->clone;
$get_libraries_url->query( "apikey=$apikey&cmd=get_libraries" );
print "$get_libraries_url\n";
my $get_libraries = get( $get_libraries_url );
die "Could not get $get_libraries_url!" unless defined $get_libraries;
my $decoded_get_libraries = decode_json( $get_libraries );
my %plexlibraries = %$decoded_get_libraries;
my %plexfinal;
my @plexlibraries;
my $section_id;
my $section_name;
my $i = "0";
			##### Loop through all Libraries and build final hash with name and id  #####
foreach my $data (keys @{$plexlibraries{'response'}{'data'}}) {
	$section_name = $plexlibraries{'response'}{'data'}[$i]{'section_name'};
	$section_id = $plexlibraries{'response'}{'data'}[$i]{'section_id'};
	$plexfinal{"Libraries"}{$section_id}{"section_id"} = $section_id; 
	$plexfinal{"Libraries"}{$section_id}{'section_name'} = $section_name; 
	$i++;
}	
			#####  Delete all libraries that are not in the edited section  #####
foreach my $libs (keys %{$plexfinal{'Libraries'}}) {
	chomp $libs;
	delete $plexfinal{Libraries}{$libs} if( $plexfinal{Libraries}{$libs}{'section_name'} !~ /$selectedlibs/ );
}

################  End Get Libraries #########################

################  Get Recently Added ########################

foreach my $section (keys %{$plexfinal{'Libraries'}}) {
	my $section_id = $plexfinal{'Libraries'}{$section}{'section_id'};
	my $get_recently_added_url = $baseurl->clone;
	$get_recently_added_url->query( "apikey=$apikey&count=2500&section_id=$section_id&cmd=get_recently_added" );
	my $get_recently_added = get( $get_recently_added_url );
	die "Could not get $get_recently_added_url!" unless defined $get_recently_added;
	my $decoded_get_recently_added = decode_json( $get_recently_added );
	my %plexrecentlyadded = %$decoded_get_recently_added;
	my $c = "0";
	foreach my $data (keys @{$plexrecentlyadded{'response'}{'data'}{'recently_added'}}) {
		my $added_at = $plexrecentlyadded{'response'}{'data'}{'recently_added'}[$c]{'added_at'};
		my $section_id = $plexrecentlyadded{'response'}{'data'}{'recently_added'}[$c]{'section_id'};
		my $rating_key = $plexrecentlyadded{'response'}{'data'}{'recently_added'}[$c]{'rating_key'};
		if ( $added_at <= $now && $added_at >= $past ) {
			$plexfinal{"Libraries"}{$section_id}{$rating_key}{"rating_key"} = $rating_key;
			$plexfinal{"Libraries"}{$section_id}{$rating_key} = $plexrecentlyadded{'response'}{'data'}{'recently_added'}[$c];
			$plexfinal{"Libraries"}{$section_id}{$rating_key}{'section_name'} = $plexfinal{"Libraries"}{$section_id}{"section_name"};
			$c++;
			################  Get Metadata ###############################
			my $get_metadata_url = $baseurl->clone;
			$get_metadata_url->query( "apikey=$apikey&cmd=get_metadata&rating_key=$rating_key" );
			my $get_metadata = get( $get_metadata_url );
			die "Could not get $get_libraries_url!" unless defined $get_metadata;
			my $decoded_get_metadata = decode_json( $get_metadata );
			my %plexmetadata = %$decoded_get_metadata;
			#print Dumper %plexmetadata;
		}
		else {
			delete $plexfinal{"Libraries"}{$section_id}{$rating_key};
		}
			
	}
	delete $plexfinal{"Libraries"}{$section_id}{"section_name"};
	delete $plexfinal{"Libraries"}{$section_id}{"section_id"};
}

print Dumper \%plexfinal;

################  End Get Recently Added #####################

foreach my $section (keys %{$plexfinal{'Libraries'}}) {
	my $section_id = $plexfinal{'Libraries'}{$section}{'section_id'};
	my $get_recently_added_url = $baseurl->clone;
	$get_recently_added_url->query( "apikey=$apikey&count=2500&section_id=$section_id&cmd=get_recently_added" );
	my $get_recently_added = get( $get_recently_added_url );
	die "Could not get $get_recently_added_url!" unless defined $get_recently_added;
	my $decoded_get_recently_added = decode_json( $get_recently_added );
	my %plexrecentlyadded = %$decoded_get_recently_added;
	my $c = "0";
	foreach my $data (keys @{$plexrecentlyadded{'response'}{'data'}{'recently_added'}}) {
		my $added_at = $plexrecentlyadded{'response'}{'data'}{'recently_added'}[$c]{'added_at'};
		my $section_id = $plexrecentlyadded{'response'}{'data'}{'recently_added'}[$c]{'section_id'};
		my $rating_key = $plexrecentlyadded{'response'}{'data'}{'recently_added'}[$c]{'rating_key'};
		if ( $added_at <= $now && $added_at >= $past ) {
			$plexfinal{"Libraries"}{$section_id}{$rating_key}{"rating_key"} = $rating_key;
			$plexfinal{"Libraries"}{$section_id}{$rating_key} = $plexrecentlyadded{'response'}{'data'}{'recently_added'}[$c];
			$plexfinal{"Libraries"}{$section_id}{$rating_key}{'section_name'} = $plexfinal{"Libraries"}{$section_id}{"section_name"};
			$c++;
			################  Get Metadata ###############################
			my $get_metadata_url = $baseurl->clone;
			$get_metadata_url->query( "apikey=$apikey&cmd=get_metadata&rating_key=$rating_key" );
			my $get_metadata = get( $get_metadata_url );
			die "Could not get $get_libraries_url!" unless defined $get_metadata;
			my $decoded_get_metadata = decode_json( $get_metadata );
			my %plexmetadata = %$decoded_get_metadata;
			#print Dumper %plexmetadata;
		}
		else {
			delete $plexfinal{"Libraries"}{$section_id}{$rating_key};
		}
			
	}
	delete $plexfinal{"Libraries"}{$section_id}{"section_name"};
	delete $plexfinal{"Libraries"}{$section_id}{"section_id"};
}

print Dumper \%plexfinal;







