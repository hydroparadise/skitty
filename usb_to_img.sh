#! /bin/bash

# device /dev/sdc
# UUID 6745-2301

mount
df
lsblk


# usbdisk="/dev/sdc1"
read -p "Type a file disk (ex: '/dev/sdc1')): " usbdisk
read -p "File name for image: " filename

defsavedir=~
read -p "Save path (default=$defsavedir): " savedir

if [[ -z "$savedir" ]]; then
    savedir=$defsavedir
fi

savepath="${savedir}/${filename}"

sudo dd if=$usbdisk of=$savepath bs=4M status=progress
