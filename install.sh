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
sign_module() {
    # clear
	echo
    while :; do
        echo -e "$yellow[INFO]$NC $yellow If you are using the security boot, you have to sign the module and import the generated certificate$NC"
        echo -e "$yellow[INFO]$NC $yellow And also make sure the openssl is installed on your machine$NC"
		read -p "$(echo -e "(Proceed to sign to module?: [${magenta}Y/N$NC]):") " auto_sign_driver
		if [[ -z "$auto_sign_driver" ]]; then
			error
		else
			if [[ "$auto_sign_driver" == [Yy] ]]; then
				echo
				echo -e "$yellow Automatical sign$NC"
				echo "----------------------------------------------------------------"
				echo          
                echo -e "$yellow[INFO]$NC Generating the cetificate..."
                openssl req -config ./openssl.cnf -new -x509 -newkey rsa:2048 -nodes -days 36500 -outform DER -keyout "my_mok.priv" -out "my_mok.der"
                echo -e "$yellow[INFO]$NC Signing the new module..."
                kmodsign sha512 my_mok.priv my_mok.der /lib/modules/$(uname -r)/kernel/drivers/net/usb/ipheth.ko
                echo -e "$yellow[INFO]$NC Importing the generated certificate..."
                echo -e "$yellow[INFO]$NC $yellow Please read this carefully:$NC"
                echo -e "$yellow[INFO]$NC Your will be prompted to set a password, and please remember this password. Once this is done, reboot. Just before loading GRUB, shim will show a blue screen (which is actually another piece of the shim project called “MokManager”). use that screen to select “Enroll MOK” and follow the menus to finish the enrolling process. You can also look at some of the properties of the key you’re trying to add, just to make sure it’s indeed the right one using “View key”. MokManager will ask you for the password we typed in earlier here; and will save the key, and we’ll reboot again.$NC"
                mokutil --import my_mok.der
                echo -e "$yellow[INFO]$NC $yellow Please keep some keywords in mind of the certificate information thus you can identify the right cetificate to be installled:$NC"
                echo -e "$yellow[INFO]$NC distinguished_name      = my_module_sign_name$NC"
                echo -e "$yellow[INFO]$NC countryName             = CA$NC"
                echo -e "$yellow[INFO]$NC stateOrProvinceName     = Alberta$NC"
                echo -e "$yellow[INFO]$NC localityName            = Calgary$NC"
                echo -e "$yellow[INFO]$NC 0.organizationName      = cyphermox$NC"
                echo -e "$yellow[INFO]$NC commonName              = Secure Boot Signing$NC"
                echo -e "$yellow[INFO]$NC emailAddress            = example@example.com$NC"
                echo -e "$yellow[INFO]$NC Done"
				break
			elif [[ "$auto_sign_driver" == [Nn] ]]; then
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
[[ $(id -u) != 0 ]] && echo -e "\n Please use ${red}sudo${NC} privilege to run it ${yellow}~(^_^) ${none}\n" && exit 1

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
       sign_module
        ;;
    1) echo -e "${yellow}[INFO]${NC} Target needs to be rebuilt"; ;;
    2) echo -e "${yellow}[INFO]${NC} Error(s) in make, please try other kernel choices or get the ${red}ipheth.c${NC} from your linux distributor"; 
       echo -e "${yellow}[INFO]${NC} Copy the ${red}ipheth.c${NC}  from your linux distributor to the patches folder and rerun the script"; 
    ;;
    *) echo -e "${yellow}[INFO]${NC} Make returned unknown status: $status"; ;;
esac;



