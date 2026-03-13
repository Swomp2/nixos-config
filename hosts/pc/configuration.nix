{config, pkgs, ...}:

{
  imports = [
    ./hardware-configuration.nix
    ../../disko/pc.nix

    ../../modules/base.nix      # Тут находятся базовые настройки системы
    ../../modules/desktop.nix   # Тут всё, что связано с GUI
    ../../modules/packages.nix  # Тут все системные пакеты
    ../../modules/security.nix  # Тут всё, что связано с безопасностью системы
    ../../modules/boot.nix      # Тут всё, что связано с экраном загрузки
    ../../modules/printing.nix  # Тут всё, что связано с принтерами
  ];

  networking.hostName = "Swomp-PC"; # Имя устройства в сети
  console.keyMap = "us";            # Дефолтная системная раскладка

  boot.initrd.systemd.tpm2.enable = true;

  boot.initrd.luks.devices = {
    cryptroot0 = {
      device = "/dev/disk/by-id/REPLACE_ME_PC_NVME0-part3";
      allowDiscards = true;
      crypttabExtraOpts = [ "tpm2-device=auto" ];
    };

    cryptroot1 = {
      device = "/dev/disk/by-id/REPLACE_ME_PC_NVME1-part1";
      allowDiscards = true;
      crypttabExtraOpts = [ "tpm2-device=auto" ];
    };
  };
  
  zramSwap = {
    enable = true;
    memoryPercent = 100;
    priority = 100;
  };
  
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi/";
    };

    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";         # Это означает использовать только EFI версию для grub
    };
  };
}
