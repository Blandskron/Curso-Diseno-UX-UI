#!/usr/bin/env bash

START="2015-01-01"
END="2015-12-31"

d="$START"
while [[ "$d" < "$END" || "$d" == "$END" ]]; do
    # 0..7 commits, pero con distribución más natural
    case $((RANDOM % 10)) in
        0|1)     n=0;;
        2|3)     n=1;;
        4|5|6)   n=2;;
        7)       n=3;;
        8)       n=4;;
        9)       n=$((5 + RANDOM%6));;  # 5-10
    esac

    # Menos actividad en fines de semana
    [[ $(date -d "$d" +%u) -ge 6 ]] && (( n = n > 2 ? n-2 : n/2 ))

    for ((i=1; i<=n; i++)); do
        h=$((8 + RANDOM%14))
        m=$((RANDOM%60))
        GIT_AUTHOR_DATE="$d $h:$m:00" GIT_COMMITTER_DATE="$d $h:$m:00" \
            git commit --allow-empty -m "Update $d #$i" --date="$d $h:$m:00" || true
    done

    d=$(date -I -d "$d +1 day")
done