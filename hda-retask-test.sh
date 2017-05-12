#!/bin/bash

current_nid=2
current_dev=5
current_pin=36

stop_nid=18
stop_dev=32

success=0

write_codec(){    
    echo "[codec]" > /lib/firmware/hda-jack-retask.fw
    echo -e "0x10138409 0x106b3300 0\n" >> /lib/firmware/hda-jack-retask.fw
}

write_pincfg(){
    echo "[pincfg]" >> /lib/firmware/hda-jack-retask.fw

    for((i = 0; i < $current_nid - 2; i++)) ; do
	(( tmp = 36 + $i ))
	printf "0x%x 0x400000f0\n" $tmp >> /lib/firmware/hda-jack-retask.fw
    done

    (( tmp = 36 + $i ))
    printf "0x%x 0x10214010\n" $tmp >> /lib/firmware/hda-jack-retask.fw
    (( i++ ))

    (( tmp = 36 + $i ))
    printf "0x%x 0x83100110\n" $tmp >> /lib/firmware/hda-jack-retask.fw
    (( i++ ))

    (( tmp = 36 + $i ))
    printf "0x%x 0x84100110\n" $tmp >> /lib/firmware/hda-jack-retask.fw
    (( i++ ))
    
    for((; i < $stop_nid; i++)) ; do
	(( tmp = 36 + $i ))
	printf "0x%x 0x400000f0\n" $tmp >> /lib/firmware/hda-jack-retask.fw
    done

    printf "\n" >> /lib/firmware/hda-jack-retask.fw
}

write_verb(){
    local nid=$current_nid
    local dev=$current_dev
    local pin=$current_pin
    
    echo "[verb]" >> /lib/firmware/hda-jack-retask.fw
    printf "0x01 0x705 0x00\n" >> /lib/firmware/hda-jack-retask.fw
    printf "0x01 0x716 0xff\n" >> /lib/firmware/hda-jack-retask.fw
    printf "0x01 0x717 0xff\n" >> /lib/firmware/hda-jack-retask.fw
    printf "0x01 0x718 0xff\n" >> /lib/firmware/hda-jack-retask.fw

    printf "0x24 0x71c 0x0\n" >> /lib/firmware/hda-jack-retask.fw
    printf "0x24 0x71d 0x0\n" >> /lib/firmware/hda-jack-retask.fw
    printf "0x24 0x71e 0x0\n" >> /lib/firmware/hda-jack-retask.fw
    printf "0x24 0x71f 0x0\n" >> /lib/firmware/hda-jack-retask.fw
    printf "0x25 0x71c 0x0\n" >> /lib/firmware/hda-jack-retask.fw
    printf "0x25 0x71d 0x0\n" >> /lib/firmware/hda-jack-retask.fw
    printf "0x25 0x71e 0x0\n" >> /lib/firmware/hda-jack-retask.fw
    printf "0x25 0x71f 0x0\n" >> /lib/firmware/hda-jack-retask.fw

    # 2, 3, 705, 706, 708
    printf "0x%02x 0x2 0x4011\n" $nid >> /lib/firmware/hda-jack-retask.fw    
    printf "0x%02x 0x3 0x1\n" $nid >> /lib/firmware/hda-jack-retask.fw    
    printf "0x%02x 0x705 0x0\n" $nid >> /lib/firmware/hda-jack-retask.fw
    printf "0x%02x 0x706 0x10\n" $nid >> /lib/firmware/hda-jack-retask.fw
    printf "0x%02x 0x708 0x80\n" $nid >> /lib/firmware/hda-jack-retask.fw

    # 707, 708, 709
    printf "0x%02x 0x707 0x85\n" $pin >> /lib/firmware/hda-jack-retask.fw
    printf "0x%02x 0x708 0x80\n" $nid >> /lib/firmware/hda-jack-retask.fw
    printf "0x%02x 0x709 0x0\n" $nid >> /lib/firmware/hda-jack-retask.fw
    # EAPD/BTL enable
    #    printf "0x%02x 0x70c 0x1\n" $pin >> /lib/firmware/hda-jack-retask.fw
    printf "0x%02x 0x71c 0x0\n" $pin >> /lib/firmware/hda-jack-retask.fw
    printf "0x%02x 0x71d 0x0\n" $pin >> /lib/firmware/hda-jack-retask.fw
    printf "0x%02x 0x71e 0x0\n" $pin >> /lib/firmware/hda-jack-retask.fw
    printf "0x%02x 0x71f 0x0\n" $pin >> /lib/firmware/hda-jack-retask.fw

    (( nid++ ))
    (( dev++ ))
    (( pin++ ))
    
    printf "0x%02x 0x2 0x4011\n" $nid >> /lib/firmware/hda-jack-retask.fw
    printf "0x%02x 0x3 0x1\n" $nid >> /lib/firmware/hda-jack-retask.fw    
    printf "0x%02x 0x705 0x0\n" $nid >> /lib/firmware/hda-jack-retask.fw
    printf "0x%02x 0x706 0x10\n" $nid >> /lib/firmware/hda-jack-retask.fw
    
    printf "0x%02x 0x707 0x45\n" $pin >> /lib/firmware/hda-jack-retask.fw
    printf "0x%02x 0x708 0x80\n" $nid >> /lib/firmware/hda-jack-retask.fw
    # EAPD/BTL enable
    #    printf "0x%02x 0x70c 0x1\n" $pin >> /lib/firmware/hda-jack-retask.fw
    printf "0x%02x 0x71c 0x10\n" $pin >> /lib/firmware/hda-jack-retask.fw
    printf "0x%02x 0x71d 0x0\n" $pin >> /lib/firmware/hda-jack-retask.fw
    printf "0x%02x 0x71e 0x17\n" $pin >> /lib/firmware/hda-jack-retask.fw
    printf "0x%02x 0x71f 0x44\n" $pin >> /lib/firmware/hda-jack-retask.fw

    (( nid++ ))
    (( dev++ ))
    (( pin++ ))
    
    printf "0x%02x 0x2 0x4011\n" $nid >> /lib/firmware/hda-jack-retask.fw
    printf "0x%02x 0x3 0x1\n" $nid >> /lib/firmware/hda-jack-retask.fw    
    printf "0x%02x 0x705 0x00\n" $nid >> /lib/firmware/hda-jack-retask.fw
    printf "0x%02x 0x706 0x11\n" $nid >> /lib/firmware/hda-jack-retask.fw

    printf "0x%02x 0x707 0x45\n" $pin >> /lib/firmware/hda-jack-retask.fw
    printf "0x%02x 0x708 0x80\n" $nid >> /lib/firmware/hda-jack-retask.fw
    # EAPD/BTL enable
    #    printf "0x%02x 0x70c 0x1\n" $pin >> /lib/firmware/hda-jack-retask.fw
    printf "0x%02x 0x71c 0x10\n" $pin >> /lib/firmware/hda-jack-retask.fw
    printf "0x%02x 0x71d 0x0\n" $pin >> /lib/firmware/hda-jack-retask.fw
    printf "0x%02x 0x71e 0x17\n" $pin >> /lib/firmware/hda-jack-retask.fw
    printf "0x%02x 0x71f 0x43\n" $pin >> /lib/firmware/hda-jack-retask.fw
}

current_nid=`cat /root/nid`
current_dev=`cat /root/dev`
current_pin=`cat /root/pin`


write_codec
write_pincfg
write_verb

(( current_nid = $current_nid + 1 ))
(( current_pin = $current_pin + 1 ))

echo "$current_nid" > /root/nid
echo "$current_dev" > /root/dev
echo "$current_pin" > /root/pin

echo "===============" >> /root/log
dmesg | grep snd >> /root/log
printf "\n\n\n" >> /root/log
amixer scontrols >> /root/log
echo "===============" >> /root/log

echo "===============" >> /root/biglog
echo "$current_nid:$current_pin" >> /root/biglog
printf "\n\n\n" >> /root/biglog
cat "/proc/asound/card0/codec#0" >> /root/biglog
echo "===============" >> /root/log

if [ "$current_nid" -lt "$stop_nid" ]
then
   reboot    
fi
