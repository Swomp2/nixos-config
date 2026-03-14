{config, pkgs, inputs, lib, ...}:
let
  unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};

  defaultCursorTheme = pkgs.writeTextDir "share/icons/default/index.theme" ''
	[Icon Theme]
	Inherits=BreezeX-RosePine-Linux
  '';
in
{
  # Разрешение несвободных пакетов
  nixpkgs.config.allowUnfree = true;
  
  # Включение hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
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
      cursor_theme_size = 24
      font_name = "Ubuntu 15"

      [background]
      path = "${../home/config/greeter/wallhaven-m9mevm.jpg}"
      fit = "Cover"
    '';
  };

  # Установка темы курсора в greeter сессию
  services.greetd.settings.default__session = {
    command = '' 
      env \
        XCURSOR_THEME=BreezeX-RosePine-Linux \
        XCURSOR_SIZE=24 \
        XCURSOR_PATH=/run/current-system/sw/share/icons \
		WLR_NO_HARDWARE_CURSORS=1 \
        GTK_THEME=Gruvbox-Dark \
        ${pkgs.cage}/bin/cage -s -mlast -- ${pkgs.regreet}/bin/regreet
    '';
    user = "greeter";
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
    QT_QPA_PLATFORMTHEME = "qt6ct";
    XCURSOR_THEME = "BreezeX-RosePine-Linux";
    XCURSOR_SIZE = "24";
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
    libnotify

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
