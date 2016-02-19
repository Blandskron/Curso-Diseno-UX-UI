#!/usr/bin/env bash

start="2014-08-08"
end="2014-12-31"

# Convertimos todo a segundos desde epoch
current_sec=$(date -d "$start" +%s)
end_sec=$(date -d "$end" +%s)

while [ $current_sec -le $end_sec ]; do
    current=$(date -I -d "@$current_sec")   # -I = formato YYYY-MM-DD

    echo "$current" >> log.txt
    
    # ... aquí tus commits aleatorios ...

    # Avanzamos un día (86400 segundos)
    ((current_sec += 86400))
done