#!/usr/bin/perl -w
#

use strict;
use Getopt::Long;
use Nagios::Plugin;

my ( $ip, $user, $pwd );
my $np = Nagios::Plugin->new;

GetOptions(
		'ip=s' => \$ip,
		'user=s' => \$user,
		'pwd=s' => \$pwd,
		);

#my $ipmiopts="";
#if ( !$ip || !$user || !$pwd ) {
#	print "Usage:\n".
#		"$0 --ip=<ip> --user=<user> --pwd=<pwd>\n";
#	exit 3;
#} else {
#	$ipmiopts = "-I lan -H $ip -U $user -P $pwd";
#}


#
# Main
#

my $powerfail=0;
my %result;

my @ipmicmd=`sudo ipmitool power status 2>&1`;
if ( grep /Error: Unable to establish LAN session/, @ipmicmd) {
  print "Unable to connect\n";
  exit 3;
}
if ( grep /Could not open device/, @ipmicmd) {
  print "Running as root?\n";
  exit 3;
}

if ( $? != 0 ) {
  print "Command not found ...\n";
  exit 3;
}

# Checks chassis status
check_chassis();


# Exit
my  ($code, $message) = $np->check_messages();
$np->nagios_exit( $code, $message );




#
# SUBS
#

#
# Check chassis
#


#System Power         : on
#Power Overload       : false
#Power Interlock      : inactive
#Main Power Fault     : false
#Power Control Fault  : false
#Power Restore Policy : always-off
#Last Power Event     : 
#Chassis Intrusion    : inactive
#Front-Panel Lockout  : inactive
#Drive Fault          : false
#Cooling/Fan Fault    : false

sub check_chassis {

	my @ipmicmd=`sudo ipmitool chassis status 2>&1`;

	my $drive="";
	my $main="";
	my $fan="";
	my $outputchassis="";
	my $rvchassis=0;

	foreach (@ipmicmd) { 
		chomp $_;
		if ( $_ =~ /Invalid command/ ) {
			# foefel voor 2650
			return (0,"");
		}
		if ( $_ =~ /Drive Fault\s+:\s+(\w+)/ ) { $drive=$1; }
		if ( $_ =~ /Main Power Fault\s+:\s+(\w+)/ ) { $main=$1; }
		if ( $_ =~ /Cooling\/Fan Fault\s+:\s+(\w+)/ ) { $fan=$1; }
	}

	if ( $drive ne "false" ) {
    $np->add_message( CRITICAL, "Drive fault" );
	}
	if ( $main ne "false" ) {
    $np->add_message( CRITICAL, "Main power fault" );
	}
	if ( $fan ne "false" ) {
    $np->add_message( CRITICAL, "Fan fault" );
	}

}
