{config, pkgs, unstable, lib, ...}:
let 
  kvTheme = pkgs.gruvbox-kvantum;
in
{
  # Включение hyprland в home manager
  wayland.windowManager.hyprland = {
    enable          = true;
    systemd.enable  = false;
  };

  # Переменные графического окружения
  home.sessionVariables = {
    QT_QPA_PLATFORM = "wayland;xcb";
    MOZ_ENABLE_WAYLAND = 1;
    VDPAU_DRIVER = "radeonsi";
    LIBVA_DRIVER_NAME = "radeonsi";
  };

  # Отключение шрифтов на уровне home manager, потому что они включены на системном уровне
  fonts.fontconfig.enable = lib.mkForce false;

  # Включение starship
  programs.starship = {
    enable = true;
  };

  # Включение стандартных директорий
  xdg.userDirs = {
  	enable = true;
  	createDirectories = true;

  	documents = "$HOME/Документы";
  	download  = "$HOME/Загрузки";
  	music     = "$HOME/Музыка";
  	pictures  = "$HOME/Изображения";
  	videos    = "$HOME/Видео";
  };

  # Тема для gtk
  gtk = {
  	enable = true;

  	theme = {
  	  name    = "Gruvbox-Dark";
  	  package = pkgs.gruvbox-gtk-theme;
  	};

  	iconTheme = {
  	  name    = "Papirus-Dark";
  	  package = pkgs.papirus-icon-theme;
  	};

  	cursorTheme = {
  	  name    = "BreezeX-RosePine-Linux";
  	  package = pkgs.rose-pine-cursor;
  	  size    = 32;
  	};
  };

  # Тема для qt
  qt = {
    enable = true;

    platformTheme.name = "qtct";
    style.name         = "kvantum";

    qt5ctSettings = {
      Appearance = {
        icon_theme       = "Papirus-Dark";
        style            = "kvantum";
        standard_dialogs = "xdgdesktopportal";
      };
    };

    qt6ctSettings = {
      Appearance = {
        icon_theme       = "Papirus-Dark";
        style            = "kvantum";
        standard_dialogs = "xdgdesktopportal";
      };
    };
  };

  xdg.configFile."Kvantum/kvantum.kvconfig" = {
    text = "
	  [General]
	  theme=Gruvbox-Dark-Brown
  	";
  	force = true;
  };

  xdg.configFile."Kvantum/Gruvbox-Dark-Brown" = { 
  	source = "${kvTheme}/share/Kvantum/Gruvbox-Dark-Brown";
	  recursive = true;

	  # Перезаписывать этот файл с помощью home manager
    force = true;
  };

  home.packages = with pkgs; [
    keepassxc
    wl-clipboard
    bemenu
    grim
    slurp
    hyprshot
    playerctl
    libreoffice-qt-fresh
    ungoogled-chromium
    mpv
    kdePackages.okular
    kdePackages.ark
    nomacs
    element-desktop
    firefox
    logseq
    strawberry
    prismlauncher
    obs-studio
    lutris
    kdePackages.qt6ct
    lxqt.pavucontrol-qt
    pcmanfm-qt
    octaveFull
    vscodium
    gui-for-singbox
    libsForQt5.qt5ct
    kdePackages.qtstyleplugin-kvantum
    gruvbox-kvantum
    nwg-look
    rose-pine-hyprcursor
    wofi
    wlogout
    obs-studio
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
    atuin
  ];
}
