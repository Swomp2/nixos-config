{ theme, timeZone, ... }:
{
  services.flatpak = {
    enable = true;

    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ];

    packages = [
      "com.logseq.Logseq"
      "org.telegram.desktop"
    ];

    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };

    overrides = {
      global = {
        Environment = {
          LANG = "ru_RU.UTF-8";
          LANGUAGE = "ru_RU:ru";
          LC_MESSAGES = "ru_RU.UTF-8";
        
          TZ = timeZone;

          XCURSOR_PATH = "/run/host/user-share/icons:/run/host/share/icons";

          XCURSOR_THEME = theme.cursor.xcursorName;
          XCURSOR_SIZE = toString theme.cursor.size;
        };

        Context.filesystems = [
          "/nix/store:ro"
          "xdg-data/icons:ro"
          "~/.icons:ro"
        ];
      };

      "com.logseq.Logseq" = {
        Context.sockets = [
          "wayland"
          "!x11"
          "!fallback-x11"
        ];

        Environment = {
          ELECTRON_OZONE_PLATFORM_HINT = "wayland";
        };
      };
    };
  };
}
