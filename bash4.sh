#!/usr/bin/env bash
# =============================================================================
# Generador de commits realistas - Versión corregida
# =============================================================================

YEAR=2017
START_DATE="${YEAR}-01-01"
END_DATE="${YEAR}-12-31"

# ── Perfil de actividad ──────────────────────────────────────────────
WEEKDAY_BASE=3.8      # promedio días laborales
WEEKEND_BASE=1.2      # promedio fines de semana

NO_COMMIT_PERCENT=18   # ← CAMBIADO: 18% de días sin commit (~66 días/año)
MAX_WEEKDAY=14
MAX_WEEKEND=7

# ----------------------------------------------------------------------

current="$START_DATE"

while [[ "$current" < "$END_DATE" || "$current" == "$END_DATE" ]]; do
    dow=$(date -d "$current" +%u 2>/dev/null || date -d "$current" +%w)
    is_weekend=$((dow >= 6 ? 1 : 0))

    if (( is_weekend == 1 )); then
        expected=$WEEKEND_BASE
        max_commits=$MAX_WEEKEND
    else
        expected=$WEEKDAY_BASE
        max_commits=$MAX_WEEKDAY
    fi

    # Decisión: ¿hoy sin commits?
    if (( RANDOM % 100 < NO_COMMIT_PERCENT )); then
        commits_today=0
    else
        # Aproximación simple a poisson + ruido
        base=$(( ${expected%.*} + (RANDOM % 3) ))  # parte entera + pequeño ruido
        extra=$(( RANDOM % 5 - 2 ))               # -2..+2
        commits_today=$(( base + extra ))

        (( commits_today < 0 )) && commits_today=0
        (( commits_today > max_commits )) && commits_today=$max_commits

        # Bonus lunes y jueves (opcional)
        if (( dow == 1 || dow == 4 )); then
            (( commits_today += RANDOM % 3 ))
            (( commits_today > max_commits )) && commits_today=$max_commits
        fi
    fi

    # ── Crear los commits ───────────────────────────────────────────────
    for (( i=1; i<=commits_today; i++ )); do
        hour=$((9 + RANDOM % 13))
        minute=$((RANDOM % 60))
        commit_time="$current $(printf "%02d:%02d:00" $hour $minute)"

        msg="Update $i - $current"

        GIT_AUTHOR_DATE="$commit_time" \
        GIT_COMMITTER_DATE="$commit_time" \
        git commit --allow-empty -m "$msg" --date="$commit_time" >/dev/null 2>&1 || true
    done

    # Siguiente día (forma robusta)
    current=$(date -I --date="$current + 1 day" 2>/dev/null) || \
              current=$(date -d "$current +1 day" +%Y-%m-%d 2>/dev/null) || \
              current=$(date -d "1 day" -d "$current" +%Y-%m-%d)
done

echo "Finalizado!"
echo "Período: $START_DATE → $END_DATE"
echo "Días sin commit esperados ≈ $((365 * NO_COMMIT_PERCENT / 100))"