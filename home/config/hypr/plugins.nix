{
  unstable,
  inputs,
  pkgs,
  ...
}:
{
  wayland.windowManager.hyprland = {
    plugins = [
      inputs.hypr-dynamic-cursors.packages.${pkgs.stdenv.hostPlatform.system}.hypr-dynamic-cursors
    ];

    settings = {
      "plugin:dynamic-cursors" = {
        enabled = true;
        mode = "tilt";
        threshold = 2;

        shake = {
          enabled = true;
          threshold = 6.0;
          limit = 2;
          timeout = 1000;
        };
      };
    };
  };
}
