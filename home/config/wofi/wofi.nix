{ theme, ... }:
{
  programs.wofi = {
    enable = true;

    settings = {
      show = "drun";
      mode = "drun";
      width = "17%";
      height = "40%";
      columns = 1;
      prompt = "Поиск";
      "filter_rate" = 100;
      "allow_markup" = true;
      "no_actions" = true;
      halign = "fill";
      valign = "start";
      "content_halign" = "fill";
      orientation = "vertical";
      insensitive = true;
      "allow_images" = true;
      "image_size" = 48;
      "gtk_dark" = true;
      layer = "overlay";
      term = "kitty";
      "hide_scroll" = true;
      "normal_window" = false;
      "line_wrap" = "word_char";
      "dynamic_lines" = true;
      matching = "multi-contains";
      "pre_display_exec" = true;
      "parse_search" = true;
    };

    style = ''
      window {
        margin: 0px;
        border: ${toString theme.borders.width}px solid ${theme.colors.accent};
        background-color: ${theme.colors.bg};
        border-radius: ${toString theme.borders.radius}px;
      }

      #input {
        padding: 4px;
        margin: 4px;
        border: none;
        border-width: 2px;
        color: ${theme.colors.fg};
        font-family: ${theme.fonts.mono};
        font-size: 16px;
        font-weight: 800;
        background-color: transparent;
        outline: none;
        border-radius: ${toString theme.borders.radius}px;
        margin: 10px 13px;
        margin-bottom: 2px;
      }
      #input:focus {
        border: ${toString theme.borders.width}px solid ${theme.colors.accent};
        box-shadow: none;
        outline: none;
      }

      #outer-box {
        margin: 0px;
        border: ${toString theme.borders.width}px solid ${theme.colors.accent};
        border-radius: ${toString theme.borders.radius}px;
        background-color: ${theme.colors.bg};
      }

      #scroll {
        margin: 5px 13px 5px 13px;
      }

      #inner-box {
        margin: 0px;
        padding: 0px;
        border: none;
        color: ${theme.colors.fg};
        font-weight: normal;
        background-color: transparent;
        border-radius: ${toString theme.spacing.xs}px;
      }

      #entry,
      #entry:hover,
      #entry:focus,
      #entry:selected,
      #entry:selected:focus,
      #entry:selected:hover {
        margin: -1px -1px;
        padding: 5px 5px;
        border: ${toString theme.borders.width}px solid transparent;
        border-radius: ${toString theme.borders.radius}px;
        outline: none;
        box-shadow: none;
        background-color: transparent;
      }

      #entry:selected,
      #entry:selected:focus,
      #entry:selected:hover {
        background-color: ${theme.colors.fg};
      }

      #img,
      #entry image {
        margin-left: 0px;
        margin-right: 10px;
        padding: 0px;
        border: none;
        background-color: transparent;
      }

      #text,
      #entry label {
        color: ${theme.colors.fg};
        background-color: transparent;
      }

      #entry:selected #text,
      #entry:selected label {
        color: ${theme.colors.bg};
        background-color: transparent;
      }
    '';
  };
}
