{config, pkgs, ...}:

{
  imports = [
    ./hardware-configuration.nix
    ../../disko/laptop.nix             # Тут всё, что связано с ноутом
    
    ../../modules/base.nix             # Тут находятся базовые настройки системы
    ../../modules/desktop.nix          # Тут всё, что связано с GUI
    ../../modules/packages.nix         # Тут все системные пакеты
    ../../modules/security.nix         # Тут всё, что связано с безопасностью системы
    ../../modules/laptop.nix           # Тут всё, что может быть нужно для ноута
    ../../modules/boot.nix             # Тут всё, что связано с экраном загрузки
    ../../modules/hardware-common.nix  # Тут всё, что общего в железе ноута и компа
    ../../modules/virtualization.nix   # Тут всё, что связано с виртуализацией и виртуальными машинами
	../../modules/gaming.nix           # Тут всё, что связано с играми
  ];

  networking.hostName = "Swomp-Laptop"; # Имя устройства в сети
  console.keyMap = "dvorak";            # Дефолтная системная раскладка

  services.smartd.devices = [
    {device = "/dev/disk/by-id/nvme-eui.002538a341b9084d";}
  ];

  boot.initrd.luks.devices.cryptroot.crypttabExtraOpts = ["tpm2-device=auto"];
  
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

    grub.enable = false;

    systemd-boot.enable = false;
  };

  environment.systemPackages = with pkgs; [
  	linuxKernel.packages.linux_6_19.cpupower
  ];

}
