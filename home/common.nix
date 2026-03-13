{config, pkgs, inputs, lib, ...}:
let
  unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system};
in
{

  # Отключение шрифтов на уровне home manager, потому что они включены на системном уровне
  fonts.fontconfig.enable = lib.mkForce false;
  imports = [
    ./desktop.nix
  ];

  xdg.configFile."emacs".source = ./config/emacs.d;
  xdg.configFile."emacs".recursive = true;

  xdg.configFile."fish".source = ./config/fish;
  xdg.configFile."fish".recursive = true;

  xdg.configFile."starship.toml".source = ./config/starship/starship.toml;

  xdg.configFile."mpv".source = ./config/mpv;
  xdg.configFile."mpv".recursive = true;

  xdg.configFile."bemenu".source = ./config/bemenu;
  xdg.configFile."bemenu".recursive = true;

  xdg.configFile."gammastep/config.ini".source = ./config/gammastep/config.ini;

  xdg.configFile."hypr/hyprlock.conf".source = ./config/hypr/hyprlock.conf;
  xdg.configFile."hypr/hypridle.conf".source = ./config/hypr/hypridle.conf;

  xdg.configFile."waybar/config.jsonc".source = ./config/waybar/config.jsonc;
  xdg.configFile."waybar/style.css".source = ./config/waybar/style.css;

  xdg.configFile."kitty/kitty.conf".source = ./config/kitty/kitty.conf;
  xdg.configFile."kitty/gruvbox_dark.conf".source = ./config/kitty/gruvbox_dark.conf;

  xdg.configFile."dunst/dunstrc".source = ./config/dunst/dunstrc;

  xdg.configFile."gtk-3.0".source = ./config/gtk-3.0;
  xdg.configFile."gtk-3.0".recursive = true;

  xdg.configFile."gtk-4.0".source = ./config/gtk-4.0;
  xdg.configFile."gtk-4.0".recursive = true;

  xdg.configFile."Kvantum".source = ./config/Kvantum;
  xdg.configFile."Kvantum".recursive = true;

  xdg.configFile."btop".source = ./config/btop;
  xdg.configFile."btop".recursive = true;

  xdg.configFile."nwg-look".source = ./config/nwg-look;
  xdg.configFile."nwg-look".recursive = true;

  xdg.configFile."pavucontrol-qt".source = ./config/pavucontrol-qt;
  xdg.configFile."pavucontrol-qt".recursive = true;

  xdg.configFile."strawberry".source = ./config/strawberry;
  xdg.configFile."strawberry".recursive = true;

  xdg.enable = true;

  # Включение starship
  programs.starship = {
    enable = true;
  };

  home.packages = with pkgs; [
    cargo
    rustc
    rustfmt
    rust-analyzer
    nodejs_24
    pyright
    eslint
    prettier
    tex-fmt
    asm-lsp
    texlab
    starship
    unstable.yt-dlp
    texliveFull
    ranger
    atuin
  ];
}
