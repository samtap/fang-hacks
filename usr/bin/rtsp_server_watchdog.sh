#!/bin/sh

RTSP_PIDFILE=$1
SLEEP=10
echo "RSTP server watchdog started"

echo "RTSP_PIDFILE=${RTSP_PIDFILE}"

while true
do
  pid="$(cat "$RTSP_PIDFILE" 2>/dev/null)"
  if [ "$pid" ]; then
    kill -0 "$pid" >/dev/null && echo "RTSP server is up and running. PID: $pid" || (
      echo "Restarting RTSP server..."
      /media/mmcblk0p2/data/etc/scripts/20-rtsp-server start
    )
  fi

  echo "Waiting for ${SLEEP} seconds..."
  sleep $SLEEP
done
