{lib, pkgs, ...}:
{
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "steam"
      "steam-unwrapped"
      "corefonts"
    ];

  programs.steam = {
  	enable = true;
  	remotePlay.openFirewall = true;
  	dedicatedServer.openFirewall = false;
  };

  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
  	mangohud
  	protonup-ng  	
  ];
}
