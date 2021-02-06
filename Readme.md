# Quick fix to Linux Iphone USB tethering with IOS 14 or higher

After IOS14, the USB tethering no loger works when the Linux kernel is lower than 5.10.4, see https://github.com/libimobiledevice/libimobiledevice/issues/1038.

Here I is a quick fix by rebuilding the ipheth driver. To use it, follow the steps:

1. Clone the project:
```bash
git clone https://github.com/potato1992/Iphone_usb_tethering_fix.git
```
2. Make the ko file:
```bash
make
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

It now should work.