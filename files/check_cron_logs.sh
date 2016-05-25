#!/bin/sh

LOG_FILE='/var/log/messages'
DATE=$(date --date="24 hours ago" '+%b %-d %H' | sed -r 's/^([a-zA-Z]+) /\1 {1,2}/g')
NAME=$(hostname --short)
CRONS_FAILING=''
IGNORE_TAG='drush|SERVICE NOTIFICATION|SERVICE ALERT'

while getopts ":i:" o; do
    case "${o}" in
        i)
            IGNORE_TAG="("$(echo "${OPTARG}" | sed 's/ /)|(/g')")"
            ;;
        *)
            echo "Bad param"
            ;;
    esac
done
shift $((OPTIND-1))


REGEX="("$(echo "$@" | sed 's/ /)|(/g')")"

##By defualt, only logs newer than 24h are checked, let's check if there even are that old logs

if egrep -q "$DATE" /var/log/messages; then
  if [ $REGEX != '()' ]; then
    CRONS_FAILING=$(cat $LOG_FILE | sed -r "1,/$DATE/d" |egrep "cron .*\[[0-9]+\].*\[error\]" | egrep -v "$IGNORE_TAG" |
    sed -r "s/^.*$NAME [^ ]+ ([^ ]* )?cron ([^\[]+).*/\2/g" | sort | uniq | egrep -v $REGEX)
  else
    CRONS_FAILING=$(cat $LOG_FILE | sed -r "1,/$DATE/d" |egrep "cron .*\[[0-9]+\].*\[error\]" | egrep -v "$IGNORE_TAG" |
    sed -r "s/^.*$NAME [^ ]+ ([^ ]* )?cron ([^\[]+).*/\2/g" | sort | uniq)
  fi

##if not, we're simply reading the whole file

else
  if [ $REGEX != '()' ]; then
    CRONS_FAILING=$(cat $LOG_FILE |egrep "cron .*\[[0-9]+\].*\[error\]" | egrep -v "$IGNORE_TAG" |
    sed -r "s/^.*$NAME [^ ]+ ([^ ]* )?cron ([^\[]+).*/\2/g" | sort | uniq | egrep -v $REGEX)
  else
    CRONS_FAILING=$(cat $LOG_FILE |egrep "cron .*\[[0-9]+\].*\[error\]" | egrep -v "$IGNORE_TAG" |
    sed -r "s/^.*$NAME [^ ]+ ([^ ]* )?cron ([^\[]+).*/\2/g" | sort | uniq)
  fi
fi

if [ -z "$CRONS_FAILING" ]; then
 echo "No cron jobs have failed over the past 24 hours."
 exit 0
else
 echo "Cron jobs that have failed over the past 24 hours: "$CRONS_FAILING
 exit 1
fi

