#!/run/current-system/sw/bin/fish
cliphist list | bemenu $bemenu_theme_args -H 10 -W 0.18 -c --prompt="История: " --list 5 -i | cliphist decode | wl-copy
