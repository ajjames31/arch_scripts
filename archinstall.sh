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
lsblk $drive
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
pacstrap /mnt base base-devel grub os-prober
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

#getting hostname
echo "Please enter a hostname for your computer in all lowercase."
read hnpc
clear

#getting sudo choice
echo "We need to set up sudo permissions for your system."
echo "There are 2 options. You can require a password to use sudo, or not require a password."
echo "Would you like to be prompted for a password when using sudo to elevate permissions? Enter y/n"
read sudoyn
clear

#getting AUR choice
echo "Would you like to install support for the Arch User Repository?"
echo "Enter y/n"
read aur
clear

#generate locale
echo "Generating Locale..."
echo en_US.UTF-8 UTF-8 >> /mnt/etc/locale.gen
arch_chroot "locale-gen"
echo "LANG=en_US.UTF-8" > /mnt/etc/locale.conf
export LANG=en_US.UTF-8
clear

#setting timezone
echo "Setting Timezone..."
arch_chroot "ln -s /usr/share/zoneinfo/America/Chicago /etc/localtime"
date
sleep 2
clear

#setting hw clock
echo "Setting System Clock as UTC..."
arch_chroot "hwclock --systohc --utc"
sleep 3
clear

#setting hostname
echo "Setting Hostname..."
arch_chroot "echo $hnpc > /etc/hostname"
sleep 3
clear

#setting sudo permissions
echo "Setting sudo permissions..."
	if [ "$sudoyn" = "y" ]
		then echo "%wheel ALL=(ALL) ALL" >> /mnt/etc/sudoers

		else echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /mnt/etc/sudoers
	fi
sleep 3
clear

#AUR support
echo "Enabling Arch User Repository Support..."
	if [ "$aur" = "y" ]
		then echo "[archlinuxfr]" >> /mnt/etc/pacman.conf
		echo "SigLevel = Never" >> /mnt/etc/pacman.conf
		echo "Server = http://repo.archlinux.fr/$arch" >> /mnt/etc/pacman.conf
		sleep 2
		arch_chroot "pacman -Syy"
		pacstrap /mnt yaourt
	fi
clear

#run mkinit
echo "Running mkinitcpio..."
arch_chroot "mkinitcpio -p linux"
sleep 3
clear

#installing grub
echo "Please enter the drive where you want the bootloader to be installed in /dev/sdx format."
read bldrive
clear
echo "Installing Bootloader..."
arch_chroot "grub-install $bldrive"
arch_chroot "grub-mkconfig -o /boot/grub/grub.cfg"
clear

#installing additional packages for video, audio, drivers
echo "Installing additional packages for video, audio, and drivers..."
clear
pacstrap /mnt xf86-video-ati xorg-server xorg-server-utils xorg-xinit xorg-twm xterm alsa-utils pulseaudio pulseaudio-alsa volumeicon parcellite
clear
echo "Installing networking and other utilities..."
pacstrap /mnt networkmanager network-manager-applet networkmanager-dispatcher-ntpd xf86-input-synaptics xdg-user-dirs gvfs file-roller ttf-dejavu libmtp gvfs-mtp git wpa_supplicant dialog iw reflector rsync mlocate bash-completion
clear

#desktop manager
echo "Installing a desktop manager..."
pacstrap /mnt lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings
clear


#Desktops
echo "You may choose one of the following desktop environments to be installed for you."
echo "Please enter the number of your choice."
echo "1 - gnome3"
echo "2 - kde"
echo "3 - xfce4"
echo "4 - lxde"
echo "5 - mate"
echo "6 - i3"
echo "7 - None, I will set up my own desktop."
read desktop;
	case $desktop in
		1) pacstrap /mnt gnome;;
		2) pacstrap /mnt plasma;;
		3) pacstrap /mnt xfce4;;
		4) pacstrap /mnt lxde;;
		5) pacstrap /mnt mate;;
		6) pacstrap /mnt i3 dmenu;;
		7) echo "Cool, we are almost done.";;
		*) echo "Not a valid selection"
			sleep 3;;
esac
clear

#starting services
echo "Enabling netowrk and desktop managaer services..."
sleep 2
arch_chroot "systemctl enable NetworkManager"
arch_chroot "systemctl enable lightdm.service"
clear

#User choice packages
echo "If you would like to install additional packages now, such as Firefox or VLC,"
echo "please type in the package names seperated by a space"
echo "Example: vlc firefox leafpad vim"
read userpacks
arch_chroot "pacman -S --noconfirm $userpacks"
clear

#reboot
echo "Installation is Finished!!! Press control-c to exit the script and stay in the live"
echo "environment. Press any key to reboot."
read
reboot




