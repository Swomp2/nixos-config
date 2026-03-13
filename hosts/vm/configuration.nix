{ modulesPath, ... }:

{
  imports = [
    ../../disko/vm.nix
    (modulesPath + "/profiles/qemu-guest.nix")

    ../../modules/base.nix
    ../../modules/desktop.nix
    ../../modules/packages.nix
    ../../modules/security.nix
    ../../modules/boot.nix
  ];

  networking.hostName = "Swomp-VM";

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
      device = "nodev";
    };
  };
}
