{config, pkgs, ...}:

{
  powerManagement.enable = true;

  powerManagement.cpuFreqGovernor = "powersave";

  services.power-profiles-daemon.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;

  services.libinput.enable = true;

  services.logind.lidSwitch = "suspend";
  services.logind.lidSwitchExternalPower = "lock";

  environment.systemPackages = with pkgs; [
    brightnessctl
    acpi
  ];
}
