{...}:
{
  programs.waybar = {

    # Настройки бара и модулей
    settings = {
      mainBar = {
        layer          = "top";
        position       = "top";
        height         = 25;
        spacing        = 3;
        "margin-top"   = 5;
        "margin-left"  = 4;
        "margin-right" = 4;

        "modules-left" = [
          "network"
          "wireplumber"
          "gamemode"
        ];

        "modules-center" = [
          "hyprland/workspaces"
        ];

        "modules-right" = [
          "tray"
          "hyprland/language"
          "clock"
          "idle_inhibitor"
        ];

        tray = {
          icon-size = 20;
          spacing   = 8;
        };

        wireplumber = {
          format         = "<span font_desc='FiraCode Nerd Font 16'>{icon}</span>   {volume}%";
          "format-muted" = "<span font_desc='FiraCode Nerd Font 16'></span>   Без звука";
          "format-icons" = {
            default      = ["" "" ""];
          };
          "on-click-right" = "bemenu-pavucontrol";
          "on-click"       = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          "on-scroll-up"   = "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+";
          "on-scroll-down" = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
          tooltip          = false;
        };

        clock = {
          format       = "<span font_desc='FiraCode Nerd Font 16'></span>  {:%I:%M}";
          "format-alt" = "<span font_desc='FiraCode Nerd Font 16'></span>  {:%a %e %b %Y}";
          tooltip      = false;
        };

        network = {
          "format-ethernet"     = "<span font_desc='FiraCode Nerd Font 16'></span>   Подключено";
          "format-disconnected" = "<span font_desc='FiraCode Nerd Font 16'></span>   Отключено";
          tooltip               = false;
        };

        "hyprland/language" = {
          "format-en"       = "<span font_desc='FiraCode Nerd Font 16'></span>   En";
          "format-ru"       = "<span font_desc='FiraCode Nerd Font 16'></span>   Ru";
          "on-click"        = "hyprctl switchxkblayout current next";
          tooltip           = false;
        };

        "idle_inhibitor" = {
          format         = "<span font_desc='FiraCode Nerd Font 16'>{icon}</span>";
          "format-icons" = {
            activated    = "";
            deactivated  = "";
          };
          tooltip        = false;
        };

        "hyprland/workspaces" = {
          "active-only"       = false;
          format              = "{name}";
          "sort-by-number"    = true;
          "on-click"          = "activate";
          "on-scroll-up"      = "hyprctl dispatch workspace -1";
          "on-scroll-down"    = "hyprctl dispatch workspace +1";
          tooltip             = false;
        };

        gamemode = {
          format             = "{glyph}";
          "format-alt"       = "{glyph} {count}";
          glyph              = "󰸿";
          "hide-not-running" = true;
          "use-icon"         = true;
          "icon-name"        = "input-gaming-symbolic";
          "icon-spacing"     = 4;
          "icon-size"        = 20;
          tooltip            = false;
        };
      };
    };

    # Стиль всего
    style = ''
      * {
        font-family: "Ubuntu";
        font-size: 18px;
        margin: 0;
        padding: 0;
        min-height: 0;
        border-radius: 8px;
      }

      window#waybar {
        background: transparent;
        color: #fbf1c7;
      }

      /* ===== рабочие столы ===== */

      #workspaces {
        background: #282828;
        border-radius: 8px;
      }

      #workspaces button {
        padding: 0px 10px;
        background: transparent;
        color: #fbf1c7;
        border-radius: 8px;
        box-shadow: none;
      }

      #workspaces button:hover {
        box-shadow: none;
      }

      #workspaces button.focused,
      #workspaces button.active,
      #workspaces button.persistent {
        background-color: #d65d0e;
        color: #282828;
      }

      #workspaces button.urgent {
        background-color: #cc241d;
        color: #282828;
      }

      /* ===== общий шрифт для модулей ===== */

      #language,
      #wireplumber,
      #clock,
      #network {
        font-family: "Ubuntu";
      }

      /* ===== цвета для модулей ===== */

      #language,
      #wireplumber,
      #network,
      #clock,
      #tray {
        background-color: #d65d0e;
        color: #282828;
      }

      /* ===== отступы ===== */

      #language,
      #wireplumber,
      #clock,
      #network {
        padding: 0 10px;
      }

      /* ===== трей ===== */

      #tray {
        background: #d65d0e;
        padding-left: 10px;
        padding-right: 10px;
        border-radius: 8px;
      }

      /* ===== idle inhibitor ===== */

      #idle_inhibitor {
        padding: 0 10px 0 8px;
        transition:
          background-color 0.2s ease,
          color 0.2s ease,
          padding 0.1s ease;
      }

      #idle_inhibitor.deactivated {
        background-color: #d65d0e;
        color: #282828;
      }

      #idle_inhibitor.activated {
        background-color: #d79921;
        color: #282828;
      }

      #idle_inhibitor:hover {
        background-color: #d79921;
      }

      #idle_inhibitor:active {
        padding-left: 10px;
        padding-right: 10px;
      }

      /* ===== gamemode  ===== */
      #gamemode {
        background-color: #d65d0e;
        color: #282828;
      }

      #gamemode.running {
        background-color: #d79921;
        color: #282828;
      }

      /* ===== состояния ===== */

      #network.disconnected {
        background-color: #cc241d;
        color: #282828;
      }
    '';
  };
}