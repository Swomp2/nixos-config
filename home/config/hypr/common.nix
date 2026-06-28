{ theme, ... }:
{
  imports = [
    ./animations.nix
    ./autostart.nix
    ./common-binds.nix
    ./env-vars.nix
    ./hypridle.nix
    ./hyprlock.nix
    ./hyprsunset.nix
    ./plugins.nix
    ./win-rules.nix
  ];

  wayland.windowManager.hyprland = {

    configType = "hyprlang";

    settings = {
      misc = {
        disable_hyprland_logo = true;
        on_focus_under_fullscreen = 2;
        disable_watchdog_warning = true;
      };

      master = {
        new_status = "slave";
      };

      cursor = {
        inactive_timeout = 5;
      };

      general = {
        border_size = 2;
        gaps_out = 5;
        gaps_in = 3;
        no_focus_fallback = true;
        "col.inactive_border" = theme.toHyprRgb theme.colors.bg;
        "col.active_border" = theme.toHyprRgb theme.colors.accent;
        layout = "master";
      };

      decoration = {
        rounding = theme.borders.radius;
        inactive_opacity = theme.opacity.inactive;

        blur = {
          enabled = true;
          size = 10;
          xray = false;
        };
      };
    };
  };
}
