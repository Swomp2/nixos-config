{...}:
let
  theme = ../../../theme.nix;
in
{
  imports = [
  	./base.nix
  	./format.nix
  	./langs.nix
  	./latex.nix
  	./lsp.nix
  	./markdown.nix
  	./ui.nix
  ];

  home.sessionVariables = {
  	EDITOR = "nvim";
  	VISUAL = "nvim";
  };

  programs.nixvim = {
  	enable = true;

  	vimAlias = true; # vim тоже будет открывать nvim
  	waylandSupport = true; # Включает поддержку буфера обмена wayland

  	withNodeJs = true; # Node провайдер для некоторых плагинов
  	withPython3 = true; # Python провайдер для некоторых плагинов
  	withRuby = true; # Ruby провайдер для некоторых плагинов
  	withPerl = true; # Perl провайдер для некоторых плагинов
  };
}
