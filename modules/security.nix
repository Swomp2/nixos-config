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
  
  # Замена sudo на doas
  security.sudo.enable = true;

  security.doas.enable = true;

  security.doas.extraRules = [
    {
      groups = ["wheel"];
      keepEnv = true;
      persist = true;
    }
  ];
}
