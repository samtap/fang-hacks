#!/bin/sh

source "/etc/fang_hacks.cfg"
HACKS_ENABLED=${HACKS_ENABLED:-1}
HACKS_HOME=${HACKS_HOME:-/media/mmcblk0p2/data}

logmsg()
{
  echo "$(date) - $0: $1" >> /tmp/hacks.log
  echo "$1"
}

do_patch()
{
  if [ ! -d "$1" ]; then
    logmsg "do_patch: \"$1\" must be a directory!"
    return 1
  fi

  if [ ! -f "$2" ]; then
    logmsg "do_patch: \"$2\" must be a patch file!"
    return 1
  fi

  old_cwd=$(pwd)
  cd "$1"
  patch < "$2"
  rc=$?
  cd "$old_cwd"
  return $rc
}

do_resize()
{
  logmsg "Resizing /dev/mmcblk0p2"
  mount /dev/mmcblk0p1 /media/mmcblk0p1 >/dev/null 2>&1
  umount /dev/mmcblk0p2 >/dev/null 2>&1
  resize2fs="/media/mmcblk0p1/bootstrap/resize2fs"
  e2fsck="/media/mmcblk0p1/bootstrap/e2fsck"
  rc=0
  if [ -x "$resize2fs" ]; then
    $resize2fs -f /dev/mmcblk0p2 >/tmp/hacks.log 2>&1
    rc=$?
  else
    echo "resize2fs not found!"
    rc=1
  fi

  mount /dev/mmcblk0p2 /media/mmcblk0p2 >/dev/null 2>&1
  if [ -e "$HACKS_HOME/.resize" ]; then
    rm "$HACKS_HOME/.resize"
  fi
  return $rc
}

# Remove stale log
if [ -f /tmp/hacks.log ]; then
  rm /tmp/hacks.log
  logmsg "Removed stale logfile"
fi

logmsg "Executing script (enabled: $HACKS_ENABLED)"

if [ "$DISABLE_CLOUD" -eq 0 ]; then
  # Wait for cloud apps to start
  OS_MAJOR="$(cat /etc/os-release | cut -d'=' -f2 | cut -d'.' -f1)"
  logmsg "Waiting for cloud apps..."
  count=0
  while [ $count -lt 30 ]; do
    if [ "$OS_MAJOR" -eq 3 ]; then
      if pidof iCamera >/dev/null; then logmsg "iCamera is running!"; break; fi
    elif [ "$OS_MAJOR" -eq 2 ]; then
      if pidof iSC3S >/dev/null; then logmsg "iSC3S is running!"; break; fi
    else 
      logmsg "Unsupported OS version $(cat /etc/os-release)"; break;
    fi
    count=$(expr $count + 1)
    sleep 1
  done
  if [ $count -eq 30 ]; then logmsg "Failed to wait for cloud apps!"; fi

  # Wait for boa webserver
  count=0
  while [ $count -lt 30 ]; do
    if pidof boa >/dev/null; then logmsg "Boa webserver is running!"; break; fi
    count=$(expr $count + 1)
    sleep 1
  done

  if ! pidof boa >/dev/null; then
    # Something is wrong, perhaps cloud apps can't connect to wifi?
    # Start boa manually so cgi scripts can provide recovery options
    logmsg "Starting boa webserver..."
    # Copy to /tmp as a workaround for weird boa error (can't open boa.conf)
    cp /usr/boa/* /tmp
    /tmp/boa >/dev/null 2>&1
  fi

else
  # Cloud disabled
  logmsg "Cloud apps are disabled"
  if [ ! -d /media/mmcblk0p1 ]; then mkdir /media/mmcblk0p1; fi
  logmsg "Mounting /media/mmcblk0p1"
  mount /dev/mmcblk0p1 /media/mmcblk0p1
  logmsg "Starting boa webserver..."
  # Copy to /tmp as a workaround for weird boa error (can't open boa.conf)
  cp /usr/boa/* /tmp
  /tmp/boa >/dev/null 2>&1
fi

# Link cgi files again if available (/tmp is volatile)
CGI_FILES="/media/mmcblk0p1/bootstrap/www"
if [ -d "$CGI_FILES" ]; then
  for i in $CGI_FILES/*; do
    if [ ! -e "/tmp/www/cgi-bin/$(basename $i)" ]; then
      logmsg "Linking $i -> /tmp/www/cgi-bin/$(basename $i)"
      ln -sf "$i" "/tmp/www/cgi-bin/$(basename $i)"
    else
      logmsg "Not linking $i: already exists"
    fi
  done
else
  logmsg "CGI scripts not found in $CGI_FILES!"
fi

if [ $HACKS_ENABLED -ne 1 ]; then
   return 0
fi

if [ ! -d "$HACKS_HOME" -o ! -f "$HACKS_HOME/etc/profile" ]; then
  logmsg "Failed to find hacks in $HACKS_HOME!"

  # Maybe the hotplug is slow... 
  # Check resize flag so we can do that first before mounting it manually
  if [ -e /etc/.resize_runonce ]; then
   do_resize && rm /etc/.resize_runonce
  fi

  mount /dev/mmcblk0p2 /media/mmcblk0p2 >> /tmp/hacks.log 2>&1
  if [ ! -d "$HACKS_HOME" -o ! -f "$HACKS_HOME/etc/profile" ]; then
    logmsg "Failed to find $HACKS_HOME!"
    return 1
  else
    logmsg "Mounted $HACKS_HOME"
  fi
elif [ -e /etc/.resize_runonce ]; then
  # Auto-mounted, but may need to be resized
  do_resize && rm /etc/.resize_runonce
fi
  
if [ -f "$HACKS_HOME/etc/profile" ]; then
  source "$HACKS_HOME/etc/profile" >/dev/null
fi

# Configuration files are located on vfat to allow off-line editing in any OS.
# Note: originals are removed or they would overwrite any changes made in the webif,
# each time the script runs!
for i in wpa_supplicant.conf hostapd.conf udhcpd.conf; do
  src="/media/mmcblk0p1/bootstrap/$i"
  tgt="/media/mmcblk0p2/data/etc/$i"
  if [ -e "/media/mmcblk0p1/bootstrap/$i" ]; then
    logmsg "Moving $i -> $tgt"
    mv "$src" "$tgt"
  fi
done

src="/media/mmcblk0p1/bootstrap/fang_hacks_rescue.cfg"
tgt="/etc/fang_hacks.cfg"
if [ -e "$src" ]; then
  logmsg "Overwriting configuration file $src -> $tgt"
  mv "$src" "$tgt"
fi

if ! type patch >/dev/null; then
  logmsg "Patch command not found! Patches will not be applied."
else
  # todo: apply patches?
  true
fi

logmsg "Running startup scripts"
run-parts "$HACKS_HOME/etc/scripts"
logmsg "Finished"

