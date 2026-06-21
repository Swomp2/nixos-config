{ ... }:
let
  workspaces = builtins.genList (x: x + 1) 9;
in
{
  imports = [ ./common.nix ];

  wayland.windowManager.hyprland = {
    settings = {
      monitorv2 = [
        {
          output = "eDP-1";
          mode = "2048x1280@120";
          position = "auto";
          scale = 1;

          bitdepth = 10;
          vrr = 1;
        }
      ];

      input = {
        kb_layout = "us, ru";
        kb_options = "grp:win_space_toggle";
        kb_variant = "dvorak,";
        natural_scroll = true;
        accel_profile = "adaptive";
        sensitivity = 0.9;
      };

      binde = [
        ", XF86MonBrightnessUp, exec, swayosd-client --brightness +5"
        ", XF86MonBrightnessDown, exec, swayosd-client --brightness -5"
      ];

      bind = [
        "SUPER ALT, L, exec, bemenu-lockscreen"
        "SUPER ALT, F, togglefloating, active"

        "SUPER ALT, M, layoutmsg, swapwithmaster"
        "SUPER ALT, H, movewindow, l"
        "SUPER ALT, T, movewindow, d"
        "SUPER ALT, N, movewindow, u"
        "SUPER ALT, S, movewindow, r"
      ]
      ++ builtins.concatLists (
        map (ws: [
          "SUPER ALT, ${toString ws}, movetoworkspacesilent, ${toString ws}"
        ]) workspaces
      );

      gesture = [
        "3, vertical, workspace"
      ];
    };
  };
}
