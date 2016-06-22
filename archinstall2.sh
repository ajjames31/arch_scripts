#this is the second part of the install script, after you have chroot into the new intall

echo "=========================="
echo "Arch Install Script"
echo "=========================="


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
echo "Generating locale..."
echo en_US.UTF-8 UTF-8 >> /etc/locale.gen
locale-gen
locale > /etc/locale.conf
clear

#setting timezone
echo "Setting timezone as American, central..."
ln -s /usr/share/zoneinfo/America/Chicago /etc/localtime
sleep 3
clear

#setting hostname
echo "Setting hostname as archpc..."
echo archpc > /etc/hostname
sleep 3
clear

#setting sudo permissions
echo "setting sudo permissions...
touch /etc/sudoers.d/01_wheel
echo %wheel ALL=(ALL) NOPASSWD: ALL >> /etc/sudoers.d/O1_wheel
sleep 3
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
pacman -S --noconfirm lightdm lightdm-gtk-greeter lightdm-gtk-greeter-setttings

#Desktops
#echo "You have selected gnome3, it is being installed now"
#pacman -S --noconfirm gnome
#echo "You have selected xfce4, it is being installed now"
#pacman -S --noconfirm xfce4 xfce4-goodies
#echo "You have selected lxde, it is being installed now"
#pacman -S --noconfirm lxde

#starting services
systemctl enable NetworkManager
systemctl enable lightdm.service

echo "The base of Arch Linux is installed! You may now install the Desktop Environment of your choice!"
