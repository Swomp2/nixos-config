{config, pkgs, lib, ...}:
{
  wayland.windowManager.hyprland.extraConfig =
    lib.mkAfter (builtins.readFile ./config/hypr/hyprland-pc.conf);

  xdg.configFile."waybar".source = ./config/waybar;
  xdg.configFile."waybar".recursive = true;
}
