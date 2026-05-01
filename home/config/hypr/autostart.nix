{...}:
{
  wayland.windowManager.hyprland.settings = {
    "exec-once" = [
      "pgrep -x swww-daemon || swww-daemon &"
      "pgrep -x swayosd-server || swayosd-server &"
      "pgrep -x udiskie || udiskie -n --appindicator --no-automount &"
      "pgrep -x lxqt-policykit-agent || lxqt-policykit-agent &"
      "pgrep -x waybar || waybar &"
      "pgrep -x dunst || dunst &"
      "pgrep -x hypridle || hypridle &"
      "pgrep -x wl-paste || wl-paste --watch cliphist store &"
      "nextcloud &"
      "clipcascade &"
      "keepassxc &"
    ];
  };
}