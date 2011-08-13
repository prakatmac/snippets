#!/usr/bin/env bash

# This script requires: xfsdump and lzop (in addition to standard utilities)
# in order to be used unmodified.


### Configuration ###

# Label for the backup set
LABEL=data1-backup
MEDIA=ext-array
# Report progress every $PROGRESS seconds
PROGRESS=60 
# Filesystem to backup
BACKUP_FROM=/data1
# Location to store backup
BACKUP_TO=/mnt/backup

### End Configuration ###

# Find device from mount point
BACKUP_DEVICE=`mount | grep "$BACKUP_FROM" | awk '{print \$1}'`


# Decide on a Full or Incremental Backup
# ()
LEVEL=1
if [[ $# > 0 ]]; then
	if [[ $@ = "full" ]]; then
		LEVEL=0
	fi
fi

# don't do full backups every week
WK=`date +%W`
ON_WK=`expr $WK % 2`

if [ $ON_WK = 1 ]; then
    # force incremental
    LEVEL=1
fi

if [[ $LEVEL == 1 ]]; then
	OUTPUT_FILE=$BACKUP_TO/$LABEL-$(date +%Y%m%d).inc
else
	OUTPUT_FILE=$BACKUP_TO/$LABEL-$(date +%Y%m%d).full	
fi

echo "Backing up $BACKUP_FROM ($BACKUP_DEVICE) to $OUTPUT_FILE"

# /usr/sbin/xfs_freeze -f $BACKUP_FROM
echo xfsdump -p $PROGRESS -L $LABEL -M $MEDIA -l $LEVEL -f $OUTPUT_FILE $BACKUP_DEVICE
/usr/sbin/xfsdump -p $PROGRESS -L $LABEL -M $MEDIA -l $LEVEL -f $OUTPUT_FILE $BACKUP_DEVICE
# /usr/sbin/xfs_freeze -u $BACKUP_FROM
# Use LZO compression instead of gzip for speed
/usr/bin/lzop -U --path=$BACKUP_TO $OUTPUT_FILE
# gzip --fast $OUTPUT_FILE
