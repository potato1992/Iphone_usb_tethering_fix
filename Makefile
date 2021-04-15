obj-m:=ipheth.o
KDIR:=/lib/modules/$(shell uname -r)/build
PWD:=$(shell pwd)
CONFIG_MODULE_SIG=n

default:
		$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
		rm -rf .*.cmd *.o *.mod.c *.ko .tmp_versions *.order *symvers *Module.markers *.mod ipheth.c *.der *.priv
