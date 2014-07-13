#!/bin/bash

#
# This script stops the OpenVPN client and establishes a direct
# NAT between wlan0 (Wi-Fi access point) and wlan1 and eth0
#
# The script can also be used to establish the direct NAT, e.g.
# to perform a hotel Wi-Fi login which is required in the clear
# before the VPN tunnel is allowed to go through.
#


/etc/init.d/openvpn stop

# disnable NATing throught the tunnel Interface

iptables -t nat -D POSTROUTING -o tun0 -j MASQUERADE
iptables -D FORWARD -i tun0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -D FORWARD -i wlan0 -o tun0 -j ACCEPT


#enable NATING directly between the Wi-Fi and the ethernet port

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT

#enable NATING directly between the two WI-Fis

iptables -t nat -A POSTROUTING -o wlan1 -j MASQUERADE
iptables -A FORWARD -i wlan1 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i wlan0 -o wlan1 -j ACCEPT


echo
echo "OpenVPN stopped, direct wlan0 to eth0 nat enabled"
echo



