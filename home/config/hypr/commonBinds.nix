{...}:
let
  workspaces = builtins.genList (x: x + 1) 9;
in
{
  wayland.windowManager.hyprland = {
    settings = {
      "$mod" = "SUPER";

      bind = [
        "$mod, I, exec, uwsm app -- pcmanfm-qt"
        "$mod, U, exec, uwsm app -- firefox"
        "$mod, O, exec, uwsm app -- strawberry"
        "$mod, P, exec, uwsm app -- kitty"

        "$mod, V, exec, bemenu-wallpapers"
        "$mod, W, exec, bemenu-swww-random"
        "$mod, semicolon, killactive"
        ''$mod, A, exec, sh -lc 'app=$(wofi --show drun --define=drun-print_desktop_file=true | sed -E "s/(\\.desktop) /\\1:/"); [ -n "$app" ] && exec uwsm app -- "$app" || exit 0' ''
        "$mod, E, exec, wlogout --buttons-per-row 4 --column-spacing 20 --row-spacing 20 --margin-left 500 --margin-right 500 --margin-top 500 --margin-bottom 500"
        "$mod, J, exec, bemenu-cliphist"
        ", PRINT, exec, bemenu-screenshot"

        "$mod, Y, fullscreen, 0"
        "$mod, H, movefocus, l"
        "$mod, T, movefocus, d"
        "$mod, N, movefocus, u"
        "$mod, S, movefocus, r"
        "$mod, M, layoutmsg, focusmaster"

        ", XF86AudioMicMute, exec, swayosd-client --input-volume mute-toggle"
        ", XF86AudioPlay, exec, swayosd-client --playerctl play-pause"
        ", Caps_Lock, exec, swayosd-client --caps-lock"
      ] ++ builtins.concatLists (
        map (ws: [
          "$mod, ${toString ws}, workspace, ${toString ws}"
        ]) workspaces
      );

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      binde = [
        ", XF86AudioRaiseVolume, exec, swayosd-client --output-volume 5 --max-volume 100"
        ", XF86AudioLowerVolume, exec, swayosd-client --output-volume -5 --max-volume 100"
        ", XF86AudioMute, exec, swayosd-client --output-volume mute-toggle"
        ", XF86AudioNext, exec, swayosd-client --playerctl next"
        ", XF86AudioPrev, exec, swayosd-client --playerctl previous"
      ];
    };
  };
}
