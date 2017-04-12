#!/bin/sh



./ffmpeg -i rtsp://localhost/unicast -c copy -hls_time 10 -hls_list_size 0 /media/mmcblk0p2/data/storage/stream.m3u8


