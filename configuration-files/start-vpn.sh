#!/bin/bash

#
# This script STARTS the OpenVPN client. This is done as follows:
#
# 1. Disable the NATing that could be in place between wlan0 (Access point) and wlan1 and eth1
#
# 2. Starts the OpenVPN client
#
# 3. puts NATing (ip masquerading) in place
#
# 4. Optional: enables port forwarding through the NAT to make services available to the outside
#    world that are running on a device behind the NAT.
#

echo ""
echo "Starting the OpenVPN client. Direct NAT is disabled first which could lead to"
echo "some error messages below. They can be safely ignored..."
echo ""

cp /etc/dnsmasq.conf.no-tunnel /etc/dnsmasq.conf
service dnsmasq restart

# disable NATING between the two Wi-Fis or between the Wi-Fi and Ethernet
# only one is running at a time but we'll just issue commands for both
iptables -t nat -D POSTROUTING -o wlan1 -j MASQUERADE
iptables -D FORWARD -i wlan1 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -D FORWARD -i wlan0 -o wlan1 -j ACCEPT

iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
iptables -D FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -D FORWARD -i wlan0 -o eth0 -j ACCEPT


# restart the openvpn client
/etc/init.d/openvpn restart

# enable NATing throught the tunnel Interface
iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE
iptables -A FORWARD -i tun0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i wlan0 -o tun0 -j ACCEPT

sleep 2
cp /etc/dnsmasq.conf.with-tunnel /etc/dnsmasq.conf
service dnsmasq restart


echo
echo "OpenVPN client started, NAT routing through TUN0 activated"
echo "wait a few seconds and then use ifconfig to see if the tunnel"
echo "was established correctly."
echo

