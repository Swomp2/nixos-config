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

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;

  services.libinput.enable = true;

  # Яркость
  hardware.brightnessctl.enable = true;

  services.logind.lidSwitch = "suspend";
  services.logind.lidSwitchDocked = "ignore";
  services.logind.lidSwitchExternalPower = "lock";

  # Настройки для аудио девайсов
  services.pipewire.wireplumber.extraConfig."30-laptop-bluetooth" = {
    "monitor.bluez.properties" = {
      "bluez5.enable-hw-volume" = true;
    };

    "monitor.bluez.rules" = [
      # Любой bluetooth-вывод делаем приоритетнее обычной встроенной карты
      {
        matches = [
          {
            "node.name" = "~bluez_output.*";
            "media.class" = "Audio/Sink";
          }
        ];
        actions = {
          "update-props" = {
            "priority.session" = 1800;
          };
        };
      }

      # Любой bluetooth-вход делаем приоритетнее встроенных микрофонов
      {
        matches = [
          {
            "node.name" = "~bluez_input.*";
            "media.class" = "Audio/Source";
          }
        ];
        actions = {
          "update-props" = {
            "priority.session" = 1800;
          };
        };
      }
    ];
  };

  environment.systemPackages = with pkgs; [
    brightnessctl
    acpi
    powertop
  ];
}
