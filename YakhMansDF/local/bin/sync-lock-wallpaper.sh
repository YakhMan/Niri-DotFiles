#!/bin/bash

WALLPAPER=$(awww query | grep -oP '(?<=currently displaying: image: ).*')


if [ -n "$WALLPAPER" ]; then
    sed -i "s|^    path = .*|    path = $WALLPAPER|" ~/.config/hypr/hyprlock.conf
fi
