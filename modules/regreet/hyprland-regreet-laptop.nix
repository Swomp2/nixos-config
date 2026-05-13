{config, lib, pkgs, inputs, ...}:
{
    environment.etc."greetd/hyprland.conf".text = 
        inputs.home-manager.lib.hm.generators.toHyprconf {

        	importantPrefixes = [
        		"$"
        		"bezier"
        		"name"
        		"output"
        	];
            attrs = {
                monitorv2 = {
                    output   = "eDP-1";
                    mode     = "2048x1280@120";
                    position = "auto";
                    scale    = 1;

                    bitdepth = 10;
                    cm       = "auto";
                    vrr      = 1;
                };

                exec-once = [
                    "${config.programs.regreet.package}/bin/regreet; ${config.programs.hyprland.package}/bin/hyprctl dispatch exit"
                ];

                env = [
                    "HYPRCURSOR_THEME, rose-pine-hyprcursor"
                    "HYPRCURSOR_SIZE, 32"
                ];

                input = {
                    kb_layout  = "us, ru";
                    kb_variant = "dvorak,";
                    kb_options = "grp:win_space_toggle";

                    follow_mouse = 0;

                    natural_scroll = true;
                    accel_profile  = "adaptive";
                    sensitivity    = 0.9;
                };

                general = {
                    gaps_in               = 0;
                    gaps_out              = 0;
                    border_size           = 0;
                };

                decoration   = {
                    rounding = 0;

                    shadow  = {
                    enabled = false;
                    };

                    blur    = {
                    enabled = false;
                    };
                };

                misc = {
                    disable_hyprland_logo           = true;
                    disable_splash_rendering        = true;
                    disable_hyprland_guiutils_check = true;
                    force_default_wallpaper         = 0;
                    disable_watchdog_warning        = true;
                };

                ecosystem = {
                    no_update_news  = true;
                    no_donation_nag = true;
                };

                windowrule = [
                    "match:class ^(regreet)$, float on"
                ];
            };
        };
}
