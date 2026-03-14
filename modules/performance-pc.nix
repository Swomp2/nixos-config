{pkgs, ...}:
{
  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "schedutil";

  boot.kernelPackages = pkgs.linuxPackages_lqx;

  boot.kernelParams = [
    "amd_pstate=active"
  ];
}
