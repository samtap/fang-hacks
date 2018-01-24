CONFIG_PARTITION=$1

echo "boot.sh, CONFIG_PARTITION: ${CONFIG_PARTITION}"

#Transfer vg_boot.sh spec.cfg param.cfg from master to slave site (/mnt/data)
boot_actor=single

/sbin/modprobe frammap.ko
cat /proc/frammap/ddr_info

ft_mode=`cat /tmp/ft_mode`

# for get pci_epcnt/cpu_enum
# pci_epcnt = n, the GM8210_EP count.
# cpu_enum = 0(host_fa726), 1(host_fa626), 2(host_7500), 3(dev_fa726), 4(dev_fa626)

if [ "$boot_actor" == "master" ] ; then
    pci_epcnt=`grep -A 3 'pci_epcnt' /proc/pmu/attribute | grep 'Attribute value' | cut -c 18`
    cpu_enum=`grep -A 3 'cpu_enum' /proc/pmu/attribute | grep 'Attribute value' | cut -c 18`
    echo "cpu_enum=$cpu_enum, pci_epcnt=$pci_epcnt"
    /sbin/modprobe cpu_comm_fa726.ko
    mdev -s
    echo ""
    read -t 2 -p "   Press q -> ENTER to exit boot procedure? " exit_boot
    if [ "$exit_boot" == "q" ] ; then
        echo "0" > /tmp/transfer_number
        cpucomm_file -c /dev/cpucomm_FA626_chan0 -f /tmp/transfer_number -w
        if [ "$pci_epcnt" == "1" ] ; then
            cpucomm_file -c /dev/cpucomm_DEV0_FA626_chan0 -f /tmp/transfer_number -w
        fi
        exit
    fi

    if [ -e ${CONFIG_PARTITION}/vg_boot.sh ] ; then
        echo "1" > /tmp/transfer_number
        cpucomm_file -c /dev/cpucomm_FA626_chan0 -f /tmp/transfer_number -w
        cpucomm_file -c /dev/cpucomm_FA626_chan0 -f ${CONFIG_PARTITION}/vg_boot.sh -w
    fi

    if [ -e ${CONFIG_PARTITION}/gmlib.cfg ] ; then
        echo "1" > /tmp/transfer_number
        cpucomm_file -c /dev/cpucomm_FA626_chan0 -f /tmp/transfer_number -w
        cpucomm_file -c /dev/cpucomm_FA626_chan0 -f ${CONFIG_PARTITION}/gmlib.cfg -w
    fi

    if [ -e ${CONFIG_PARTITION}/param.cfg ] ; then
        echo "1" > /tmp/transfer_number
        cpucomm_file -c /dev/cpucomm_FA626_chan0 -f /tmp/transfer_number -w
        cpucomm_file -c /dev/cpucomm_FA626_chan0 -f ${CONFIG_PARTITION}/param.cfg -w
    fi

    if [ -e ${CONFIG_PARTITION}/spec.cfg ] ; then
        echo "1" > /tmp/transfer_number
        cpucomm_file -c /dev/cpucomm_FA626_chan0 -f /tmp/transfer_number -w
        cpucomm_file -c /dev/cpucomm_FA626_chan0 -f ${CONFIG_PARTITION}/spec.cfg -w
    fi

    echo "0" > /tmp/transfer_number
    cpucomm_file -c /dev/cpucomm_FA626_chan0 -f /tmp/transfer_number -w

    if [ "$pci_epcnt" == "1" ] ; then
        if [ -e ${CONFIG_PARTITION}/vg_boot.sh ] ; then
            echo "1" > /tmp/transfer_number
            cpucomm_file -c /dev/cpucomm_DEV0_FA626_chan0 -f /tmp/transfer_number -w
            cpucomm_file -c /dev/cpucomm_DEV0_FA626_chan0 -f ${CONFIG_PARTITION}/vg_boot.sh -w
        fi
    
        if [ -e ${CONFIG_PARTITION}/gmlib.cfg ] ; then
            echo "1" > /tmp/transfer_number
            cpucomm_file -c /dev/cpucomm_DEV0_FA626_chan0 -f /tmp/transfer_number -w
            cpucomm_file -c /dev/cpucomm_DEV0_FA626_chan0 -f ${CONFIG_PARTITION}/gmlib.cfg -w
        fi

        if [ -e ${CONFIG_PARTITION}/param.cfg ] ; then
            echo "1" > /tmp/transfer_number
            cpucomm_file -c /dev/cpucomm_DEV0_FA626_chan0 -f /tmp/transfer_number -w
            cpucomm_file -c /dev/cpucomm_DEV0_FA626_chan0 -f ${CONFIG_PARTITION}/param.cfg -w
        fi
    
        if [ -e ${CONFIG_PARTITION}/spec.cfg ] ; then
            echo "1" > /tmp/transfer_number
            cpucomm_file -c /dev/cpucomm_DEV0_FA626_chan0 -f /tmp/transfer_number -w
            cpucomm_file -c /dev/cpucomm_DEV0_FA626_chan0 -f ${CONFIG_PARTITION}/spec.cfg -w
        fi
    
        echo "0" > /tmp/transfer_number
        cpucomm_file -c /dev/cpucomm_DEV0_FA626_chan0 -f /tmp/transfer_number -w
    fi

elif [ "$boot_actor" == "slave" ] ; then
    pci_epcnt=`grep -A 3 'pci_epcnt' /proc/pmu/attribute | grep 'Attribute value' | cut -c 18`
    cpu_enum=`grep -A 3 'cpu_enum' /proc/pmu/attribute | grep 'Attribute value' | cut -c 18`
    echo "cpu_enum=$cpu_enum, pci_epcnt=$pci_epcnt"
    /sbin/modprobe cpu_comm_fa626.ko
    mdev -s
    if [ "$cpu_enum" == "1" ] ; then
        cd ${CONFIG_PARTITION}
        cpucomm_file -c /dev/cpucomm_FA726_chan0  -r
    
        transfer_number=`cat /tmp/transfer_number`
        while [ "$transfer_number" == "1" ]
        do
            echo do next
            cpucomm_file -c /dev/cpucomm_FA726_chan0 -r
            cpucomm_file -c /dev/cpucomm_FA726_chan0 -r
            transfer_number=`cat /tmp/transfer_number`
        done
        sed -i 's/cpu_actor=master/cpu_actor=slave/' ${CONFIG_PARTITION}/vg_boot.sh
    elif [ "$cpu_enum" == "4" ] ; then
        cd ${CONFIG_PARTITION}
        cpucomm_file -c /dev/cpucomm_HOST_FA726_chan0  -r
    
        transfer_number=`cat /tmp/transfer_number`
        while [ "$transfer_number" == "1" ]
        do
            echo do next
            cpucomm_file -c /dev/cpucomm_HOST_FA726_chan0 -r
            cpucomm_file -c /dev/cpucomm_HOST_FA726_chan0 -r
            transfer_number=`cat /tmp/transfer_number`
        done
        sed -i 's/cpu_actor=master/cpu_actor=slave_ep/' ${CONFIG_PARTITION}/vg_boot.sh
    fi    
else
                if [ "$ft_mode" == "1" ] || [ "$ft_mode" == "2" ] ; then
                        echo "ft mode, no exit boot"
                else
            echo "remove boot exit select for speed up"
#           read -t 2 -p "   Press q -> ENTER to exit boot procedure? " exit_boot
#           if [ "$exit_boot" == "q" ] ; then
#               exit
#           fi
          fi
fi

if [ "$ft_mode" == "1" ] || [ "$ft_mode" == "2" ] ; then
echo "ft boot"
sd_ft_dir=/tmp/sd/ft
data_ft_dir=/mnt/data/ft
if [ -d $sd_ft_dir ];then
        ft_dir=$sd_ft_dir
else
        ft_dir=$data_ft_dir
fi
sh $ft_dir/ft_boot.sh ${CONFIG_PARTITION} ${ft_mode} ${ft_dir}
else
echo "vg boot"
sh ${CONFIG_PARTITION}/vg_boot.sh ${CONFIG_PARTITION}
fi
