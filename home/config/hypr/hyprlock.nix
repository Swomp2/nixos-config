{
  homeDir,
  theme,
  unstable,
  ...
}:
{
  programs.hyprlock = {
    enable = true;
    package = unstable.hyprlock;

    settings = {
      background = [
        {
          monitor = "";
          path = "${homeDir}/lockscreen/lockscreen.png";
        }
      ];

      input-field = [
        {
          monitor = "";
          size = "200, 50";
          outline_thickness = theme.borders.width;
          dots_size = 0.3;
          dots_spacing = 0.15;
          dots_center = false;
          dots_rounding = -1;
          outer_color = theme.toHyprRgb theme.colors.accent;
          inner_color = theme.toHyprRgb theme.colors.bg;
          font_color = theme.toHyprRgb theme.colors.fg;
          fade_on_empty = true;
          fade_timeout = 1000;
          placeholder_text = "<i>Введи пароль</i>";
          hide_input = false;
          rounding = -1;
          check_color = theme.toHyprRgb theme.colors.accent;
          fail_color = theme.toHyprRgb theme.colors.errorBright;
          fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
          fail_transition = 300;
          capslock_color = theme.toHyprRgb theme.colors.error;
          numlock_color = -1;
          bothlock_color = -1;
          swap_font_color = false;
          invert_numlock = false;

          position = "0, -20";
          halign = "center";
          valign = "center";
        }
      ];

      label = [
        {
          monitor = "";
          text = "Не подсматривай :)";
          color = theme.toHyprRgb theme.colors.fg;
          font_size = 25;
          font_family = theme.fonts.ui;

          position = "0, 60";
          halign = "center";
          valign = "center";
        }

        {
          monitor = "";
          text = "$TIME";
          color = theme.toHyprRgb theme.colors.fg;
          font_size = 70;
          font_family = theme.fonts.ui;

          position = "0, 150";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
