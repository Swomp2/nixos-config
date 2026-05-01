{config, pkgs, unstable, ...}:
{
  
  # Включение плагина для курсора в hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;

    xwayland.enable = true;

    systemd.enable = true;

    systemd.variables = ["--all"];

    plugins = [
      unstable.hyprlandPlugins.hypr-dynamic-cursors
    ];

    extraConfig = ''
      plugin:dynamic-cursors {
        enabled = true
        mode = tilt
        threshold = 2

        shake {
          enabled = true
          threshold = 6.0
          limit = 2
          timeout = 1000
        }
      }
    '';
  };

  home.packages = with pkgs; [
    firefox
    keepassxc
    nextcloud-client
    libreoffice-qt-fresh
    kitty
    unstable.waybar
    dunst
    wl-clipboard
    swww
    bemenu
    grim
    slurp
    strawberry
    udiskie
    cliphist
    hyprshot
    lxqt.lxqt-policykit
    playerctl
    kdePackages.qt6ct
    lxqt.pavucontrol-qt
    pcmanfm-qt
    kdePackages.ark
    unstable.hyprsunset
    swayosd
    nomacs # Для просмотра фоток)
    kdePackages.okular
    element-desktop
    logseq
    octaveFull
    vscodium
    gui-for-singbox
    papirus-icon-theme
    gruvbox-gtk-theme
    libsForQt5.qt5ct
    kdePackages.qtstyleplugin-kvantum
    gruvbox-kvantum
    nwg-look
    rose-pine-hyprcursor
    mpv
    prismlauncher
    ungoogled-chromium
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
