#!/usr/bin/perl

use strict;
use warnings;

my $debug = 0;

my $ParamGPS = 16;
my $ParamIOS = 26;

my $l = 1;

open(my $ficGPS, "GPS_1892462225.tcx.org",) or die "Impossible d'ouvrir $!";
open(my $ficIOS, "W_1892446204.tcx.org",) or die "Impossible d'ouvrir $!";

my $ligneGPS;
my $ligneIOS;

my $TimeGPS;
my $StringTimeGPS;
my @TabTimeGPS;
my $TimeSecondGPS;

my $StringTimeIOS;
my @TabTimeIOS;
my $TimeSecondIOS;

while ( $l <= $ParamGPS ) {
	$ligneGPS = <$ficGPS>;
	$ligneIOS = <$ficIOS>;

#	print "$l IOS = $ligneIOS$l GPS = $ligneGPS" if ( $debug != 0 );

#	print "<- GPS" if ( $debug != 0 );
	print $ligneGPS;

	$l += 1;
}

# GPS & IOS ----- <Calories>0</Calories> 

while ( $l <= $ParamIOS ) {
	$ligneIOS = <$ficIOS>;

#	print "$l IOS = $ligneIOS$l GPS = $ligneGPS" if ( $debug != 0 );;

#	print "<- IOS" if ( $debug != 0 );
	print $ligneIOS;
	$l += 1;
}

# IOS ----- <Track>

# *************** PATERN TIME IN GPS *****************

while ( $ligneGPS = <$ficGPS> ) {
	if ( defined ( $ligneIOS ) ) {
		if ( $ligneGPS !~ /<Trackpoint>/ ) {
			print "ko GPS $ligneGPS" if ( $debug != 0 );
		} else {
#			print "<- GPS" if ( $debug != 0 );
			print $ligneGPS;
			$ligneGPS = <$ficGPS>;
	
#			print "TIME = $ligneGPS" if ( $debug != 0 );
			$TimeGPS = $ligneGPS;
			
			$StringTimeGPS = $TimeGPS;
			$StringTimeGPS =~ s/\s//g;
			$StringTimeGPS =~ s/[-T:.]/ /g;
			@TabTimeGPS = split(/ /,$StringTimeGPS);
#			print "TabTimeGPS = H:$TabTimeGPS[4] M:$TabTimeGPS[5] S:$TabTimeGPS[6]\n" if ( $debug != 0 );
			$TimeSecondGPS = $TabTimeGPS[4] * 3600 + $TabTimeGPS[5] * 60 + $TabTimeGPS[6];
#			print "TimeSecondGPS = $TimeSecondGPS\n" if ( $debug != 0 );
	
			while ( $ligneGPS !~ /<Extensions>/ ) {
#				print "<- GPS" if ( $debug != 0 );
				print $ligneGPS;
				$ligneGPS = <$ficGPS>;
			}
			
	# GPS ----- <Extensions>
	 
			# *************** PATERN TIME IN IOS *****************
			
			my $rechercheTime = 0;
	
			while ( $rechercheTime == 0 && defined ( $ligneIOS = <$ficIOS> ) ) {
				if ( $ligneIOS =~ /<Time>/ ) {
#					print "match <Time> in IOS $ligneIOS" if ( $debug != 0 );
		
					$StringTimeIOS = $ligneIOS;
					$StringTimeIOS =~ s/\s//g;
					$StringTimeIOS =~ s/[-T:.]/ /g;
					@TabTimeIOS = split(/ /,$StringTimeIOS);
#					print "TabTimeIOS = H:$TabTimeIOS[4] M:$TabTimeIOS[5] S:$TabTimeIOS[6]\n" if ( $debug != 0 );
					$TimeSecondIOS = $TabTimeIOS[4] * 3600 + $TabTimeIOS[5] * 60 + $TabTimeIOS[6];
					print "TimeSecondIOS = $TimeSecondIOS\n" if ( $debug != 0 );
		
					if ( $TimeSecondIOS >= $TimeSecondGPS ) {
						print "TimeSecondIOS($TimeSecondIOS) >= TimeSecondGPS($TimeSecondGPS)\n" if ( $debug != 0 );
						$rechercheTime = 1;
	
						# *************** PATERN HEARTRATEBPM IN IOS *****************
			
						while ( $ligneIOS !~ /<HeartRateBpm>/ ) {
							print "ko IOS $ligneIOS" if ( $debug != 0 );
							$ligneIOS = <$ficIOS>;
						}
			
						# *************** PATERN ns3:TPX IN IOS *****************
				
						while ( $ligneIOS !~ /<ns3:TPX>/ ) {
#							print "<- IOS " if ( $debug != 0 );
							print $ligneIOS;
							$ligneIOS = <$ficIOS>;
						}
				
#						print "<- IOS " if ( $debug != 0 );
						print $ligneIOS;
						$ligneIOS = <$ficIOS>;
				
						if ( $ligneIOS =~ /<ns3:Speed>/ ) {
							print "ko IOS $ligneIOS" if ( $debug != 0 );
							$ligneIOS = <$ficIOS>;
						}
	
						# *************** PATERN ns3:Speed IN GPS ???? *****************
			
						while ( $ligneGPS !~ /<\/Trackpoint>/ ) {
							if ( $ligneGPS =~ /<ns3:Speed>/ ) {
#								print "<- GPS " if ( $debug != 0 );
								print $ligneGPS;
								$ligneGPS = <$ficGPS>;
							} else {
								print "ko GPS $ligneGPS" if ( $debug != 0 );
								$ligneGPS = <$ficGPS>;
							}
						}
	
						# *************** PATERN </Trackpoint> IN IOS *****************
			
						while ( $ligneIOS !~ /<\/Trackpoint>/ ) {
#							print "<- IOS " if ( $debug != 0 );
							print $ligneIOS;
							$ligneIOS = <$ficIOS>;
						}
				
#						print "<- IOS" if ( $debug != 0 );
						print $ligneIOS;
						$ligneIOS = <$ficIOS>;
			
					} else {
						$ligneIOS = <$ficIOS>;
					}
				}
			}
		}
	} else {
		print "<- GPS" if ( $debug != 0 );
		print "$ligneGPS";
	}
}
