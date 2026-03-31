#!/run/current-system/sw/bin/fish

set answer (echo "Выключиться"\n"Перезагрузиться"\n"Выйти"| bemenu --nb "#282828" --nf "#fbf1c7" --tb "#d65d0e" --tf "#282828" --fb "#282828" --ff "#fbf1c7" --hb "#d65d0e" --hf "#282828" --ab "#282828" --af "#fbf1c7" -H 10 -W 0.15 -c --border 2 --bdr "#d65d0e" --prompt="Что сделать? " --list 5 -i --fn "Ubuntu Regular 12")

if test $answer = "Перезагрузиться"
   exec systemctl reboot
else if test $answer = "Выключиться"
   exec systemctl poweroff
else if test $answer = "Выйти"
   exec hyprctl dispatch exit
end
