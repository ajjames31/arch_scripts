#!/bin/bash

#This is a script to install i3 window manager on Arch Linux and copy my config file

#Installing packages
pacstrap /mnt i3 dmenu lxterminal gedit vim lxappearance numix-themes deepin-icon-theme

#Copying config file
cp /i3config/i3config /mnt~/.config/i3/config

echo "Install is complete!"
