#!/bin/sh

HACKS_ENABLED=1
HACKS_HOME=/media/mmcblk0p2/data

#####################################################

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
fi

if [ $HACKS_ENABLED -ne 1 ]; then
   return 0
fi

if [ ! -d "$HACKS_HOME" -o ! -f "$HACKS_HOME/etc/profile" ]; then
  logmsg "Failed to find hacks in $HACKS_HOME!"

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
  do_resize && rm /etc/.resize_runonce
fi
  
if [ -f "$HACKS_HOME/etc/profile" ]; then
  source "$HACKS_HOME/etc/profile" >/dev/null
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

