# VySOlator
VySOlator provides isolation of (virtual) networks based on VyOS. The goal of this project is to provide an initial setup for anyone who is looking to properly isolate (virtual) networks and protect their host machine. Use cases for this project: 
* Pentesting
* Malware research 

Currently only one network (internet only) is provided but more will be added as the project progresses.

# Process (steps)
* Building the VyOS iso
* Configure additional VMware networks
* Create and configure the VyOS virtual machine
* Troubleshooting
* Optional: test your setup
    1. Use your favourite network attacks and ensure it works as intended
    1. Create a pull request or issue if you found a way to access something else than the internet

## Building the VyOS iso
A pre-build iso is available through VyOS (https://downloads.vyos.io/). However, building it from scratch allows for more granular control. Here are the steps for building the iso using docker:  

1. Install docker, you can use the script in this repository
    * sudo ./install-docker.sh
1. Clone the VyOS repo and change the branch to crux 
    * git clone https://github.com/vyos/vyos-build
    * cd vyos-build
    * git checkout crux
1. From within the vyos-build folder
    * sudo docker build -t vyos-builder docker
    * sudo docker run --rm -it --privileged -v $(pwd):/vyos -w /vyos vyos-builder bash
        * ./configure --custom-package vim --build-by DiabloHorn
        * sudo make iso

The result of the above commands will be the iso created in the ```build``` directory within the ```vyos-build``` directory. This is the iso we can use to install VyOS.

## Configure additional VMware networks

What you have to do is add network interfaces that do nothing, no DHCP no nothing. Since this is different per virtualization solution you can refer to the following guides, depending on the virtualization software that you use:

* [VMWare fusion and fusion pro](vmware-fusion_howto-add-interfaces.md)
* VMware workstation (todo)
* VirtualBox (todo)



## Create and configure the VyOS virtual machine

### Creating the virtual machine
Add a new virual machine and select install from disc or image as the installation method. In the next screen select the vyos image we build in the previous step. As the operating system we choose Linux/Debian 7.x 64-bit (newer Debian version might also work). Recommended disk space is 5 GB and memory 512 mb.

After you are happy with the VM and boot from the iso you can login with the following credentials:

Username: ```vyos```  
Password: ```vyos```

On the commandline interface just run ```install image``` and make some common sense choices. After you are one, reboot the system. You will be able to login into your virtual gateway using your chosen password. The username will remain ```vyos```. You can now shutdown (```poweroff```) your virtual machine to be able to configure some additional network interfaces.

### Configure the virtual machine
Let's configure the bare minimum to be able to configure VyOS remotely. Our VyOS virtual machine should have three interfaces. Which we will use as follow:

* ```show interfaces ethernet```
    * eth0 will be our uplink or connection to the internet
    * eth1 will be our mgmt interface to control vyos remotely from a different VM
    * eth2 will be our internet only interfaces where we can place multiple VMs

After logging in the following list of commands will perform the basic configuration to be able to manage VyOS remotely.

> ```configure```  
> ```set interfaces ethernet eth1 description 'mgmt interface'```  
> ```set interfaces ethernet eth1 address '10.7.7.1'```
> ```commit```  
> ```set service ssh listen-address '10.7.7.1'```  
> ```set service ssh port '22'```  
> ```commit```  
> ```save```  
> ```exit```

The above shoud have configured SSH on the mgmt interface. You should now be able to SSH into VyOS from a different VM. Ensure that the mgmt VM is configured with the vmnet2 interface. This mgmt VM will not have internet or any other connections.

## Running setup script
We perform the following from our mgmt VM:  
> ```scp setup-config.sh vyos@10.7.7.1:~/```

Then we login to VyOS and do the following:  
> ```chmod +x setup-config.sh```  
>```sg vyattacfg -c ./setup-config.sh```

That's it. If we now place a VM in the same segment / interfaces as vmnet2/eth2 it will only be able to connect to the internet.

## Troubleshooting
* *Running "sudo docker build -t vyos-builder docker" does not work (container is unable to install packages)*
When running docker on Ubuntu 16 you might have no internet inside your containers, comment out dnsmasq in /etc/NetworkManager/NetworkManager.conf and restart the Network Manager service. 
* *I messed up the configuration*
    > ```configure```  
    > ```load /opt/vyatta/etc/config.boot.default```  
    > ```commit```  
    > ```# If you are doing this remote, connection will drop after this```  
    > ```save```  
    > ```exit```  
    > ```reboot```
* *Can I use different IP ranges than your example?*  
Yes, of course. Be mindful of typo's
 
# References
* https://docs.docker.com/install/linux/docker-ce/ubuntu/
* https://github.com/vyos/vyos-build
* https://vyos.readthedocs.io/en/latest/install.html
* https://spin.atomicobject.com/2017/04/03/vmware-fusion-custom-virtual-networks/
* https://github.com/bertvv/cheat-sheets/blob/master/docs/VyOS.md
* https://superuser.com/questions/1130898/no-internet-connection-inside-docker-containers



