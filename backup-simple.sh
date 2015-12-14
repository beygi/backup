#!/bin/bash
#echo "Creating mysql new binary log at `date`"

echo "Daily Backup started `date`"
echo "Full mysql database dump started"
echo 'All existing full backups will be removed'
PREFIX='mysql-dump.'
DT=`date "+%Y-%m-%d|%H:%M:%S"`
DBFN=$PREFIX$DT'.sql'
rm -f /home/mahdy/backup/*.bz2

mysqldump -u root -pyourPassword --add-drop-table --lock-all-tables --databases yourDBname > /home/mahdy/backup/$DBFN
bzip2 /home/mahdy/backup/$DBFN
echo "mysql dump complete"
echo "using scp to sync mysql backup files"
scp /home/mahdy/backup/*.bz2 mahdy@destination.com:/home/mahdy/backup/prefixDir/mysql
echo "using rsync to sync uploads directory"
rsync -a --update -e ssh /extra/userUploads mahdy@destination.com:/home/mahdy/backup/prefixDir/
echo "done"
