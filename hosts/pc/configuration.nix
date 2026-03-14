{config, pkgs, ...}:

{
  imports = [
    ./hardware-configuration.nix
    ../../disko/pc.nix

    ../../modules/base.nix             # Тут находятся базовые настройки системы
    ../../modules/desktop.nix          # Тут всё, что связано с GUI
    ../../modules/packages.nix         # Тут все системные пакеты
    ../../modules/security.nix         # Тут всё, что связано с безопасностью системы
    ../../modules/boot.nix             # Тут всё, что связано с экраном загрузки
    ../../modules/printing.nix         # Тут всё, что связано с принтерами
    ../../modules/hardware-common.nix  # Тут всё, что общего в железе ноута и компа
    ../../modules/performance-pc.nix   # Тут всё, что связано с производительностью на компе
    ../../modules/virtualization.nix   # Тут всё, что связано с виртуализацией и виртуальными машинами
  ];

  networking.hostName = "Swomp-PC"; # Имя устройства в сети
  console.keyMap = "us";            # Дефолтная системная раскладка

  services.smartd.devices = [
    {device = "/dev/disk/by-id/nvme-eui.00000000000000016479a751e0c0162e";}
    {device = "/dev/disk/by-id/nvme-eui.00000000000000016479a751e0c01638";}
  ];

  boot.initrd.luks.devices = {
    cryptroot0 = {
      device = "/dev/disk/by-partlabel/cryptroot0";
      allowDiscards = true;
      crypttabExtraOpts = [ "tpm2-device=auto" ];
    };

    cryptroot1 = {
      device = "/dev/disk/by-partlabel/cryptroot1";
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
