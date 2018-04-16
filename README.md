WLAN-VPN-Pi
===========

Cloned from https://github.com/martinsauter/WLAN-VPN-Pi.git

This repository contains scripts and code to use a Raspberry Pi 3 with built in Wifi as a Wi-Fi access point (wlan0) that connects to the Internet via Ethernet (eth0).

Connection to the Internet is NATed and a VPN client tunnel to a VPN server CAN used to encrypt ALL traffic to and from ALL devices connected to the access point. At startup, direct NATing is used an the VPN tunnel has to be started via the shell manually. This behavior can be changed if desired.

OpenVPN in client mode is used for creating the tunnel to an OpenVPN server somewhere on the Internet. A great project description of how to set-up a VPN server on the other end at home (on a Raspberry Pi, of course) can be found at http://readwrite.com/2014/04/10/raspberry-pi-vpn-tutorial-server-secure-web-browsing. Alternatively it's also possible to use a commercial service that offers OpenVPN server connectivity.

Check functionality with: 
* run ifconfig on the pi:  tun0 should be available and passing data.
* when connected to Pi_AP with your laptop, browse to https://www.privateinternetaccess.com and login: 
    PIA should tell that you are protected.

Hardware Requirements: 
A Raspberry Pi 3 with built-in Wi-Fi. Backhaul is done via Ethernet.

Additional steps for PIA configuration:
* Add pwd.txt to the following line: auth-user-pass ==> auth-user-pass pwd.txt in openvpn config file
* Edit pwd.txt to add username and password for your pia account
* Change DNS entry in /etc/dnsmasq.conf.with-tunnel to point to PIA DNS: 209.222.18.222 or 209.222.18.218
* To start automatic at boot, modify /etc/wifipi-start.sh by removing the NAT commands and inserting a 
    call to start-vpn.sh

Thanks Martin, maikcat, dnsleak.com and dnsleaktest.com!

https://github.com/martinsauter/WLAN-VPN-Pi/wiki
