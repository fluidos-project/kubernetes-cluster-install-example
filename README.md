# Noetic installation

Full unattantendded installation ros noetic with graphical capabilites

## Cloud Init setup
```bash
git clone git@github.com:RobotnikAutomation/kubernetes-install.git
checkout devel
cd kubernetes-install
```

## Cloud init configuration server
- Start the http server on the remote machine
```bash
git clone git@github.com:RobotnikAutomation/kubernetes-install.git
checkout devel
cd kubernetes-install
cd www/
python3 -m http.server 3003
```

## Method 1: grub edit

### Installation
1. Burn the image on a pendrive
2. Run the cloud init http server on the remote machine
3. Ensure that machine you are going to install has ethernet connection with dhcp
4. Boot the machine with the pendrive
5. Press e when the grub enter
6. Change the line to `linux /casper/vmlinuz autoinstall ip=dhcp ds=nocloud-net\;s=http://192.168.20.165:3003/edge1/ -- net.ifnames=0 biosdevname=0`
7. Press F10
5. Wait thill the installation is over
6. Remove the pendrive
7. restart the machine
8. Wait till cloud init runs all the first boot commands

## Method 2: script
edit the following `script/iso-params` file or use the argument parser

```bash

../scripts/customize-ubuntu-iso.sh
```

```bash
../scripts/customize-ubuntu-iso.sh --help

Automated ubuntu installation creator
Version: 1.0.0

Usage:
../scripts/customize-ubuntu-iso.sh
../scripts/customize-ubuntu-iso.sh [OPTIONS]

Optional arguments:
 -d, --distro [DISTRO]               Select ubuntu distro (focal/jammy)
                                     (focal/jammy)
 -s, --net                           Select to use the cloud-init
                                     server
 -e, --embedded                      Select to embedded the nocloud file
                                     inside the iso
                                     (This will invalide the ci* options)
 -f, --ci-file [FILE]                cloud-init file path
 -t, --ci-server-prot [PROTOCOL]     Cloud-init server protocol
                                     (https/http)
 -n, --ci-server-name [URL]          Cloud-init server url
 -p, --ci-server-port [PORT]         Cloud-init server port (default 80/443)
 -d, --ci-server-folder [FOLDER]     Cloud-init server folder

 -h, --help                Shows this help

 -v, --version             Shows the version of the script

```
### Installation
1. Burn the image on a pendrive
2. Run the cloud init http server on the remote machine
3. Ensure that machine you are going to install has ethernet connection with dhcp
4. Boot the machine with the pendrive
5. Wait thill the installation is over (machine will power off)
6. Remove the pendrive
7. restart the machine
8. Wait till the machine reboots again with full desktop capabilites
