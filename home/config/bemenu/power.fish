#!/bin/fish

set answer (echo "Выключиться"\n"Перезагрузиться"\n"Выйти"| bemenu --nb "#282828" --nf "#fbf1c7" --tb "#98971a" --tf "#282828" --fb "#282828" --ff "#fbf1c7" --hb "#98971a" --hf "#282828" --ab "#282828" --af "#fbf1c7" -H 10 -M 1130 -c --border 2 --bdr "#98971a" --prompt="Что сделать? " --list 5 -i --fn "Ubuntu Regular 10")

if test $answer = "Перезагрузиться"
   exec loginctl reboot
else if test $answer = "Выключиться"
   exec loginctl poweroff
else if test $answer = "Выйти"
   pgrep -x sway || exec hyprctl dispatch exit
   pgrep -x Hyprland || exec swaymsg exit
end
