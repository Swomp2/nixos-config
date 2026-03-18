#!/bin/fish

grim ~/lockscreen/lockscreen.png && convert -blur 18,4 ~/lockscreen/lockscreen.png ~/lockscreen/lockscreen.png

playerctl stop

hyprlock
