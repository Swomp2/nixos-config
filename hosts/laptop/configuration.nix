{config, pkgs, ...}:

{
  imports = [
    ./hardware-configuration.nix
    ../../disko/laptop.nix
    
    ../../modules/base.nix      # Тут находятся базовые настройки системы
    ../../modules/desktop.nix   # Тут всё, что связано с GUI
    ../../modules/packages.nix  # Тут все системные пакеты
    ../../modules/security.nix  # Тут всё, что связано с безопасностью системы
    ../../modules/laptop.nix    # Тут всё, что может быть нужно для ноута
    ../../modules/boot.nix      # Тут всё, что связано с экраном загрузки
    ../../modules/hardware-common.nix  # Тут всё, что общего в железе ноута и компа
  ];

  networking.hostName = "Swomp-Laptop"; # Имя устройства в сети
  console.keyMap = "dvorak";            # Дефолтная системная раскладка

  boot.initrd.systemd.tpm2.enable = true;

  services.smartd.devices = [
    {device = "/dev/disk/by-id/nvme-eui.002538a341b9084d";}
  ];

  boot.initrd.luks.devices.cryptroot = {
    device = "/dev/disk/by-partlabel/cryptroot";
    allowDiscards = true;
    crypttabExtraOpts = [ "tpm2-device=auto" ];
  };
  
  zramSwap = {
    enable = true;
    memoryPercent = 25;
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
