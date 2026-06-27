{
  config,
  pkgs,
  unstable,
  lib,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    (lib.hiPrio coreutils-full)

    gettext
    glibcLocales

    hunspell
    hunspellDicts.ru_RU
    hyphenDicts.ru_RU
  
    git
    curl
    wget
    dysk
    lsd
    btop
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
    libva-utils
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
