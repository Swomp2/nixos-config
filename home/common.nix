{ pkgs, theme, ... }:
let
  bemenuTheme = pkgs.writeText "bemenu-theme.fish" ''
    set -g theme_bg '${theme.colors.bg}'
    set -g theme_fg '${theme.colors.fgStrong}'
    set -g theme_accent '${theme.colors.accent}'
    set -g theme_border_width '${toString theme.borders.width}'
    set -g theme_radius '${toString theme.borders.radius}'

    set -g bemenu_theme_args \
      --nb "$theme_bg" \
      --nf "$theme_fg" \
      --tb "$theme_accent" \
      --tf "$theme_bg" \
      --fb "$theme_bg" \
      --ff "$theme_fg" \
      --hb "$theme_accent" \
      --hf "$theme_bg" \
      --ab "$theme_bg" \
      --af "$theme_fg" \
      --border "$theme_border_width" \
      --bdr "$theme_accent" \
      --fn '${theme.fonts.uiRegular} ${toString theme.fonts.sizes.normal}'
  '';

  mkFishBin =
    name: file:
    pkgs.writeShellScriptBin name ''
      exec ${pkgs.fish}/bin/fish -C 'source ${bemenuTheme}' ${file} "$@"
    '';
in
{
  imports = [
    ./desktop.nix
    ./flatpak.nix
    ./config/starship/starship.nix
    ./config/ranger/ranger.nix
    ./config/wlogout/wlogout.nix
    ./config/wofi/wofi.nix
    ./config/kitty/kitty.nix
    ./config/fish/fish.nix
    ./config/dunst/dunst.nix
    ./config/btop/btop.nix
    ./config/uwsm/env.nix
    ./config/firefox/firefox.nix
  ];

  home.language = {
    base = "ru_RU.UTF-8";
    messages = "ru_RU.UTF-8";
    time = "ru_RU.UTF-8";
    numeric = "ru_RU.UTF-8";
    monetary = "ru_RU.UTF-8";
    paper = "ru_RU.UTF-8";
    measurement = "ru_RU.UTF-8";
  };

  home.sessionVariables = {
    LANGUAGE = "ru_RU:ru";
  };

  xdg.configFile."mpv".source = ./config/mpv;
  xdg.configFile."mpv".recursive = true;

  xdg.configFile."nwg-look".source = ./config/nwg-look;
  xdg.configFile."nwg-look".recursive = true;

  xdg.configFile."pavucontrol-qt".source = ./config/pavucontrol-qt;
  xdg.configFile."pavucontrol-qt".recursive = true;

  xdg.enable = true;

  home.packages = with pkgs; [
    (mkFishBin "bemenu-cliphist" ./config/bemenu/cliphist.fish)
    (mkFishBin "bemenu-lockscreen" ./config/bemenu/lockscreen.fish)
    (mkFishBin "bemenu-pavucontrol" ./config/bemenu/pavucontrol.fish)
    (mkFishBin "bemenu-swww-random" ./config/bemenu/swww-random.fish)
    (mkFishBin "bemenu-screenshot" ./config/bemenu/screenshot.fish)
    (mkFishBin "bemenu-wallpapers" ./config/bemenu/wallpapers.fish)
    (mkFishBin "bemenu-wifi" ./config/bemenu/wifi.fish)
  ];
}
