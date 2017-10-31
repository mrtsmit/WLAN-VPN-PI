#!/bin/bash

#
# Wi-Fi-Pi-install-script.sh
#
# @version    1.5 2016-04-21
# @copyright  Copyright (c) 2014 Martin Sauter, martin.sauter@wirelessmoves.com
# @license    GNU General Public License v2
# @since      Since Release 1.0
#
# Installs and configures all necessary components
# for a Raspberry Pi to act as a Wi-Fi access point
# with backhaul over:
#
# a) Ethernet cable
# b) Wi-Fi, if a second USB device is connected
#
# For details see the project Wiki at:
#
#              https://github.com/martinsauter/WLAN-VPN-Pi/wiki
#
# Version History
#
# 1.0 - Initial version on Github
#
# 1.1 - Improved startup behavior by restarting wlan0 after booting in
#       rc.localhost
#
# 1.2 - Limit the sshd to wlan0 (the 192.168.55.0 subnet)
#     - Shell script added to generate the tar file
#
# 1.3 - Include system package update at start of script
#     - Remove wolfram-engine to reduce update
#     - Install tcpdump and htop utilities as they are useful in this context
#
# 1.4 - 2016-01-06
#     - Small updates to support Raspbian based on Debian Jessie
#       Released in September 2015:
#     - The Jessie Image starts the OpenVPN client automatically, therefore
#       NAT forwarding between the wlan0 and tun0 interfaces is enabled
#       during power up in rc.local
#     - Disable IPv6 in sysctl.conf which is now necessary as it is active
#       by default. For the VPN client this is not desirable as some
#       VPN providers only offer IPv6 connectivity but also return IPv6
#       DNS responses. If there is local IPv6 connectivity, data does
#       then NOT flow through the tunnel but circumvents it.
#     - hostapd is now held with apt-mark hold so it is not updated
#       automatically. This is necessary as a proprietary hostapd is used
#       for the WiFi USB dongles used for this project.
#
# 1.41 - Debian Jessie - DNS through tunnel interface fix in dhcpd.conf
#
# 1.5  - 2016-04-21
#      - Improved DNS behavior: By using different versions of dnsmasq.conf
#        when the VPN tunnel is started and stopped it is ensured that DNS
#        requests flow through the VPN tunnel when established. When direct
#        Internet access is used the local DNS resolver is used instead.
#      - Check for root permissions in scripts introduced to prevent partial
#        execution without proper access rights.
#
# 1.51 - 2016-07-01 modified the script to stop rpi-update from running
#        as at some point between kernel 4.1 and 4.4, the hostapd Wifi 
#        Access Point functionality used below got broken. Until a fix is 
#        in place make sure you have a kernel version <= 4.1 before 
#        proceeding
#
# 1.52 - 2017-02-08 further modified the script to prevent kernel updates
#        which break the hostapd functinality of the proprietary model
#        THIS IS VERY BAD FOR SECURITY. CONSIDER USING A RASPI 3 FOR
#        THIS PROJECT THAT DOES NOT SUFFER FROM THIS PROBLEM!!!!!
#
##############################################################################
# IMPORTANT: This script significantly changes the network configuration
# of eth0, wlan0 and wlan1 and a fair number of network configuration files.
# ONLY USE WITH A FRESH RASPBERRY PI IMAGE FILE
##############################################################################
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU AFFERO GENERAL PUBLIC LICENSE
# License as published by the Free Software Foundation; either
# version 3 of the License, or any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU AFFERO GENERAL PUBLIC LICENSE for more details.
#
# You should have received a copy of the GNU Affero General Public
# License along with this library.  If not, see <http://www.gnu.org/licenses/>.

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root, please try again" 1>&2
   exit 1
fi

echo "#### Wi-Fi Pi Access Point and VPN Installation"
echo "###################################################"
echo ""

#### General Pi Setup
#### TO BE DONE MANUALLY BEFORE RUNNING THIS SCRIPT!!!

#sudo raspi-config --> change locale, etc.
#sudo reboot

echo ""
echo "#################################################################"
echo "WARNING: THIS PROJECT DISABLES KERNEL UPDATES AS THESE"
echo "BREAK THE PROPRIETARY HOSTAPD ACCESS POINT FUNCTIONALITY."
echo "THIS IS A SECURITY RISK!!! CONSIDER USING A RASPBERRY PI 3"
echo "FOR THIS PROJECT WHICH DOES NOT HAVE THIS PROBLEM!!!"
echo ""
echo "MAKE SURE YOU HAVE AN IMAGE WITH AN OLD KERNEL!"
echo "FOR DETAILS SEE THE WIKI TO THIS PROJECT AT"
echo "https://github.com/martinsauter/WLAN-VPN-Pi/wiki/Installation"
echo "#################################################################"
echo ""


#### After the reboot install and configure all necessary components
#######################################################################

echo "###############################################################"
echo "IMPORTANT: The script requires you to change the Raspberry Pi"
echo "default password as otherwise the setup is not secure."
echo "###############################################################"

passwd pi


echo ""
echo "#################################################################"
echo " Updating all packages to the latest version and removing the"
echo " Wolfram engine as it is not needed and requires huge udpates."
echo " Also, tcpdump and htop are installed as they might be useful"
echo "#################################################################"

sudo apt-mark hold raspberrypi-kernel
sudo apt-mark hold raspberrypi-bootloader

apt-get update
apt-get -y remove wolfram-engine
apt-get -y install htop tcpdump
apt-get -y upgrade

# Temporarily deactivating the kernel update instructions. 
# For details see v1.51 description above.
#
#apt-get -y install rpi-update
#
#rpi-update

echo ""
echo "###############################################################"
echo "#### Unpacking configuration files"
echo "###############################################################"

tar xvzf wifipi.tar

#per default all configuration files are read only except for the owner
chmod 644 ./configuration-files/*
#script files must be executable
chmod 755 ./configuration-files/*.sh
#the openvpn directory needs exec rights so it can be opened
chmod 775 ./configuration-files/openvpn
#openvpn config files must only be read/writable for the owner
chmod 600 ./configuration-files/openvpn/*.*

cd ./configuration-files

echo ""
echo "done..."
echo ""

echo "#### Copying basic configuration for eth0, wlan0 and wlan1"
echo "###############################################################"

cp interfaces /etc/network/interfaces
cp wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf

echo ""
echo "done..."
echo ""


echo "#### Installing and configuring wlan0 as Wi-Fi AP"
echo "########################################################"

apt-get -y install hostapd

mkdir hostapd-install
cd hostapd-install

#precompiled hostapd for specific chipset
wget http://www.daveconroy.com/wp3/wp-content/uploads/2013/07/hostapd.zip
unzip -o hostapd.zip 
mv /usr/sbin/hostapd /usr/sbin/hostapd.bak
mv hostapd /usr/sbin/hostapd.edimax 
ln -sf /usr/sbin/hostapd.edimax /usr/sbin/hostapd 
chown root.root /usr/sbin/hostapd 
chmod 755 /usr/sbin/hostapd

cd ..

#copy access point configuration file
cp hostapd.conf /etc/hostapd/

#make sure hostapd is not updated automatically as we use a proprietary one (see above)
sudo apt-mark hold hostapd

#put a modified action_wpa.sh in lace to fix wpa supplicant misbehavior with two Wi-Fi interfaces
cp action_wpa.sh /etc/wpa_supplicant/action_wpa.sh

#autostart hostapd on system startup
cp hostapd /etc/default/hostapd

#autostart sometimes doesn't work correctly, so add a start/stop wlan0 to rc.local
cp rc.local /etc/rc.local

echo ""
echo "done..."
echo ""


echo "#### Installing and configuring the DHCP server to serve wlan0"
echo "###################################################################"

apt-get -y install hostapd isc-dhcp-server
cp dhcpd.conf /etc/dhcp/dhcpd.conf
cp isc-dhcp-server /etc/default/isc-dhcp-server

echo ""
echo "###### NOTE: The failure report above is o.k., it will work after rebooting... #####"
echo ""

echo ""
echo "done..."
echo ""


echo "#### Enabling ip packet routing between interfaces"
echo "########################################################"

cp sysctl.conf /etc/sysctl.conf

echo ""
echo "done..."
echo ""

echo "### Installing and configuring Dnsmasq as a local DNS server"
echo "##############################################################"

apt-get install -y dnsmasq

cp dnsmasq.conf.no-tunnel /etc/dnsmasq.conf
cp dnsmasq.conf.no-tunnel /etc/dnsmasq.conf.no-tunnel
cp dnsmasq.conf.with-tunnel /etc/dnsmasq.conf.with-tunnel

echo ""
echo "done..."
echo ""


echo "### Installing the OpenVPN client service"
echo "###############################################"

apt-get -y install openvpn
cp ./openvpn/* /etc/openvpn

#disable openvpn client autostart
apt-get -y install chkconfig
chkconfig openvpn off

echo ""
echo "done..."
echo ""

echo "### Limiting SSH access to the Access Point Wifi network"
echo "### (192.168.55.0) in /etc/ssh/sshd_config"
echo "########################################################"

cp sshd_config /etc/ssh

echo ""
echo "done..."
echo ""

#copy VPN start and stop batch files to upper directory
cp start* ..
cp stop* ..

echo ""
echo "#####################################################"
echo "The Wi-Fi Access Point configuration is as follows:"
echo ""

cat /etc/hostapd/hostapd.conf

echo ""
echo "#####################################################" 
echo ""

echo ""
echo "#####################################################"
echo "The network configuration of the Wi-Fi AP interface"
echo "(wlan0) is as follows"
echo ""

cat /etc/network/interfaces

echo ""
echo "#####################################################" 
echo ""

echo ""
echo "#####################################################"
echo "For details to start Internet access with or without"
echo "the VPN tunnel see the project Wiki at Github at"
echo ""
echo "  https://github.com/martinsauter/WLAN-VPN-Pi/wiki"
echo ""
echo "#####################################################" 
echo ""

echo "#########################################################"
echo "### and now reboot to make the changes come into effect"
echo "#########################################################"


