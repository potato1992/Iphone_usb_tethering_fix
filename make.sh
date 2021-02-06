ver=$(uname -r)          # get kernel release version
ver_num="${ver%.*-*}"        # remove suffix starting with '.' and containing '-'

array=(`echo $ver_num | tr '.' ' '` ) 
let ver_num=${array[0]}*1000+${array[1]}

#version 5.0 as the division line
ver_div=5000

FILE=./ipheth.c
if test -f "$FILE"; then
    echo "[INFO] $FILE exists, goto make directly"
else
    echo "[INFO] Copying patch file..."
    if [ $ver_num -gt $ver_div ]
    then 
        echo "[INFO] Kernel version $ver, using the patch 5.3.0"
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



