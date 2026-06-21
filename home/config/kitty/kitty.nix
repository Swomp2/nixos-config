{ theme, ... }:
{
  programs.kitty = {
    enable = true;

    settings = {
      # Настройки
      font_family = theme.fonts.mono;
      font_size = theme.fonts.sizes.small;
      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";
      disable_ligatures = "never";
      confirm_os_window_close = 0;
      background_opacity = theme.opacity.terminal;
      cursor_trail = 50;
      cursor_trail_decay = "0.3 0.6";

      # Цвета
      background = theme.colors.bg;
      foreground = theme.colors.fg;

      cursor = theme.colors.muted;

      selection_foreground = theme.colors.muted;
      selection_background = theme.colors.bgAlt;

      color0 = theme.colors.bg;
      color8 = theme.colors.muted;

      color1 = theme.colors.error;
      color9 = theme.colors.errorBright;

      color2 = theme.colors.green;
      color10 = theme.colors.greenBright;

      color3 = theme.colors.warning;
      color11 = theme.colors.warningBright;

      color4 = theme.colors.blue;
      color12 = theme.colors.blueBright;

      color5 = theme.colors.purple;
      color13 = theme.colors.purpleBright;

      color6 = theme.colors.aqua;
      color14 = theme.colors.aquaBright;

      color7 = theme.colors.neutral;
      color15 = theme.colors.muted;
    };

    keybindings = {
      "ctrl+plus" = "change_font_size all +2.0";
      "ctrl+minus" = "change_font_size all -2.0";
    };
  };
}
