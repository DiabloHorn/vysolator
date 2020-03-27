# Adding network interfaces to VMware fusion
This guide concerns the adding of network interfaces without DHCP to VMware fusion. The pro edition has a network editor and instruction can be found in a different file.

1. Add the network interfaces to your VM using the regular way of doing so
    * Virtual Machine --> Settings --> Add Device
1. Shutdown all of VMWare fusion
1. Edit the file ```/Library/Preferences/VMware Fusion/networking```
    * Ensure you have enough privileges ex: sudo
1. Edit the added interfaces to something like this
    * Recommended to keep the IP ranges the same that you'll use within your virtual network
        > answer VNET_2_DHCP no  
        > answer VNET_2_HOSTONLY_NETMASK 255.255.255.0  
        > answer VNET_2_HOSTONLY_SUBNET 10.5.5.0  
        > answer VNET_2_VIRTUAL_ADAPTER no

1. Start VMware fusion
1. Edit the properties of the network adapters to use the vmnet2 and vmnet3 adapters respectively.

Repeat the above steps each time you want to add a virtual network.

## Troubleshooting

* *Adapter options grayed out*  
Delete the DHCP hashes in the configuration file and restart VMware fusion or reboot

