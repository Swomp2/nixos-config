{...}:
{
  wayland.windowManager.hyprland = {

    bezier = [
      "open, 0.645, 0.045, 0.355, 1"
      "close, 0.11, 0.73, 0.93, 0.02"
      "switch, 0.5, -1, 0.265, 2"
      "fade_move, 0.46, 0.46, 0.75, 0.77"
      "windows_move, 1, 0, 0, 1"
      "layers_animation, 0.87, 0.02, 0.01, 0.97"
      "layers_fade, 0.59, 0.59, 0.59, 0.59"
    ];

    animation = [
      "workspaces, 1, 4, switch, slidefadevert"
      "windowsIn, 1, 3.3, open, popin"
      "windowsOut, 1, 3.3, close, popin"
      "windowsMove, 1, 3, windows_move"
      "fadeIn, 1, 2, default"
      "fadeOut, 1, 2, default"
      "fadeSwitch, 1, 2, windows_move"
      "fadeShadow, 1, 2, default"
      "fadeDim, 1, 2, default"
      "fadeLayers, 1, 1, windows_move"
      "layersIn, 1, 1, default, slide"
      "layersOut, 1, 1, windows_move, slide"
    ];

    layerrule = [
      {
        name = "no_anim_for_hyprshot_selection";
        no_anim = true;
        "match:namespace" = "selection";
      }
    ];
  };
}