#!/bin/bash
for f in ~/.config/waybar/scripts/*
do
        pkill -f "$f"
done
sudo pkill bluetoothd
pkill obexd
pkill blueman-applet
pkill blueman-tray
pkill waybar
