# arch_scripts
My personal scripts for Arch Linux


The scripts may be downloaded by git clone https://github.com/ajjames31/arch_scripts.

The first script "archinstall1.sh" will guide the user through setting up
the drive and partitions to intall Arch Linux on. It then installs the base
and base-devel packages. After installation, the script will download the second 
script "archinstall2.sh" and place it in the root of the new system. It also
changes the permissions to make it executable. The first script
exits after it chroot's into the newly installed system.

The second script must be started manually by entering "/arch_scripts/archinstall2.sh". 
The second script guides the user through the rest of a basic Arch Linux installation.
It installs basic xorg and pulseaudio packages and it gives the user a 
choice of several desktop environments. These include gnome, kde, mate, xfce, and lxde. 