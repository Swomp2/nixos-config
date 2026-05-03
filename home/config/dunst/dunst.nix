{ ... }:

{
  services.dunst = {
    enable = true;

    settings = {
      global = {
        font               = "Ubuntu Regular 12";
        corner_radius      = 5;
        width              = "(20, 400)";
        origin             = "top-right";
        offset             = "10x10";
        format             = "<b>%s</b>\\n%b";
        force_xwayland     = false;
        layer              = "top";
        text_icon_padding  = 10;
        horizontal_padding = 10;
      };

      "change-urgency" = {
        appname        = "dunstify";
        urgency        = "low";
      };

      urgency_low = {
        background    = "#282828";
        foreground    = "#ebdbb2";
        frame_color   = "#d65d0e";
        timeout       = 3;
        alignment     = "left";
        hide_text     = false;
        set_transient = true;
        icon_position = "left";
        min_icon_size = 64;
        max_icon_size = 128;
      };

      urgency_normal = {
        background    = "#282828";
        foreground    = "#ebdbb2";
        frame_color   = "#d65d0e";
        timeout       = 3;
        alignment     = "left";
        hide_text     = false;
        set_transient = true;
        icon_position = "left";
        min_icon_size = 64;
        max_icon_size = 128;
      };

      urgency_critical = {
        background    = "#282828";
        foreground    = "#ebdbb2";
        frame_color   = "#cc241d";
        timeout       = 5;
        alignment     = "left";
        hide_text     = false;
        set_transient = true;
        icon_position = "left";
        min_icon_size = 64;
        max_icon_size = 128;
      };
    };
  };
}