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

# Look Up LVM2 Logical Volume Information for BACKUP_DEVICE
LV_NAME=`lvdisplay "$BACKUP_DEVICE" | grep "LV Name" \
    | sed 's/LV\ Name[ \t]*//'`

echo "Logical Volume $LV_NAME selected."

# Create a snapshot of the Logical Volume
/sbin/lvcreate -L100G -s -n "$LABEL-snapshot" $LV_NAME
SNAPSHOT_NAME=`echo $LV_NAME | sed 's/[^\/]*\$/$LABEL-snapshot/'`

# Mount the snapshot
/bin/mount $SNAPSHOT_NAME /mnt/snapshot -onouuid,ro
echo "Snapshot $SNAPSHOT_NAME created mounted at /mnt/snapshot"

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

echo "Backing up $BACKUP_FROM ($BACKUP_DEVICE) via Snapshot ($SNAPSHOT_NAME) to $OUTPUT_FILE"

echo xfsdump -p $PROGRESS -L $LABEL -M $MEDIA -l $LEVEL -f $OUTPUT_FILE $SNAPSHOT_NAME
# /usr/sbin/xfsdump -p $PROGRESS -L $LABEL -M $MEDIA -l $LEVEL -f $OUTPUT_FILE $SNAPSHOT_NAME

# Unmount and Remove the snapshot
/bin/umount /mnt/snapshot
/sbin/lvremove -f $SNAPSHOT_NAME

# Use LZO compression instead of gzip for speed
# /usr/bin/lzop -U --path=$BACKUP_TO $OUTPUT_FILE
# gzip --fast $OUTPUT_FILE
