# Quick fix to Linux Iphone USB tethering with IOS 14 or higher
(Tested with ubuntu 18.04, kernel 5.4.0-65, if you fail in the build, please download your own kernel source, see bottom description)

After IOS14, the USB tethering no loger works with [libimobiledevice](https://github.com/libimobiledevice/libimobiledevice) when the Linux kernel is lower than 5.10.4, see the [issue](https://github.com/libimobiledevice/libimobiledevice/issues/1038)

Here is a quick fix by rebuilding the ipheth driver with the revised code. To use it, follow the steps:

1. Clone the project:
```bash
git clone https://github.com/potato1992/Iphone_usb_tethering_fix.git
```
2. Enter the project folder and build the driver file:
```bash
cd Iphone_usb_tethering_fix/
chmod +x ./install.sh
sudo bash ./install.sh
```
- Follow the guide, and you can stop here if you successfully use the automatic installation.
For manually installation after build:
1. Backup your original driver:
```bash
sudo cp /lib/modules/$(uname -r)/kernel/drivers/net/usb/ipheth.ko /lib/modules/$(uname -r)/kernel/drivers/net/usb/ipheth.ko.bak
```
2. Remove the old driver:
```bash
sudo rmmod ipheth
```
3. Copy the built driver
```bash
sudo cp ipheth.ko /lib/modules/$(uname -r)/kernel/drivers/net/usb/
```
4. Reload the new driver
```bash
sudo modprobe ipheth
```

It should work properly now.

- One more thing:
It is expected to repeat those processes if the kernel has been updated.

# Note
This project inlclude all the revised versions of the **ipheth** driver from Linux kernel git [repo history](https://github.com/torvalds/linux/commits/master/drivers/net/usb/ipheth.c)  from Linux 3.1 to Linux 5.9. However, there are two major possibilities that will cause the build fail:

1. sometimes third-party Linux distributor (like the odroid version) may revise this driver code, which can cause the build fail.
In this case, please refer to your Linux distributor and download the corresponding source file of the Kernel your are using (check by uname -r)

Then find the **ipheth.c**  at: drivers/net/usb/, copy it to the **patches** folder, manually change the **ipheth.c** you put in the **patches** folder, like the following:
```C
//#define IPHETH_BUF_SIZE         1516
//replaced with:
#define IPHETH_BUF_SIZE         1514
```
Rerun the install.sh, then the compilation should pass.

2. As the project can not include all linux versions source code, the compilzation will rely on local Linux header files. It will fail if your system does not comes with the Linux header files, check it by running:
```bash
ls -l /lib/modules/$(uname -r)/build
```
The output should be something like the following to indicate a proper soft link:
```bash
lrwxrwxrwx 1 root root 39 Jan 19 01:34 /lib/modules/5.4.0-65-generic/build -> /usr/src/linux-headers-5.4.0-65-generic
```
There are two possible solutions to it, 

(1) Install the Linux header of the same version of uname -r.

(2) Install a official version of ubuntu/debian in a vmware machine, then install and switch to the linux kernel version of the target PC, run the scripts and a **ipheth.ko** driver will be there, copy it to the desitination PC then perform a manual installation as instructed in the Readme.md.

- This script will not work for openwrt user since openwrt does not come with neccesssy component to build the kernel module, please download the openwrt firmware source code, change the code **ipheth.c**  at: drivers/net/usb/, as instructed in Problem 1, then compile the openwrt driver using the toolkit from your openwrt distributor. 

## Raspberry pi
It seems that the Linux kernel of the rasbian system has already been updated to higher than 5.10, thus do a apt upgrade to update the kernel would make the usb tethering work without this script.

But if you donot want to update the kernel and fail in the build with the reson of missing Linux Kernel, like:
make -C /lib/modules/5.10.11-v7+/build M=/home/pi/Iphone_usb_tethering_fix modules
make[1]: *** /lib/modules/5.10.11-v7+/build: No such file or directory.  Stop.
make: *** [Makefile:6: default] Error 2

Things would be easy to fix this:
```bash
sudo apt-get install raspberrypi-kernel-headers
```


