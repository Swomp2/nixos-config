{config, pkgs, lib, ...}:
{
  wayland.windowManager.hyprland.extraConfig =
    lib.mkAfter (builtins.readFile ./config/hypr/hyprland-laptop.conf);

  xdg.configFile."waybar".source = ./config/waybar-laptop;
  xdg.configFile."waybar".recursive = true;
}
