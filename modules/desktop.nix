{
  config,
  pkgs,
  lib,
  unstable,
  inputs,
  theme,
  ...
}:
{
  # Разрешение несвободных пакетов
  nixpkgs.config = {
    allowUnfree = true;
  };

  # Universal Wayland Session Manager
  programs.uwsm.enable = true;

  # Включение gnome keyring
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  security.pam.services.login.enableGnomeKeyring = true;

  # Включение hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  # Это для тем и иконок для greeter
  environment.pathsToLink = [
    "/share/icons"
    "/share/themes"
    "/share/fonts"
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XCURSOR_SIZE = toString theme.cursor.size;
    XCURSOR_THEME = theme.cursor.xcursorName;
    QT_QPA_PLATFORMTHEME = theme.qt.platformTheme;
  };

  # Это нужно для поддержки filepicker
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  # Надо для pipewire, чтобы он мог использовать realtime sheduler
  security.rtkit.enable = true;
  security.polkit.enable = true;

  # Сам pipewire
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    wireplumber = {
      enable = true;

      extraConfig = {
        "10-audio-policy" = {
          "wireplumber.settings" = {
            "device.restore-routes" = true;
            "node.restore-default-targets" = false;
            "linking.follow-default-target" = true;
            "node.stream.restore-target" = false;
            "linking.allow-moving-streams" = true;
          };
        };

        "15-lower-hdmi-priority" = {
          "monitor.alsa.rules" = [
            {
              matches = [
                {
                  "node.name" = "~alsa_output.*hdmi.*";
                  "media.class" = "Audio/Sink";
                }
              ];
              actions = {
                "update-props" = {
                  "priority.session" = 700;
                };
              };
            }
          ];
        };
      };
    };
  };

  # Включение службы для работы с внешними накопителями
  services.udisks2.enable = true;
  services.gvfs.enable = true;

  # Включение java
  programs.java = {
    enable = true;
    package = pkgs.jdk;
  };

  # Настройки VPN
  programs.throne = {
    enable = true;
    tunMode.enable = true;
  };

  fonts.fontDir.enable = true;

  environment.systemPackages = with pkgs; [
    mangohud
    protonup-ng
    nvtopPackages.amd
    libnotify
    rose-pine-cursor
    unstable.hyprlock
    unstable.hypridle
    imagemagick
    ffmpeg-full
    p7zip-rar
    rar
    unrar
    gruvbox-gtk-theme
    papirus-icon-theme
    virt-viewer
    guestfs-tools
    cargo
    rustc
    nodejs_24
    python3
    gcc
    gdb
    libgcc
    clang
    clang-tools
    gnumake
    cmake
    ninja
    autoconf
    automake
    uv
  ];
}
