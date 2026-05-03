{...}:
{
  programs.wofi = {
    enable = true;

    settings = {
      show               = "drun";
      mode               = "drun";
      width              = "17%";
      height             = "40%";
      columns            = 1;
      prompt             = "Поиск";
      "filter_rate"      = 100;
      "allow_markup"     = true;
      "no_actions"       = true;
      halign             = "fill";
      valign             = "start";
      "content_halign"   = "fill";
      orientation        = "vertical";
      insensitive        = true;
      "allow_images"     = true;
      "image_size"       = 48;
      "gtk_dark"         = true;
      layer              = "overlay";
      term               = "kitty";
      "hide_scroll"      = true;
      "normal_window"    = false;
      "line_wrap"        = "word_char";
      "dynamic_lines"    = true;
      matching           = "multi-contains";
      "pre_display_exec" = true;
      "parse_search"     = true;
    };

    style = ''
      window {
        margin: 0px;
        border: 2px solid #d65d0e;
        border-width: 2px;
        background-color: #282828;
        border-radius: 8px;
      }

      #input {
        padding: 4px;
        margin: 4px;
        border: none;
        border-width: 2px;
        color: #ebdbb2;
        font-family: FiraCode Nerd Font;
        font-size: 16px;
        font-weight: 800;
        background-color: transparent;
        outline: none;
        border-radius: 8px;
        margin: 10px 13px;
        margin-bottom: 2px;
      }
      #input:focus {
        border: 2px solid #d65d0e;
        box-shadow: none;
        outline: none;
      }

      #inner-box {
        margin: 4px;
        border: 4px solid transparent;
        color: #ebdbb2;
        font-weight: normal;
        background-color: transparent;
        /* background-color: red; */
        border-radius: 4px;
      }

      #outer-box {
        margin: 0px;
        border: 2px solid #d65d0e;
        border-radius: 8px;
        background-color: #282828;
      }

      #scroll {
        margin: 5px 13px 5px 13px;
      }

      #inner-box {
        margin: 0px;
        padding: 0px;
        border: none;
        background-color: transparent;
      }

      #entry,
      #entry:hover,
      #entry:focus,
      #entry:selected,
      #entry:selected:focus,
      #entry:selected:hover {
        margin: -1px -1px;
        padding: 5px 5px;
        border: 2px solid transparent;
        border-radius: 8px;
        outline: none;
        box-shadow: none;
        background-color: transparent;
      }

      #entry:selected,
      #entry:selected:focus,
      #entry:selected:hover {
        background-color: #ebdbb2;
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
        color: #ebdbb2;
        background-color: transparent;
      }

      #entry:selected #text,
      #entry:selected label {
        color: #282828;
        background-color: transparent;
      }
    '';
  };
}