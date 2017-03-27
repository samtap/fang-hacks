#!/bin/sh

echo "IR script started"
# ir_init
#gpio_ms1 -n 2 -m 1 -v 1 # this causes increased current flow
gpio_ms1 -n 2 -m 1 -v 0 # has something to do with the ir-cut/pass filter movement
gpio_aud write 1 1 0    # pin 1 is an output and is set to low, purpose unknown
gpio_aud write 0 2 1    # pin 2 is an input, the photoresistor
gpio_aud write 1 0 0    # pin 0 is an output and set to low, these are the ir-leds

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
                        gpio_ms1 -n 2 -m 1 -v 1 # filter movement enabled
                        gpio_aud write 1 0 0    # disable ir led and latch the filter in the correct position
                        gpio_ms1 -n 2 -m 1 -v 0 # filter movement disabled
                        echo 0x40 > /proc/isp/filter/saturation
                        IR_ON=0
                fi
        else
                if [ $IR_ON -eq 0 ]
                then
                       echo 0x0 > /proc/isp/filter/saturation
                        gpio_ms1 -n 2 -m 1 -v 0 # filter movement enabled
                        gpio_aud write 1 0 1    # enable ir led and latch the filter in the correct position
                        gpio_ms1 -n 2 -m 1 -v 1 # filter movement disabled
                        IR_ON=1
                fi
        fi
        sleep 3
done
