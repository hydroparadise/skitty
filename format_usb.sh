#! /bin/bash

# device /dev/sdc
# UUID 6745-2301

mount
df
lsblk

# usbdisk="/dev/sdc1"
read -p "Type a file system (ex: '/dev/sdc1')): " usbdisk

echo "Unmounting $usbdisk"
sudo umount $usbdisk

read -p "New parttion name: " newname


# sudo dd if=/dev/zero of=dev/sdc1
sudo mkfs.ext4 $usbdisk -L $newname
# sudo mkfs.ext4 -n $newname -I $usbdisk

mntdir="/mnt/usb/$newname"
un="$USER:$USER" 

echo "Mounting $usbdisk to $mntdir"

sudo mkdir -p $mntdir
sudo chmod 777 $mntdir
sudo mount $usbdisk $mntdir
sudo chown -R $un $mntdir
