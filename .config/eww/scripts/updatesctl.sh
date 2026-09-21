#!/bin/bash

if [[ -z $(eww active-windows | grep 'update-panel') ]]; then
    eww update updates_loading=true
    eww open update-panel && eww update updaterev=true
    # loop del spinner, corre mientras updates_loading sea true
    (
        frames="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
        i=0
        while [[ "$(eww get updates_loading)" == "true" ]]; do
            frame="${frames:$i:1}"
            eww update updates_spinner_frame="$frame"
            i=$(( (i + 1) % ${#frames} ))
            sleep 0.08
        done
    ) &
    
    (
        updates_json=$(./scripts/updates.sh)
        eww update updates_list="$updates_json"
        eww update updates_loading=false
    ) &
else
    eww update updaterev=false
    (sleep 0.2 && eww close update-panel) &
fi