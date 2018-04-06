#!/bin/sh

echo "RTSP Watchdog script started"

while :
do
        sleep 10
        if pgrep -x "snx_rtsp_server" > /dev/null
        then
               echo "RTSP ON"
        else
               echo "RTSP OFF"
               /media/mmcblk0p2/data/etc/scripts/20-rtsp-server start > /dev/null
        fi
done
