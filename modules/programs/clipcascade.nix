{ config, lib, pkgs, ... }:

let
  cfg = config.programs.clipcascade;
  pythonEnv = pkgs.python3.withPackages (ps: with ps; [
    requests
    websocket-client
    pycryptodomex
    pyperclip
    pystray
    pyfiglet
    beautifulsoup4
    xxhash
    plyer
    aiortc
    pygobject3
  ]);

  clipcascadePkg = pkgs.stdenvNoCC.mkDerivation rec {

    pname = "clipcascade";
    version = cfg.version;
    src = pkgs.fetchFromGitHub {
      owner = "Sathvik-Rao";
      repo = "ClipCascade";
      rev = version;
      hash = cfg.hash;
    };

    nativeBuildInputs = [ pkgs.makeWrapper ];
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/clipcascade
      cp -r ClipCascade_Desktop $out/share/clipcascade/
      mkdir -p $out/bin
      makeWrapper ${pythonEnv}/bin/python3 $out/bin/clipcascade \\
        --set PATH ${lib.makeBinPath [
          pkgs.xclip
          pkgs.wl-clipboard
          pkgs.dunst
          pkgs.xdg-utils
          pkgs.dbus
          pkgs.ffmpeg
          pkgs.gtk3
        ]} \\
        --prefix PYTHONPATH : "${pythonEnv}/${pythonEnv.sitePackages}" \\
        --add-flags "$out/share/clipcascade/ClipCascade_Desktop/src/main.py"
      runHook postInstall
    '';
  };
in
{
  options.programs.clipcascade = {
    enable = lib.mkEnableOption "ClipCascade client";
    autostart = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Автозапуск ClipCascade при входе в графический сеанс";
    };

    version = lib.mkOption {
      type = lib.types.str;
      default = "3.1.0";
      description = "Версия ClipCascade";
    };

    hash = lib.mkOption {
      type = lib.types.str;
      default = "sha256-CsAEPCdPHxWz7gp4ES4r5bOnVUKDw3oo8lt4MXqKyo=";
      description = "Хэш исходников fetchFromGitHub";
    };

  };

  config = lib.mkIf cfg.enable {
    home-manager.users.swomp = { lib, ... }: {
      home.packages = [ clipcascadePkg ];
      systemd.user.services.clipcascade = lib.mkIf cfg.autostart {
        Unit = {
          Description = "ClipCascade clipboard sync client";
          After = [ "graphical-session.target" "network-online.target" ];
          Wants = [ "graphical-session.target" "network-online.target" ];
          PartOf = [ "graphical-session.target" ];
        };

        Service = {
          Type = "simple";
          ExecStart = "${clipcascadePkg}/bin/clipcascade";
          Restart = "on-failure";
          RestartSec = 3;
          Environment = [
            "XDG_CURRENT_DESKTOP=Hyprland"
          ];
        };

        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    };
  };
}
