#!/bin/bash

set -euo pipefail

# 1) Redes guardadas: ssid -> autoconnect (true/false)
declare -A autoconnect
while IFS=: read -r uuid type; do
  [[ "$type" == "802-11-wireless" ]] || continue
  ssid=$(nmcli --escape no -g 802-11-wireless.ssid connection show uuid "$uuid")
  auto=$(nmcli --escape no -g connection.autoconnect connection show uuid "$uuid")
  if [[ "$auto" == "yes" ]]; then
    autoconnect["$ssid"]=true
  else
    autoconnect["$ssid"]=false
  fi
done < <(nmcli -t -f UUID,TYPE connection show)

# 2) Redes visibles (sin duplicados, ignorando SSID vacíos)
declare -A seen in_use
order=()
while IFS=: read -r use ssid; do
  [[ -n "$ssid" ]] || continue
  if [[ -z "${seen[$ssid]:-}" ]]; then
    seen["$ssid"]=1
    order+=("$ssid")
    in_use["$ssid"]=false
  fi
  if [[ "$use" == "*" ]]; then
    in_use["$ssid"]=true
  fi
done < <(nmcli -t --escape no -f IN-USE,SSID device wifi list)

# 3) Salida JSON (las redes no guardadas tienen autoconnect=false)
for ssid in "${order[@]}"; do
  printf '%s\t%s\t%s\n' "$ssid" "${in_use[$ssid]}" "${autoconnect[$ssid]:-false}"
done | jq -Rn '
  [inputs | split("\t") | {
    ssid: .[0],
    in_use: (.[1] == "true"),
    autoconnect: (.[2] == "true")
  }]'