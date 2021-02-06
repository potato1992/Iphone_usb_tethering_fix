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
sudo ./install.sh
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
This project inlclude the all revised version from Linux kernel git [repo history](https://github.com/torvalds/linux/commits/master/drivers/net/usb/ipheth.c) for the **ipheth** driver from Linux 3.1 to Linux 5.9. However, sometimes third-party Linux distributor (like the odroid version) may revise this driver code, which can cause the build fail.

If you are facing problem with the build, please refer to your Linux distributor and download the corresponding source file of the Kernel your are using (check by uname -r)

Then find the **ipheth.c**  at: drivers/net/usb/, copy it to the **patches** folder, manually change the **ipheth.c** you put in the **patches** folder, like the following:
```C
//#define IPHETH_BUF_SIZE         1516
//replaced with:
#define IPHETH_BUF_SIZE         1514
```
Rerun the install.sh, then the compilation should pass.
