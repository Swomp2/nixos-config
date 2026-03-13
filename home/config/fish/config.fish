starship init fish | source
set fish_greeting ""

fish_add_path ~/.nix-profile/bin

if status is-interactive
    set -gx ATUIN_NOBIND "true"
    atuin init fish | source

    bind \cr _atuin_search
    bind -M insert \cr _atuin_search
end
