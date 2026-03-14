{...}:
{
  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "schedutil";

  boot.kernelPackages = pkgs.linuxPackages_zen;

  boot.kernelParams = [
    "amd_pstate=active"
  ];
}
