#!/bin/bash
# Chequea repos oficiales (checkupdates) y AUR (paru -Qua),
# mostrando un spinner braille en la barra mientras corre.

eww update updating=true

frames=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
(
  i=0
  while [ "$(eww get updating)" = "true" ]; do
    eww update spinner_frame="${frames[i]}"
    i=$(( (i + 1) % 10 ))
    sleep 0.08
  done
) &
spinner_pid=$!

official=$(checkupdates 2>/dev/null)
aur=$(paru -Qua 2>/dev/null)

count_official=$(echo -n "$official" | grep -c .)
count_aur=$(echo -n "$aur" | grep -c .)
count=$((count_official + count_aur))

build_rows() {
  local pkgs="$1"
  local rows=""
  while read -r line; do
    [ -z "$line" ] && continue
    name=$(echo "$line" | awk '{print $1}')
    old=$(echo "$line" | awk '{print $2}')
    new=$(echo "$line" | awk '{print $4}')
    rows+="(box :class \"row\" :orientation \"h\" :space-evenly false
      (label :class \"pkg-name\" :halign \"start\" :hexpand true :text \"$name\")
      (label :class \"ver-old\" :text \"$old\")
      (label :class \"arrow\" :text \"→\")
      (label :class \"ver-new\" :text \"$new\"))"
  done <<< "$pkgs"
  echo "$rows"
}

rows_official=$(build_rows "$official")
rows_aur=$(build_rows "$aur")

body="(box :orientation \"v\" :space-evenly false $rows_official $rows_aur)"

eww update updates_count="$count"
eww update updates_body="$body"

eww update updating=false
wait "$spinner_pid" 2>/dev/null