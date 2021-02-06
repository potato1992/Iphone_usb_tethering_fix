ver=$(uname -r)          # get kernel release version
ver_num="${ver%.*-*}"        # remove suffix starting with '.' and containing '-'
ver_num="${ver_num//.}"          # remove periods (a single `/` would do here)

kernel_version=`uname -a|awk '{print $3}'`

ver_div=50

FILE=./ipheth.c
if test -f "$FILE"; then
    echo "[INFO] $FILE exists, goto make directly"
else
    echo "[INFO] Copying patch file..."
        if [ $ver_num -gt $ver_div ]
    then 
        echo "[INFO] Kernel version $ver, using the patch 5.4.0"
        cp ./patchs/ipheth_5.3.0.c ipheth.c
    else
        echo "[INFO] Kernel version $ver, using the patch 4.9.y"
        cp ./patchs/ipheth_4.9.y.c ipheth.c
    fi
fi
echo ''
make
status=$?;
echo ''
case "$status" in
    0) echo '[INFO] All makefiles passed'; ;;
    1) echo '[INFO] Target needs to be rebuilt'; ;;
    2) echo '[INFO] Error(s) in make, please get your own ipheth.c'; ;;
    *) echo "[INFO] Make returned unknown status: $status"; ;;
esac;



