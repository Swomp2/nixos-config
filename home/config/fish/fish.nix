{ config, ... }:
let
  home = config.home.homeDirectory;
in
{
  programs.fish = {
    enable = true;

    shellInit = ''
      set fish_greeting ""

      set -g fish_color_autosuggestion brblack
      set -g fish_color_cancel -r
      set -g fish_color_command normal
      set -g fish_color_comment red
      set -g fish_color_cwd green
      set -g fish_color_cwd_root red
      set -g fish_color_end green
      set -g fish_color_error brred
      set -g fish_color_escape brcyan
      set -g fish_color_history_current --bold
      set -g fish_color_host normal
      set -g fish_color_host_remote yellow
      set -g fish_color_normal normal
      set -g fish_color_operator brcyan
      set -g fish_color_param cyan
      set -g fish_color_quote yellow
      set -g fish_color_redirection cyan --bold
      set -g fish_color_search_match white --background=brblack
      set -g fish_color_selection white --bold --background=brblack
      set -g fish_color_status red
      set -g fish_color_user brgreen
      set -g fish_color_valid_path --underline

      set -g fish_pager_color_completion normal
      set -g fish_pager_color_description yellow -i
      set -g fish_pager_color_prefix normal --bold --underline
      set -g fish_pager_color_progress brwhite --background=cyan
      set -g fish_pager_color_selected_background -r
    '';

    interactiveShellInit = ''
      fish_default_key_bindings

      set -gx ATUIN_NOBIND true

      if command -q atuin
        atuin init fish | source

        bind \cr _atuin_search
        bind -M insert \cr _atuin_search
      end
    '';
  };

  programs.atuin = {
    enable = true;
    enableFishIntegration = false;
  };

  home.sessionVariables = {
    STOW_DIR = "${home}/Stow";
    STOW_TARGET = home;
  };

  home.sessionPath = [
    "${home}/.local/bin"
    "${home}/.nix-profile/bin"
    "${home}/.local/share/npm/bin"
    "${home}/.cargo/bin"
  ];
}