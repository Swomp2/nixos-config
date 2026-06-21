{ theme, ... }:
{
  xdg.configFile."uwsm/env".text = ''
    export XDG_DATA_DIRS="$HOME/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:''${XDG_DATA_DIRS:-/etc/profiles/per-user/$USER/share:/run/current-system/sw/share:/usr/local/share:/usr/share}"

    export XCURSOR_THEME="${theme.cursor.xcursorName}"
    export XCURSOR_SIZE="${toString theme.cursor.size}"

    export QT_QPA_PLATFORM="wayland;xcb"
    export QT_QPA_PLATFORMTHEME="${theme.qt.platformTheme}"
    export MOZ_ENABLE_WAYLAND="1"
    export NIXOS_OZONE_WL="1"
  '';
}
