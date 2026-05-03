{...}:
{
  wayland.windowManager.hyprland = {
    settings = {
      env = [
        "MOZ_ENABLE_WAYLAND, 1"
        "XDG_SESSION_TYPE, wayland"
        "XDG_CURRENT_DESKTOP, Hyprland"
        "XDG_SESSION_DESKTOP, Hyprland"
        "QT_QPA_PLATFORM, wayland;xcb"
        "HYPRSHOT_DIR, /home/swomp/Изображения/Скрины/ПК и ноут/"
        "VDPAU_DRIVER, radeonsi"
        "LIBVA_DRIVER_NAME, radeonsi"
        "HYPRCURSOR_THEME, rose-pine-hyprcursor"
        "HYPRCURSOR_SIZE, 32"
      ];
    };
  };
}