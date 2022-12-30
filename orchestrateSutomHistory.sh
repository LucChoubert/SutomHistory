#!/bin/bash

function cleanup ()
{
   echo "Script just got Killed"
   echo "TODO: implement proper cleanup"
   exit 1
}

# capture CTRL+C, CTRL+Z and quit singles using the trap
trap cleanup SIGINT
trap cleanup SIGQUIT
trap cleanup SIGTSTP

# Check if parameters exists in the environment
if [ -z "${WEBSITE_WITH_SUTOM_HISTORY}" ]; then
    echo "Environment variable WEBSITE_WITH_SUTOM_HISTORY must exist to provide the website from which to scrap Sutom History data - exiting"
    exit 1
fi

if [ -z "${MAIL_FROM}" ]; then
    echo "Environment variable MAIL_FROM must exist to provide the smtp email account to use to send result - exiting"
    exit 1
fi

if [ -z "${MAIL_TO}" ]; then
    echo "Environment variable MAIL_TO must exist to provide the recipient of the email with Sutom History data - exiting"
    exit 1
fi

if [ ! -f "ssmtp.conf" ]; then
    echo "No config file for ssmtp - exiting"
    exit 1
fi

OUTPUT_DIR="."
if [ -d "/output" ]; then
    OUTPUT_DIR="/output"
fi


#Start Infinite Loop
while :
do

  next_run_epoch=$(date -u -d "tomorrow 01:00:00" +"%s")
  now_epoch=$(date -u +"%s")
  diff_epoch=$(($next_run_epoch - $now_epoch))

  echo == Waiting $diff_epoch seconds until next run tomorrow at 1am UTC ==

  sleep $diff_epoch

  now_datetime=$(date +"%y-%m-%d_%H%M%S")

  echo == Starting downloading website at $now_datetime ==

  mkdir -p $now_datetime

  log_file=/tmp/wget_$now_datetime.log
  rm -f $log_file
  wget -o $log_file --mirror --directory-prefix=$now_datetime https://$WEBSITE_WITH_SUTOM_HISTORY
  rm -f $log_file

  echo == Finished downloading website at `date +"%y-%m-%d_%H%M%S"` ==

  echo == Starting extracting Sutom data at `date +"%y-%m-%d_%H%M%S"` ==

  now_date=$(date +"%y-%m-%d")
  rm -f SutomHistory_$now_date.csv
  python SutomHistory.py $now_datetime/$WEBSITE_WITH_SUTOM_HISTORY/ > $OUTPUT_DIR/SutomHistory_$now_date.csv

  echo == Finished extracting Sutom data at `date +"%y-%m-%d_%H%M%S"` ==

  echo == Sending result by email ==
  cat << MAIL > email_$now_date.txt
From: "SutomHistory" <$MAIL_FROM>
To: "$MAIL_TO" <$MAIL_TO>
Subject: Sutom History $now_date
MIME-Version: 1.0

MAIL

  previous_file=$(ls -rt1 `find $OUTPUT_DIR -name SutomHistory\*csv ! -newer $OUTPUT_DIR/SutomHistory_$now_date.csv | xargs` | tail -n 2 | head -n 1)
  #yesterday_date=$(date --date 'yesterday' +"%y-%m-%d")
  #if test -f "SutomHistory_$(yesterday_date).csv"; then
  #    echo == Sutom data extracted yesterday, doing diff ==
  #fi
  if [ "$previous_file" != "$OUTPUT_DIR/SutomHistory_$now_date.csv" ]; then
      echo == Previous Sutom data identified, doing diff ==
      comm --nocheck-order -13 $previous_file $OUTPUT_DIR/SutomHistory_$now_date.csv >> email_$now_date.txt
      echo == Finished Diff ==
  else
      cat $OUTPUT_DIR/SutomHistory_$now_date.csv >> email_$now_date.txt
  fi

  cat email_$now_date.txt | ssmtp -Cssmtp.conf $MAIL_TO
  rm -f email_$now_date.txt
  echo == Finished email sending ==


  echo == Starting Cleanup ==
  rm -rf $now_datetime
  echo == Finished Cleanup ==

done
