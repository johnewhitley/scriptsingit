#!/bin/bash
#Author: John Whitley
#Date: 7-8-17 12:56AM
#This Script was designed to backup sharon's data to a secondary local HDD

##Variables For Email##
DATETIME=`date +%Y/%m/%d`
LOGDATA="$(grep $DATETIME /rsync/logs/rsync.log)"

##Rsync Job/Main Script##
rsync -av --delete --log-file=/rsync/logs/rsync.log /data/shares/sharon /rsync/sharon_rsync
rsync -av --delete --log-file=/rsync/logs/rsync.log /data/shares/amber /rsync/amber_rsync
rsync -av --delete --log-file=/rsync/logs/rsync.log /data/shares/johnw /rsync/johnw_rsync
rsync -av --delete --log-file=/rsync/logs/rsync.log /data/shares/e-books /rsync/e-books_rsync
rsync -av --delete --log-file=/rsync/logs/rsync.log /data/shares/scripts /rsync/scripts_rsync
rsync -av --delete --log-file=/rsync/logs/rsync.log /data/shares/2018\ Taxes /rsync/taxes_rsync
rsync -av --delete --log-file=/rsync/logs/rsync.log /data/shares/movies /rsync/movies_rsync
rsync -av --delete --log-file=/rsync/logs/rsync.log /data/shares/tv /rsync/tv_rsync
rsync -av --delete --log-file=/rsync/logs/rsync.log /data/shares/programs /rsync/programs_rsync
rsync -av --delete --log-file=/rsync/logs/rsync.log /data/shares/games /rsync/games_rsync

##Export Varibles##
Export DATETIME=`date +%Y/%m/%d`
Export LOGDATA="$(grep $DATETIME /rsync/logs/rsync.log)"

##Wait 90 Seconds##
Wait 90

#Kick off Email Notification Script##
/bin/bash /data/shares/scripts/rsync_email_job.sh
/bin/bash /home/johnw/scriptsingit/serverstats.sh

##END##
