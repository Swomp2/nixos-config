{config, pkgs, inputs, lib, ...}:
let
  unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system};

  mkFishBin = name: file:
    pkgs.writeShellScriptBin name ''
      exec ${pkgs.fish}/bin/fish ${file} "$@"
    '';

  kvTheme = pkgs.gruvbox-kvantum;
in
{

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
  
  # Отключение шрифтов на уровне home manager, потому что они включены на системном уровне
  fonts.fontconfig.enable = lib.mkForce false;

  imports = [
    ./desktop.nix
    ./config/starship/starship.nix
    ./config/ranger/ranger.nix
  ];

  # Тема для gtk
  gtk = {
  	enable = true;

  	theme = {
  	  name = "Gruvbox-Dark";
  	  package = pkgs.gruvbox-gtk-theme;
  	};

  	iconTheme = {
  	  name = "Papirus-Dark";
  	  package = pkgs.papirus-icon-theme;
  	};

  	cursorTheme = {
  	  name = "BreezeX-RosePine-Linux";
  	  package = pkgs.rose-pine-cursor;
  	  size = 32;
  	};
  };

  # Тема для qt
  qt = {
    enable = true;

    platformTheme.name = "qtct";
    style.name = "kvantum";

	qt5ctSettings = {
	  Appearance = {
	    icon_theme = "Papirus-Dark";
	    style = "kvantum";
	    standard_dialogs = "xdgdesktopportal";
	  };
	};

	qt6ctSettings = {
	  Appearance = {
	    icon_theme = "Papirus-Dark";
	    style = "kvantum";
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

  xdg.configFile."fish".source = ./config/fish;
  xdg.configFile."fish".recursive = true;

  xdg.configFile."mpv".source = ./config/mpv;
  xdg.configFile."mpv".recursive = true;

  xdg.configFile."wlogout".source = ./config/wlogout;
  xdg.configFile."wlogout".recursive = true;

  xdg.configFile."wofi".source = ./config/wofi;
  xdg.configFile."wofi".recursive = true;

  xdg.configFile."gammastep/config.ini".source = ./config/gammastep/config.ini;

  xdg.configFile."hypr/hyprlock.conf".source = ./config/hypr/hyprlock.conf;
  xdg.configFile."hypr/hypridle.conf".source = ./config/hypr/hypridle.conf;

  xdg.configFile."kitty/kitty.conf".source = ./config/kitty/kitty.conf;
  xdg.configFile."kitty/gruvbox_dark.conf".source = ./config/kitty/gruvbox_dark.conf;

  xdg.configFile."hypr/animations.conf"

  xdg.configFile."dunst/dunstrc".source = ./config/dunst/dunstrc;

  xdg.configFile."btop".source = ./config/btop;
  xdg.configFile."btop".recursive = true;

  xdg.configFile."nwg-look".source = ./config/nwg-look;
  xdg.configFile."nwg-look".recursive = true;

  xdg.configFile."pavucontrol-qt".source = ./config/pavucontrol-qt;
  xdg.configFile."pavucontrol-qt".recursive = true;

  xdg.enable = true;

  # Включение starship
  programs.starship = {
    enable = true;
  };

  home.packages = with pkgs; [
    cargo
    rustc
    rustfmt
    rust-analyzer
    nodejs_24
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
    prismlauncher
    ungoogled-chromium
    wofi
    wlogout

    (mkFishBin "bemenu-cliphist" ./config/bemenu/cliphist.fish)
    (mkFishBin "bemenu-lockscreen" ./config/bemenu/lockscreen.fish)
    (mkFishBin "bemenu-pavucontrol" ./config/bemenu/pavucontrol.fish)
    (mkFishBin "bemenu-swww-random" ./config/bemenu/swww-random.fish)
    (mkFishBin "bemenu-screenshot" ./config/bemenu/screenshot.fish)
    (mkFishBin "bemenu-wallpapers" ./config/bemenu/wallpapers.fish)
    (mkFishBin "bemenu-wifi" ./config/bemenu/wifi.fish)
  ];
}
