{ config, lib, pkgs, ... }:

let

  cfg = config.programs.clipcascade;

  appIndicatorPkg =

    if pkgs ? libayatana-appindicator

    then pkgs.libayatana-appindicator

    else pkgs.libayatana-appindicator;

  pythonEnv = pkgs.python3.withPackages (ps: with ps; [

    tkinter

    requests

    websocket-client

    pycryptodome

    pyperclip

    pystray

    pyfiglet

    beautifulsoup4

    xxhash

    plyer

    aiortc

    pygobject3

  ]);

  giTypelibPath = lib.makeSearchPath "lib/girepository-1.0" [

    pkgs.gtk3

    pkgs.glib

    pkgs.gdk-pixbuf

    pkgs.pango

    pkgs.atk

    appIndicatorPkg

  ];

  xdgDataDirs = lib.makeSearchPath "share"[

    pkgs.gtk3

    pkgs.gsettings-desktop-schemas

    pkgs.hicolor-icon-theme

    pkgs.shared-mime-info

  ];

  runtimePath = lib.makeBinPath [

    pkgs.xclip

    pkgs.wl-clipboard

    pkgs.dunst

    pkgs.xdg-utils

    pkgs.dbus

    pkgs.ffmpeg

    pkgs.gtk3

  ];

  clipcascadePkg = pkgs.stdenvNoCC.mkDerivation rec {

    pname = "clipcascade";

    version = cfg.version;

    src = pkgs.fetchFromGitHub {

      owner = "Sathvik-Rao";

      repo = "ClipCascade";

      rev = "v${version}";

      hash = cfg.hash;

    };

    nativeBuildInputs = [ pkgs.makeWrapper ];

    dontBuild = true;

    installPhase = ''

      runHook preInstall

      mkdir -p "$out/share/clipcascade"

      cp -r ClipCascade_Desktop "$out/share/clipcascade/"

      mkdir -p "$out/bin"

      cat > "$out/bin/clipcascade" <<'EOF'

#!${pkgs.runtimeShell}

set -e

app_home="$HOME/.local/share/clipcascade"

run_dir="$app_home/ClipCascade_Desktop"

src_dir="${placeholder "out"}/share/clipcascade/ClipCascade_Desktop"

if [ ! -d "$run_dir" ]; then

  mkdir -p "$app_home"

  cp -r "$src_dir" "$run_dir"

fi
chmod -R u+rwX "$run_dir"

export GI_TYPELIB_PATH="${giTypelibPath}"

export XDG_DATA_DIRS="${xdgDataDirs}"

export XDG_CURRENT_DESKTOP="Hyprland"

export PATH="${runtimePath}:$PATH"

export PYTHONPATH="${pythonEnv}/${pythonEnv.sitePackages}"

cd "$run_dir/src"

exec ${pythonEnv}/bin/python3 ./main.py

EOF

      chmod +x "$out/bin/clipcascade"

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

      default = "sha256-csAEPCdPHxWz7gp4ES4r5bOnVUKDw3oo8lt4MXqKyo=";

      description = "Хэш исходников";

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

          Environment = [ "XDG_CURRENT_DESKTOP=Hyprland" ];

        };

        Install = {

          WantedBy = [ "graphical-session.target" ];

        };

      };

    };

  };
}
