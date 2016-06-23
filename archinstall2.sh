#!/bin/bash

#this is the second part of the install script, after you have chroot into the new intall

clear
echo "=========================="
echo "Arch Install Script"
echo "=========================="
echo

#set root password and create user
echo "Please enter the root password for your new system."
passwd
echo "Please enter a user name for a new user."
read username
useradd -m -g users -G adm,lp,wheel,power,audio,video -s /bin/bash $username
echo "Please enter a password for $username."
passwd $username
clear

#generate locale
echo en_US.UTF-8 UTF-8 >> /etc/locale.gen
locale-gen
locale > /etc/locale.conf
clear

#setting timezone
echo "Please enter your country, capitalizing the first letter. ex America"
read country
echo "Please enter your region, capitalizing the first letter. ex Chicago"
read region
echo "Setting timezone..."
ln -s /usr/share/zoneinfo/$country/$region /etc/localtime
sleep 3
clear

#setting hostname
echo "Please enter a hostname for your computer in all lowercase."
read hnpc
echo archpc > /etc/$hnpc
sleep 3
clear

#setting sudo permissions
echo "We need to set up sudo permissions for your system."
echo "There are 2 options. You can require a password to use sudo, or not require a password."
echo "Would you like to be prompted for a password when using sudo to elevate permissions?"
read sudoyn
	if [ "$sudoyn" = "y" ]
		then mv /etc/sudoers /etc/sudoers.backup
		cp /arch_scripts/sudoers.passwd /etc/sudoers

		else mv /etc/sudoers /etc/sudoers.backup
		cp arch_scripts/sudoers.nopasswd /etc/sudoers
	fi
clear

#mkinit
echo "Running mkinit..."
mkinitcpio -p linux
clear

#installing grub
echo "Installing Bootloader..."
pacman -S --noconfirm grub os-prober
grub-install $drive
grub-mkconfig -o /boot/grub/grub.cfg
clear

#installing additional packages for video, audio, drivers
echo "Installing additional packages for video, audio, and drivers..."
pacman -S --noconfirm wpa_supplicant dialog iw reflector rsync mlocate bash-completion
pacman -S --noconfirm xf86-video-ati xorg-server xorg-server-utils xorg-xinit xorg-twm xterm
pacman -S --noconfirm alsa-utils pulseaudio pulseaudio-alsa
pacman -S --noconfirm networkmanager xfce4-notifyd network-manager-applet 
pacman -S --noconfirm xf86-input-synaptics xdg-user-dirs gvfs file-roller ttf-dejavu libmtp gvfs-mtp
clear

#desktop manager
pacman -S --noconfirm lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings
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
		1) pacman -S gnome;;
		2) pacman -S plasma;;
		3) pacman -S xfce4;;
		4) pacman -S lxde;;
		5) pacman -S mate;;
		6) echo "Cool, we are almost done.";;
		*) echo "Not a valid selection"
			sleep 3;;
esac
clear

#starting services
systemctl enable NetworkManager
systemctl enable lightdm.service
clear

echo "Installation is finished!!! This script will exit. You may reboot your system now,"
echo "or continue working in the live environment."
