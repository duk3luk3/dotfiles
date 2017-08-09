#!/bin/bash

CURRENT_STATE=`amixer -c 1 get Master | egrep 'Playback.*?\[o' | egrep -o '\[o.+\]'`

if [[ $CURRENT_STATE == '[on]' ]]; then
    amixer -c 1 set Master mute
else
    amixer -c 1 set Master unmute
    amixer -c 1 set Speaker unmute
    amixer -c 1 set Headphone unmute
fi
