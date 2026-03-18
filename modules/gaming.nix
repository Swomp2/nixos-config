{lib, pkgs, unstable, ...}:
{
  programs.steam = {
  	enable = true;
  	package = unstable.steam;
  	remotePlay.openFirewall = true;
  	dedicatedServer.openFirewall = false;
  };

  programs.gamemode.enable = true;
  programs.gamescope = {
  	enable = true;
  	capSysNice = true;
  };

  environment.systemPackages = with pkgs; [
  	mangohud
  	protonup-ng  	
  ];
}
