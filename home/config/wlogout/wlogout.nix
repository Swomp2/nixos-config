{ theme, ... }:
{
  programs.wlogout = {
    enable = true;

    layout = [
      {
        "label" = "shutdown";
        "action" = "systemctl poweroff";
        "keybind" = "s";
        "width" = 0.18;
        "height" = 0.55;
      }
      {
        "label" = "reboot";
        "action" = "systemctl reboot";
        "keybind" = "r";
        "width" = 0.18;
        "height" = 0.55;
      }
      {
        "label" = "logout";
        "action" = "hyprctl dispatch exit";
        "keybind" = "o";
        "width" = 0.18;
        "height" = 0.55;
      }
      {
        "label" = "lock";
        "action" = "bemenu-lockscreen";
        "keybind" = "l";
        "width" = 0.18;
        "height" = 0.55;
      }
    ];

    style = ''
      window {
        font-family: ${theme.fonts.mono};
        font-size: 14pt;
        color: ${theme.colors.bg};
        background-color: transparent;
      }

      button {
        background-repeat: no-repeat;
        background-position: center;
        background-size: 50%;
        border-style: solid;
        border-radius: ${toString theme.borders.radius}px;
        border-width: ${toString theme.borders.width}px;
        border-color: ${theme.colors.accent};
        background-color: ${theme.colors.fg};
        color: ${theme.colors.bg};
        margin: ${toString theme.spacing.lg}px;
        transition: background-color 0.3s ease-in-out;
      }

      button:hover {
        background-color: ${theme.colors.bgAlt};
        color: ${theme.colors.fg};
      }

      button:focus {
        background-color: ${theme.colors.bg};
        color: ${theme.colors.fg};
      }

      #logout {
        background-image: image(url("${./icons/logout-hover.png}"));
      }
      #logout:focus {
        background-image: image(url("${./icons/logout.png}"));
      }
      #logout:hover {
        background-image: image(url("${./icons/logout.png}"));
      }

      #shutdown {
        background-image: image(url("${./icons/power-hover.png}"));
      }
      #shutdown:focus {
        background-image: image(url("${./icons/power.png}"));
      }
      #shutdown:hover {
        background-image: image(url("${./icons/power.png}"));
      }

      #reboot {
        background-image: image(url("${./icons/restart-hover.png}"));
      }
      #reboot:focus {
        background-image: image(url("${./icons/restart.png}"));
      }
      #reboot:hover {
        background-image: image(url("${./icons/restart.png}"));
      }

      #lock {
        background-image: image(url("${./icons/lock-hover.png}"));
      }
      #lock:focus {
        background-image: image(url("${./icons/lock.png}"));
      }
      #lock:hover {
        background-image: image(url("${./icons/lock.png}"));
      }
    '';
  };
}
