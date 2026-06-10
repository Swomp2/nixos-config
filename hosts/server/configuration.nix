{config, lib, pkgs, ...}:
{
  imports = [
  	./hardware-configuration.nix
  	../../disko/server.nix                             # Тут всё, что связано с разметкой диска
  	
  	../../modules/server/base.nix                      # Тут находятся базовые настройки системы
  	../../modules/server/boot.nix                      # Тут всё, что связано с загрузкой системы
  	../../modules/server/hardware-common.nix           # Тут всё, что связано с железом сервера
  	../../modules/server/security.nix                  # Тут всё, что связано с безопасностью системы
  	../../modules/server/packages.nix                  # Тут все системные пакеты для сервера
  	../../modules/packages.nix                         # Тут все системные пакеты
  	../../modules/server/nginx.nix                     # Тут конфигурация nginx
  	../../modules/server/docker.nix                    # Тут docker сервисы
  	../../modules/server/oneshot-secrets-generator.nix # Тут генерируются все секреты для работы сервисов
  ];

  networking.hostName = "Swomp-Server"; # Имя устройства в сети
  console.keyMap = "us";                # Дефолтная системная раскладка

  services.smartd.devices = [
  	{device = "/dev/disk/by-id/nvme-AOC_SD123330_93_2280_NVME_512GB_SD1HN2445KA00528";}
  ];

  boot.initrd.luks.devices.cryptroot.crypttabExtraOpts = ["tpm2-device=auto"];

  systemd.network.wait-online.enable = true;

  # Отключение физического swap, использование только zram
  swapDevices = lib.mkForce [];

  zramSwap = {
  	enable        = true;
  	memoryPercent = 100;
  	priority      = 100;
  };

  boot.kernelParams = [
    "systemd.gpt_auto=no"
    "rd.systemd.gpt_auto=no"
  ];

  boot.loader = {
  	efi = {
  	  canTouchEfiVariables = true;
  	  efiSysMountPoint     = "/boot/efi";
  	};
  };
}
