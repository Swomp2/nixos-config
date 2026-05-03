{config, pkgs, inputs, ...}:
let

  mkFishBin = name: file:
    pkgs.writeShellScriptBin name ''
      exec ${pkgs.fish}/bin/fish ${file} "$@"
    '';
in
{
  imports = [
    ./desktop.nix
    ./config/starship/starship.nix
    ./config/ranger/ranger.nix
    ./config/wlogout/wlogout.nix
    ./config/wofi/wofi.nix
    ./config/kitty/kitty.nix
    ./config/fish/fish.nix
    ./config/dunst/dunst.nix
    ./config/btop/btop.nix
  ];

  xdg.configFile."mpv".source = ./config/mpv;
  xdg.configFile."mpv".recursive = true;

  xdg.configFile."btop".source = ./config/btop;
  xdg.configFile."btop".recursive = true;

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
