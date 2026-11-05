#!/bin/bash

while true; do
        clear

        read -r memt mema <<< "$(awk '/^MemTotal:/ {t=$2} /^MemAvailable:/ {a=$2} END {print t, a}' /proc/meminfo)"

        if [ -z "$memt" ]; then
                echo "Error: Total memory cannot be read"
                exit 1
        elif [ -z "$mema" ]; then
                echo "Error: Available memory cannot be read"
                exit 1
        elif [ "$memt" -eq 0 ]; then
                echo "Error: Total memory = 0"
                exit 1
        elif [ "$mema" -gt "$memt" ]; then
                echo "Error: Available memory greater than Total Memory"
                exit 1
        else
                memusage=$(echo "scale=1; (($memt-$mema)*100)/$memt" | bc)
        fi

        echo -e " Total memory = $memt kb \n Available Memory = $mema kb"
        echo " Memory usage = $memusage %"
        echo

        read -r timesum idle <<< "$(awk '/^cpu / {t=$2+$3+$4+$5+$6+$7+$8+$9; i=$5+$6; print t, i}' /proc/stat)"
        read -r timesum1 idle1 <<< "$(awk '/^cpu / {t=$2+$3+$4+$5+$6+$7+$8+$9; i=$5+$6; print t, i}' /proc/stat)"

        del1=$((timesum1-timesum))
        del2=$((idle1-idle))

        if [ "$del1" -le 0 ]; then
                echo "Error: CPU counters did not advance"
                exit 1
        fi

        cpuusage=$(echo "scale=1; (($del1-$del2)*100)/$del1" | bc)
        echo " CPU usage = $cpuusage %"
        sleep 1
done
