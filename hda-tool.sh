#!/bin/bash

# --------------------------------
# Author: Joël Krähemann
# program: hda-tool.sh
# Version: 0.1
# Lincense: GPLv3
# Title: hda-verb discovery and exploration
# Description: hda-tool.sh was developed with
#  intese to ease configuration of high
#  definition audio codecs.
# --------------------------------


# variable default soundcard
soundcard=()

# global capabilities
gcap=()

# number of output and input streams supported
noss=0
niss=0
nbss=0
nsdo=0
is_64bit=0

# version info
vmaj=()
vmin=()

# output and input payload capability
opc=()
ipc=()

# global control
gctl=()

# accepted unsolicited response enable, flush control and controller reset
aunsol=0
fcntrl=0
crst=0

# wake enable
wakeen=()

sdiwen=0

print_usage()
{
    echo "example usage:"
    echo "  hda-tool.sh /dev/snd/hwC0D0"
}

list_soundcards(){
    if [ -z "$(ls -A /dev/snd)" ] ; then
	echo "No soundcard driver loaded"
    else
	ls -l /dev/snd/hw*
    fi
}

list_global_capabilities(){
    echo "retrieving global capability"
    
    gcap=`hda-verb $soundcard 0x0 PARAMETERS 0x0 2> /dev/null | awk -F' ' '{print substr($NF, 3)}'`
    
    printf "returned 0x$gcap\n\n"

    (( noss = ( $((16#f000)) & $((16#$gcap)) ) >> 12 ))
    (( niss = ( $((16#0f00)) & $((16#$gcap)) ) >> 8 ))
    (( nbss = ( $((16#00f8)) & $((16#$gcap)) ) >> 3 ))
    (( nsdo = ( $((16#0006)) & $((16#$gcap)) ) >> 1 ))
    
    printf "number of output streams supported: $noss\n"
    printf "number of input streams supported: $niss\n"
    printf "number of bi-directional streams supported: $nbss\n"
    printf "number of serial data out signals supported: $nsdo\n\n"

    (( is_64bit = $((16#0001)) & $((16#$gcap)) ))

    printf "Supports 64 bit adressing: $is_64bit\n\n"

    echo -e " ---- \n"
}

list_version(){
    local revision=()
    
    echo -n "version info VMAJ.VMIN is: "
    
    revision=`hda-verb $soundcard 0x0 PARAMETERS 0x2 2> /dev/null | awk -F' ' '{print substr($NF, 3)}'`

    (( vmaj = 0xff00 & $revision ))
    (( vmin = 0x00ff & $revision ))
    
    printf "$((16#$vmaj)).$((16#$vmin))\n\n"

    echo -e " ---- \n"
}

list_payload(){
    echo "retrieving output and input payload capabilitity"
    
    opc=`hda-verb $soundcard 0x0 PARAMETERS 0x4 2> /dev/null | awk -F' ' '{print substr($NF, 3)}'`
    ipc=`hda-verb $soundcard 0x0 PARAMETERS 0x6 2> /dev/null | awk -F' ' '{print substr($NF, 3)}'`

    printf "returned opc = 0x$opc\n"
    printf "returned ipc = 0x$opc\n\n"

    echo -e " ---- \n"
}

list_global_control(){
    echo "retrieving global control"
    
    gctl=`hda-verb $soundcard 0x0 PARAMETERS 0x8 2> /dev/null | awk -F' ' '{print substr($NF, 3)}'`

    printf "returned 0x$gctl\n\n"

    (( aunsol = ( $((16#00000100)) & $((16#$gctl)) ) >> 8 ))
    (( fcntrl = ( $((16#00000002)) & $((16#$gctl)) ) >> 1 ))
    (( crst = $((16#00000001)) & $((16#$gctl))))

    printf "accepted unsolicited response enable: $aunsol\n"
    printf "flush control: $fcntrl\n"
    printf "controller reset: $crst\n\n"

    echo -e " ---- \n"
}

list_wake_enable(){
    echo "retrieving wake enable"

    wakeen=`hda-verb $soundcard 0x0 PARAMETERS 0xC 2> /dev/null | awk -F' ' '{print substr($NF, 3)}'`

    printf "returned 0x$wakeen\n\n"
    
    (( sdiwen = $((16#7fff)) & $((16#$waken)) ))

    printf "SDIN wake enable flags $sdiwen"

    echo -e " ---- \n"
}

set_global_control(){
    local gctl=()
    local aunsol=()
    local fcntrl=()
    local crst=()
    
    gctl=`hda-verb $soundcard 0x0 PARAMETERS 0x8 2> /dev/null | awk -F' ' '{print substr($NF, 3)}'`

    read -e -p "Enable accept unsolicited response [0/1]: " -i "1" aunsol
    read -e -p "Flush control [0/1]: " -i "0" fcntrl
    read -e -p "Controller reset [0/1] (stiky): " -i "0" crst

    # toggle enable accept unsolicited response
    if [ "$aunsol" == "0" ] ; then
	(( gctl = $gctl & ( ~ $((16#00000100)) ) ))
    else
	(( gctl = $gctl | $((16#00000100)) ))	
    fi

    # toggle flush control
    if [ "$fcntrl" == "0" ] ; then
	(( gctl = $gctl & ( ~ $((16#00000002)) ) ))
    else
	(( gctl = $gctl | $((16#00000002)) ))	
    fi

    # toggle controller reset
    if [ "$crst" == "0" ] ; then
	(( gctl = $gctl & ( ~ $((16#00000001)) ) ))
    else
	(( gctl = $gctl | $((16#00000001)) ))	
    fi

    # send command using function RESET verb
    hda-verb $soundcard 0x0 0x7ff $gctl

    echo -e " ---- \n"    
}

run_interactive()
{
    cmd=()

    while [ "$cmd" != "quit" ] ; do
	read -p "enter next command index[0 = list available, quit = exit interactive mode]: " cmd

	case $cmd in
	    0)
		echo "[1] list global capabilities"
		echo "[2] list version"
		echo "[3] list payload"
		echo "[4] list global control"
		echo "[5] set global control"
		echo "[6] list wake enable"
		;;
	    1)
		list_global_capabilities
		;;
	    2)
		list_version
		;;
	    3)
		list_payload
		;;
	    4)
		list_global_control
		;;
	    5)
		set_global_control
		;;
	    6)
		list_wake_enable
		;;
	    quit)
		echo "leaving interactive mode"
		;;
	    *)
		echo "Unsupported command index $cmd"
		;;
	esac
    done
}

# entry point
if [ $# -eq 1 ] ; then
    soundcard=$1

    # list some information
    list_global_capabilities
    list_version
    list_payload
    list_global_control
    list_wake_enable

    # going interactive
    run_interactive
else
    print_usage

    echo -e "\navailable soundcards:"
    list_soundcards
    
    exit 0
fi
