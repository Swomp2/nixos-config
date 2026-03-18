{pkgs, username, lib, ...}:
{
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "hplip"
    ];
  
  services.printing = {
    enable = true;
    webInterface = true;
    drivers = [
      pkgs.hplipWithPlugin
    ];
  };

  hardware.sane = {
    enable = true;
    extraBackends = [
      pkgs.hplipWithPlugin
    ];
  };

  environment.systemPackages = with pkgs; [
  	hplipWithPlugin
  	system-config-printer
  	simple-scan
  ];

  users.users.${username}.extraGroups = [
    "lp"
    "scanner"
  ];
}
