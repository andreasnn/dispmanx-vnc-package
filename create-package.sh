version=2019-1

# Get the source code
wget https://github.com/patrikolausson/dispmanx_vnc/archive/master.zip
unzip master.zip

# Compile
make -C dispmanx_vnc-master

# Copy bin file to bin folder
mv dispmanx_vnc-master/dispmanx_vncserver dispmanx-vncserver/usr/bin

# Remove files
rm -fr master.zip dispmanx_vnc-master

# Create the package
dpkg-deb --build dispmanx-vncserver dispmanx-vncserver_$version.deb

# Add this to post installation
#systemctl enable dispmanx_vncserver
