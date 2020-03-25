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
    1. Manual installation
    1. Basic configuration
* Running our setup script
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
todo

## Running our setup script
todo

# References
* https://docs.docker.com/install/linux/docker-ce/ubuntu/
* https://github.com/vyos/vyos-build
* 


