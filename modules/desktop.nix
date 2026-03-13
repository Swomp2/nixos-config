{config, pkgs, inputs, ...}:
let
  unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system};
in
{
  # Включение hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Включение менеджера сеансов
  programs.regreet = {

    enable = true;

    theme = {
      name = "Gruvbox-Dark";
      package = pkgs.gruvbox-dark-gtk;
    };

    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };

    cursorTheme = {
      name = "Rose-Pine-Cursor";
      package = pkgs.rose-pine-cursor;
    };

    font = {
      name = "FiraCode Nerd Font";
      size = 15;
      package = pkgs.nerd-fonts.fira-code;
    };

    settings = {
      GTK = {
        application_prefer_dark_theme = true;
        cursor_theme_size = 24;
      };

      background = {
        path = ../home/config/greeter/wallhaven-m9mevm.jpg;
        fit = "Cover";
      };
    };
  };

  services.gnome.gnome-keyring.enable = true;

  security.pam.services = {
    greetd.enableGnomeKeyring = true;
    hyprlock.enableGnomeKeyring = true;
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
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
  };

  # Включение службы для работы с внешними накопителями
  services.udisks2.enable = true;
  services.gvfs.enable = true;

  # Включение поддержки только AMD
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

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
    emacs
    libsForQt5.qtstyleplugin-kvantum
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
    ];
  };
}
