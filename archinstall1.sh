#!/bin/bash


#This is a script to install Arch Linux
clear
echo "===================================="
echo "Arch Linux Install Script"
echo "===================================="
echo
#list drives
lsblk -S

#Choose drive
echo "Enter the drive that you want to use in /dev/sdx format."
read drive
clear

#partition drive
echo "Do you want to manually partition $drive? (y/n)"
read ans1
     if  [  "$ans1" = "y"  ]
          then cfdisk $drive
     
     fi
     clear
     
#select partition
echo "Below is a list of the partitions on $drive."
lsblk
echo "Enter the partition where you want to install Arch."
echo "Please use /dev/sda1 format" 
read part
echo "Enter the partition for your swap" 
read spart

#format and mount partitions 
mkfs.ext4 $part
mkswap &spart
mount $part /mnt
swapon $spart
clear

#install base
echo "Press enter to begin installing Arch onto $part"
read 
pacstrap /mnt base base-devel 
clear

#generate fstab
echo "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab
clear

#chroot into installation
arch-chroot /mnt /bin/bash

