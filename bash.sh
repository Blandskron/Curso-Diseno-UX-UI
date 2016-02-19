#!/usr/bin/env bash

START_DATE="2014-08-08"
END_DATE="2014-12-31"

# Configuración de commits por día (valores típicos de humanos)
#           nada  muy poco  poco   normal   activo   muy activo
DISTRIBUCION=( 0.08    0.20    0.35    0.20     0.12     0.05 )
CANTIDADES=(    0       1       2       3-5      6-10    11-18 )

# Probabilidad de "días sin commit" por año (más realista)
PROB_SIN_COMMIT=0.22           # ~8 semanas al año sin commits

current="$START_DATE"
while [[ "$current" < "$END_DATE" || "$current" == "$END_DATE" ]]; do

    year=$(date -d "$current" +%Y)
    
    # Los lunes y viernes suelen tener más actividad en muchos repos
    dow=$(date -d "$current" +%u)  # 1=lunes ... 7=domingo
    weekend_bonus=0
    [[ $dow -eq 6 || $dow -eq 7 ]] && weekend_bonus=-2  # menos fines de semana

    # Decidir si hoy se commitea o no
    if (( RANDOM % 100 < PROB_SIN_COMMIT * 100 )); then
        commits_today=0
    else
        # Elegir nivel de actividad del día
        r=$(awk -v n=$RANDOM 'BEGIN{srand(n); sum=0; r=rand(); for(i=1;i<=length(a);i++){sum+=a[i]; if(r<=sum) {print i; exit}}}' \
            a="${DISTRIBUCION[*]}")
        
        case $r in
            1) commits_today=0;;
            2) commits_today=1;;
            3) commits_today=2;;
            4) commits_today=$((RANDOM % 3 + 3));;     # 3..5
            5) commits_today=$((RANDOM % 5 + 6));;     # 6..10
            6) commits_today=$((RANDOM % 8 + 11));;    # 11..18
            *) commits_today=1;;
        esac
        
        # Ajuste ligero por fin de semana
        (( commits_today += weekend_bonus ))
        (( commits_today < 0 )) && commits_today=0
    fi

    echo "$current - $commits_today commits" >> activity.log

    for ((i=1; i<=commits_today; i++)); do
        # Hora más natural (8:00 ~ 23:30)
        hour=$((8 + RANDOM % 15))
        minute=$((RANDOM % 60))
        
        commit_date="$current $hour:$minute:00"
        
        # Mensajes un poco más variados (opcional)
        messages=(
            "Update $current"
            "Daily progress"
            "Changes"
            "Refactoring"
            "Fix stuff"
            "More work"
        )
        
        GIT_AUTHOR_DATE="$commit_date" \
        GIT_COMMITTER_DATE="$commit_date" \
        git commit --allow-empty -m "${messages[RANDOM % ${#messages[@]}]} - $current" --date="$commit_date" || true
    done

    current=$(date -I -d "$current + 1 day")
done

echo "¡Listo! Actividad generada entre $START_DATE y $END_DATE"