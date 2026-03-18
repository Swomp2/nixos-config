{pkgs, ...}:
{
  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "schedutil";

  boot.kernelPackages = pkgs.linuxPackages_lqx;

  boot.kernelParams = [
    "amd_pstate=active"
  ];

  # Настройки для аудио девайсов
  services.pipewire.wireplumber.extraConfig."30-pc-audio-cleanup" = {
    "monitor.alsa.rules" = [
      # JBL: оставить только микрофон, sink убрать
      {
        matches = [
          {
            "node.description" = "~JBL Quantum Stream.*";
            "media.class" = "Audio/Sink";
          }
        ];
        actions = {
          "update-props" = {
            "node.disabled" = true;
          };
        };
      }

      # Starship: оставить только вывод, source убрать
      {
        matches = [
          {
            "node.description" = "~Starship/Matisse HD Audio Controller.*";
            "media.class" = "Audio/Source";
          }
        ];
        actions = {
          "update-props" = {
            "node.disabled" = true;
          };
        };
      }

      # Starship сделать основным sink
      {
        matches = [
          {
            "node.description" = "~Starship/Matisse HD Audio Controller.*";
            "media.class" = "Audio/Sink";
          }
        ];
        actions = {
          "update-props" = {
            "priority.session" = 1400;
          };
        };
      }

      # JBL сделать основным source
      {
        matches = [
          {
            "node.description" = "~JBL Quantum Stream.*";
            "media.class" = "Audio/Source";
          }
        ];
        actions = {
          "update-props" = {
            "priority.session" = 2000;
          };
        };
      }
    ];
  };
}
