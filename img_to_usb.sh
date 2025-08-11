#! /bin/bash

# device /dev/sdc
# UUID 6745-2301

mount
df
sudo fdisk -l
blkid
lsblk


read -p "File name for image (ex: '/home/user/usb_img.img'): " filepath
read -p "Type a file disk (ex: '/dev/sdc')): " usbdisk

echo dd if=$filepath of=$usbdisk bs=2048 status=progress
# sudo dd if=$usbdisk of=$savepath bs=4M status=progress
