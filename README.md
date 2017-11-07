WLAN-VPN-Pi
===========

This repository contains scripts and code to use a Raspberry Pi 3 with built in Wifi as a Wi-Fi access point (wlan0) that connects to the Internet via the following interfaces:

* Ethernet (eth0)
* It is also possible to use an additional WLAN interface (wlan1) as backhaul with an additional USB Wifi dongle. In practice however, stability and performance are far from ideal. Use of wlan1 backhaul is thus discouraged!

Connection to the Internet is NATed and a VPN client tunnel to a VPN server CAN used to encrypt ALL traffic to and from ALL devices connected to the access point. At startup, direct NATing is used an the VPN tunnel has to be started via the shell manually. This behavior can be changed if desired.

OpenVPN in client mode is used for creating the tunnel to an OpenVPN server somewhere on the Internet. A great project description of how to set-up a VPN server on the other end at home (on a Raspberry Pi, of course) can be found at http://readwrite.com/2014/04/10/raspberry-pi-vpn-tutorial-server-secure-web-browsing. Alternatively it's also possible to use a commercial service that offers OpenVPN server connectivity.

Hardware Requirements: 

Option 1: A Raspberry Pi 3 with built-in Wi-Fi. Backhaul is possible via Ethernet or Wi-Fi (discouraged). If Wi-Fi is used a USB Wi-Fi dongle is required (see below).

Option 2 (discouraged): A Raspberry Pi 1/2 (without built-in Wi-Fi). Apart from a Raspberry Pi, a USB Wi-Fi dongle is necessary. If Wi-Fi is used as a backhaul, a second Wi-Fi USB dongle is required. This option is STRONGLY discourages as hostapd of Raspbian Strech does not work reliably with external Wifi dongles over longer periods of time (EDIMAX EW-7811UN USB Wifi dongle).

Have a look at the project's wiki for installation and use instructions: 

https://github.com/martinsauter/WLAN-VPN-Pi/wiki
