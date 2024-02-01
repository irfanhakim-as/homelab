network:
  ethernets:
    {{NETWORK_INTERFACE}}:
      addresses: [{{IPADDR}}/24]
      dhcp4: false
      gateway4: {{GATEWAY}}
      nameservers:
        addresses: [{{DNS1}},{{DNS2}}]
  version: 2