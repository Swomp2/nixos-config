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
          position = "0x0";
          scale = 1;

          bitdepth = 10;
          cm = "dcip3";

          supports_wide_color = 1;
          supports_hdr = 1;

          min_luminance = 0.0005;
          max_luminance = 500;
          max_avg_luminance = 400;

          vrr = 0;
        }

        # Внешние подключаемые мониторы
        {
          output = "";
          mode = "preffered";
          position = "auto";
          scale = "auto";
        }
      ];

      render = {
        cm_enabled = true;

        # HDR будет включаться только для полноэкранного hdr контента
        cm_auto_hdr = 2;
        send_content_type = true;

        keep_unmodified_copy = 2;
        use_fp16 = 2;
        non_shader_cm = 2;
        use_shader_blur_blend = true;

        cm_sdr_eotf = "gamma22";
      };

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
