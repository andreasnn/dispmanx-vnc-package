#!/usr/bin/env bash

project_dir=`pwd`
version=2019-1

function host_install_packages()
{
	sudo apt-get update
	sudo apt-get -y upgrade
	sudo apt-get -y install git qemu-user-static vim
}

function host_build_filesystem()
{
	git clone https://github.com/osmc/osmc.git
	cd osmc/filesystem/osmc-rbp2-filesystem
	sudo \. build.sh

	cd $project_dir
	tar -xpvf osmc/filesystem/osmc-rbp2-filesystem/*.tar.xz -C filesystem
}

function host_start_chroot()
{
	chroot=filesystem

	sudo cp /usr/bin/qemu-arm-static $chroot/usr/bin
	sudo cp /etc/resolv.conf $chroot/etc

	mkdir $chroot/share
	sudo mount -o bind . $chroot/share
	sudo mount -o bind /dev $chroot/dev

	#chmod 777 $chroot/tmp

	sudo chroot $chroot /bin/bash /share/create-package.sh

	sudo umount $chroot/dev
	sudo umount $chroot/share
}

function chroot_install_packages()
{
	# Install needed packages
	apt-get update
	apt-get -y dist-upgrade
	apt-get install -y build-essential rbp-userland-dev-osmc libvncserver-dev libconfig++-dev
}

function chroot_build_dispmanx_package()
{
	cd /share

	# Get the source code
	git clone https://github.com/patrikolausson/dispmanx_vnc.git

	# Compile
	make -C dispmanx_vnc

	# Copy bin file to bin folder
	mv dispmanx_vnc/dispmanx_vncserver dispmanx-vncserver/usr/bin

	# Create the package
	dpkg-deb --build dispmanx-vncserver dispmanx-vncserver_$version.deb

	# Add this to post installation
	#systemctl enable dispmanx_vncserver
}


ischroot

if [ $? == 1 ]
then
	host_install_packages
	host_build_filesystem
	host_start_chroot
else
	chroot_install_packages
	chroot_build_dispmanx_package
fi
