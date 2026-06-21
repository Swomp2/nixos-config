{ homeDir, theme, ... }:
{
  wayland.windowManager.hyprland = {
    settings = {
      env = [
        "HYPRSHOT_DIR, ${homeDir}/Изображения/Скрины/ПК и ноут/"
        "HYPRCURSOR_THEME, ${theme.cursor.hyprcursorName}"
        "HYPRCURSOR_SIZE, ${toString theme.cursor.size}"
      ];
    };
  };
}
