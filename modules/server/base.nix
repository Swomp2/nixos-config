{pkgs, ...}:

{
  time.timeZone = "Europe/Moscow";

  i18n.defaultLocale = "ru_RU.UTF-8";

  # Включение runtime библиотек для питона
  programs.nix-ld = {
  	enable = true;
  	libraries = with pkgs; [
  	  stdenv.cc.cc
  	];
  };

  # Автоудаление старых версий системы
  nix.gc = {
  	automatic  = true;
  	dates      = "weekly";
  	options    = "--delete-older-than 14d";
  	persistent = true;
  };

  boot.loader.systemd-boot.configurationLimit = 10;

  # Сокрытие загрузчика
  boot.loader.timeout = 5;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  networking.useNetworkd = true;
  systemd.network.enable = true;

  networking.networkmanager.enable = false;

  systemd.network.networks."10-lan" = {
  	matchConfig.MACAddress = "68:1d:ef:46:9f:f7";

  	networkConfig = {
  	  Address = "192.168.1.244/24";
  	  Gateway = "192.168.1.1";
  	  DNS     = ["1.1.1.1" "9.9.9.9"];
  	};
  };

  services.openssh.enable = true;

  programs.fish.enable = true;

  # Псевдонимы
  environment.shellAliases = {
    cat   = "bat";
    ls    = "lsd";
    clear = "clear -T xterm-256color";
    top   = "btop";
  };

  # Переопределение глобальных переменных
  environment.sessionVariables = {
  	EDITOR = "micro";
  	VISUAL = "micro";
  };
  
  system.stateVersion = "25.11"; # Версия первой установленной NixOS на этой машине не связана с версией пакетов

}
