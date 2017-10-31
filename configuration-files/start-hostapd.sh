#!/bin/sh -e

sleep 10
sudo /usr/sbin/hostapd -B -P /var/run/hostapd.pid /etc/hostapd/hostapd.conf &

sleep 10
sudo service isc-dhcp-server restart &

sleep 3
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT

sudo iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
sudo iptables -A FORWARD -i eth1 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i wlan0 -o eth1 -j ACCEPT

sudo service dnsmasq restart

