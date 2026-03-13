#!/bin/fish

grim ~/Pictures/lockscreen/screenshot.png && convert -blur 18,4 ~/Pictures/lockscreen/screenshot.png ~/Pictures/lockscreen/screenshot.png

playerctl stop

hyprlock
