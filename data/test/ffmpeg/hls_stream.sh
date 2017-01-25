#!/bin/sh

./ffmpeg -i rtsp://localhost/unicast -c copy -hls_time 10 -hls_list_size 6 -hls_wrap 10 -start_number 1 /tmp/www/hls/stream.m3u8
