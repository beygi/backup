#!/bin/bash
#################################################################
# You need megatools in order to upload your backup file to MEGA
# Download megatools from http://megatools.megous.com/
#################################################################
# Simple backup script for GNU/Linux servers
# Please help to simplify and develop new features
# Narbeh - http://narbeh.org - narbeh.aj@gmail.com
#################################################################

################
# Configuration
################

# Backup path
backup_path="/root"

# Directories to backup (Multi value)
backup_directories="/etc /root /home/jack /var/log"

# Copy to other media (Multi value)
external_copy="false"
external_storage="/mnt /media/usb"

# SCP to other server
scp_enable="false"
scp_server="1.2.3.4"
scp_port="22"
scp_username="root"
scp_path="/media/backups"

# Encryption. Methods are GPG and mcrypt (Later)
#encrypt_backup="false"
#encryption_method=""
#gpg_public_key_name=""
#remove_archive_after_encryption="no"

# Send an email the result of the backup process
send_email="false"
email_to="test@example.com"

# Upload to MEGA.nz if you have installed the client.
# /Root/ is the main directory in MEGA.nz
mega_upload="false"
mega_email=""
mega_pass=""
mega_path="/Root/backups"

# Full MySQL dump (All Databases)
mysql_backup="false"
mysql_user=""
mysql_pass=""

# Full PostgreSQL dump (All Databases)
postgres_backup="false"
postgres_user=""
postgres_pass=""

################
# Do the backup
################

# Output colors. No need to edit
color='\033[0;36m'
nc='\033[0m'
date=$(date +"%Y-%m-%d %H:%M:%S")

echo -e "\n ${color}--- Backup process is now running for user root \n${nc}"
# Removing old backup folder
rm -rf $backup_path/Backup/*
mkdir -p $backup_path/Backup/$(date +"%F") && cur_date=$(date +%F)
echo -e "\n ${color}--- Current backup folder is now located in $backup_path/Backup/$cur_date \n${nc}"

# Backing up the directories
echo -e "\n ${color}--- Backing up directories \n${nc}"
mkdir $backup_path/Backup/temp_folder
for backup_dirs in $backup_directories
do
	cp -r $backup_dirs $backup_path/Backup/temp_folder
done
tar -cf $backup_path/Backup/$cur_date/Directories.tar.bz2 $backup_path/Backup/temp_folder
echo "Done"

sleep 1

# MySQL section
if [ $mysql_backup = "true" ]
then
	echo -e "\n ${color}--- MySQL backup enabled, backing up: \n${nc}"
	mysqldump -u $mysql_user -p$mysql_pass --events --all-databases | gzip -9 > $backup_path/Backup/$cur_date/MySQL_Full_Dump_$cur_date.sql.gz
	echo "Done"
fi

sleep 1

# PostgreSQL section
if [ $postgres_backup = "true" ]
then
	echo -e "\n ${color}--- PostgreSQL backup enabled, backing up: \n${nc}"
	pg_dump -Fc -U $postgres_user > $backup_path/Backup/$cur_date/Postgres_Full_Dump_$cur_date.dump
	echo "Done"
fi

sleep 1

# Create TAR file
echo -e "\n ${color}--- Creating TAR file located in $backup_path/Full_Backup_$cur_date.tar.bz2 \n${nc}"
tar -cf $backup_path/Full_Backup_$cur_date.tar.bz2 $backup_path/Backup/$cur_date/
echo -e "\n ${color}--- Removing backup directory \n${nc}"
rm -rf $backup_path/Backup/

sleep 1

# Copy to other storage
if [ $external_copy = "true" ]
then
	echo -e "\n ${color}--- Copy backup archive to $external_storage: \n${nc}"
	for cp_paths in $external_storage
	do
		cp $backup_path/Full_Backup_$cur_date.tar.bz2 $cp_paths/
	done
	echo "Done"
fi

sleep 1

# SCP to other server
if [ $scp_enable = "true" ]
then
	echo -e "\n ${color}--- SCP backup archive to $scp_server: \n${nc}"
	scp -P $scp_port $backup_path/Full_Backup_$cur_date.tar.bz2 '$scp_username'@'$scp_server':$scp_path
	echo "Done"
fi

sleep 1

# Upload TAR file to MEGA.nz
if [ $mega_upload = "true" ]
then
	echo -e "\n ${color}--- Uploading backup archive to MEGA.nz \n${nc}"
	megaput --path $mega_path -u $mega_email -p $mega_pass $backup_path/Full_Backup_$cur_date.tar.bz2
	echo "Done"
fi

# Send a simple email notification 
if [ $send_email = "true" ]
then
	echo -e "Backup process has finished.\n $date" | mail -s "Backup Result" $email_to 2> /dev/null
fi

echo -e "\n ${color}--- Backup process has finished \n${nc}"

exit 0
