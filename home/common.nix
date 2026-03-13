{config, pkgs, ...}:
{
  imports = [
    ./desktop.nix
  ];
  home.username = "swomp";
  home.homeDirectory = "/home/swomp/";
  home.stateVersion = "25.11";

  xdg.enable = true;

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
    biber
    texliveFull
    ranger
  ];
}
