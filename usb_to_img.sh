#! /bin/bash

# device /dev/sdc
# UUID 6745-2301

mount
df
sudo fdisk -l
lsblk

# usbdisk="/dev/sdc"
read -p "Type a file disk (ex: '/dev/sdc')): " usbdisk
read -p "File name for image (ex: 'usb_img.img'): " filename

defsavedir=~
read -p "Save path (default=$defsavedir): " savedir

if [[ -z "$savedir" ]]; then
    savedir=$defsavedir
fi

savepath="${savedir}/${filename}"

echo dd if=$usbdisk of=$savepath bs=2048 status=progress
# sudo dd if=$usbdisk of=$savepath bs=4M status=progress
