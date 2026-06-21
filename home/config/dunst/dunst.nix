{ theme, ... }:
let
  normalUrgency = {
    background = theme.colors.bg;
    foreground = theme.colors.fg;
    frame_color = theme.colors.accent;
    timeout = 3;
    alignment = "left";
    hide_text = false;
    set_transient = true;
    icon_position = "left";
    min_icon_size = 64;
    max_icon_size = 128;
  };
in
{
  services.dunst = {
    enable = true;

    settings = {
      global = {
        font = "${theme.fonts.uiRegular} ${toString theme.fonts.sizes.normal}";
        corner_radius = theme.borders.notificationRadius;
        width = "(20, 400)";
        origin = "top-right";
        offset = "10x10";
        format = "<b>%s</b>\\n%b";
        force_xwayland = false;
        layer = "top";
        text_icon_padding = 10;
        horizontal_padding = 10;
      };

      "change-urgency" = {
        appname = "dunstify";
        urgency = "low";
      };

      urgency_low = normalUrgency;

      urgency_normal = normalUrgency;

      urgency_critical = {
        background = theme.colors.bg;
        foreground = theme.colors.fg;
        frame_color = theme.colors.error;
        timeout = 5;
        alignment = "left";
        hide_text = false;
        set_transient = true;
        icon_position = "left";
        min_icon_size = 64;
        max_icon_size = 128;
      };
    };
  };
}
