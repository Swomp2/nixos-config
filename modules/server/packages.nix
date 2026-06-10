{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
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
    kitty.terminfo
  ];
}
