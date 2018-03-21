#!/bin/bash
#Author: John Whitley
#This Script is designed to send a success or failure email

##Variables##
DATETIME=`date +%Y/%m/%d`
LOGDATA="$(grep $DATETIME /rsync/logs/rsync.log)"

#Email Notification Script##
if [ “$?” = “0” ];

        then

echo -e "Rsync Process was Successful. The Rsync Job has Completed Successfully at $DATETIME.\n\nToday's Logs:\n$LOGDATA" | mailx -s "Rsync Job Successful" johnewhitley@gmail.com

        else

echo -e "Rsync Process was Unsuccesful. Failure occured at $DATETIME.\n\nToday's Logs:\n$LOGDATA" | mailx -s "Rsync Job Unsuccessful" johnewhitley@gmail.com, sharon_irving@comcast.net

        exit 0
fi

