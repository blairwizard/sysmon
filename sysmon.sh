#!/bin/bash

snapshot() {
        local i=0 name user nice system idle iowait irq softirq steal rest
        names=(); total=(); idles=()

        while read -r name user nice system idle iowait irq softirq steal rest; do
                names[i]=$name
                total[i]=$(( user + nice + system + idle + iowait + irq + softirq + steal ))
                idles[i]=$(( idle + iowait ))
                i=$(( i + 1 ))
        done < <(grep '^cpu' /proc/stat)
}

while true; do
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

        snapshot
        total1=("${total[@]}")
        idles1=("${idles[@]}")
        snapshot

        cols=4
        overall=""
        grid=""
        for i in "${!total[@]}"; do
                dt=$(( total[i] - total1[i] ))
                di=$(( idles[i] - idles1[i] ))

                if [ "$dt" -le 0 ]; then
                        usage="n/a"
                else
                        usage=$(echo "scale=1; (($dt-$di)*100)/$dt" | bc)
                fi

                if [ "$i" -eq 0 ]; then
                        overall=" Overall CPU = $usage %"
                        pct=$(printf "%.0f" "$usage")
                        width=100
                        filled=$(( pct * width / 100 ))
                        for (( j=0; j<width; j++ )); do
                        if (( j < filled )); then printf '█'; else printf '░'; fi
                        done
                        echo
                else
                        printf -v cell ' Core %-2s %5s %%  ' "${names[i]#cpu}" "$usage"
                        grid+=$cell
                        if (( i % cols == 0 )); then
                                grid+=$'\n'
                        fi
                fi
        done

        clear
        echo -e " Total memory = $memt kb \n Available Memory = $mema kb"
        echo " Memory usage = $memusage %"
        echo
        echo "$overall"
        echo
        echo "$grid"
        sleep 1
done