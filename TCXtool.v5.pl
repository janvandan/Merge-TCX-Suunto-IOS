#!/usr/bin/perl

use strict;
use warnings;

my $nomficGPS = "GPS_activity_1905540884.tcx";
my $nomficIOS = "W_activity_1905536039.tcx";

my $debug = 0;

my $ParamGPS = 16;
my $ParamIOS = 26;

my $l = 1;

my $ligneGPS;
my $ligneIOS;

my $TimeGPS;
my $ligneTrackpointGPS;

open(my $ficGPS, $nomficGPS,) or die "Impossible d'ouvrir $!";
open(my $ficIOS, $nomficIOS,) or die "Impossible d'ouvrir $!";

while ( $l <= $ParamGPS ) {
	$ligneGPS = <$ficGPS>;
	$ligneIOS = <$ficIOS>;

	print "$l IOS = $ligneIOS$l GPS = $ligneGPS" if ( $debug >= 5 );
	print "<- GPS" if ( $debug >= 5 ); print $ligneGPS;

	$l += 1;
}

# GPS & IOS ----- <Calories>0</Calories> 

while ( $l <= $ParamIOS ) {
	$ligneIOS = <$ficIOS>;
	print "$l IOS = $ligneIOS$l GPS = $ligneGPS" if ( $debug >= 5 );;

	print "<- IOS" if ( $debug >= 5 ); print $ligneIOS;
	$l += 1;
}

close $ficIOS or die "Impossible de fermer $!";

# *************** PATERN TIME IN GPS *****************

while ( $ligneGPS = <$ficGPS> ) {
	if ( $ligneGPS !~ /<Trackpoint>/ ) {
		print "ko GPS $ligneGPS" if ( $debug >= 3 );
	} else {
		$ligneTrackpointGPS = $ligneGPS;
		$TimeGPS = <$ficGPS>;
		print "TIME = $TimeGPS" if ( $debug >= 3 );
	
		# *************** PATERN TIME IN IOS *****************
		my $rechercheTime = 0;
	
		open($ficIOS, $nomficIOS,) or die "Impossible d'ouvrir $!";

		while ( $rechercheTime == 0 && defined ( $ligneIOS = <$ficIOS> ) ) {
			if ( $ligneIOS =~ /$TimeGPS/ ) {
				print "match $TimeGPS in IOS $ligneIOS" if ( $debug >= 3 );
				$rechercheTime = 1;

				print "<- GPS" if ( $debug >= 5 ); print $ligneTrackpointGPS;
				print "<- GPS" if ( $debug >= 5 ); print $TimeGPS;
				$ligneGPS = <$ficGPS>;

				while ( $ligneGPS !~ /<Extensions>/ ) {
					print "<- GPS" if ( $debug >= 4 ); print $ligneGPS;
					$ligneGPS = <$ficGPS>;
				}

				# *************** PATERN HEARTRATEBPM IN IOS *****************
				while ( $ligneIOS !~ /<HeartRateBpm>/ ) {
					print "ko IOS $ligneIOS" if ( $debug >= 3 );
					$ligneIOS = <$ficIOS>;
				}
		
				# *************** PATERN ns3:TPX IN IOS *****************
				while ( $ligneIOS !~ /<ns3:TPX>/ ) {
					print "<- IOS " if ( $debug >= 4 ); print $ligneIOS;
					$ligneIOS = <$ficIOS>;
				}
				
				print "<- IOS " if ( $debug >= 4 ); print $ligneIOS;
				$ligneIOS = <$ficIOS>;
				
				if ( $ligneIOS =~ /<ns3:Speed>/ ) {
					print "ko IOS $ligneIOS" if ( $debug != 0 );
					$ligneIOS = <$ficIOS>;
				}
	
				# *************** PATERN ns3:Speed IN GPS ???? *****************
				while ( $ligneGPS !~ /<\/Trackpoint>/ ) {
					if ( $ligneGPS =~ /<ns3:Speed>/ ) {
						print "<- GPS " if ( $debug >= 4 ); print $ligneGPS;
						$ligneGPS = <$ficGPS>;
					} else {
						print "ko GPS $ligneGPS" if ( $debug >= 3 );
						$ligneGPS = <$ficGPS>;
					}
				}
	
				# *************** PATERN </Trackpoint> IN IOS *****************
				while ( $ligneIOS !~ /<\/Trackpoint>/ ) {
					print "<- IOS " if ( $debug >= 4 ); print $ligneIOS;
					$ligneIOS = <$ficIOS>;
				}
				
				print "<- IOS" if ( $debug >= 4 ); print $ligneIOS;
				$ligneIOS = <$ficIOS>;
			
			} else {
				print "no match $TimeGPS in IOS $ligneIOS\n" if ( $debug >= 5 );
			}
		}
	}
}

close $ficGPS or die "Impossible de fermer $!";
close $ficIOS or die "Impossible de fermer $!";
