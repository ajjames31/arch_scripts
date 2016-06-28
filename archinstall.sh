#!/bin/bash


#This is a script to install Arch Linux
clear
echo "===================================="
echo "Arch Linux Install Script"
echo "===================================="
echo
#update pacman mirrorlist
echo "Updating pacman mirrorlist..."
reflector --verbose --country 'United States' -l 200 -p http --sort rate --save /etc/pacman.d/mirrorlist
pacman -S archlinux-keyring
pacman-keys --refresh-keys
clear

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
genfstab -U /mnt >> /mnt/etc/fstab
clear

#chroot code, adapted from AIF. Excellent code!!!
arch_chroot() {
    arch-chroot /mnt /bin/bash -c "${1}"
}  

#set root password and create user
echo "Please enter the root password for your new system."
arch_chroot "passwd"
echo "Please enter a user name for a new user."
read username
arch_chroot "useradd -m -g users -G adm,lp,wheel,power,audio,video -s /bin/bash $username"
echo "Please enter a password for $username."
arch_chroot "passwd $username"
clear

#generate locale
echo en_US.UTF-8 UTF-8 >> /mnt/etc/locale.gen
arch_chroot "locale-gen"
echo "LANG=en_US.UTF-8" > /mnt/etc/locale.conf
clear

#setting timezone
echo "Please enter your country, capitalizing the first letter. ex America"
read country
echo "Please enter your region, capitalizing the first letter. ex Chicago"
read region
echo "Setting timezone..."
arch_chroot "ln -s /usr/share/zoneinfo/$country/$region /etc/localtime"
date
sleep 5
clear

#setting hw clock
arch_chroot "hwclock --systohc --utc"
clear

#setting hostname
echo "Please enter a hostname for your computer in all lowercase."
read hnpc
arch_chroot "echo $hnpc > /etc/hostname"
sleep 3
clear

#setting sudo permissions
echo "We need to set up sudo permissions for your system."
echo "There are 2 options. You can require a password to use sudo, or not require a password."
echo "Would you like to be prompted for a password when using sudo to elevate permissions? Enter y/n"
read sudoyn
	if [ "$sudoyn" = "y" ]
		then mv /mnt/etc/sudoers /mnt/etc/sudoers.backup
		cp /arch_scripts/sudoers.passwd /mnt/etc/sudoers

		else mv /mnt/etc/sudoers /mnt/etc/sudoers.backup
		cp arch_scripts/sudoers.nopasswd /mnt/etc/sudoers
	fi
clear

#AUR support
echo "Would you like to install support for the Arch User Repository?"
echo "Enter y/n"
read aur
	if [ "$aur" = "y" ]
		then mv /mnt/etc/pacman.conf /mnt/etc/pacman.conf.backup;
		cp arch_scripts/pacman.conf /mnt/etc/pacman.conf;
		cp arch_scripts/pacman.conf /etc/pacman.conf;
		echo "Bonus! Colors and ILoveCandy activated as well!!!";
		sleep 5;
		arch_chroot "pacman -Syy";
		arch_chroot "pacman -S yaourt";
	fi
clear

#run mkinit
echo "Running mkinitcpio..."
arch_chroot "mkinitcpio -p linux"
clear

#installing grub
echo "Please enter the drive where you want the bootloader to be installed in /dev/sdx format."
read bldrive
echo "Installing Bootloader..."
arch_chroot "pacman -S --noconfirm grub os-prober"
arch_chroot "grub-install $bldrive"
arch_chroot "grub-mkconfig -o /boot/grub/grub.cfg"
clear

#installing additional packages for video, audio, drivers
echo "Installing additional packages for video, audio, and drivers..."
arch_chroot "pacman -S --noconfirm wpa_supplicant dialog iw reflector rsync mlocate bash-completion"
clear
arch_chroot "pacman -S --noconfirm xf86-video-ati xorg-server xorg-server-utils xorg-xinit xorg-twm xterm"
clear
arch_chroot "pacman -S --noconfirm alsa-utils pulseaudio pulseaudio-alsa"
clear
arch_chroot "pacman -S --noconfirm networkmanager network-manager-applet networkmanager-dispatcher-ntpd"
clear
arch_chroot "pacman -S --noconfirm xf86-input-synaptics xdg-user-dirs gvfs file-roller ttf-dejavu libmtp gvfs-mtp"
clear

#desktop manager
arch_chroot "pacman -S --noconfirm lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings"
clear


#Desktops
echo "You may choose one of the following desktop environments to be installed for you."
echo "Please enter the number of your choice."
echo "1 - gnome3"
echo "2 - kde"
echo "3 - xfce4"
echo "4 - lxde"
echo "5 - mate"
echo "6 - None, I will set up my own desktop."
read desktop;
	case $desktop in
		1) arch_chroot "pacman -S --noconfirm gnome";;
		2) arch_chroot "pacman -S --noconfirm plasma";;
		3) arch_chroot "pacman -S --noconfirm xfce4";;
		4) arch_chroot "pacman -S --noconfirm lxde";;
		5) arch_chroot "pacman -S --noconfirm mate";;
		6) echo "Cool, we are almost done.";;
		*) echo "Not a valid selection"
			sleep 3;;
esac
clear

#starting services
arch_chroot "systemctl enable NetworkManager"
arch_chroot "systemctl enable lightdm.service"
clear

#User choice packages
echo "If you would like to install additional packages now, such as Firefox or VLC,"
echo "please type in the package names seperated by a space"
echo "Example: vlc firefox leafpad"
read userpacks
arch_chroot "pacman -S --noconfirm $userpacks"
clear

#reboot
echo "Installation is Finished!!! Press control-c to exit the script and stay in the live"
echo "environment. Press any key to reboot."
read
reboot




