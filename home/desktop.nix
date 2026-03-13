{config, pkgs, ...}:
{
  # Включение плагина для курсора в hyprland
  wayland.windowManager.hyprland = {
    package = null;
    portalPackage = null;

    plugins = [
      pkgs.hyprlandPlugins.hypr-dynamic-cursors
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
