{config, pkgs, lib, ...}:
{
  # Включение lanzaboote
  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.lanzaboote = {
  	enable = true;
  	pkiBundle = "/var/lib/sbctl";
  };

  environment.systemPackages = [
  	pkgs.sbctl
  ];

  # Включение apparmor и файервола

  security.apparmor.enable = true;

  networking.firewall.enable = true;
  
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
