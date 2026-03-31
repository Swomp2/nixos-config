#!/run/current-system/sw/bin/fish

function wifi_notify
    set -l title $argv[1]
    set -l body $argv[2]

    if type -q notify-send
        notify-send $title $body
    else
        echo "$title: $body" >&2
    end
end

if not type -q nmcli
    wifi_notify "Wi-Fi" "Не найден nmcli"
    exit 1
end

if not type -q bemenu
    wifi_notify "Wi-Fi" "Не найден bemenu"
    exit 1
end

# На всякий случай включаем Wi-Fi
nmcli radio wifi on >/dev/null 2>&1

# Список SSID
set -l ssids (
    nmcli -t -f SSID dev wifi list --rescan yes \
    | awk 'NF && !seen[$0]++'
)

# Меню выбора
set -l choice (
    begin
        echo "[ввести SSID вручную]"
        printf '%s\n' $ssids
    end | bemenu --nb "#282828" --nf "#fbf1c7" --tb "#d65d0e" --tf "#282828" --fb "#282828" --ff "#fbf1c7" --hb "#d65d0e" --hf "#282828" --ab "#282828" --af "#fbf1c7" -H 10 -W 0.13 -c --border 2 --bdr "#d65d0e" --list 15 -i --fn "Ubuntu Regular 12" --prompt="Wi-Fi"
)

# Отмена
if test -z "$choice"
    exit 0
end

# Ручной ввод SSID
set -l ssid "$choice"
if test "$choice" = "[ввести SSID вручную]"
    set ssid (printf '' | bemenu -p "SSID")
    if test -z "$ssid"
        exit 0
    end
end

# Пароль
set -l password (printf '' | bemenu --nb "#282828" --nf "#fbf1c7" --tb "#d65d0e" --tf "#282828" --fb "#282828" --ff "#fbf1c7" --hb "#d65d0e" --hf "#282828" --ab "#282828" --af "#fbf1c7" -H 10 -W 0.13 -c --border 2 --bdr "#d65d0e" --list 15 -i --fn "Ubuntu Regular 12" -p "Пароль (пусто = open)" -x indicator)

# Подключение
if test -n "$password"
    nmcli device wifi connect "$ssid" password "$password"
else
    nmcli device wifi connect "$ssid"
end

if test $status -eq 0
    wifi_notify "Wi-Fi" "Подключено к $ssid"
else
    wifi_notify "Wi-Fi" "Не удалось подключиться к $ssid"
    exit 1
end
