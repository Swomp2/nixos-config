{
  lib,
  theme,
  laptop ? false,
}:
let
  inherit (theme)
    borders
    colors
    fonts
    spacing
    ;
in
''
  * {
    font-family: "${fonts.ui}";
    font-size: ${toString fonts.sizes.large}px;
    margin: 0;
    padding: 0;
    min-height: 0;
    border-radius: ${toString borders.radius}px;
  }

  window#waybar {
    background: transparent;
    color: ${colors.fgStrong};
  }

  #workspaces {
    background: ${colors.bg};
    border-radius: ${toString borders.radius}px;
  }

  #workspaces button {
    padding: 0 ${toString spacing.lg}px;
    background: transparent;
    color: ${colors.fgStrong};
    border-radius: ${toString borders.radius}px;
    box-shadow: none;
  }

  #workspaces button:hover {
    box-shadow: none;
  }

  #workspaces button.focused,
  #workspaces button.active,
  #workspaces button.persistent {
    background-color: ${colors.accent};
    color: ${colors.bg};
  }

  #workspaces button.urgent {
    background-color: ${colors.error};
    color: ${colors.bg};
  }

  #language,
  #wireplumber,
  #clock,
  #network {
    font-family: "${fonts.ui}";
  }

  #language,
  #wireplumber,
  #network,
  #clock,
  #tray {
    background-color: ${colors.accent};
    color: ${colors.bg};
  }

  #language,
  #wireplumber,
  #clock,
  #network {
    padding: 0 ${toString spacing.lg}px;
  }

  #tray {
    background-color: ${colors.accent};
    padding-left: ${toString spacing.lg}px;
    padding-right: ${toString spacing.lg}px;
    border-radius: ${toString borders.radius}px;
  }

  #idle_inhibitor {
    padding: 0 ${toString spacing.lg}px 0 ${toString spacing.md}px;
    transition:
      background-color 0.2s ease,
      color 0.2s ease,
      padding 0.1s ease;
  }

  #idle_inhibitor.deactivated {
    background-color: ${colors.accent};
    color: ${colors.bg};
  }

  #idle_inhibitor.activated {
    background-color: ${colors.warning};
    color: ${colors.bg};
  }

  #idle_inhibitor:hover {
    background-color: ${colors.warning};
  }

  #idle_inhibitor:active {
    padding-left: ${toString spacing.lg}px;
    padding-right: ${toString spacing.lg}px;
  }

  #gamemode {
    background-color: ${colors.accent};
    color: ${colors.bg};
  }

  #gamemode.running {
    background-color: ${colors.warning};
    color: ${colors.bg};
  }

  #network.disconnected {
    background-color: ${colors.error};
    color: ${colors.bg};
  }

  ${lib.optionalString laptop ''
    #bluetooth {
      padding-left: ${toString spacing.lg}px;
      padding-right: ${toString spacing.lg}px;
    }

    #bluetooth.connected {
      background-color: ${colors.error};
      color: ${colors.bg};
    }

    #bluetooth.disabled,
    #bluetooth.off,
    #bluetooth.on {
      background-color: ${colors.accent};
      color: ${colors.bg};
    }

    #power-profiles-daemon {
      background-color: ${colors.accent};
      color: ${colors.bg};
      padding-left: ${toString spacing.lg}px;
      padding-right: ${toString spacing.lg}px;
    }

    #power-profiles-daemon.performance {
      background-color: ${colors.error};
    }

    #power-profiles-daemon.balanced {
      background-color: ${colors.warning};
    }

    #backlight {
      background-color: ${colors.accent};
      color: ${colors.bg};
      padding-left: ${toString spacing.lg}px;
      padding-right: ${toString spacing.lg}px;
    }

    #battery {
      background-color: ${colors.accent};
      color: ${colors.bg};
      padding-left: ${toString spacing.lg}px;
      padding-right: ${toString spacing.lg}px;
    }

    #battery.critical {
      background-color: ${colors.error};
      color: ${colors.bg};
    }

    #battery.charging {
      background-color: ${colors.warning};
    }
  ''}
''
