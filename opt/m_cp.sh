#!/bin/sh
DIR=/media/mmcblk0p2/data/opt/snaps;
mkdir -p $DIR >/dev/null 2>&1;
cd $DIR;
ls -A1t  | sed -e '1,1000d' | xargs rm >/dev/null 2>&1;
cp /tmp/www/snapshot.jpg $(date +"%Y%m%d_%H%M%S").jpg


