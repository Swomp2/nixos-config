{config, pkgs, ...}:

{

  # Включение apparmor и файервола

  security.apparmor.enable = true;

  networking.firewall.enable = true;
  
  # Замена sudo на doas
  
  security.sudo.enable = false;

  security.doas.enable = true;

  security.doas.extraRules = [
    {
      groups = ["wheel"];
      keepEnv = true;
      persist = true;
    }
  ];
}
