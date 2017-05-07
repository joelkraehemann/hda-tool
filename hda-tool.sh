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

vmaj=()
vmin=()

opc=()
ipc=()

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
    echo -n "version info VMAJ.VMIN is: "
    
    vmaj=`hda-verb $soundcard 0x0 PARAMETERS 0x3 2> /dev/null | awk -F' ' '{print substr($NF, 3)}'`
    vmin=`hda-verb $soundcard 0x0 PARAMETERS 0x2 2> /dev/null | awk -F' ' '{print substr($NF, 3)}'`
    
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

# entry point
if [ $# -eq 1 ] ; then
    soundcard=$1

    list_global_capabilities
    list_version
    list_payload
else
    print_usage

    echo -e "\navailable soundcards:"
    list_soundcards
    
    exit 0
fi

