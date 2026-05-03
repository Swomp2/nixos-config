{unstable, ...}:
{
  wayland.windowManager.hyprland = {
    plugins = [
      unstable.hyprlandPlugins.hypr-dynamic-cursors
    ];

    settings = {
      "plugin:dynamic-cursors" = {
        enabled   = true;
        mode      = "tilt";
        threshold = 2;

        shake = {
          enabled   = true;
          threshold = 6.0;
          limit     = 2;
          timeout   = 1000;
        };
      };
    };
  };
}