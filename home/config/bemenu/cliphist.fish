#!/bin/fish
cliphist list | bemenu --nb "#282828" --nf "#fbf1c7" --tb "#98971a" --tf "#282828" --fb "#282828" --ff "#fbf1c7" --hb "#98971a" --hf "#282828" --ab "#282828" --af "#fbf1c7" -H 10 -M 1000 -c --border 2 --bdr "#98971a" --prompt="История: " --list 5 -i --fn "Ubuntu Regular 10" | cliphist decode | wl-copy
