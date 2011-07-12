#!/usr/bin/env bash

### Configuration ###

# Label for the backup set
LABEL=data1-backup
MEDIA=ext-array
# Report progress every $PROGRESS seconds
PROGRESS=60 
# Filesystem to backup
BACKUP_FROM=/dev/sda1
BACKUP_MOUNT_POINT=/data1
# Location to store backup
BACKUP_TO=/mnt/backup

### End Configuration ###

# Decide on a Full or Incremental Backup
# ()
LEVEL=1
if [[ $# > 0 ]]; then
	if [[ $@ = "full" ]]; then
		LEVEL=0
	fi
fi

if [[ $LEVEL == 1 ]]; then
	OUTPUT_FILE=$BACKUP_TO/$LABEL-$(date +%Y%m%d).inc
else
	OUTPUT_FILE=$BACKUP_TO/$LABEL-$(date +%Y%m%d).full	
fi

echo "Backing up $BACKUP_MOUNT_POINT ($BACKUP_FROM) to $OUTPUT_FILE"

# xfs_freeze -f $BACKUP_MOUNT_POINT
# xfsdump -p $PROGRESS -L $LABEL -M $MEDIA -l -f $OUTPUT_FILE $BACKUP_FROM
# xfs_freeze -u $BACKUP_MOUNT_POINT
# gzip --fast $OUTPUT_FILE