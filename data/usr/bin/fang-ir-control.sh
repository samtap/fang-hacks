#!/bin/sh

echo "IR script started"
# ir_init
gpio_ms1 -n 2 -m 1 -v 1
gpio_aud write 1 1 0
gpio_aud write 0 2 1
gpio_aud write 1 0 0

sleep 3

# ir loop
IR_ON=0

while :
do
        DAY="$(gpio_aud read 2)"
        if [ $DAY -eq 1 ]
        then
                if [ $IR_ON -eq 1 ]
                then
                        gpio_ms1 -n 2 -m 1 -v 1
                        gpio_aud write 1 0 0
                        echo 0x40 > /proc/isp/filter/saturation
                        IR_ON=0
                fi
        else
                if [ $IR_ON -eq 0 ]
                then
                       echo 0x0 > /proc/isp/filter/saturation
                        gpio_aud write 1 0 1
                        gpio_ms1 -n 2 -m 1 -v 0
                        IR_ON=1
                fi
        fi
        sleep 3
done
