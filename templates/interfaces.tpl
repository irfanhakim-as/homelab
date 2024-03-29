# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
# allow-hotplug {{NETWORK_INTERFACE}}
# iface {{NETWORK_INTERFACE}} inet dhcp
auto {{NETWORK_INTERFACE}}
iface {{NETWORK_INTERFACE}} inet static
address {{IPADDR}}
netmask {{NETMASK}}

gateway {{GATEWAY}}
dns-nameservers {{DNS1}} {{DNS2}}