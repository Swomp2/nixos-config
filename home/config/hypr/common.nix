{...}:
{
  wayland.windowManager.hyprland = {
    settings = {
      render = {
        cm_enabled  = true;
        cm_auto_hdr = 0;
      };

      misc = {
        disable_hyprland_logo     = true;
        on_focus_under_fullscreen = 2;
        disable_watchdog_warning  = true;
      };

      master = {
        new_status = "slave";
      };

      cursor = {
        inactive_timeout = 5;
      };

      general = {
        border_size           = 2;
        gaps_out              = 5;
        gaps_in               = 3;
        no_focus_fallback     = true;
        "col.inactive_border" = "rgb(282828)";
        "col.active_border"   = "rgb(d65d0e)";
        layout                = "master";
      };

      decoration = {
        rounding         = 8;
        inactive_opacity = 0.9;

        blur = {
          enabled = true;
          size    = 10;
          xray    = false;
        };
      };
    };
  };
}