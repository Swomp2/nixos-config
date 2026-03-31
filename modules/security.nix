{config, pkgs, lib, ...}:
{
  boot.lanzaboote = {
  	enable = true;
  	pkiBundle = "/var/lib/sbctl";
  };

  environment.systemPackages = [
  	pkgs.sbctl
  ];

  # Включение apparmor и файервола

  security.apparmor.enable = true;

  security.apparmor.packages = [
  	pkgs.apparmor-profiles
  ];

  security.apparmor.policies = {
  	"firefox" = {
  	  state = "enforce";
  	  path = "${pkgs.apparmor-profiles}/etc/apparmor.d/firefox";
  	};

  	"element-desktop" = {
  	  state = "enforce";
  	  path = "${pkgs.apparmor-profiles}/etc/apparmor.d/element-desktop";
  	};

  	"steam" = {
  	  state = "enforce";
  	  path = "${pkgs.apparmor-profiles}/etc/apparmor.d/steam";
  	};
  };
  
  networking.firewall = {
  	enable = true;
  	
  	checkReversePath = false;
  	logReversePathDrops = false;

	# Разрешённые входящие TCP для игр, звонков, TURN
  	allowedTCPPorts = [
  	  3478
  	  3479
  	  3480
  	  5349
  	  10901
  	];

	# Разрешённые UDP для игр, звонков, TURN/WebRTC
  	allowedUDPPorts = [
  	  3478
  	  3479
  	  5349
  	  8571
  	];

  	# Главный диапазон для TURN relay
  	allowedUDPPortRanges = [
  	  {from = 49152; to = 65535;}
  	];
  };
  
  # Включение sudo
  security.sudo.enable = true;
}
