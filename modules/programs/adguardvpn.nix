{ config, lib, pkgs, ... }:

let
  cfg = config.programs.adguardvpn-cli;

  installScriptUrl =
    "https://raw.githubusercontent.com/AdguardTeam/AdGuardVPNCLI/master/scripts/${cfg.channel}/install.sh";

  runtimePath = lib.makeBinPath (with pkgs; [
    bash
    coreutils
    curl
    findutils
    gawk
    gnugrep
    gnused
    gnutar
    gzip
    iproute2
    iptables
    kmod
    nftables
    procps
    systemd
    util-linux
  ]);

  installHelper = pkgs.writeShellScriptBin "adguardvpn-cli-install" ''
    set -euo pipefail
    dir='${cfg.dataDir}'
    tmp="$(mktemp /tmp/adguardvpn-install.XXXXXX.sh)"
    trap 'rm -f "$tmp"' EXIT
    sudo ${pkgs.coreutils}/bin/install -d -m 0755 "$dir"
    ${pkgs.curl}/bin/curl -fsSL '${installScriptUrl}' -o "$tmp"
    sudo ${pkgs.bash}/bin/sh "$tmp" -o "$dir" -a n -v
  '';
  
  uninstallHelper = pkgs.writeShellScriptBin "adguardvpn-cli-uninstall" ''
    set -euo pipefail
    tmp="$(mktemp /tmp/adguardvpn-uninstall.XXXXXX.sh)"
    trap 'rm -f "$tmp"' EXIT
    ${pkgs.curl}/bin/curl -fsSL '${installScriptUrl}' -o "$tmp"
    sudo ${pkgs.bash}/bin/sh "$tmp" -o '${cfg.dataDir}' -u -a y -v
  '';

  wrapper = pkgs.writeShellScriptBin "adguardvpn-cli" ''
    set -euo pipefail
    export PATH='${runtimePath}':"$PATH"
    bin='${cfg.dataDir}/adguardvpn-cli'
    if \[ ! -x "$bin" \]; then
      echo "AdGuard VPN CLI ещё не установлен"
      echo "Сначала выполни: sudo adguardvpn-cli-install"
      exit 1
    fi
    exec "$bin" "$@"
  '';

in
{
  options.programs.adguardvpn-cli = {
    enable = lib.mkEnableOption "AdGuard VPN CLI wrapper for NixOS";

    channel = lib.mkOption {
      type = lib.types.enum [ "release" "beta" "nightly" ];
      default = "nightly";
      description = "Какой канал AdGuard VPN CLI использовать";
    };
    
    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/adguardvpn-cli";
      description = "Куда складывать бинарник AdGuard VPN CLI";
    };

  };

  config = lib.mkIf cfg.enable {
    programs.nix-ld.enable = lib.mkDefault true;

    programs.nix-ld.libraries = with pkgs; [
      stdenv.cc.cc
      openssl
      zlib
    ];

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 root root - -"
    ];
    
    environment.systemPackages = [
      wrapper
      installHelper
      uninstallHelper
    ];
  };
}
