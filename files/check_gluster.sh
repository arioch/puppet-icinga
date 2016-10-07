#!/bin/bash

## Fork of MarkR’s GlusterFS-checks at:
## http://exchange.nagios.org/directory/Plugins/System-Metrics/File-System/GlusterFS-checks/details

### CHANGELOG
## 1.0.2
# * 07/01/2014
# * Modified by Doug Wilson <dwilson@customink.com>
# * includes carrillm’s fix to support TB sized volumes
# * outputs all errors on a critical alarm, not just free space

# This Nagios script was written against version 3.3 & 3.4 of Gluster.  Older
# versions will most likely not work at all with this monitoring script.
#
# Gluster currently requires elevated permissions to do anything.  In order to
# accommodate this, you need to allow your Nagios user some additional
# permissions via sudo.  The line you want to add will look something like the
# following in /etc/sudoers (or something equivalent):
#
# Defaults:nagios !requiretty
# nagios ALL=(root) NOPASSWD:/usr/sbin/gluster volume status [[\:graph\:]]* detail,/usr/sbin/gluster volume heal [[\:graph\:]]* info
#
# That should give us all the access we need to check the status of any
# currently defined peers and volumes.

# Inspired by a script of Mark Nipper
#
# 2013, Mark Ruys, mark.ruys@peercode.nl

PATH=/sbin:/bin:/usr/sbin:/usr/bin

PROGNAME=$(basename -- $0)
PROGPATH=`echo $0 | sed -e 's,[\\/][^\\/][^\\/]*$,,'`
REVISION="1.0.1"

. $PROGPATH/utils.sh

# parse command line
usage () {
	echo ""
	echo "USAGE: "
	echo "  $PROGNAME -v VOLUME -n BRICKS [-w GB -c GB]"
	echo "     -n BRICKS: number of bricks"
	echo "     -w and -c values in GB"
	exit $STATE_UNKNOWN
}


while getopts "v:n:w:c:" opt; do
	case $opt in
	v) VOLUME=${OPTARG} ;;
	n) BRICKS=${OPTARG} ;;
	w) WARN=${OPTARG} ;;
	c) CRIT=${OPTARG} ;;
	*) usage ;;
	esac
done


#if [ -z "${VOLUME}" -o -z "${BRICKS}" ]; then
#	usage
#fi

Exit () {
	echo "$1: ${2:0}"
	status=STATE_$1
	exit ${!status}
}

# check for commands
for cmd in basename bc awk sudo pidof gluster; do
	if ! type -p "$cmd" >/dev/null; then
		Exit UNKNOWN "$cmd not found"
	fi
done

# check for glusterd (management daemon)
if ! pidof glusterd &>/dev/null; then
	Exit CRITICAL "glusterd management daemon not running"
fi

# check for glusterfsd (brick daemon)
if ! pidof glusterfsd &>/dev/null; then
	Exit CRITICAL "glusterfsd brick daemon not running"
fi

function dostuff() {
errors=()
VOLUME=$1
ex_stat=OK
BRICKS=$(sudo gluster volume info $VOLUME | grep "Number of Bricks" | cut -f8 -d" ")

if sudo gluster volume heal data info split-brain | grep 'Number of entries in split-brain: [1-9]'; then
	errors=("${errors[@]}" "entries in split-brain present!")
fi


# get volume status
bricksfound=0
freegb=9999999
shopt -s nullglob
tl=$(sudo gluster volume status $VOLUME detail | wc -l)
cr=0
sudo gluster volume status $VOLUME detail | while IFS='\n' read line; do

	cr=$(echo "$cr+1" | bc)
    field=($(echo $line))
    firstword=$(echo $line | cut -f1 -d" ")
    
	case $firstword in
	Brick) 
		brick=${field[@]:2}
		;;
	Disk)
		key=${field[@]:0:3}
		if [ "${key}" = "Disk Space Free" ]; then
			freeunit=${field[@]:4}
                        unit=${freeunit: -2}
                        free=${freeunit::${#freeunit}-2}
			freeconvgb=`echo "($free*1024)" | bc`
			if [ "$unit" = "TB" ]; then
				free=$freeconvgb
				unit="GB"
			fi
			if [ "$unit" != "GB" ]; then
				Exit UNKNOWN "unknown disk space size $freeunit"
			fi
                        free=$(echo "${free} / 1" | bc -q)
			if [ $free -lt $freegb ]; then
				freegb=$free
			fi
		fi
		;;
	Online)
		online=$(echo ${field[@]:2} | sed -r 's/^.*\: (.*)/\1/g')
		if [ "${online}" = "Y" ]; then
			let $((bricksfound++))
		else
			errors=("${errors[@]}" "$brick offline")
		fi
		;;
	esac
    if [ $cr -eq $tl ]; then

        if [ $bricksfound -eq 0 ]; then
	      Exit CRITICAL "no bricks found"
        elif [ $bricksfound -lt $BRICKS ]; then
	      errors=("${errors[@]}" "found $bricksfound bricks, expected $BRICKS ")
	      ex_stat="WARNING_stat"
        fi
        if [ -n "$CRIT" -a -n "$WARN" ]; then
	      if [ $CRIT -ge $WARN ]; then
		    Exit UNKNOWN "critical threshold below warning"
	      elif [ $freegb -lt $CRIT ]; then
		    errors=("${errors[@]}" "free space ${freegb}GB")
	        ex_stat="CRITICAL_stat"
	      elif [ $freegb -lt $WARN ]; then
		    errors=("${errors[@]}" "free space ${freegb}GB")
		    ex_stat="WARNING_stat"
	      fi
     fi

     # exit with warning if errors
     if [ -n "$errors" ]; then
	   sep='; '
	   msg=$(printf "${sep}%s" "${errors[@]}")
     	   msg=${msg:${#sep}}
           if [ ${ex_stat} == "CRITICAL_stat" ]; then
		 echo -n CRITICAL\ "${msg}"; return 2
	   else
		 echo -n WARNING\ "${msg}"; return 1
	   fi
     fi
     # exit with no errors
     echo -n OK\ "${bricksfound} bricks; free space ${freegb}GB"

  fi
done
}
RETVAL=0
for i in $(sudo gluster volume list); do
  echo -n " "$i": "
  dostuff $i
  RV=$?
  if [ $RV -gt $RETVAL ]; then
    RETVAL=$RV
  fi
done
exit $RETVAL
