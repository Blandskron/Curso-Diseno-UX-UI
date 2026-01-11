#!/usr/bin/env bash
# Mezcla realista 2017–2026 (versión simplificada pero efectiva)

START_DATE="2017-01-01"
END_DATE="2026-01-11"   # fecha actual aproximada

current="$START_DATE"

while [[ "$current" < "$END_DATE" || "$current" == "$END_DATE" ]]; do

    year=$(date -d "$current" +%Y)
    month=$(date -d "$current" +%m)
    dow=$(date -d "$current" +%u)  # 1=lun ... 7=dom
    is_weekend=$((dow >= 6 ? 1 : 0))

    # ========== PERFILES POR AÑO ==========
    case $year in
        2017|2018)
            # Estudiante irregular + vacaciones verano
            base=$((is_weekend ? 3 : 5))
            if [[ $month == "01" || $month == "02" || $month == "07" ]]; then base=$((base + 4)); fi
            commits=$((base + RANDOM % 5 - 2))
            ;;
        2019)
            # Freelance caótico - ráfagas + silencios
            if (( RANDOM % 100 < 45 )); then commits=0; else commits=$((1 + RANDOM % 12)); fi
            ;;
        2020|2021)
            # Pandemia → mucha actividad
            base=$((is_weekend ? 6 : 8))
            commits=$((base + RANDOM % 7 - 3))
            ;;
        2022)
            # Burnout
            commits=$((RANDOM % 100 < 72 ? 0 : 1 + RANDOM % 4))
            ;;
        2023)
            # Vuelta lenta
            base=$((is_weekend ? 1 : 4))
            commits=$((base + RANDOM % 5 - 2))
            ;;
        2024|2025|2026)
            # Adulto responsable - menos fines de semana
            if (( is_weekend == 1 && RANDOM % 100 < 70 )); then
                commits=0
            else
                base=$((is_weekend ? 2 : 6))
                commits=$((base + RANDOM % 6 - 2))
            fi
            ;;
        *) commits=1;; # fallback
    esac

    (( commits < 0 )) && commits=0
    (( commits > 16 )) && commits=16  # límite realista

    # Horarios más naturales según etapa
    if (( year <= 2021 )); then
        hour=$((12 + RANDOM % 12))  # más nocturno
    else
        hour=$((9 + RANDOM % 10))   # horario más de oficina
    fi
    minute=$((RANDOM % 60))

    for ((i=1; i<=commits; i++)); do
        commit_time="$current $(printf "%02d:%02d:00" $hour $((minute + (i*7)%60)))"
        
        GIT_AUTHOR_DATE="$commit_time" \
        GIT_COMMITTER_DATE="$commit_time" \
        git commit --allow-empty -m "Update $year-$month-$i" --date="$commit_time" >/dev/null 2>&1 || true
    done

    current=$(date -I --date="$current + 1 day" 2>/dev/null) || \
              current=$(date -d "$current +1 day" +%Y-%m-%d)
done

echo "Mezcla completada 2017–2026"