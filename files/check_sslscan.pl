#!/usr/bin/perl 
#
# $Id: check_sslscan.pl 468 2015-04-13 08:09:53Z phil $
#
# program: check_sslscan
# author, (c): Philippe Kueck <projects at unixadm dot org>
#
# requires: LWP::UserAgent, JSON, Getopt::Long, Pod::Usage
#

use strict;
use warnings;

use LWP::UserAgent;
use JSON;
use Getopt::Long;
use Pod::Usage;

my $api = "https://api.ssllabs.com/api/v2";
my $score = {
  'A+' => 7, 'A' => 6, 'A-' => 5, 'B' => 4, 'C' => 3,
  'D' => 2, 'E' => 1, 'F' => 0, 'T' => 0, 'M' => 0
};

sub nagexit {
  my $exitc = {0 => 'OK', 1 => 'WARNING', 2 => 'CRITICAL', 3 => 'UNKNOWN'};
  printf "%s - %s\n", $exitc->{$_[0]}, $_[1];
  exit $_[0]
}

my $config = {'warn' => 'B', 'crit' => 'C'};
Getopt::Long::Configure("no_ignore_case");
GetOptions(
  'H=s' => \$config->{'host'},
  'w=s' => \$config->{'warn'},
  'c=s' => \$config->{'crit'},
  'ip=s' => \$config->{'ip'},
  'p' => \$config->{'publish'},
  'x' => \$config->{'nocache'},
  'a=i' => sub {$config->{'nocache'} = 0; $config->{'maxage'} = $_[1]},
  'd' => \$config->{'debug'},
  'h|help' => sub {pod2usage({'-exitval' => 3, '-verbose' => 2})}
) or pod2usage({'-exitval' => 3, '-verbose' => 0});
pod2usage({'-exitval' => 3, '-verbose' => 0}) unless $config->{'host'};

my $ua = new LWP::UserAgent;
$ua->agent("nagios/check_sslscan ". ('$Revision: 468 $' =~ /(\d+)/)[0]);

my ($resp, $result);
local $SIG{ALRM} = sub {nagexit 3, "timeout"};
alarm 900;

$resp = $ua->get(
  sprintf "%s/analyze?host=%s&all=done&publish=%s&%s",
    $api, $config->{'host'}, $config->{'publish'}?'on':'off',
    $config->{'nocache'}?"startNew=on":
    "fromCache=on".($config->{'maxage'}?'&maxAge='.$config->{'maxage'}:'')
);

for (;;) {
  nagexit 3, $resp->status_line unless $resp->is_success;
  $result = from_json($resp->decoded_content);
  last if $result->{'status'} eq 'READY';
  sleep 10;
  $resp = $ua->get(
    sprintf "%s/analyze?host=%s&all=done",
    $api, $config->{'host'}
  )
}
alarm 0;

if ($config->{'ip'}) {
  $resp = $ua->get(
    sprintf "%s/getEndpointData?host=%s&s=%s",
    $api, $config->{'host'}, $config->{'ip'}
  );
  $result = from_json($resp->decoded_content);
  $result->{'endpoints'}[0] = $result
}

if ($config->{'debug'}) {
  use Data::Dumper;
  print Dumper $result
}

nagexit 3, "unknown result set" unless
  exists $result->{'endpoints'} &&
  exists $result->{'endpoints'}[0] &&
  exists $result->{'endpoints'}[0]->{'grade'};

my $grade = $result->{'endpoints'}[0]->{'grade'};

nagexit 2, sprintf "score is %s", $grade
  if $score->{$grade} <= $score->{$config->{'crit'}};
nagexit 1, sprintf "score is %s", $grade
  if $score->{$grade} <= $score->{$config->{'warn'}};
nagexit 0, sprintf "score is %s", $grade


__END__
=encoding utf8

=head1 NAME

check_sslscan

=head1 VERSION

$Revision: 468 $

=head1 SYNOPSIS

 check_sslscan -H HOST -w GRADE -c GRADE [-p] [-x] [-a MAXAGE] [-ip IP address]

=head1 OPTIONS

=over 8

=item B<H>

Host to check using Qualys SSL Labs' sslscan.

=item B<ip>

IP to check when the Host has more than one endpoint

=item B<w>

Warn at or below grade I<GRADE> (defaults to I<B>).

=item B<c>

Critical at or below I<GRADE> (defaults to I<C>).

=item B<p>

Publish results at Qualys SSL Labs.

=item B<x>

do not accept cached results.

=item B<a>

max cache age in hours (unsets C<-x> implicitly).

=item B<d>

debug mode, print resulting json.

=back

=head1 DESCRIPTION

This nagios/icinga check script checks the website's ssllabs grade.

Possible grades: 'A+', 'A', 'A-', 'B'..'F', 'T' (trust issues), 'M' (certificate name mismatch).

=head1 DEPENDENCIES

=over 8

=item C<LWP::UserAgent>

=item C<JSON>

=item C<Pod::Usage>

=item C<Getopt::Long>

=back

=head1 AUTHOR

Philippe Kueck <projects at unixadm dot org>
credit for maxage goes to Alexander Prinz
credit for endpoint ip selection to JosÃ© Miranda

=cut