#!/bin/bash

current_nid=2
current_dev=5
current_pin=36

current_gpio=0

stop_nid=17

enable_hp=1
enable_speaker_left=0
enable_speaker_right=0

pci_match="1f.3"
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

    if [ $enable_hp ] ;
    then
	(( tmp = 36 + $i ))
	printf "0x%x 0x002b4020\n" $tmp >> /lib/firmware/hda-jack-retask.fw
	(( i++ ))
    fi
    
    if [ $enable_speaker_left ] ;
    then
	(( tmp = 36 + $i ))
	printf "0x%x 0x90100110\n" $tmp >> /lib/firmware/hda-jack-retask.fw
	(( i++ ))
    fi
    
    if [ $enable_speaker_right ] ;
    then
	(( tmp = 36 + $i ))
	printf "0x%x 0x90100111\n" $tmp >> /lib/firmware/hda-jack-retask.fw
	(( i++ ))
    fi
    
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
    # power state D0 
    printf "0x01 0x705 0x00\n" >> /lib/firmware/hda-jack-retask.fw
    # gpio
    printf "0x01 0x714 0x%02x\n" $current_gpio >> /lib/firmware/hda-jack-retask.fw
    printf "0x01 0x715 0x%02x\n" $current_gpio >> /lib/firmware/hda-jack-retask.fw
    printf "0x01 0x716 0x%02x\n" $current_gpio >> /lib/firmware/hda-jack-retask.fw
    printf "0x01 0x717 0x%02x\n" $current_gpio >> /lib/firmware/hda-jack-retask.fw
    printf "0x01 0x718 0x%02x\n" $current_gpio >> /lib/firmware/hda-jack-retask.fw
    # enable processing
    printf "0x01 0x786 0x1\n" >> /lib/firmware/hda-jack-retask.fw
 
    # disable default speaker
    printf "0x24 0x71c 0x0\n" >> /lib/firmware/hda-jack-retask.fw
    printf "0x24 0x71d 0x0\n" >> /lib/firmware/hda-jack-retask.fw
    printf "0x24 0x71e 0x0\n" >> /lib/firmware/hda-jack-retask.fw
    printf "0x24 0x71f 0x0\n" >> /lib/firmware/hda-jack-retask.fw

    # disable default speaker
    printf "0x25 0x71c 0x0\n" >> /lib/firmware/hda-jack-retask.fw
    printf "0x25 0x71d 0x0\n" >> /lib/firmware/hda-jack-retask.fw
    printf "0x25 0x71e 0x0\n" >> /lib/firmware/hda-jack-retask.fw
    printf "0x25 0x71f 0x0\n" >> /lib/firmware/hda-jack-retask.fw

    # disable default hp
    printf "0x2c 0x71c 0x0\n" >> /lib/firmware/hda-jack-retask.fw
    printf "0x2c 0x71d 0x0\n" >> /lib/firmware/hda-jack-retask.fw
    printf "0x2c 0x71e 0x0\n" >> /lib/firmware/hda-jack-retask.fw
    printf "0x2c 0x71f 0x0\n" >> /lib/firmware/hda-jack-retask.fw

    if [ $enable_hp ]
    then
	# 2, 3, 705, 706, 708
	printf "0x%02x 0x705 0x0\n" $nid >> /lib/firmware/hda-jack-retask.fw
	printf "0x%02x 0x3 0xa030\n" $nid >> /lib/firmware/hda-jack-retask.fw    
	printf "0x%02x 0x706 0x10\n" $nid >> /lib/firmware/hda-jack-retask.fw
	printf "0x%02x 0x708 0x80\n" $nid >> /lib/firmware/hda-jack-retask.fw
	printf "0x%02x 0x773 0x0\n" $nid >> /lib/firmware/hda-jack-retask.fw

	# 707, 708, 709
	printf "0x%02x 0x705 0x00\n" $pin >> /lib/firmware/hda-jack-retask.fw
	printf "0x%02x 0x707 0x85\n" $pin >> /lib/firmware/hda-jack-retask.fw
	printf "0x%02x 0x70c 0x2\n" $pin >> /lib/firmware/hda-jack-retask.fw
	printf "0x%02x 0x708 0x80\n" $pin >> /lib/firmware/hda-jack-retask.fw
	printf "0x%02x 0x709 0x0\n" $pin >> /lib/firmware/hda-jack-retask.fw
	# EAPD/BTL enable
	printf "0x%02x 0x70c 0x2\n" $pin >> /lib/firmware/hda-jack-retask.fw
	printf "0x%02x 0x71c 0x0\n" $pin >> /lib/firmware/hda-jack-retask.fw
	printf "0x%02x 0x71d 0x0\n" $pin >> /lib/firmware/hda-jack-retask.fw
	printf "0x%02x 0x71e 0x0\n" $pin >> /lib/firmware/hda-jack-retask.fw
	printf "0x%02x 0x71f 0x0\n" $pin >> /lib/firmware/hda-jack-retask.fw

	printf "0x%02x 0x724 0x3\n" $nid >> /lib/firmware/hda-jack-retask.fw

	printf "0x%02x 0x2 0x4011\n" $nid >> /lib/firmware/hda-jack-retask.fw    

	(( nid++ ))
	(( dev++ ))
	(( pin++ ))
    fi
    
    if [ $enable_speaker_left ]
    then
	printf "0x%02x 0x705 0x0\n" $nid >> /lib/firmware/hda-jack-retask.fw
	printf "0x%02x 0x3 0xa030\n" $nid >> /lib/firmware/hda-jack-retask.fw    
	printf "0x%02x 0x706 0x10\n" $nid >> /lib/firmware/hda-jack-retask.fw
	printf "0x%02x 0x70c 0x2\n" $nid >> /lib/firmware/hda-jack-retask.fw
	printf "0x%02x 0x773 0x0\n" $nid >> /lib/firmware/hda-jack-retask.fw

	printf "0x%02x 0x705 0x00\n" $pin >> /lib/firmware/hda-jack-retask.fw
	printf "0x%02x 0x707 0x45\n" $pin >> /lib/firmware/hda-jack-retask.fw
	printf "0x%02x 0x708 0x80\n" $pin >> /lib/firmware/hda-jack-retask.fw
	# EAPD/BTL enable
	printf "0x%02x 0x70c 0x2\n" $pin >> /lib/firmware/hda-jack-retask.fw
	printf "0x%02x 0x71c 0x10\n" $pin >> /lib/firmware/hda-jack-retask.fw
	printf "0x%02x 0x71d 0x0\n" $pin >> /lib/firmware/hda-jack-retask.fw
	printf "0x%02x 0x71e 0x17\n" $pin >> /lib/firmware/hda-jack-retask.fw
	printf "0x%02x 0x71f 0x43\n" $pin >> /lib/firmware/hda-jack-retask.fw

	printf "0x%02x 0x724 0x3\n" $nid >> /lib/firmware/hda-jack-retask.fw

	printf "0x%02x 0x2 0x4011\n" $nid >> /lib/firmware/hda-jack-retask.fw

	(( nid++ ))
	(( dev++ ))
	(( pin++ ))
    fi
    
    if [ $enable_speaker_right ]
    then
	printf "0x%02x 0x705 0x00\n" $nid >> /lib/firmware/hda-jack-retask.fw
	printf "0x%02x 0x3 0xa030\n" $nid >> /lib/firmware/hda-jack-retask.fw    
	printf "0x%02x 0x706 0x11\n" $nid >> /lib/firmware/hda-jack-retask.fw
	printf "0x%02x 0x70c 0x2\n" $nid >> /lib/firmware/hda-jack-retask.fw
	printf "0x%02x 0x773 0x0\n" $nid >> /lib/firmware/hda-jack-retask.fw

	printf "0x%02x 0x705 0x00\n" $pin >> /lib/firmware/hda-jack-retask.fw
	printf "0x%02x 0x707 0x45\n" $pin >> /lib/firmware/hda-jack-retask.fw
	printf "0x%02x 0x708 0x80\n" $pin >> /lib/firmware/hda-jack-retask.fw
	# EAPD/BTL enable
	printf "0x%02x 0x70c 0x2\n" $pin >> /lib/firmware/hda-jack-retask.fw
	printf "0x%02x 0x71c 0x10\n" $pin >> /lib/firmware/hda-jack-retask.fw
	printf "0x%02x 0x71d 0x0\n" $pin >> /lib/firmware/hda-jack-retask.fw
	printf "0x%02x 0x71e 0x17\n" $pin >> /lib/firmware/hda-jack-retask.fw
	printf "0x%02x 0x71f 0x44\n" $pin >> /lib/firmware/hda-jack-retask.fw

	printf "0x%02x 0x724 0x3\n" $nid >> /lib/firmware/hda-jack-retask.fw

	printf "0x%02x 0x2 0x4011\n" $nid >> /lib/firmware/hda-jack-retask.fw
    fi
}

echo "!!test soundcard check log!!"

sleep 5

current_nid=`cat /root/nid`
current_dev=`cat /root/dev`
current_pin=`cat /root/pin`

current_gpio=`cat /root/gpio`

(( i = $current_nid - 1 ))
(( j = $current_pin - 1 ))

echo "===============" >> /root/log

echo "$current_gpio - $i:$j" >> /root/log
printf "\n\n\n" >> /root/log

dmesg | grep -e snd -e sound -e alsa -e $pci_match >> /root/log
printf "\n\n\n" >> /root/log
amixer scontrols >> /root/log
echo "===============" >> /root/log

echo "===============" >> /root/biglog
echo "$current_gpio - $i:$j" >> /root/biglog
printf "\n\n\n" >> /root/biglog

cat "/proc/asound/card0/codec#0" >> /root/biglog
echo "===============" >> /root/biglog

write_codec
write_pincfg
write_verb

(( current_nid = $current_nid + 1 ))
(( current_pin = $current_pin + 1 ))

echo "$current_nid" > /root/nid
echo "$current_dev" > /root/dev
echo "$current_pin" > /root/pin

if [ "$current_nid" -lt "$stop_nid" ]
then
    if [ "$current_gpio" -lt 256 ]
    then
	reboot
    fi
else
    if [ "$current_gpio" -eq 0 ]
    then
	current_gpio=1
    else
	(( current_gpio = $current_gpio * 2 ))
    fi
    
    echo "$current_gpio" > /root/gpio

    if [ $enable_hp ] ;
    then
	echo "options snd_hda_intel model=mbp131" > /etc/modprobe.d/alsa-base.conf
	echo "options snd_hda_codec_cirrus hp_out_mask=$current_gpio" >> /etc/modprobe.d/alsa-base.conf
	echo "options snd_hda_codec_cirrus speaker_out_mask=0" >> /etc/modprobe.d/alsa-base.conf
    fi

    if [ $enable_speaker_left ] ;
    then
	echo "options snd_hda_intel model=mbp131" > /etc/modprobe.d/alsa-base.conf
	echo "options snd_hda_codec_cirrus hp_out_mask=0" >> /etc/modprobe.d/alsa-base.conf
	echo "options snd_hda_codec_cirrus speaker_out_mask=$current_gpio" >> /etc/modprobe.d/alsa-base.conf
    fi

    if [ $enable_speaker_right ] ;
    then
	echo "options snd_hda_intel model=mbp131" > /etc/modprobe.d/alsa-base.conf
	echo "options snd_hda_codec_cirrus hp_out_mask=0" >> /etc/modprobe.d/alsa-base.conf
	echo "options snd_hda_codec_cirrus speaker_out_mask=$current_gpio" >> /etc/modprobe.d/alsa-base.conf
    fi

    reboot
fi
