#!/run/current-system/sw/bin/fish

set answer (echo "Скриншот всего экрана"\n"Скриншот активного окна"\n"Скриншот области" | bemenu $bemenu_theme_args -H 10 -W 0.16 -c --prompt="Выбери действие: " --list 4 -i)

if test $answer = "Скриншот всего экрана"
    hyprshot -m output
else if test $answer = "Скриншот области"
    hyprshot -m region
else if test $answer = "Скриншот активного окна"
    hyprshot -m window
end
