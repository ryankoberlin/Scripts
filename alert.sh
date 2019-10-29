#!/bin/bash

# Battery alert script for DWM
# Ryan Oberlin 2019

# echo -e "\x07" # Ring the bell, will highlight DWM tag if we're interactive

# Icons located here:
# /usr/local/share/icons/gnome/48x48/status/

_warn() {

    ICON='battery-caution' 
    if [[ $PERC < 16 ]]; then
        MSG="\nBattery currently at ${PERC}%\nHibernation in 5 minutes"
    else 
        MSG="\nBattery currently at ${PERC}%"
    fi

    /usr/local/bin/zenity --error \
    --width=200 \
    --height=125 \
    --text="${MSG}" \
    --icon-name=$ICON \

}

# Check the battery status and sleep
while true; 
do
    export PERC=$(/usr/sbin/apm -l)
    if [[ $PERC < 7 ]] && [[ $(apm -a) == 0 ]]; then
        zenity --text="\nSystem hibernating in 30 seconds" --error
        sleep 30 
        if [[ $(apm -a) != 1 ]]; then
            zenity --text="\nSystem hibernating NOW!" --error
            sleep 5
            apm -Z
        fi
    elif [[ $PERC > 30 ]]; then
        sleep 900
    else 
        pkill zenity
        _warn
        sleep 300
    fi
done
