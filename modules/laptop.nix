{config, pkgs, ...}:

{
  powerManagement.enable = true;

  # Последнее стабильное ядро, а не lts
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernelParams = [
    "amd_pstate=active"
  ];

  # Профили энергопотребления
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;

  services.libinput.enable = true;

  services.logind.lidSwitch = "suspend";
  services.logind.lidSwitchDocked = "ignore";
  services.logind.lidSwitchExternalPower = "lock";

  environment.systemPackages = with pkgs; [
    brightnessctl
    acpi
    powertop
  ];
}
