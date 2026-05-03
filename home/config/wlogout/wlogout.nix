{...}:
{
  programs.wlogout = {
    enable = true;

    layout = [
      {
        "label"   = "shutdown";
        "action"  = "systemctl poweroff";
        "keybind" = "s";
        "width"   = 0.18;
        "height"  = 0.55;
      }
      {
        "label"   = "reboot";
        "action"  = "systemctl reboot";
        "keybind" = "r";
        "width"   = 0.18;
        "height"  = 0.55;
      }
      {
        "label"  = "logout";
        "action"  = "hyprctl dispatch exit";
        "keybind" = "o";
        "width"   = 0.18;
        "height"  = 0.55;
      }
      {
        "label"   = "lock";
        "action"  = "bemenu-lockscreen";
        "keybind" = "l";
        "width"   = 0.18;
        "height"  = 0.55;
      }
    ];

    style = ''
      window {
        font-family: FiraCode Nerd Font;
        font-size: 14pt;
        color: #282828; /* text */
        background-color: transparent;
      }

      button {
        background-repeat: no-repeat;
        background-position: center;
        background-size: 50%;
        border-style: solid;
        border-radius: 8px;
        border-width: 2px;
        border-color: #d65d0e;
        background-color: #ebdbb2;
        color: #282828;
        margin: 10px;
        transition:
        background-color 0.3s ease-in-out;
      }

      button:hover {
        background-color: #3c3836;
        color: #ebdbb2;
      }

      button:focus {
        background-color: #282828;
        color: #ebdbb2;
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
