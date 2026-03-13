{config, pkgs, ...}:
{
  xdg.configFile."hypr/hyprland-pc.conf".source = ../config/hypr/hyprland.conf;
  xdg.configFile."hypr/hyprlock.conf".source = ../config/hypr/hyprlock.conf;
  xdg.configFile."hypr/hypridle.conf".source = ../config/hypr/hypridle.conf;

  xdg.configFile."waybar/config.jsonc".source = ../config/waybar/config.jsonc;
  xdg.configFile."waybar/style.css".source = ../config/waybar/style.css;

  xdg.configFile."kitty/kitty.conf".source = ../config/kitty/kitty.conf;
  xdg.configFile."dunst/dunstrc".source = ../config/dunst/dunstrc;
}
