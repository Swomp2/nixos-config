{
  config,
  pkgs,
  unstable,
  lib,
  theme,
  ...
}:
let
  kvTheme = pkgs.gruvbox-kvantum;
in
{
  # Импорт adguard vpn и clipcascade
  imports = [
  	./programs/adguardvpn.nix
  	./programs/clipcascade.nix
  ];

  # Включение adguard vpn и clipcascade
  programs.adguardvpn-cli = {
  	enable = true;
  	channel = "nightly";
  };

  programs.clipcascade = {
  	enable = true;
  	autostart = true;
  };

  # Включение xdg autostart
  xdg.autostart.enable = true;

  # Включение hyprland в home manager
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;

    package = null;
    portalPackage = null;
  };

  # Включение gnome keyring
  services.gnome-keyring.enable = true;

  # Переменные home manager
  home.sessionVariables = {
    QT_QPA_PLATFORM = "wayland;xcb";
    MOZ_ENABLE_WAYLAND = 1;
    VDPAU_DRIVER = "radeonsi";
    LIBVA_DRIVER_NAME = "radeonsi";
  };

  # Отключение шрифтов на уровне home manager, потому что они включены на системном уровне
  fonts.fontconfig.enable = lib.mkForce false;

  # Включение стандартных директорий
  xdg.userDirs = {
    enable = true;
    createDirectories = true;

    setSessionVariables = true;

    documents = "$HOME/Документы";
    download = "$HOME/Загрузки";
    music = "$HOME/Музыка";
    pictures = "$HOME/Изображения";
    videos = "$HOME/Видео";
  };

  # Тема для gtk
  gtk = {
    enable = true;

    theme = {
      name = theme.gtk.themeName;
      package = pkgs.gruvbox-gtk-theme;
    };

    iconTheme = {
      name = theme.gtk.iconThemeName;
      package = pkgs.papirus-icon-theme;
    };

    cursorTheme = {
      name = theme.cursor.xcursorName;
      package = pkgs.rose-pine-cursor;
      size = theme.cursor.size;
    };

    # Фикс для новой версии home-manager
    gtk4.theme = config.gtk.theme;
  };

  # Тема для qt
  qt = {
    enable = true;

    platformTheme.name = "qtct";
    style.name = theme.qt.style;

    qt5ctSettings = {
      Appearance = {
        icon_theme = theme.gtk.iconThemeName;
        style = theme.qt.style;
        standard_dialogs = "xdgdesktopportal";
      };
    };

    qt6ctSettings = {
      Appearance = {
        icon_theme = theme.gtk.iconThemeName;
        style = theme.qt.style;
        standard_dialogs = "xdgdesktopportal";
      };
    };
  };

  xdg.configFile."Kvantum/kvantum.kvconfig" = {
    text = "
	  [General]
	  theme=${theme.qt.kvantumTheme}
  	";
    force = true;
  };

  xdg.configFile."Kvantum/Gruvbox-Dark-Brown" = {
    source = "${kvTheme}/share/Kvantum/Gruvbox-Dark-Brown";
    recursive = true;

    # Перезаписывать этот файл с помощью home manager
    force = true;
  };

  # Включение ssh агента
  services.ssh-agent = {
    enable = true;
    socket = "ssh-agent";
  };

  home.packages = with pkgs; [
    wl-clipboard
    bemenu
    flatpak
    grim
    slurp
    hyprshot
    playerctl

    libreoffice-qt-fresh
    hunspell
    hunspellDicts.ru_RU
    hyphenDicts.ru_RU
    
    ungoogled-chromium
    mpv
    kdePackages.okular
    kdePackages.ark
    nomacs
    element-desktop
    strawberry
    prismlauncher
    obs-studio
    lutris
    kdePackages.qt6ct
    lxqt.pavucontrol-qt
    pcmanfm-qt
    octaveFull
    vscodium
    libsForQt5.qt5ct
    kdePackages.qtstyleplugin-kvantum
    gruvbox-kvantum
    nwg-look
    rose-pine-hyprcursor
    rustfmt
    rust-analyzer
    pyright
    eslint
    prettier
    tex-fmt
    asm-lsp
    texlab
    unstable.yt-dlp
    texliveFull
    qpdf
  ];
}
