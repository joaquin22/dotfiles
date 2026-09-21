#!/usr/bin/env bash

get_workspaces() {
    active_name=$(hyprctl activeworkspace -j | jq -r '.name')
    existing=$(hyprctl workspaces -j)

    jq -cn --arg active "$active_name" --argjson existing "$existing" '
        [$existing[] | select(.name | test("^-?[0-9]+$")) | (.name | tonumber) | select(. > 0)] as $existing_ids
        | (if ($active | test("^-?[0-9]+$")) then ($active | tonumber) else null end) as $active_id
        | ([range(1;5)] + $existing_ids) | unique | sort as $ids
        | $ids | map({
            id: .,
            active: (. == $active_id),
            occupied: ($existing_ids | any(. == .))
        })
    '
}


get_special_visible() {
    hyprctl monitors -j | jq -c '[.[] | .specialWorkspace.name] | any(. == "special:magic")'
}

emit() {
    jq -cn --argjson ws "$(get_workspaces)" --argjson special "$(get_special_visible)" \
        '{workspaces: $ws, special_visible: $special}'
}

emit

socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
    case "$line" in
        workspace*|createworkspace*|destroyworkspace*|moveworkspace*|activelayout*|openwindow*|closewindow*)
            emit
            ;;
    esac
done