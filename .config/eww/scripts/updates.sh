#!/bin/bash

# paru -Qu | jq -R -s '
#   split("\n") | map(select(length > 0)) |
#   map(split(" ")) |
#   map({pkg_name: .[0], pkg_version: .[1], pkg_repo: .[3]})
# '