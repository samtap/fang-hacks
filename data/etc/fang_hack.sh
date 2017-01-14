#!/bin/sh

# If set to 0, only the original telnetd is started
# If set to 1, all hacks are applied
HACKS_ENABLED=1
HACKS_HOME=/media/mmcblk0p1/hacks

# Override timezone (using some kind of offset, i.e for GMT+1, use GMT-1 to get the correct time)
TZ="GMT-1"

#####################################################

function file_exists() {
    type -f "$1" >/dev/null 2>&1
}

function do_patch() {
    if [ ! -d "$0" ]; then
        echo "do_patch: \"$0\" must be a directory!"
    fi

    if [ ! -f "$1" ]; then
        echo "do_patch: \"$1\" must be a patch file!"
    fi

    old_cwd=`pwd`
    cd "$0"
    patch -p0 $1
    cd "$old_cwd"
}


if [ $HACKS_ENABLED -ne 1 ]; then
    echo "Fang hacks disabled!"

    # todo: Revert firstrun patches?
    rm /etc/firstrun_complete >/dev/null 2>&1

    echo "Starting telnetd..."
    telnetd &
    return 0
fi

if [ ! -f /etc/firstrun_complete -o "$1" == "firstrun" ]; then
    echo "Fang hacks - Applying..."

    if [ ! -d "/media/mmcblk0p1" ]; then
	mkdir "/media/mmcblk0p1"
    fi
    mount /dev/mmcblk0p1 /media/mmcblk0p1


    if [ ! -d "$HACKS_HOME" -o ! -f "$HACKS_HOME/etc/profile" ]; then
	echo "Failed to find hacks in $HACKS_HOME!"
	return 1
    else
        source "$HACKS_HOME/etc/profile"
        HACKS_PROFILE_SET=1
    fi
  
    if [ ! file_exists patch ]; then
	echo "Patch not found!"
	return 1
    fi

    # Patch sdcard hotplug to automatically mount ext2 volumes 
    do_patch "/etc/hotplug" "$HACKS_HOME/etc/patches/firstrun/hotplug.patch"

    # Set TZ
    if [ -n "$TZ" ]; then
	echo "Current time: `date`"
	echo "Set TZ to $TZ"
	echo "$TZ" > /etc/TZ
	echo "Updated time: `date`"
    fi

    touch /etc/firstrun_complete
fi

if [ ! -d "$HACKS_HOME" ]; then
    echo "XiaoFang hacks not found in $HACKS_HOME!"
    return 1
fi

if [ -n "$HACKS_PROFILE_SET" ]; # already set during firstrun
    source "$HACKS_HOME/etc/profile"
fi

# todo: Apply patches in $HACKS_HOME/etc/patches?

run-parts "$HACKS_HOME/etc/scripts"
