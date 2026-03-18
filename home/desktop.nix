{config, pkgs, unstable, ...}:
{
  # Включение плагина для курсора в hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;

    plugins = [
      unstable.hyprlandPlugins.hypr-dynamic-cursors
    ];

    extraConfig = ''
      plugin:dynamic-cursors {
        enabled = true
        mode = tilt
        threshold = 2

        shake {
          enabled = true
          threshold = 6.0
          limit = 2
          timeout = 1000
        }
      }
    '';
  };
}
