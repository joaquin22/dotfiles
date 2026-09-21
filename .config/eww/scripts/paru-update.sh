#!/bin/bash

kitty --title paru-update -e bash -c 'paru -Syu; echo; read -p "Presiona Enter para cerrar..."'