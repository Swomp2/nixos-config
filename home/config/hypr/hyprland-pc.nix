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
          output = "DP-1";
          mode = "2560x1440@165";
          position = "auto";
          scale = 1;

          bitdepth = 10;

          cm = "hdredid";
          supports_hdr = 1;
          supports_wide_color = 1;

          # min_luminance = 0.45;
          # max_luminance = 450;
          # max_avg_luminance = 400;

          sdr_min_luminance = 0.2;
          sdr_max_luminance = 220;
          sdrbrightness = 1.1;
          sdrsaturation = 1.2;

          vrr = 1;
        }
      ];

      render = {
        cm_enabled = true;
        cm_auto_hdr = 1;
        send_content_type = true;

        keep_unmodified_copy = 2;

        use_fp16 = 2;

        non_shader_cm = 2;
        use_shader_blur_blend = true;

        cm_sdr_eotf = "gamma22";
      };

      input = {
        kb_layout = "us, ru";
        kb_options = "grp:rshift_toggle";
        natural_scroll = true;
        accel_profile = "adaptive";
        sensitivity = 1;
      };

      bind = [
        "SUPER CTRL, L, exec, bemenu-lockscreen"
        "SUPER CTRL, F, togglefloating, active"

        "SUPER CTRL, M, layoutmsg, swapwithmaster"
        "SUPER CTRL, H, movewindow, l"
        "SUPER CTRL, T, movewindow, d"
        "SUPER CTRL, N, movewindow, u"
        "SUPER CTRL, S, movewindow, r"
      ]
      ++ builtins.concatLists (
        map (ws: [
          "SUPER CTRL, ${toString ws}, movetoworkspacesilent, ${toString ws}"
        ]) workspaces
      );
    };
  };
}
