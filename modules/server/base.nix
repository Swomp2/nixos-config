{ pkgs, timeZone, ... }:

{
  time.timeZone = timeZone;

  # Русская локаль
  i18n = {
    defaultLocale = "ru_RU.UTF-8";
  
    extraLocaleSettings = {
      LC_CTYPE = "ru_RU.UTF-8";
      LC_NUMERIC = "ru_RU.UTF-8";
      LC_TIME = "ru_RU.UTF-8";
      LC_COLLATE = "ru_RU.UTF-8";
      LC_MONETARY = "ru_RU.UTF-8";
      LC_MESSAGES = "ru_RU.UTF-8";
      LC_PAPER = "ru_RU.UTF-8";
      LC_NAME = "ru_RU.UTF-8";
      LC_ADDRESS = "ru_RU.UTF-8";
      LC_TELEPHONE = "ru_RU.UTF-8";
      LC_MEASUREMENT = "ru_RU.UTF-8";
      LC_IDENTIFICATION = "ru_RU.UTF-8";
    };
  };

  # Включение runtime библиотек для питона
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
    ];
  };

  # Автоматическая синхронизация времени по интернету
  networking.timeServers = [
    "time.cloudflare.com"
    "0.pool.ntp.org"
    "1.pool.ntp.org"
    "2.pool.ntp.org"
  ];

  # Автоудаление старых версий системы
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
    persistent = true;
  };

  # Оптимизация хранилища nix
  nix.optimise = {
  	automatic = true;
  	dates = [ "weekly" ];
  };

  nix.settings = {
  	auto-optimise-store = true;
  };

  boot.loader.systemd-boot.configurationLimit = 10;

  # Сокрытие загрузчика
  boot.loader.timeout = 0;

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
      DNS = [
        "1.1.1.1"
        "9.9.9.9"
      ];
    };
  };

  services.openssh.enable = true;

  programs.fish.enable = true;

  # Псевдонимы
  environment.shellAliases = {
    cat = "bat";
    ls = "lsd";
    clear = "clear -T xterm-256color";
    top = "btop";
  };

  # Переопределение глобальных переменных
  environment.sessionVariables = {
    LANGUAGE = "ru_RU:ru";
  
    EDITOR = "micro";
    VISUAL = "micro";
  };

  system.stateVersion = "25.11"; # Версия первой установленной NixOS на этой машине не связана с версией пакетов

}
