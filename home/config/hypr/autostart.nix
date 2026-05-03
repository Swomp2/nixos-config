{pkgs, unstable, ...}:
{
  services.swww.enable = true;

  services.swayosd.enable = true;

  services.lxqt-policykit-agent.enable = true;

  services.dunst.enable = true;

  services.cliphist.enable = true;

  services.nextcloud-client = {
    enable            = true;
    startInBackground = true;
  };

  programs.waybar = {
    enable         = true;
    package        = unstable.waybar;
    systemd.enable = true;
  };

  services.udiskie = {
    enable    = true;
    tray      = "always";
    automount = true;
  };

  wayland.windowManager.hyprland.settings = {
    "exec-once" = [
      "clipcascade &"
      "keepassxc &"
    ];
  };
}