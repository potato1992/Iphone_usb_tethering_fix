# Quick fix to Linux Iphone USB tethering with IOS 14 or higher
(Tested with ubuntu 18.04, kernel 5.4.0-65, if you fail in the process, please download your own kernel, see bottom description)

After IOS14, the USB tethering no loger works with [libimobiledevice](https://github.com/libimobiledevice/libimobiledevice) when the Linux kernel is lower than 5.10.4, see the [issue](https://github.com/libimobiledevice/libimobiledevice/issues/1038)

Here I is a quick fix by rebuilding the ipheth driver with the revised code. To use it, follow the steps:

1. Clone the project:
```bash
git clone https://github.com/potato1992/Iphone_usb_tethering_fix.git
```
2. Enter the project folder and make the ko file:
```bash
cd Iphone_usb_tethering_fix/
chmod +x ./make.sh
./make.sh
```
3. Backup your original driver:
```bash
sudo cp /lib/modules/$(uname -r)/kernel/drivers/net/usb/ipheth.ko /lib/modules/$(uname -r)/kernel/drivers/net/usb/ipheth.ko.bak
```
4. Remove the old driver:
```bash
sudo rmmod ipheth
```
5. Copy the built driver
```bash
sudo cp ipheth.ko /lib/modules/$(uname -r)/kernel/drivers/net/usb/
```
6. Reload the new driver
```bash
sudo modprobe ipheth
```

It should work properly now.

- One more thing:
It is expected to repeat those processes if the kernel has been updated.

# Note
If you are facing problem with the make, please run "uname -r" to get your linux kernel version, and download the source file of the Kernel your are using (if not found, use the nearest version may also work).

Then find the ipheth.c  at: drivers/net/usb/, copy it to the project folder, modify the code:
```C
//#define IPHETH_BUF_SIZE         1516
//replace with:
#define IPHETH_BUF_SIZE         1514
```
Then the compilation should pass.
