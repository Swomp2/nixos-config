{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (lib.hiPrio coreutils-full)

    gettext
    glibcLocales

    hunspell
    hunspellDicts.ru_RU
    hyphenDicts.ru_RU

    dig
    inetutils
    traceroute
    mtr
    tcpdump
    nmap
    iperf3
    iproute2
    ethtool
    docker-compose
    openssl
    restic
    rclone
    postgresql
    jq
    yq
    zstd
    lz4
    pv
    powertop
    btop
    kitty.terminfo
  ];
}
