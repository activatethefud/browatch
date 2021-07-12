#!/bin/bash

cd "$(dirname "$0")"

source sites.sh

[ -n "$1" ] && EMAIL="$1" || EMAIL="nikolasutic@protonmail.com"
CHANGED=0
SUBJECT="Subject: BroWatch changes [$(date)]"
CHANGES=""
CHANGED_SITES=()

for idx in $(seq 0 2 $((${#sites[@]} - 1))); do
        ALIAS=${sites[idx]}
        URL=${sites[idx+1]}

        wget -O "$ALIAS" "$URL"
        diff "$ALIAS" "${ALIAS}_old" >/dev/null

        DIFF_STATUS=$?
        [ $DIFF_STATUS -eq 1 ] && CHANGES+="Changes in $URL
        
"       && CHANGED_SITES+=("$ALIAS")
        [ $DIFF_STATUS -lt 2 ] && CHANGED=$((CHANGED | DIFF_STATUS))

        mv ${ALIAS} ${ALIAS}_old

done

MESSAGE="$(printf "%s (%s) [ %s ]\n\n%s" "$SUBJECT" "${#CHANGED_SITES[@]}" "${CHANGED_SITES[*]}" "$CHANGES")"

[ $CHANGED -eq 1 ] && echo "Sending changes..." && ( echo "$MESSAGE" | msmtp -- "$EMAIL" )
[ $CHANGED -ne 1 ] && echo "No changes..."

echo "$(date)" > last_run
