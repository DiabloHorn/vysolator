# Adding networks/segments to VMware fusion
This guide concerns the adding of network interfaces without DHCP to VMware fusion.
1. Add the network interfaces to your VM using the regular way of doing so
    * Virtual Machine --> Settings --> Add Device
1. Shutdown all of VMWare fusion
1. Edit the following file as superuser ```/Library/Preferences/VMware Fusion/networking```
1. Add the following interfaces at the bottom of the file 
        > answer VNET_2_DHCP no  
        > answer VNET_2_HOSTONLY_NETMASK 255.255.255.0  
        > answer VNET_2_HOSTONLY_SUBNET 10.7.7.0  
        > answer VNET_2_VIRTUAL_ADAPTER no  
        > answer VNET_3_DHCP no  
        > answer VNET_3_HOSTONLY_NETMASK 255.255.255.0  
        > answer VNET_3_HOSTONLY_SUBNET 10.8.8.0  
        > answer VNET_3_VIRTUAL_ADAPTER no
1. Start VMware fusion

