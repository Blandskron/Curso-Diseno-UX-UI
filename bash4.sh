#!/usr/bin/env bash

start="2016-01-01"
end="2016-12-31"

current="$start"

while [[ "$current" < "$end" || "$current" == "$end" ]]; do
    echo "$current" >> log.txt
    git add log.txt

    # Tus commits aleatorios aquí...
    # Ejemplo simple:
    GIT_AUTHOR_DATE="$current 14:30:00" \
    GIT_COMMITTER_DATE="$current 14:30:00" \
    git commit --allow-empty -m "Actividad $current" || true

    # Solución al problema del 8 de septiembre:
    current=$(date --iso-8601=date --date="$current +1 day" 2>/dev/null) || {
        echo "Fallo raro en date, usando alternativa..."
        current=$(date -d "$current tomorrow" +%Y-%m-%d)
    }
done