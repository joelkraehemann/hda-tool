#!/bin/bash

# --------------------------------
# Author: Joël Krähemann
# Program: hda-tool.sh
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

# sdi wake enable
sdiwen=0

# state change status
statests=()

# sdi wake
sdiwake=0

# global status
gsts=()

# flush status
fsts=0

# output stream payload
outstrmpay=()

# input stream payload
instrmpay=()

# interrupt control
intctl=()

# global interrupt enable
gie=0

# controller interrupt enable
cie=0

# stream interrupt enable
sie=0

# interrupt status
intsts=()

# global interrupt status
gis=0

# controller interrupt status
cis=0

# stream interrupt status
sis=0

# wall clock
wclck=()

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
    
    revision=`hda-verb $soundcard 0x0 PARAMETERS 0x3 2> /dev/null | awk -F' ' '{print substr($NF, 3)}'`
    (( vmaj = 0xff & $revision ))

    revision=`hda-verb $soundcard 0x0 PARAMETERS 0x2 2> /dev/null | awk -F' ' '{print substr($NF, 3)}'`
    (( vmin = 0xff & $revision ))
    
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

    #TODO:JK: verifiy me
    # send command using function RESET verb
    hda-verb $soundcard 0x0 0x7ff $gctl

    echo -e " ---- \n"
}

list_wake_enable(){
    echo "retrieving wake enable"

    wakeen=`hda-verb $soundcard 0x0 PARAMETERS 0xC 2> /dev/null | awk -F' ' '{print substr($NF, 3)}'`

    printf "returned 0x$wakeen\n\n"
    
    (( sdiwen = $((16#7fff)) & $((16#$waken)) ))

    printf "SDIN wake enable flags $sdiwen\n\n"

    echo -e " ---- \n"
}

set_wake_enable(){
    local wakeen=()
    local sdiwen=0
    
    wakeen=`hda-verb $soundcard 0x0 PARAMETERS 0xC 2> /dev/null | awk -F' ' '{print substr($NF, 3)}'`

    read -e -p "Enable SDIN wake flags [0x7f] (resume well): " -i "0x0" sdiwen

    sdiwen=$((16#${sdiwen:2}))
    
    (( wakeen = $wakeen & (~ $((16#7f)) ) ))
    (( wakeen = $wakeen | $sdiwen ))

    #TODO:JK: verifiy me
    # send command using function SDI SELECT verb
    hda-verb $soundcard 0x0 0x704 $wakeen

    echo -e " ---- \n"    
}

list_state_change_status(){
    echo "retrieving state change status"

    statests=`hda-verb $soundcard 0x0 PARAMETERS 0xE 2> /dev/null | awk -F' ' '{print substr($NF, 3)}'`

    printf "returned 0x$statests\n\n"

    (( sdiwake = $((16#7fff)) & $((16#$statests)) ))

    printf "SDIN state change status flags $sdiwake\n\n"

    echo -e " ---- \n"
}

set_state_change_status()
{
    local statests="0"
    local sdiwake=0

    printf "NOTE: it is not supported to modify state change status\n"

    read -e -p "SDIN signal(s) received [0x7f] (sticky bit read-only status, write 1 to clear status register - resume well): " -i "0x0" sdiwake

    sdiwake=$((16#${sdiwake:2}))

    #TODO:JK: implement me
    
    echo -e " ---- \n"    
}

list_global_status(){
    echo "retrieving state change status"

    gsts=`hda-verb $soundcard 0x0 PARAMETERS 0x10 2> /dev/null | awk -F' ' '{print substr($NF, 3)}'`

    printf "returned 0x$gsts\n\n"

    (( fsts = $((16#0002)) & $((16#$gsts)) ))

    printf "flush status $fsts\n\n"

    echo -e " ---- \n"    
}

set_global_status(){
    local gsts="0"
    local fsts=0

    printf "NOTE: it is not supported to clear flush status\n"

    read -e -p "Flush status [0x0] (write 0x1 to clear): " -i "0x0" fsts

    fsts=$((16#${fsts:2}))

    #TODO:JK: implement me
    
    echo -e " ---- \n"
}

list_output_stream_payload_capability(){
    echo "retrieving output stream payload capability"

    outstrmpay=`hda-verb $soundcard 0x0 PARAMETERS 0x18 2> /dev/null | awk -F' ' '{print substr($NF, 3)}'`

    printf "returned 0x$outstrmpay\n\n"
    
    echo -e " ---- \n"
}

list_input_stream_payload_capability(){
    echo "retrieving input stream payload capability"

    instrmpay=`hda-verb $soundcard 0x0 PARAMETERS 0x1a 2> /dev/null | awk -F' ' '{print substr($NF, 3)}'`

    printf "returned 0x$instrmpay\n\n"
    
    echo -e " ---- \n"
}

list_interrupt_control()
{
    local is1=0
    local is2=0
    local os1=0
    local os2=0
    local os3=0
    local bs1=0
    
    echo "retrieving interrupt control"

    intctl=`hda-verb $soundcard 0x0 PARAMETERS 0x20 2> /dev/null | awk -F' ' '{print substr($NF, 3)}'`
    
    printf "returned 0x$intctl\n\n"

    (( gie = ( $intctl & $((16#8000)) ) >> 31 ))    
    (( cie = ( $intctl & $((16#4000)) ) >> 30 ))
    (( sie = $intctl & $((16#3fff)) ))
    
    printf "global interrupt enable $gie\n"
    printf "controller interrupt enable $cie\n\n"

    printf "stream interrupt enable 0x$sie\n"

    (( is1 = $((16#$sie)) & 0x0001 ))    
    (( is2 = ( $((16#$sie)) & 0x0002 ) >> 1 ))    

    (( os1 = ( $((16#$sie)) & 0x0004 ) >> 2 ))
    (( os2 = ( $((16#$sie)) & 0x0008 ) >> 3 ))
    (( os3 = ( $((16#$sie)) & 0x0010 ) >> 4 ))

    (( bs1 = ( $((16#$sie)) & 0x0020 ) >> 5 ))    

    printf "  input stream 1 enable $is1\n"
    printf "  input stream 2 enable $is2\n"
    printf "  output stream 1 enable $os1\n"
    printf "  output stream 2 enable $os2\n"
    printf "  output stream 3 enable $os3\n"
    printf "  bidirectional stream 1 enable $bs1\n\n"
    
    echo -e " ---- \n"
}

set_interrupt_control(){
    local intctl="0"
    local gie=0
    local cie=0
    local sie=0
    local is1=0
    local is2=0
    local os1=0
    local os2=0
    local os3=0
    local bs1=0

    printf "NOTE: it is not supported to set interrupt control\n"

    read -e -p "Global interrupt enable [0x1]: " -i "0x1" gie
    read -e -p "Controller interrupt enable [0x1]: " -i "0x1" cie
    read -e -p "Stream interrupt enable [0x1]: " -i "0x1" sie

    read -e -p "  input stream 1 enable [0x1]: " -i "0x1" is1
    read -e -p "  input stream 2 enable [0x1]: " -i "0x1" is2
    read -e -p "  output stream 1 enable [0x1]: " -i "0x1" os1
    read -e -p "  output stream 2 enable [0x1]: " -i "0x1" os2
    read -e -p "  output stream 3 enable [0x1]: " -i "0x1" os3
    read -e -p "  bi-directional stream 1 enable [0x1]: " -i "0x1" bs1
    
    gie=$((16#${gie:2}))
    cie=$((16#${cie:2}))
    sie=$((16#${sie:2}))

    is1=$((16#${is1:2}))
    is2=$((16#${is2:2}))
    os1=$((16#${os1:2}))
    os2=$((16#${os2:2}))
    os3=$((16#${os3:2}))
    bs1=$((16#${bs1:2}))

    (( intctl = ($gie << 31) | ($cie << 30) | ($sie << 29) | ($is1) | ($is2 << 1) | ($os1 << 2) | ($os2 << 3) | ($os3 << 4) | ($bs1 << 5) ))

    #TODO:JK: implement me
    
    echo -e " ---- \n"
}

list_interrupt_status()
{
    local is1=0
    local is2=0
    local os1=0
    local os2=0
    local os3=0
    local bs1=0
    
    echo "retrieving interrupt status"

    intsts=`hda-verb $soundcard 0x0 PARAMETERS 0x24 2> /dev/null | awk -F' ' '{print substr($NF, 3)}'`
    
    printf "returned 0x$intsts\n\n"

    (( gis = ( $intctl & $((16#8000)) ) >> 31 ))    
    (( cis = ( $intctl & $((16#4000)) ) >> 30 ))
    (( sis = $intctl & $((16#3fff)) ))
    
    printf "global interrupt status $gis\n"
    printf "controller interrupt status $cis\n\n"

    printf "stream interrupt status 0x$sis\n"

    (( is1 = $((16#$sie)) & 0x0001 ))    
    (( is2 = ( $((16#$sie)) & 0x0002 ) >> 1 ))    

    (( os1 = ( $((16#$sie)) & 0x0004 ) >> 2 ))
    (( os2 = ( $((16#$sie)) & 0x0008 ) >> 3 ))
    (( os3 = ( $((16#$sie)) & 0x0010 ) >> 4 ))

    (( bs1 = ( $((16#$sie)) & 0x0020 ) >> 5 ))    

    printf "  input stream 1 status $is1\n"
    printf "  input stream 2 status $is2\n"
    printf "  output stream 1 status $os1\n"
    printf "  output stream 2 status $os2\n"
    printf "  output stream 3 status $os3\n"
    printf "  bidirectional stream 1 status $bs1\n\n"
    
    echo -e " ---- \n"
}

list_wall_clock_counter()
{
    echo "retrieving wall clock counter"

    wclck=`hda-verb $soundcard 0x0 PARAMETERS 0x30 2> /dev/null | awk -F' ' '{print substr($NF, 3)}'`
    
    printf "returned 0x$wclck\n\n"

    echo -e " ---- \n"
}

scan_audio_widget_capabilities(){
    local awc=()
    local pcc=()
    local widget_start=2
    local widget_end=80
    local nid=0
    
    echo -e "scan for audio widget capabilites\n"

    for((i=0; i < widget_end - widget_start; i++))
       {
	   (( nid = $widget_start + $i ))

	   echo "NID=$nid"	   
	   
	   awc=`hda-verb $soundcard $nid PARAMETERS 0x9 2> /dev/null | awk -F' ' '{print substr($NF, 3)}'`

	   echo "return $awc"

	   # audio output
	   if (( ( $((16#$awc)) & 1 ) == 1 )) ; then
	       printf "* audio output\n"
	   fi

	   # audio input
	   if (( ( $((16#$awc)) & (1 << 1) ) == (1 << 1) )) ; then
	       printf "* audio input\n"
	   fi

	   # audio mixer
	   if (( ( $((16#$awc)) & (1 << 2) ) == (1 << 2) )) ; then
	       printf "* audio mixer\n"
	   fi

	   # audio selector
	   if (( ( $((16#$awc)) & (1 << 3) ) == (1 << 3) )) ; then
	       printf "* audio selector\n"
	   fi

	   # pin complex
	   if (( ( $((16#$awc)) & (1 << 4) ) == (1 << 4) )) ; then
	       local vref=0
	       
	       printf "* pin complex\n"

	       pcc=`hda-verb $soundcard $nid PARAMETERS 0xC 2> /dev/null | awk -F' ' '{print substr($NF, 3)}'`

	       if (( ( $((16#$pcc)) & 1 ) == 1 )) ; then
		   printf "  - impendance sense capable\n"
	       fi

	       if (( ( $((16#$pcc)) & (1 << 1) ) == (1 << 1) )) ; then
		   printf "  - trigger required\n"
	       fi

	       if (( ( $((16#$pcc)) & (1 << 2) ) == (1 << 2) )) ; then
		   printf "  - presence detect capable\n"
	       fi

	       if (( ( $((16#$pcc)) & (1 << 3) ) == (1 << 3) )) ; then
		   printf "  - head-phone drive capable\n"
	       fi

	       if (( ( $((16#$pcc)) & (1 << 4) ) == (1 << 4) )) ; then
		   printf "  - output capable\n"
	       fi

	       if (( ( $((16#$pcc)) & (1 << 5) ) == (1 << 5) )) ; then
		   printf "  - input capable\n"
	       fi

	       if (( ( $((16#$pcc)) & (1 << 6) ) == (1 << 6) )) ; then
		   printf "  - balanced I/O pins\n"
	       fi

	       if (( ( $((16#$pcc)) & (1 << 7) ) == (1 << 7) )) ; then
		   printf "  - HDMI\n"
	       fi

	       (( vref = ( $((16#$pcc)) & (0xff << 8) ) >> 8 ))
	       
	       printf "  - VRef control 0x$vref\n"

	       if (( ( $((16#$pcc)) & (1 << 16) ) == (1 << 16) )) ; then
		   printf "  - EAPD capable\n"
	       fi

	       if (( ( $((16#$pcc)) & (1 << 24) ) == (1 << 24) )) ; then
		   printf "  - display port\n"
	       fi

	       if (( ( $((16#$pcc)) & (1 << 27) ) == (1 << 27) )) ; then
		   printf "  - high bitrate\n"
	       fi
	   fi

	   # power widget
	   if (( ( $((16#$awc)) & (1 << 5) ) == (1 << 5) )) ; then
	       printf "* power widget\n"
	   fi

	   # volume knob widgret
	   if (( ( $((16#$awc)) & (1 << 6) ) == (1 << 6) )) ; then
	       printf "* volume knob widget\n"
	   fi

	   # beep
	   if (( ( $((16#$awc)) & (1 << 7) ) == (1 << 7) )) ; then
	       printf "* beep generator\n"
	   fi
	   
	   printf "\n"
       }
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
		echo "[7] set wake enable"
		echo "[8] list state change status"
		echo "[9] set state change status"
		echo "[10] list global status"
		echo "[11] set global status"
		echo "[12] list output stream payload capability"
		echo "[13] list input stream payload capability"
		echo "[14] list interrupt control"
		echo "[15] set interrupt control"
		echo "[16] list interrupt status"
		echo "[17] list wall clock counter"
		echo "[999] scan audio widget capabilities"
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
	    7)
		set_wake_enable
		;;
	    8)
		list_state_change_status
		;;
	    9)
		set_state_change_status
		;;
	    10)
		list_global_status
		;;
	    11)
		set_global_status
		;;
	    12)
		list_output_stream_payload_capability
		;;
	    13)
		list_input_stream_payload_capability
		;;
	    14)
		list_interrupt_control
		;;
	    15)
		set_interrupt_control
		;;
	    16)
		list_interrupt_status
		;;
	    17)
		list_wall_clock_counter
		;;
	    999)
		scan_audio_widget_capabilities
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
    list_state_change_status
    list_global_status
    list_output_stream_payload_capability
    list_input_stream_payload_capability
    list_interrupt_control
    list_interrupt_status
    list_wall_clock_counter
    
    # going interactive
    run_interactive
else
    print_usage

    echo -e "\navailable soundcards:"
    list_soundcards
    
    exit 0
fi
