#!/bin/bash

sudo systemctl start bluetooth

# obexd typically auto-starts via dbus, no manual launch needed

blueman-applet &
disown

blueman-tray &
disown

waybar &
disown

for f in ~/.config/waybar/scripts/*
do
    "$f" &
    disown
done