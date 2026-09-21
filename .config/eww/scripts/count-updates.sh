#!/bin/bash

count_official=$(checkupdates 2>/dev/null | grep -c .)
count_aur=$(paru -Qua 2>/dev/null | grep -c .)

count=$((count_official + count_aur))

eww update updates_count="$count"
