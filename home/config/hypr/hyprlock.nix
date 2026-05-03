{pkgs, unstable, ...}:
{
  programs.hyprlock = {
    enable = true;
    package = unstable.hyprlock;

    settings = {
      background = [
        {
          monitor = "";
          path = "/home/swomp/lockscreen/lockscreen.png";
        }
      ];

      input-field = [
        {
          monitor = "";
          size = "200, 50";
          outline_thickness = 2;
          dots_size = 0.3;
          dots_spacing = 0.15;
          dots_center = false;
          dots_rounding = -1;
          outer_color = "rgb(d65d0e)";
          inner_color = "rgb(282828)";
          font_color = "rgb(ebdbb2)";
          fade_on_empty = true;
          fade_timeout = 1000;
          placeholder_text = "<i>Введи пароль</i>";
          hide_input = false;
          rounding = -1;
          check_color = "rgb(d65d0e)";
          fail_color = "rgb(fb4934)";
          fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
          fail_transition = 300;
          capslock_color = "rgb(cc241d)";
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
          color = "rgb(ebdbb2)";
          font_size = 25;
          font_family = "Ubuntu";

          position = "0, 60";
          halign = "center";
          valign = "center";
        }

        {
          monitor = "";
          text = "$TIME";
          color = "rgb(ebdbb2)";
          font_size = 70;
          font_family = "Ubuntu";

          position = "0, 150";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}