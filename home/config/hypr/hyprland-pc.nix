{...}:
let 
  workspaces = builtins.genList (x: x + 1) 9;
in
{
  imports = [
    ./animations.nix
    ./autostart.nix
    ./common.nix
    ./commonBinds.nix
    ./envVars.nix
    ./winRules.nix
    ./plugins.nix
    ./hypridle.nix
    ./hyprlock.nix
    ./hyprsunset.nix
  ];

  wayland.windowManager.hyprland = {
    settings = {
      monitorv2 = [
        {
          output        = "DP-1";
          mode          = "2560x1440@165";
          position      = "auto";
          scale         = 1;

          bitdepth      = 10;
          cm            = "hdr";

          vrr           = 1;

          sdrbrightness = 1.3;
          sdrsaturation = 1.0;
        }
      ];

      input = {
        kb_layout      = "us, ru";
        kb_options     = "grp:rshift_toggle";
        natural_scroll = true;
        accel_profile  = "adaptive";
        sensitivity    = 1;
      };

      "$mod" = "SUPER";

      bind = [
        "$mod CTRL, L, exec, bemenu-lockscreen"
        "$mod CTRL, F, togglefloating, active"
        
        "$mod CTRL, M, layoutmsg, swapwithmaster"
        "$mod CTRL, H, movewindow, l"
        "$mod CTRL, T, movewindow, d"
        "$mod CTRL, N, movewindow, u"
        "$mod CTRL, S, movewindow, r"
      ] ++ builtins.concatLists (
        map (ws: [
          "$mod CTRL, ${toString ws}, movetoworkspacesilent, ${toString ws}"
        ]) workspaces
      );
    };
  };
}