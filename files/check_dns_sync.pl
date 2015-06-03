#!/usr/bin/perl
#############################################################################
#                                                                           #
# This script was initially developed by Anstat Pty Ltd for internal use    #
# and has kindly been made available to the Open Source community for       #
# redistribution and further development under the terms of the             #
# GNU General Public License v2: http://www.gnu.org/licenses/gpl-2.0.html   #
#                                                                           #
#############################################################################
#                                                                           #
# This script is supplied 'as-is', in the hope that it will be useful, but  #
# neither Anstat Pty Ltd nor the authors make any warranties or guarantees  #
# as to its correct operation, including its intended function.             #
#                                                                           #
# Or in other words:                                                        #
#       Test it yourself, and make sure it works for YOU.                   #
#                                                                           #
#############################################################################
# Author: George Hansper                      e-mail:  george@hansper.id.au #
#############################################################################

use strict;
use Net::DNS;
# man Net::DNS::Resolver for more information
use Getopt::Std;
use Socket;
use Net::IP;

my $rcsid = '$Id: check_dns_secondary.pl,v 1.9 2013/10/17 10:19:39 george Exp george $';
my $rcslog = '
  $Log: check_dns_secondary.pl,v $
  Revision 1.9  2013/10/17 10:19:39  george
  Made script more ePN friendly by initializing $aa{} and changing == to eq
  ePN is very fussy about such things.

  Revision 1.8  2013/04/26 12:59:17  george
  Use defined(...) in place of  ...eq undef  to allow ePN to be used.

  Revision 1.7  2012/11/21 10:06:33  george
  Added support for AAAA records, for IPv6. Also need to install IO::Socket::INET6 for IPv6 to work.

  Revision 1.6  2011/06/15 22:43:37  george
  Fix: also look at authority section for data, as well as answer section
  Fix: retain original server name for error messages when using -n (numeric) flag

  Revision 1.5  2008/11/25 10:35:10  george
  Fixed comment in log message.

  Revision 1.4  2007/12/09 23:15:19  georgeh
  Fixed error: Use of uninitialized value in numeric eq (==) at optarg{h}

  Revision 1.3  2006/01/25 06:16:42  georgeh
  Added copyright header

  Revision 1.2  2004/12/15 01:06:46  georgeh
  Changed error message if no SOA reply

  Revision 1.1  2004/12/13 23:11:37  georgeh
  Initial revision

';

my %optarg;
my $getopt_result;
my $dns_server;
my $domain;
my $opt_numeric = 0;
my $opt_dns_debug = 0;
my $opt_dns_timeout;
my $opt_key="";
my $ns_reply;
my $addr_reply;
my $soa_reply;
my (%soa,%serial,%master,%ns_ip,%aa);
my ($ns_rr, $soa_rr_master, $soa_rr_secondary);
my $res;
my $status = "";
my $msg = "";	
my $ns_ip_type;
my $critical = 0;
my $warnings = 0;
$getopt_result = getopts('s:T:k:dnVh', \%optarg) ;
my $exit_status = 0;
if ( $getopt_result <= 0 || defined($optarg{'h'}) ) {
	print STDERR "Check all DNS servers for a domain\n";
	print STDERR "An error is generated if any server is not functioning, or not authoritative\n";
	print STDERR "A warning is generated if any server lags the others in serial-number\n";
	print STDERR "Usage: $0 \[-h|-V] | \[-s dns_server_ip] \[-T seconds] \[-n] \[-d] domain_name\n" ;
	print STDERR "\t-h  print this help message and exit\n" ;
	print STDERR "\t-V  Print version and log, and exit\n" ;
	print STDERR "\t-s  IP address of initial DNS server to query\n" ;
	print STDERR "\t-n  print numeric IPs, instead of DNS names\n";
	print STDERR "\t-d  enable debugging output from DNS queries\n";
	print STDERR "\t-T  set DNS timeout value in seconds\n";
	print STDERR "\nExample:\n\t$0 -T 10 example.com\n";
	print STDERR "\t$0 -s 8.8.8.8 example.com\n";
	print STDERR "\nNote:\tThis plugin requires the perl package Net::DNS available from cpan.org\n";
	print STDERR "\tFor IPv6 support, this plugin also requires the package IO::Socket::INET6\n";
	print STDERR "\tThese are typically packaged as rpms named perl-Net-DNS and perl-IO-Socket-INET6 respectively\n";
	if ( $optarg{'h'} == 1 ) {
		exit 0;
	} else {
		exit 1;
	}
}

if( defined($optarg{'V'}) ) {
	print STDERR $rcsid . "\n";
	print STDERR $rcslog . "\n";
	exit 0;
}

if( defined($optarg{'s'}) ) {
	$dns_server = $optarg{'s'};
}

if( defined($optarg{'n'}) ) {
	$opt_numeric = 1;
}
if( defined($optarg{'d'}) ) {
	$opt_dns_debug = 1;
}

if( defined($optarg{'T'}) ) {
	$opt_dns_timeout = $optarg{'T'};
}

if( defined($optarg{'k'}) ) {
        $opt_key = $optarg{'k'};
}


foreach my $domain(@ARGV) {
$res = Net::DNS::Resolver->new(
	recurse => 1,
	debug => $opt_dns_debug,
	);
my $tsig;

if( $dns_server) {
	$res->nameservers ($dns_server);
}

if( $opt_dns_timeout) {
	$res->tcp_timeout ($opt_dns_timeout);
	$res->udp_timeout ($opt_dns_timeout);
}


# Determine the name servers for this domain
%ns_ip = (); 
$ns_reply = $res->send( $domain, 'NS',);
if ( ! defined($ns_reply) ) {
	if($dns_server) {
		print "ERROR - DNS server not responding: $dns_server\n";
	} else {
		print "ERROR - DNS servers not responding (check nameservers in /etc/resolv.conf)\n";
	}
	exit 2;
} elsif ( $ns_reply->header->ancount == 0 && $ns_reply->header->nscount == 0 ) {
	print "ERROR - No name servers exist for $domain\n";
	exit 2;
} else {
	my $j;
	for($j=0; $j<$ns_reply->answer; $j++) {
		if ( ($ns_reply->answer)[$j]->type eq "NS" ) {
			my ($name);
			$name = ($ns_reply->answer)[$j]->rdatastr;
			$name =~ s/\.$//;
			$ns_ip{$name} = "IP_not_found";
		}
	}
	for($j=0; $j<$ns_reply->authority; $j++) {
		if ( ($ns_reply->authority)[$j]->type eq "NS" ) {
			my ($name);
			$name = ($ns_reply->authority)[$j]->rdatastr;
			# prune trailing '.' from name
			$name =~ s/\.$//;
			$ns_ip{$name} = "IP_not_found";
		}
	}
	# but what if the additional information is not about our name-servers?
	for($j=0; $j<$ns_reply->additional; $j++) {
		if ( ($ns_reply->additional)[$j]->type eq 'A' || ($ns_reply->additional)[$j]->type eq 'AAAA' ) {
			my ($name,$ip);
			$ip = ($ns_reply->additional)[$j]->rdatastr;
			$name = ($ns_reply->additional)[$j]->name;
			if( $ns_ip{$name} eq "IP_not_found" ) {
				$ns_ip{$name} = $ip;
			}
		}
	}
}

my $name_server;
my @name_servers;

# Lookup any nameservers who's IP's were not included in the 'additional' section
# of the original query

foreach $name_server ( keys %ns_ip ) {
#	my $ip = Net::IP->new($ns_ip{$name_server});
#	$ns_ip_type = ($ip->iptype());
	if( $ns_ip{$name_server} eq "IP_not_found" ) {
		# lookup address records 'A' for IPv4
		$addr_reply = $res->send( $name_server, 'A');
		my $j;
		for($j=0; $j<$addr_reply->answer; $j++) {
			if ( ($addr_reply->answer)[$j]->type eq 'A' ) {
				my $ip;
				$ip = ($addr_reply->answer)[$j]->rdatastr;
				$ns_ip{$name_server} = $ip;
				last;
			}
		}
		# also need to look up AAAA records for IPv6
		$addr_reply = $res->send( $name_server, 'AAAA');
		for($j=0; $j<$addr_reply->answer; $j++) {
			if ( ($addr_reply->answer)[$j]->type eq 'AAAA' ) {
				my $ip;
				$ip = ($addr_reply->answer)[$j]->rdatastr;
				$ns_ip{$name_server} = $ip;
				last;
			}
		}
	}
}

# Disable recursion for SOA queries
#$res->recurse(0);


if($opt_numeric) {
	@name_servers = map { if( $ns_ip{$_} eq "IP_not_found") { $_; } else { $ns_ip{$_};  } } ( keys %ns_ip );
} else {
	@name_servers = ( keys %ns_ip );
}

my $error=0;
my $warning=0;
my %error_txt;
my %warning_txt;
my %performance_txt;
my $performance_txt;

# Collect the SOA records for each name server, check for errors
foreach $name_server ( @name_servers ) {
}
foreach $name_server ( @name_servers ) {
	my $ip = Net::IP->new($ns_ip{$name_server});
if ( $ns_ip{$name_server} ne "IP_not_found" ) {
	$ns_ip_type = ($ip->iptype());

}	
	if($opt_numeric) {
		$res->nameservers ( $name_server );
	} else {
		$res->nameservers ( $ns_ip{$name_server} );
	}
	if ( $ns_ip{$name_server} eq "IP_not_found" ) {
		$error = 1;
		$error_txt{$name_server} = "No IP address for $name_server from $dns_server";
		$performance_txt{$name_server} = "IP_not_found";
		$serial{$name_server} = "";
		$ns_ip{$name_server} = $name_server;
		$aa{$name_server} = 0;
		next;
	} 

	if($opt_dns_debug) {
		$res->debug(1);
	}

	$soa_reply = $res->send($domain, "SOA");


	if( ! defined ($soa_reply) ) {
#		$error = 1;
#		$error_txt{$name_server} = "No reply from $name_server (server down?)";
#		$performance_txt{$name_server} = "Timeout";
#		$serial{$name_server} = "";
#		$aa{$name_server} = 0;
		next;
	} elsif ( $soa_reply->header->ancount == 0 ) {		
		$error = 1;
		$error_txt{$name_server} = "No SOA answer from $name_server (not secondary DvNS?)";
		$performance_txt{$name_server} = "No answer";
		$serial{$name_server} = "";
		$aa{$name_server} = 0;
		next;
	}
	$aa{$name_server} = $soa_reply->header->aa;
	$serial{$name_server} = ($soa_reply->answer)[0]->serial;
	# The master name is copied from the SOA record, and doesn't really affect normal operation
	$master{$name_server} = ($soa_reply->answer)[0]->mname;
	$performance_txt{$name_server} = "";
}
# Check the serial numbers (warning only)
# Sort in descending order, but authoritave servers always precede non-authoritative
# ie check $aa{} first, and use it if it is significant (non-0), otherwise check the serial numbers
# So $name_server[0] becomes a server with the highest serial number which is also authoritative 
@name_servers =  ( sort { ($aa{$b} <=> $aa{$a}) || ($serial{$b} <=> $serial{$a}) } (@name_servers));

$performance_txt = "serial=$serial{$name_servers[0]}";

foreach $name_server ( @name_servers ) {
	if ( $serial{$name_server} eq $serial{$name_servers[0]} ) {
		$performance_txt .= "; $name_server $performance_txt{$name_server}";
	} elsif ( $serial{$name_server} eq "" ) {
	#	$warning=1;
	#	if ( $error_txt{$name_server} eq "" ) {
	#		$warning_txt{$name_server} = "$name_server no SOA reply";
	#	}
	#	$performance_txt .= "; $name_server $performance_txt{$name_server}";
	} else {
		$warning =1;
		$warning_txt{$name_server} = "$name_server is out-of-date ($serial{$name_server})";
		$performance_txt .= "; $name_server $serial{$name_server} $performance_txt{$name_server}";
	}
}

if ($error) {
	$status = "$domain: ERROR - serial=$serial{$name_servers[0]}: " . (join "; ", (values %error_txt), (values %warning_txt))."\n" .$status;
        $exit_status = 1;
	$msg = "$domain: $performance_txt\n$msg";
	$critical += 1;
} elsif ($warning) {
	$status = "$domain: WARNING - serial=$serial{$name_servers[0]}: ". (join "; ", (values %warning_txt))." " .$status;
	  if ($exit_status == 0) {
                $exit_status = 1;
          }
	$msg = "$domain: $performance_txt\n$msg";
	$warnings += 1;
} else {
}
}
 if ($exit_status == 0) {
 	print "All OK\n";
  } else {
	print "Domains in warning state: $warnings, Domains in critical state: $critical out of " . scalar @ARGV." " .$status;
#	print "\n";
#  	print $status;
  }
exit   $exit_status
