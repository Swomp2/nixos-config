{...}:
{
  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "schedutil";

  boot.kernelParams = [
    "amd_pstate=active"
  ];
}
