#!/bin/bash
# Idempotent disk partionining, filesystem creation, fstab entry and mounting of volume.

set -e

DATA_DIR=/some/data/dir
DISK_NAME=/dev/sdb
VOLUME_NAME="$DISK_NAME"1
FSTAB_STRING="$VOLUME_NAME $DATA_DIR ext4 defaults 0 0"

# IDEMPOTENT PARTITION
if fdisk -l | grep -q $VOLUME_NAME; then
  echo "Already partitioned $DISK_NAME"
else
  echo "Need to partition $DISK_NAME"
  parted -s -a optimal $DISK_NAME mklabel gpt -- mkpart primary ext4 0% 100%
fi

# IDEMPOTENT FILESYSTEM CREATION
if file $VOLUME_NAME | grep -q "ext4" ; then
  echo "$VOLUME_NAME already has an ext4 filesystem"
else
  echo "Need to create filesystem for $VOLUME_NAME"
  mkfs.ext4 $VOLUME_NAME
fi

# IDEMPOTENT FSTAB ENTRY
if grep -q "$FSTAB_STRING" /etc/fstab; then
  echo "Already in fstab."
else
  echo "Adding fstab entry"
  echo "$FSTAB_STRING " >>/etc/fstab
fi

# IDEMPOTENT MOUNT
if mountpoint -q "$DATA_DIR" ; then
    echo "$DATA_DIR is already mounted."
else
    echo "$DATA_DIR is not mounted, mounting now..."
    mount $DATA_DIR
fi
