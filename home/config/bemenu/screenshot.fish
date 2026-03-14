#!/bin/fish

set answer (echo "Скриншот всего экрана"\n"Скриншот активного окна"\n"Скриншот области" | bemenu --nb "#282828" --nf "#fbf1c7" --tb "#d65d0e" --tf "#282828" --fb "#282828" --ff "#fbf1c7" --hb "#d65d0e" --hf "#282828" --ab "#282828" --af "#fbf1c7" -H 10 -M 1100 -c --border 2 --bdr "#d65d0e" --prompt="Выбери действие: " --list 4 -i --fn "Ubuntu Regular 12")

if test $answer = "Скриншот всего экрана"
    hyprshot -m output
else if test $answer = "Скриншот области"
    hyprshot -m region
else if test $answer = "Скриншот активного окна"
    hyprshot -m window
end
