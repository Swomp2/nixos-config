{config, pkgs, ...}:

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
  boot.loader.timeout = 0;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  networking.networkmanager.enable = true;

  services.openssh.enable = true;

  programs.fish.enable = true;

  environment.shellAliases = {
    cat = "bat";
    ls  = "lsd";
  };
  
  system.stateVersion = "25.11"; # Версия первой установленной NixOS на этой машине не связана с версией пакетов

}
