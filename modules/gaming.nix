{lib, pkgs, unstable, ...}:
{
  programs.steam = {
  	enable = true;
  	package = unstable.steam.override {
  	  extraPkgs = steamPkgs: with steamPkgs; [
  	  	gamemode
  	  ];
  	};
  	
  	remotePlay.openFirewall = true;
  	dedicatedServer.openFirewall = false;
  };

  programs.gamemode = {
  	enable = true;

  	settings = {
  	  general = {
  	  	desiredgov = "performance";
  	  	renice = 10;
  	  	ioprio = 0;
  	  };
  	};
  };
  programs.gamescope = {
  	enable = true;
  	capSysNice = true;
  };

  environment.systemPackages = with pkgs; [
  	mangohud
  	protonup-ng
  	unstable.lutris  	
  ];
}
