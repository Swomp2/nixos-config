{config, pkgs, inputs, ...}:
let
  unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system};
in
{
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
