{...}:
{
  programs.kitty = {
    enable = true;

    settings = {
      # Настройки
      font_family             = "FiraCode Nerd Font";
      font_size               = 10;
      bold_font               = "auto";
      italic_font             = "auto";
      bold_italic_font        = "auto";
      disable_ligatures       = "never";
      confirm_os_window_close = 0;
      background_opacity      = 0.8;

      # Цвета
      background = "#282828";
      foreground = "#ebdbb2";

      cursor     = "#928374";

      selection_foreground = "#928374";
      selection_background = "#3c3836";

      color0     = "#282828";
      color8     = "#928374";

      color1     = "#cc241d";
      color9     = "#fb4934";

      color2     = "#98971a";
      color10    = "#b8bb26";

      color3     = "#d79921";
      color11    = "#fabd2d";

      color4     = "#458588";
      color12    = "#83a598";

      color5     = "#b16286";
      color13    = "#d3869b";

      color6     = "#689d6a";
      color14    = "#8ec07c";

      color7     = "#a89984";
      color15    = "#928374";
    };

    keybindings = {
      "ctrl+plus"  = "change_font_size all +2.0";
      "ctrl+minus" = "change_font_size all -2.0";
    };
  };
}