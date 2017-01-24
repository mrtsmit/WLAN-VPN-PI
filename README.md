WLAN-VPN-Pi
===========

This repository contains scripts and code to use a Raspberry Pi as a Wi-Fi access point (wlan0) that connects to the Internet via the following interfaces:

* Ethernet (eth0)
* An additional WLAN interface (wlan1)

Connection to the Internet is NATed and a VPN client tunnel to a VPN server is used to encrypt ALL traffic to and from ALL devices connected to the access point. Alternatively, direct NATing without a VPN tunnel is also possible.

OpenVPN in client mode is used for creating the tunnel to an OpenVPN server somewhere on the Internet. A great project description of how to set-up a VPN server on the other end at home (on a Raspberry Pi, of course) can be found at http://readwrite.com/2014/04/10/raspberry-pi-vpn-tutorial-server-secure-web-browsing. Alternatively it's also possible to use a commercial service that offers OpenVPN server connectivity.

Hardware Requirements: 
Option 1: Raspberry Pi 3 with built-in Wi-Fi. Backhaul is possible via Ethernet of Wi-Fi. If Wi-Fi is used a USB Wi-Fi dongle is required (see below).

Option 2: Raspberry Pi 1/2 (without built-in Wi-Fi). Apart from a Raspberry Pi, a USB Wi-Fi dongle is necessary. If Wi-Fi is used as a backhaul, a second Wi-Fi USB dongle is required. This project uses a hostapd executable that was compiled for the Realtek RTL8188CUS chipset. The following devices have been checked for compatibility:

* EDIMAX EW-7811UN

For other chipsets, other hostapd executables might be required.

Have a look at the project's wiki for installation and use instructions: 

https://github.com/martinsauter/WLAN-VPN-Pi/wiki
