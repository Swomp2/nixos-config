{...}:
let
  workspaces = builtins.genList (x: x + 1) 9;
in
{
  wayland.windowManager.hyprland = {
    settings = {

      bind = [
        "SUPER, I, exec, uwsm app -- pcmanfm-qt"
        "SUPER, U, exec, uwsm app -- firefox"
        "SUPER, O, exec, uwsm app -- strawberry"
        "SUPER, P, exec, uwsm app -- kitty"

        "SUPER, V, exec, bemenu-wallpapers"
        "SUPER, W, exec, bemenu-swww-random"
        "SUPER, semicolon, killactive"
        ''SUPER, A, exec, sh -lc 'app=$(wofi --show drun --define=drun-print_desktop_file=true | sed -E "s/(\\.desktop) /\\1:/"); [ -n "$app" ] && exec uwsm app -- "$app" || exit 0' ''
        "SUPER, E, exec, wlogout --buttons-per-row 4 --column-spacing 20 --row-spacing 20 --margin-left 500 --margin-right 500 --margin-top 500 --margin-bottom 500"
        "SUPER, J, exec, bemenu-cliphist"
        ", PRINT, exec, bemenu-screenshot"

        "SUPER, Y, fullscreen, 0"
        "SUPER, H, movefocus, l"
        "SUPER, T, movefocus, d"
        "SUPER, N, movefocus, u"
        "SUPER, S, movefocus, r"
        "SUPER, M, layoutmsg, focusmaster"

        ", XF86AudioMicMute, exec, swayosd-client --input-volume mute-toggle"
        ", XF86AudioPlay, exec, swayosd-client --playerctl play-pause"
        ", Caps_Lock, exec, swayosd-client --caps-lock"
      ] ++ builtins.concatLists (
        map (ws: [
          "SUPER, ${toString ws}, workspace, ${toString ws}"
        ]) workspaces
      );

      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
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
