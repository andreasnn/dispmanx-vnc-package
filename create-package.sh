version=2019-1


function chroot()
{
	chroot=~/Downloads/filesystem

	mkdir $chroot/share
	sudo mount -o bind . $chroot/share
	sudo mount -o bind /dev $chroot/dev

	# Network setup
	sudo cp /etc/resolv.conf $chroot/etc

	sudo chroot $chroot /bin/bash /share/create-package.sh

	sudo umount $chroot/dev
	sudo umount $chroot/share
}

function install_packages()
{
	# Install needed packages
	apt-get update
	apt-get -y dist-upgrade
	apt-get install -y build-essential rbp-userland-dev-osmc libvncserver-dev libconfig++-dev
}

function compile_dispmanx()
{
	cd /share

	# Get the source code
	git clone https://github.com/patrikolausson/dispmanx_vnc.git

	# Compile
	make -C dispmanx_vnc

	# Copy bin file to bin folder
	mv dispmanx_vnc/dispmanx_vncserver dispmanx-vncserver/usr/bin
}

function build_package()
{
	# Create the package
	dpkg-deb --build dispmanx-vncserver dispmanx-vncserver_$version.deb

	# Add this to post installation
	#systemctl enable dispmanx_vncserver
}


ischroot

if [ $? == 1 ]
then
	chroot
else
	install_packages
	compile_dispmanx
	build_package
fi
