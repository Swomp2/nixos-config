{config, pkgs, lib, ...}:
{
  wayland.windowManager.hyprland.extraConfig =
    lib.mkAfter (builtins.readFile ./config/hypr/hyprland-pc.conf);
}
