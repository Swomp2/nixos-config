{config, pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    dysk
    lsd
    btop
    libgcc
    clang
    clang-tools
    gnumake
    cmake
    ninja
    autoconf
    automake
    uv
    bat
    zip
    unzip
    p7zip
    gnused
    stow
    micro

    python3
    gcc
    gdb

    dosfstools
    btrfs-progs
    ntfs3g
    xfsprogs
    exfatprogs
  ];
}
