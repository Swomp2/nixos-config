#!/usr/bin/env fish

# Использование:
#   wallpapers.fish ~/Pictures/Wallpapers
#
# Переменные для настройки:
#   WALLPAPER_DIR
#   WALLPAPER_WOFI_WIDTH
#   WALLPAPER_WOFI_HEIGHT
#   WALLPAPER_COLUMNS
#   WALLPAPER_IMAGE_SIZE

set -l wallpaper_dir ""

if test (count $argv) -ge 1
    set wallpaper_dir $argv[1]
else if set -q WALLPAPER_DIR
    set wallpaper_dir $WALLPAPER_DIR
else
    for dir in \
        "$HOME/Nextcloud/Photos/Wallpapers" \
        "$HOME/Nextcloud/Фото/Обои" \
        "$HOME/Pictures/Wallpapers" \
        "$HOME/Изображения/Обои" \
        "$HOME/Wallpapers" \
        "$HOME/Обои"

        if test -d "$dir"
            set wallpaper_dir "$dir"
            break
        end
    end
end

if test -z "$wallpaper_dir"
    echo "Папка с обоями не найдена"
    echo "Пример:"
    echo "  wallpapers.fish ~/Pictures/Wallpapers"
    exit 1
end

set -l wofi_width 1050
set -l wofi_height 760
set -l columns 4
set -l image_size 240

if set -q WALLPAPER_WOFI_WIDTH
    set wofi_width $WALLPAPER_WOFI_WIDTH
end

if set -q WALLPAPER_WOFI_HEIGHT
    set wofi_height $WALLPAPER_WOFI_HEIGHT
end

if set -q WALLPAPER_COLUMNS
    set columns $WALLPAPER_COLUMNS
end

if set -q WALLPAPER_IMAGE_SIZE
    set image_size $WALLPAPER_IMAGE_SIZE
end

set -l cache_home "$HOME/.cache"
if set -q XDG_CACHE_HOME
    set cache_home "$XDG_CACHE_HOME"
end

set -l picker_dir "$cache_home/wofi-wallpaper-picker"
mkdir -p "$picker_dir"

set -l wofi_conf "$picker_dir/config"
set -l wofi_style "$picker_dir/style.css"

begin
    echo "normal_window=false"
    echo "layer=overlay"
    echo "allow_images=true"
    echo "image_size=$image_size"
    echo "columns=$columns"
    echo "sort_order=default"
    echo "matching=contains"
    echo "insensitive=true"
    echo "parse_search=false"
    echo "dmenu-print_line_num=true"
    echo "no_actions=true"
    echo "no_custom_entry=true"
    echo "hide_scroll=false"
    echo "hide_search=true"
    echo "cache_file=/dev/null"

    # Главное: не растягивать entry по ширине ячейки.
    echo "orientation=vertical"
    echo "halign=fill"
    echo "content_halign=center"
    echo "valign=start"
end > "$wofi_conf"

begin
    echo "window {"
    echo "  margin: 0px;"
    echo "  padding: 0px;"
    echo "  border: 2px solid #d65d0e;"
    echo "  background-color: #282828;"
    echo "  border-radius: 8px;"
    echo "}"
    echo ""
    echo "#outer-box {"
    echo "  margin: 0px;"
    echo "  padding: 0px;"
    echo "  border: 2px solid #d65d0e;"
    echo "  background-color: #282828;"
    echo "  border-radius: 8px;"
    echo "}"
    echo ""
    echo "#scroll {"
    echo "  margin: 10px;"
    echo "  padding: 0px;"
    echo "  border: none;"
    echo "  background-color: transparent;"
    echo "}"
    echo ""
    echo "#inner-box {"
    echo "  margin: 0px;"
    echo "  padding: 0px;"
    echo "  border: none;"
    echo "  background-color: transparent;"
    echo "}"
    echo ""
    echo "#entry,"
    echo "#entry:hover,"
    echo "#entry:focus,"
    echo "#entry:selected,"
    echo "#entry:selected:focus,"
    echo "#entry:selected:hover {"
    echo "  margin: 6px;"
    echo "  padding: 0px;"
    echo "  border: 2px solid transparent;"
    echo "  border-radius: 6px;"
    echo "  background-color: transparent;"
    echo "  outline: none;"
    echo "  box-shadow: none;"
    echo "}"
    echo ""
    echo "#entry:selected,"
    echo "#entry:selected:focus,"
    echo "#entry:selected:hover {"
    echo "  border: 2px solid #d65d0e;"
    echo "  background-color: transparent;"
    echo "}"
    echo ""
    echo "#img,"
    echo "#entry image {"
    echo "  margin: 0px;"
    echo "  padding: 0px;"
    echo "  border: none;"
    echo "  background-color: transparent;"
    echo "}"
    echo ""
    echo "#text,"
    echo "#entry label {"
    echo "  opacity: 0;"
    echo "  font-size: 0px;"
    echo "  min-width: 0px;"
    echo "  min-height: 0px;"
    echo "  margin: 0px;"
    echo "  padding: 0px;"
    echo "  color: transparent;"
    echo "}"
end > "$wofi_style"

function apply_wallpaper
    set -l file "$argv[1]"

    if not test -f "$file"
        echo "Файл не найден: $file"
        return 1
    end

    ensure_swww_daemon
    or return 1

    # Без -o применяется ко всем output'ам.
    # --resize crop явно указывает нормальное поведение для обоев.
    for attempt in (seq 1 3)
        if swww img "$file" \
            --resize crop \
            --transition-type outer \
            --transition-pos 0.5,0.3 \
            --transition-step 50 \
            --transition-fps 165

            return 0
        end

        sleep 0.2
    end

    echo "swww не смог установить обои: $file"
    return 1
end

set -l files (
    find -L "$wallpaper_dir" -type f \
        \( -iname '*.jpg' \
        -o -iname '*.jpeg' \
        -o -iname '*.png' \
        -o -iname '*.webp' \
        -o -iname '*.bmp' \
        -o -iname '*.gif' \) \
        | sort -V
)

if test (count $files) -eq 0
    echo "В папке нет картинок: $wallpaper_dir"
    exit 1
end

set -l entries

for file in $files
    # Только картинка, без текста.
    set -a entries "img:$file"
end

set -l chosen_line (
    printf '%s\n' $entries | wofi \
        --dmenu \
        --conf "$wofi_conf" \
        --style "$wofi_style" \
        --width "$wofi_width" \
        --height "$wofi_height" \
        --columns "$columns" \
        --allow-images \
        --no-custom-entry
)

if test -z "$chosen_line"
    exit 0
end

# wofi print_line_num возвращает номер строки.
# Для fish-массива нужен индекс с 1.
set -l index (math "$chosen_line + 1")

if test "$index" -lt 1 -o "$index" -gt (count $files)
    echo "Неверный индекс: $index"
    exit 1
end

set -l wallpaper "$files[$index]"

apply_wallpaper "$wallpaper"
