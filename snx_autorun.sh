#!/bin/sh

[ -z "$MDEV" ] && return

echo "$(date) - $0: Running (device: $MDEV)" >> /tmp/hacks.log 2>&1

# if [ ! $(pidof telnetd >/dev/null) ]; then
#   echo "$(date) - $0: Starting telnetd" >> /tmp/hacks.log 2>&1
#   telnetd &
# else
#   echo "$(date) - $0: Telnetd already running! (PID: $(pidof telnetd))" >> /tmp/hacks.log 2>&1
# fi

if [ ! -d "/tmp/www/cgi-bin" ]; then
	mkdir -p "/tmp/www/cgi-bin";
	echo "$(date) - $0: Created /tmp/www/cgi-bin" >> /tmp/hacks.log 2>&1
fi
for i in /media/$MDEV/bootstrap/www/*; do
  echo "$i -> /tmp/www/cgi-bin/$(basename $i)"
  ln -sf "$i" "/tmp/www/cgi-bin/$(basename $i)" >> /tmp/hacks.log 2>&1
done 
