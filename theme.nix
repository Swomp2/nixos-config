{
  colors = {
    bg = "#282828";
    bgAlt = "#3c3836";
    bgMuted = "#665c54";
    fg = "#ebdbb2";
    fgStrong = "#fbf1c7";
    muted = "#928374";
    accent = "#d65d0e";
    warning = "#d79921";
    warningBright = "#fabd2d";
    error = "#cc241d";
    errorBright = "#fb4934";
    green = "#98971a";
    greenBright = "#b8bb26";
    blue = "#458588";
    blueBright = "#83a598";
    purple = "#b16286";
    purpleBright = "#d3869b";
    aqua = "#689d6a";
    aquaBright = "#8ec07c";
    neutral = "#a89984";
  };

  fonts = {
    ui = "Ubuntu";
    uiRegular = "Ubuntu Regular";
    mono = "FiraCode Nerd Font";
    icons = "FiraCode Nerd Font";

    sizes = {
      small = 10;
      normal = 12;
      large = 18;
    };
  };

  spacing = {
    xs = 4;
    sm = 5;
    md = 8;
    lg = 10;
    xl = 13;
  };

  borders = {
    radius = 8;
    notificationRadius = 5;
    width = 2;
  };

  opacity = {
    normal = 1.0;
    inactive = 0.9;
    terminal = 0.8;
  };

  cursor = {
    xcursorName = "BreezeX-RosePine-Linux";
    hyprcursorName = "rose-pine-hyprcursor";
    size = 32;
  };

  gtk = {
    themeName = "Gruvbox-Dark";
    iconThemeName = "Papirus-Dark";
  };

  qt = {
    platformTheme = "qt6ct";
    style = "kvantum";
    kvantumTheme = "Gruvbox-Dark-Brown";
  };

  toHyprRgb = color: "rgb(${builtins.substring 1 6 color})";
}
