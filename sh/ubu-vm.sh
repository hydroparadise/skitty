#!/bin/bash
# Run: curl -s -o- https://raw.githubusercontent.com/hydroparadise/skitty/sh/ubu-vm.sh | bash

# Check for QEMU install
if command -v qemu-system-x86_64 &> /dev/null; then
    echo "QEMU (VMware-based) is already installed. Proceeding..."
else
    # Update package list and install QEMU
    echo "QEMU is not installed. Installing QEMU..."
    sudo apt-get update -y
    sudo apt-get install qemu-system-x86-64 -y
fi

if [ -d "$HOME/.ubulive" ]; then
    echo "The directory ~/.ubulive exists."
else
    echo "The directory ~/.ubulive does not exist."
    echo "Creating storage location in ~/.ubulive"
    mkdir -p ~/.ubulive
fi



# ISO Location
url="https://cdimage.ubuntu.com/ubuntu-server/daily-live/current/plucky-live-server-amd64.iso"
local_filename=$(basename "$url")
home=~

# Check if the file already exists
if [ ! -f "${home}/.ubulive/${local_filename}" ]; then
    echo "The Ubuntu ISO does not exist locally. Downloading..."
    wget -P ~/.ubulive "$url"
else
    echo "The Ubuntu ISO already exists locally. Skipping download."
fi

# Create a persistent disk image
disk_image="${home}/.ubulive/ubuntu-persistent.img"
if [ ! -f "$disk_image" ]; then
    echo "Creating a 20GB virtual hard drive for persistence..."
    qemu-img create -f qcow2 "$disk_image" 20G
else
    echo "Virtual disk already exists, using $disk_image"
fi

if [[ ! -f "$disk_image" ]]; then
    echo "Error: The file '$disk_image' does not exist."
    exit 1
fi

chmod 755 ~/.ubulive/*

# echo "$home"/.ubulive/"$local_filename"
# echo "$disk_image"

# Run QEMU with specified specifications and persistent storage
# qemu-system-x86_64 \
# -cdrom "$home"/.ubulive/"$local_filename" \
# -m 6G \
# -smp 4 \
# -drive file="$disk_image",format=qcow2,id=hd0,if=virtio \
# -device virtio-scsi-pci \
# -device e1000,netdev=net0 \
# -netdev user,id=net0,hostfwd=tcp::5555-:22,hostfwd=tcp::4200-:4200 \
# -device VGA,vgamem_mb=128 \
# -boot menu=on,order=c,once=d \
# & command_pid=$!


if [[ ! -f "$disk_image" ]]; then
    echo "Error: The file '$disk_image' does not exist."
    exit 1
fi

# Get the size of the file in bytes using stat
file_size_bytes=$(stat --printf="%s" "$disk_image")

# Define the minimum size in bytes (1 GB)
min_size_bytes=$((1024 * 1024 * 1024)) # 1 GiB = 2^30 bytes

# Compare the file size to the minimum size
if [[ $file_size_bytes -ge $min_size_bytes ]]; then
    echo "The disk image is at least 1 GB in size.  Assuming existing installation..."

   # Run QEMU with specified specifications and persistent storage
   qemu-system-x86_64 \
    -m 6G \
    -smp 4 \
    -drive file="$disk_image",format=qcow2,id=hd0,if=virtio \
    -device virtio-scsi-pci \
    -device e1000,netdev=net0 \
    -netdev user,id=net0,hostfwd=tcp::5555-:22,hostfwd=tcp::4200-:4200 \
    -device VGA,vgamem_mb=128 \
    -boot menu=on,order=c \
    & command_pid=$!
    echo "QEMU Process PID $command_pid"

else

   # Run QEMU with specified specifications and persistent storage
   qemu-system-x86_64 \
    -cdrom "$home"/.ubulive/"$local_filename" \
    -m 6G \
    -smp 4 \
    -drive file="$disk_image",format=qcow2,id=hd0,if=virtio \
    -device virtio-scsi-pci \
    -device e1000,netdev=net0 \
    -netdev user,id=net0,hostfwd=tcp::5555-:22,hostfwd=tcp::4200-:4200 \
    -device VGA,vgamem_mb=128 \
    -boot menu=on,order=c,once=d \
    & command_pid=$!

    echo "The disk image is smaller than 1 GB. Assuming new installation..."
    echo ""
    echo "QEMU Ubuntu Server Live VM Launch has started..."
    echo " * Click inside QEMU window to take control of QEMU VM"
    echo " * Press Ctrl+Alt+G break out of QEMU VM"
    echo ""
    echo "Wait for Welcome screen to appears, then perform the following steps in QEMU: "
    echo " 1) Press the F2 key to enter shell prompt as root."
    echo " 2) Enter the command 'passwd ubuntu-server' to set for SSH session"
    echo " 3) You may be requested to accept an SSH key, type: yes"
    echo " 4) Use the password you set in QEMU to now login as ubuntu-server"
    echo
    echo "Command to connect:    ssh <user>@localhost -p 5555"
    echo "With port forwarding:  ssh -L 4200:localhost:4200 <user>@localhost -p 5555" 
    echo "QEMU Process PID $command_pid"

    # /dev/tty needed to read keystroke because stdin is redirected
    pause() {
        echo "Press any key to start SSH session on port 5555 and continue setup..."
        while ! [ -t 0 ]; do
            sleep 1
        done
        read -n 1 -s
    }
    pause < /dev/tty

   # Temp PW:
   # Remove previous host ssh key when VM is restarted
   ssh-keygen -f ~/.ssh/known_hosts -R [localhost]:5555

   read -p "Enter the user name created during setup: " user < /dev/tty  &&
   ssh "$user"@localhost -p 5555 -t \
     "sudo apt-get install git -y && git clone https://github.com/hydroparadise/skitty; cd skitty/sh && . ubu-cli.sh; bash -l"

fi

