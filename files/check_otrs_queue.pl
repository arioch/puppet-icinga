#!/usr/bin/perl -w

# Original script is from: http://exchange.nagios.org/directory/Plugins/Helpdesk-and-Ticketing/check_otrs-2Epl/details
#####
#####Script zur Anzeige neuer Tickets, noch nicht bearbeiteter Tickets in OTRS
#####Copyright (c) 2008 by Michael Glaess
#####


use strict;
use Getopt::Long;
use vars qw($opt_t $opt_q $opt_c $opt_w $opt_v $opt_h);
my(%ERRORS) = ( OK=>0, WARNING=>1, CRITICAL=>2, UNKNOWN=>3, WARN=>1, CRIT=>2 );
use DBI;
use DBD::mysql;
use Net::SMTP;
sub print_help();

my $VERSION ="1.0";
my $DBuser;
my $DBpass;
my $DBname;
my $DBhost;
my $opt_v;
my $opt_h;
my $opt_w;
my $opt_c;
my $opt_t;      #0=Neue Tickets;1=offene Tickets
my $opt_q;      #3=Queue Servicehotline
my $status  ="0";
my $count = 0;
my $sql;
my $result;
my $message;
my $message_tickets = "";
my @data;
my $ticket_number;
my $queue_name;


sub check_otrs {
#Check DatabaseConnection
my $dbhm=DBI->connect("dbi:mysql:$DBname:$DBhost","$DBuser","$DBpass",
    {
    PrintError=>1,
    }
);
unless ( $dbhm ) {
    die("No Connection to Database");
    }
my $dbhm2=DBI->connect("dbi:mysql:$DBname:$DBhost","$DBuser","$DBpass",
    {
    PrintError=>1,
    }
);


if ( $opt_t == "0" ) {
    # New Tickets
    #$sql = "Select count(*) as Count from ticket where queue_id='".$opt_q."' and ticket_state_id='1'";    
    $sql = "SELECT ticket.tn,queue.name FROM ticket LEFT JOIN queue ON ticket.queue_id = queue.id WHERE ticket.ticket_state_id='1' AND ticket_lock_id='1' AND ((UNIX_TIMESTAMP() - ticket.create_time_unix) > 1800) AND (queue.calendar_name = 1 OR (queue.calendar_name = 2 AND (HOUR(CURTIME()) > 7 AND HOUR(CURTIME()) < 17)));";    
    
} elsif ( $opt_t == "1" ) {
     # Open Tickets
     #$sql = "Select count(*) as Count from ticket where queue_id='".$opt_q."' and ticket_state_id='4'";    
     $sql = "SELECT ticket.tn,queue.name FROM ticket LEFT JOIN queue ON ticket.queue_id = queue.id WHERE ticket.ticket_state_id='4' AND ticket_lock_id='1' AND ((UNIX_TIMESTAMP() - ticket.create_time_unix) > 1800) AND (queue.calendar_name = 1 OR (queue.calendar_name = 2 AND (HOUR(CURTIME()) > 7 AND HOUR(CURTIME()) < 17)));";    
}

my $sqlp=$dbhm->prepare($sql);
if (!$sqlp->execute()){
    print "CRITICAL - Unable to Execute SQL-Query";
    $status = $ERRORS{'CRITICAL'};
    }    

#$result=$sqlp->fetchrow_hashref();
#Set Optimize Text for Nagios
#    $count=$result->{Count};

if ( $opt_t == "0" )
    {$message .= "New";}          #New
if ( $opt_t == "1" )
    {$message .="Open";}          #Open


while (@data = $sqlp->fetchrow_array()) {
    $count++;
    $ticket_number = $data[0];
    $queue_name = $data[1];
    if ($message_tickets eq ""){
        $message_tickets = $ticket_number."(".$queue_name.")";
    } else {
        $message_tickets = $message_tickets.", ".$ticket_number."(".$queue_name.")";
    }
}

$message = $message." tickets: ".$count.", list: ".$message_tickets;

if    ($count >= $opt_c) 
        {$status = $ERRORS{'CRITICAL'};}
elsif ($count >= $opt_w) 
        {$status = $ERRORS{'WARNING'};}
else { $status = $ERRORS{'OK'};}


$sqlp->finish();

}
####################################


sub print_help () {
    printf "$0 plugin for Nagios check for new or open Tickets in OTRS\n";
    printf "Copyright (c) 2008 Michael Glaess\n";
    printf "Usage:\n";
    printf "   -q (--queue)  Queue: Default: 3 entspricht Servicehotline\n";
    printf "   -t (--type)   Type:  Default: 0 entspricht Neue Tickets\n";
    printf "   -w (--warn)   Warning-Level, Default: 0\n";
    printf "   -c (--crit)   Criticle-Level, Default: 2\n\n";
    printf "   -H (--host)   IP or FQDN of mysql host\n";
    printf "   -u (--user)   User of mysql database\n";
    printf "   -p (--pass)   Password to mysql database\n";
    printf "   -n (--dbname) Database name\n\n";
    printf "   -v            Version\n";
    printf "   -h (--help)   Help\n";
    printf "\n";
    print_usage();    
}
##############################################
sub print_usage () {
        print "Usage: $0 \n";
        print "       $0 -w 2 -c 3\n";
        print "       $0 -t 1 -q 3 -w 2 -c 4\n";
        print "       $0 -t 1 -q 3 -w 2 -c 4 -H DBhost -u DBuser -p DBpass -n DBname\n";
}
###############################################
$ENV{'BASH_ENV'}=''; 
$ENV{'ENV'}='';

Getopt::Long::Configure('bundling');
GetOptions
        ("v" => \$opt_v, "version"      => \$opt_v,
         "h" => \$opt_h, "help"         => \$opt_h,
         "q:i" => \$opt_q, "queue"      => \$opt_q,
         "t:i" => \$opt_t, "type"       => \$opt_t,
         "w:i" => \$opt_w, "warn"       => \$opt_w,
         "c:i" => \$opt_c, "crit"       => \$opt_c,

         "H:s" => \$DBhost, "host"      => \$DBhost,
         "u:s" => \$DBuser, "user"      => \$DBuser,
         "p:s" => \$DBpass, "pass"      => \$DBpass,
         "n:s" => \$DBname, "dbname"    => \$DBname );

#Set default Values
if ( !$opt_t){$opt_t=0;} #Just new Tickets
if ( !$opt_w){$opt_w=1;} #Warning at just one ticket
if ( !$opt_c){$opt_c=2;} #Set Critical even on two tickets
if ( !$opt_q){$opt_q=3;} #Default QUEUE -> Needs to Change!!

if ( !$DBhost and !$DBuser and !$DBpass and !$DBname){
        print_help();
        print "\n###############################################";
        print "\nParameters about database are required!!!\n";
        print "###############################################\n";
        exit $ERRORS{UNKNOWN}; 
}

#printf "OPT_t = $opt_t,OPT_w= $opt_w, OPT_c = $opt_c, OPT_q = $opt_q\n";
if ($opt_v) {
        print "$0: $VERSION\n" ;
        exit $ERRORS{'OK'};
}
if ($opt_h) {print_help(); exit $ERRORS{'OK'};}

$status = $ERRORS{OK}; $message = '';

#Call CheckUp Routine
check_otrs;

#Give System a feedback what have we done
if( $message ) {
        if( $status == $ERRORS{OK} ) {
                print "OK: ";
        } elsif( $status == $ERRORS{WARNING} ) {
                print "WARNING: ";
        } elsif( $status == $ERRORS{CRITICAL} ) {
                print "CRITICAL: ";
        }
        print "$message\n";
} else {
        $status = $ERRORS{UNKNOWN};
        print "No Data yet\n";
}
exit $status;
