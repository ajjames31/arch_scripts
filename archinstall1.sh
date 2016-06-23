#!/bin/bash


#This is a script to install Arch Linux
clear
echo "===================================="
echo "Arch Linux Install Script"
echo "===================================="
echo
#list drives
echo "Below is a list of drives available on your computer."
lsblk --nodeps

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
lsblk -lno NAME,SIZE,TYPE $drive
echo "Enter the partition where you want to install Arch."
echo "Please use /dev/sda1 format" 
read part
echo "Would you like to use a SWAP partition? (y/n)" 
read swapyn
	if [ "$swapyn" = "y" ]
		then echo "Enter the partition that you would like to use as SWAP in /dev/sda1 format."
		read spart
		mkswap $spart
		swapon $spart
	fi

#format and mount partitions 
mkfs.ext4 $part
mount $part /mnt
clear

#install base
echo "Press enter to begin installing Arch onto $part"
read 
pacstrap /mnt base base-devel git 
clear

#generate fstab
echo "Generating fstab..."
genfstab -L /mnt >> /mnt/etc/fstab
clear

#Copying the script to the root of the new system
git clone https://github.com/ajjames31/arch_scripts /mnt/arch_scripts
chmod +x /mnt/arch_scripts/archinstall2.sh
/mnt/arch_scripts/archinstall2.sh

#chroot into installation
arch-chroot /mnt /bin/bash

