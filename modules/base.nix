{config, pkgs, ...}:

{
  time.timeZone = "Europe/Moscow";

  i18n.defaultLocale = "ru_RU.UTF-8";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  networking.networkmanager.enable = true;

  programs.fish.enable = true;
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  environment.shellAliases = {
    cat = "bat";
    ls  = "lsd";
  };
  
  system.stateVersion = "25.11"; # # Версия первой установленной NixOS на этой машине; не связана с версией пакетов

}
