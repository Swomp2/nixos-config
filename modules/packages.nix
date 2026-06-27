{
  config,
  pkgs,
  unstable,
  lib,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    dysk
    lsd
    bat
    zip
    unzip
    p7zip
    gnused
    stow
    micro
    dosfstools
    btrfs-progs
    ntfs3g
    xfsprogs
    exfatprogs
    smartmontools
    nvme-cli
    fwupd
    lm_sensors
    pciutils
    usbutils
    dmidecode
    lshw
    clinfo
    vulkan-tools
    vdpauinfo
  ];

  fonts = {
    packages = with pkgs; [
      ubuntu-sans
      fira-code
      nerd-fonts.ubuntu
      nerd-fonts.fira-code
      nerd-fonts.symbols-only

      # Шрифты Майкрософт
      corefonts
    ];
  };
}
