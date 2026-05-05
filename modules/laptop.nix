{config, pkgs, unstable, inputs, ...}:

{
  powerManagement.enable = true;

  # Последнее стабильное ядро, а не lts
  boot.kernelPackages = pkgs.linuxKernel.kernels.linux_6_18;

  boot.kernelParams = [
    "amd_pstate=active"
  ];

  # Профили энергопотребления
  services.upower.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;
  services.blueman.enable = true;

  services.libinput.enable = true;

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitchExternalPower = "suspend";
    HandlePowerKey = "ignore";
  };

  disabledModules = [ "services/hardware/tlp.nix" ];
  
  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/services/hardware/tlp.nix"
  ];
  
  # Параметры батареи
  services.power-profiles-daemon.enable = true;

  # Настройки для аудио девайсов
  services.pipewire.wireplumber.extraConfig."30-laptop-bluetooth" = {
    "monitor.bluez.properties" = {
      "bluez5.enable-hw-volume" = true;
      "bluez5.enable-sbc-xq" = true;
      "bluez5.hfphsp-backend" = "native";
      "bluez5.roles" = [ "a2dp_sink" "hfp_hf" "hfp_ag" ];
    };
  
    "monitor.bluez.rules" = [
      # Для всех bluetooth-гарнитур:
      # при подключении сразу поднимать аудиопрофиль
      {
        matches = [
          {
            "device.name" = "~bluez_card.*";
          }
        ];
        actions = {
          "update-props" = {
            "bluez5.auto-connect" = [ "a2dp_sink" "hfp_hf" ];
            "bluez5.hw-volume" = [ "a2dp_sink" "hfp_hf" ];
            "device.profile" = "a2dp-sink";
          };
        };
      }
  
      # Любой bluetooth-вывод делаем приоритетнее встроенной карты
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
    blueman
  ];
}
