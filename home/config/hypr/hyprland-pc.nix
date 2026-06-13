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
    ./winRules.nix
    ./envVars.nix
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

          vrr           = 1;
        }
      ];

      input = {
        kb_layout      = "us, ru";
        kb_options     = "grp:rshift_toggle";
        natural_scroll = true;
        accel_profile  = "adaptive";
        sensitivity    = 1;
      };

      bind = [
        "SUPER CTRL, L, exec, bemenu-lockscreen"
        "SUPER CTRL, F, togglefloating, active"
        
        "SUPER CTRL, M, layoutmsg, swapwithmaster"
        "SUPER CTRL, H, movewindow, l"
        "SUPER CTRL, T, movewindow, d"
        "SUPER CTRL, N, movewindow, u"
        "SUPER CTRL, S, movewindow, r"
      ] ++ builtins.concatLists (
        map (ws: [
          "SUPER CTRL, ${toString ws}, movetoworkspacesilent, ${toString ws}"
        ]) workspaces
      );
    };
  };
}
