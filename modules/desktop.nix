{config, pkgs, lib, unstable, inputs, ...}:
{
  # Разрешение несвободных пакетов
  nixpkgs.config.allowUnfree = true;
  
  # Включение hyprland
  programs.hyprland = {
    enable          = true;
    xwayland.enable = true;
    package         = unstable.hyprland;
    portalPackage  = unstable.xdg-desktop-portal-hyprland;
  };

  # Импорт впн и clipcascade
  imports = [
  	./programs/adguardvpn.nix
  	./programs/clipcascade.nix
  ];

  programs.adguardvpn-cli = {
  	enable  = true;
  	channel = "nightly";
  };

  programs.clipcascade = {
  	enable    = true;
  	autostart = true;
  	version   = "3.1.0";
  	hash      = "sha256-+csAEPCdPHxWz7gp4ES4r5bOnVUKDw3oo8lt4MXqKyo=";
  };

  # Это для тем и иконок для greeter
  environment.pathsToLink = [
    "/share/icons"
    "/share/themes"
    "/share/fonts"
  ];

  # Включение менеджера сеансов
  programs.regreet.enable = true;

  # Его конфигурация
  environment.etc."greetd/regreet.toml" = lib.mkForce {
    text = ''
      [GTK]
      application_prefer_dark_theme = true
      theme_name = "Gruvbox-Dark"
      icon_theme_name = "Papirus-Dark"
      cursor_theme_name = "BreezeX-RosePine-Linux"
      cursor_theme_size = 32
      font_name = "Ubuntu 15"

      [appearance]
      greeting_msg = "О, здарова"

      [background]
      path = "${../home/config/greeter/wallhaven-m9mevm.jpg}"
      fit = "Cover"
    '';
  };

  services.gnome.gnome-keyring.enable = true;

  security.pam.services = {
    greetd.enableGnomeKeyring = true;
    hyprlock.enableGnomeKeyring = true;
    login.enableGnomeKeyring = true;
  };

  programs.seahorse.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XCURSOR_SIZE = "32";
    XCURSOR_THEME = "BreezeX-RosePine-Linux";
    QT_QPA_PLATFORMTHEME = "qt6ct";
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

  # Включение flatpak
  services.flatpak.enable = true;
  
  environment.systemPackages = with pkgs; [
    firefox
    keepassxc
    imagemagick
    nextcloud-client
    libreoffice-qt-fresh

    kitty
    unstable.waybar
    dunst
    swww
    wl-clipboard
    bemenu
    j4-dmenu-desktop
    grim
    slurp
    ffmpeg-full
    cliphist
    hyprshot
    unstable.hyprlock
    unstable.hypridle
    lxqt.lxqt-policykit
    playerctl
    udiskie
    strawberry
    kdePackages.qt6ct
    lxqt.pavucontrol-qt
    pcmanfm-qt
    kdePackages.ark
    gammastep
    swayosd
    nomacs # Для просмотра фоток)
    libnotify
    kdePackages.okular
    element-desktop
    logseq
    octaveFull
    vscodium

    papirus-icon-theme
    gruvbox-gtk-theme
    libsForQt5.qt5ct
    kdePackages.qtstyleplugin-kvantum
    gruvbox-kvantum
    nwg-look
    rose-pine-cursor
    rose-pine-hyprcursor
    mpv
  ];

  fonts = {
    packages = with pkgs; [
      ubuntu-sans
      fira-code
      nerd-fonts.ubuntu
      nerd-fonts.fira-code
      nerd-fonts.symbols-only

      # Шрифты Майкрософт
      corefonts
    ];
  };

  fonts.fontDir.enable = true;
}
