# vysolator
vyos based isolation of networks. Currently only the following is provided:

* An internet only segment/network

## VyOS
You can read up and download VyOS from the following locations

* https://vyos.io
* https://vyos.readthedocs.io

# Getting started
I'd recommend compiling VyOS, this enables you to tweak it more to your own requirements in the future. If you prefer to not compile VyOS yourself you can also download the ISO from:

* https://downloads.vyos.io/


The steps we will be performing are:

* Building VyOS
    1. Installing docker
    1. Obtaining VyOS source
    1. Building VyOS
* Initial VyOS setup
    1. Virtual machine setup
    1. Basic configuration
* Running our setup script
* Troubleshooting
* Optional: test your setup
    1. Use your favourite network attacks and ensure it works as intended
    1. Create a pull request or issue if you found a way to access something else than the internet

## Building VyOS
We will be using the docker way of building VyOS. The instructions on the readme of the vyos-build repository are much more detailed. This is just my way of getting it done.

1. Install docker, you can use the script in this repository
    * sudo ./install-docker.sh
1. checkout VyOS repository and branch
    * git clone https://github.com/vyos/vyos-build
    * cd vyos-build
    * git checkout crux
1. sudo docker build -t vyos-builder docker
1. sudo docker run --rm -it --privileged -v $(pwd):/vyos -w /vyos vyos-builder bash
    * ./configure --custom-package vim --build-by DiabloHorn
    * sudo make iso

The result of the above commands will be the iso created in the ```build``` directory within the ```vyos-build``` directory. This is the iso we can use to install VyOS.

## Initial VyOS setup
Now that we have an iso we can create a virtual machine and install VyOS. You could also have compiled virtualization specific options, but I still prefer the iso myself.

### **Virtual machine setup**
The virtual machine setup is pretty straight forward. I usually configure a default machine with a single network interface and remove unncessary peripherals.

After you are happy with the VM and boot from the iso you can login with the following credentials:

Username: ```vyos```  
Password: ```vyos```

On the commandline interface just run ```install image``` and make some common sense choices. After you are one, reboot the system. You will be able to login into your virtual gateway using your chosen password. The username will remain ```vyos```. You can now shutdown (```poweroff```) your virtual machine to be able to configure some additional network interfaces.

What you have to do is add network interfaces that do nothing, no DHCP no nothing. Since this is different per virtualization solution you can refer to the following guides, depending on the virtualization software that you use:

* [VMWare fusion](vmware-fusion_howto-add-interfaces.md)
* VMware fusion Pro (todo)
* VMware workstation (todo)
* VirtualBox (todo)

### **Basic configuration**
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

## Running our setup script
So I've thought about using ansible, but since VyOS can be fully configured with a single configuration file. I've thought that for the moment using SCP to copy the file over is good enough.

We perform the following from our mgmt VM:  
> ```scp setup-config.sh vyos@10.7.7.1:~/```

Then we login to VyOS and do the following:  
> ```chmod +x setup-config.sh```  
>```sg vyattacfg -c ./setup-config.sh```

That's it. If we now place a VM in the same segment / interfaces as vmnet2/eth2 it will only be able to connect to the internet.

## Troubleshooting

* *I messed up the configuration*
    > ```configure```  
    > ```load /opt/vyatta/etc/config.boot.default```  
    > ```commit```  
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




