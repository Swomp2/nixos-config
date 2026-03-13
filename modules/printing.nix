{pkgs, username, ...}:
{
  services.printing = {
    enable = true;
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

  users.users.${username}.extraGroups = [
    "lp"
    "scanner"
  ];
}
