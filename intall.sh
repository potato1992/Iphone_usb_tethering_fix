#!/bin/bash

ver=$(uname -r)          # get kernel release version
ver_num="${ver%.*-*}"        # remove suffix starting with '.' and containing '-'

old_line="#define IPHETH_BUF_SIZE         1516"
new_line="#define IPHETH_BUF_SIZE         1514"

i=0
for entry in patches/*
do
  patch_array[i]="$(basename "$entry")"
  let i=i+1
done

error() {
	echo -e "\n$red Input error!$NC\n"
}

red='\e[91m'
green='\e[92m'
yellow='\e[93m'
magenta='\e[95m'
cyan='\e[96m'
NC='\e[0m'
_red() { echo -e ${red}$*${none}; }
_green() { echo -e ${green}$*${none}; }
_yellow() { echo -e ${yellow}$*${none}; }
_magenta() { echo -e ${magenta}$*${none}; }
_cyan() { echo -e ${cyan}$*${none}; }

#get selected patch version
patch_ver_config() {
	# clear
	echo
	while :; do
        echo -e "Please select the patch version you want:"
        echo
		i=0
        for item in "${patch_array[@]}"; do
            echo -e "${yellow}$i.${NC} $item"
            let i=i+1
        done
        let n_patch=i
        let i=i-1

        echo
        echo -e "Your current kernel version is ${red}$ver${NC}"
        echo -e "The selected version should be ${yellow}slightly lower${NC} than your current kernel version"
        echo -e "For example, for ${red}5.4.0-65-generic${NC}, I will select ${red}ipheth_5.3.0.c${NC}"
        echo -e "*Note: The ipheth_4.9.y_odroid.c is used for odroid from hardkernel only"

		read -p "$(echo -e "Enter your choice: [${yellow}0-$i${NC}]"):" patch_ver_sel
		[ -z "$patch_ver_sel" ] && patch_ver_sel=1
		case $patch_ver_sel in
		[0-9] | [0-9][0-9])
            if [ $patch_ver_sel -lt $n_patch ]; then
                echo
                echo -e "You have selected ${yellow}$patch_ver_sel${NC}. ${patch_array[patch_ver_sel]}"
                echo "----------------------------------------------------------------"
                echo
                break
            else
                error
            fi
            ;;
		*)
			error
			;;
		esac
	done
	
}

#install driver
driver_install() {
    # clear
	echo
    while :; do

		read -p "$(echo -e "(Do you want to install the driver automatically?: [${magenta}Y/N$NC]):") " auto_install_driver
		if [[ -z "$auto_install_driver" ]]; then
			error
		else
			if [[ "$auto_install_driver" == [Yy] ]]; then
				echo
				echo -e "$yellow Automatical install$NC"
				echo "----------------------------------------------------------------"
				echo
                echo -e "$yellow[INFO]$NC Backuping your old driver to $red/lib/modules/$(uname -r)/kernel/drivers/net/usb/ipheth.ko.bak$NC"
                cp /lib/modules/$(uname -r)/kernel/drivers/net/usb/ipheth.ko /lib/modules/$(uname -r)/kernel/drivers/net/usb/ipheth.ko.bak
                echo -e "$yellow[INFO]$NC Removing your old driver"
                rmmod ipheth
                echo -e "$yellow[INFO]$NC Coping the new driver"
                cp ipheth.ko /lib/modules/$(uname -r)/kernel/drivers/net/usb/
                echo -e "$yellow[INFO]$NC Installing the new driver"
                modprobe ipheth
                echo -e "$yellow[INFO]$NC Done"
				break
			elif [[ "$auto_install_driver" == [Nn] ]]; then
				echo
				echo -e "$yellow[INFO]$NC Exit"
				echo "----------------------------------------------------------------"
				echo
                exit 1
				break
			else
				error
			fi
		fi

	done
}

# Root
[[ $(id -u) != 0 ]] && echo -e "\n Please use ${red}sudo${NC} privilege to run ${yellow}~(^_^) ${none}\n" && exit 1

patch_ver_config
echo -e "${yellow}[INFO]${NC} Copying patch file..."
cp ./patches/${patch_array[patch_ver_sel]} ipheth.c
echo -e "${yellow}[INFO]${NC} Revising the code..."
sed -i.bak "s/${old_line}/${new_line}/g" ipheth.c

echo ''
make
status=$?;
echo ''
case "$status" in
    0) echo -e "${yellow}[INFO]${NC} All makefiles passed";
       echo -e "${yellow}[INFO]${NC} Please continue to install the driver";
       driver_install
        ;;
    1) echo -e "${yellow}[INFO]${NC} Target needs to be rebuilt"; ;;
    2) echo -e "${yellow}[INFO]${NC} Error(s) in make, please try other kernel choices or get the ${red}ipheth.c${NC} from your linux distributor"; 
       echo -e "${yellow}[INFO]${NC} Copy the ${red}ipheth.c${NC}  from your linux distributor to the patches folder and rerun the script"; 
    ;;
    *) echo -e "${yellow}[INFO]${NC} Make returned unknown status: $status"; ;;
esac;



