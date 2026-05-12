{ config, lib, pkgs, username ? "swomp", ... }:

let
  cfg = config.programs.clipcascade;

  optionalPkg = name:
    lib.optionals (builtins.hasAttr name pkgs) [ (builtins.getAttr name pkgs) ];

  appIndicatorPkgs =
    optionalPkg "libappindicator-gtk3"
    ++ optionalPkg "libayatana-appindicator"
    ++ optionalPkg "libdbusmenu-gtk3";

  guiLibs = [
    pkgs.gobject-introspection
    pkgs.gtk3
    pkgs.glib
    pkgs.gdk-pixbuf
    pkgs.pango
    pkgs.atk
    pkgs.cairo
    pkgs.harfbuzz
    pkgs.gsettings-desktop-schemas
    pkgs.hicolor-icon-theme
    pkgs.shared-mime-info
    pkgs.xorg.libX11
  ] ++ appIndicatorPkgs;

  giTypelibPath = lib.concatStringsSep ":" (lib.flatten (map (pkg: [
    "${pkg}/lib/girepository-1.0"
    "${lib.getLib pkg}/lib/girepository-1.0"
    "${lib.getDev pkg}/lib/girepository-1.0"
  ]) guiLibs));

  xdgDataDirs = lib.makeSearchPath "share" guiLibs;
  libraryPath = lib.makeLibraryPath guiLibs;

  runtimePath = lib.makeBinPath [
    pkgs.coreutils
    pkgs.xclip
    pkgs.wl-clipboard
    pkgs.dunst
    pkgs.libnotify
    pkgs.xdg-utils
    pkgs.dbus
    pkgs.ffmpeg
    pkgs.gtk3
  ];

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
    pycairo
    pillow
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

      mkdir -p "$out/share/clipcascade"
      cp -r ClipCascade_Desktop "$out/share/clipcascade/"

      mkdir -p "$out/bin"
      cat > "$out/bin/clipcascade" <<'SCRIPT'
#!${pkgs.bash}/bin/bash
set -euo pipefail

export PATH="${runtimePath}:$PATH"
export GI_TYPELIB_PATH="${giTypelibPath}:''${GI_TYPELIB_PATH:-}"
export LD_LIBRARY_PATH="${libraryPath}:''${LD_LIBRARY_PATH:-}"
export XDG_DATA_DIRS="${xdgDataDirs}:''${XDG_DATA_DIRS:-}"
export GDK_BACKEND="''${GDK_BACKEND:-wayland,x11}"
export PYSTRAY_BACKEND="''${PYSTRAY_BACKEND:-appindicator}"
export PYTHONPATH="${pythonEnv}/${pythonEnv.sitePackages}:''${PYTHONPATH:-}"

app_home="''${XDG_DATA_HOME:-$HOME/.local/share}/clipcascade"
run_dir="$app_home/ClipCascade_Desktop"
src_dir="${placeholder "out"}/share/clipcascade/ClipCascade_Desktop"
marker="$run_dir/.nix-source-version"

# ClipCascade keeps mutable state near main.py, so use a writable copy.
# Refresh program code on version changes, but preserve generated state files.
if [ ! -d "$run_dir/src" ] || [ ! -f "$marker" ] || [ "$(cat "$marker")" != "${version}" ]; then
  mkdir -p "$app_home"
  tmp_dir="$(mktemp -d)"

  if [ -d "$run_dir/src" ]; then
    for file in DATA ClipCascade.lock clipcascade_log.log; do
      if [ -e "$run_dir/src/$file" ]; then
        cp -a "$run_dir/src/$file" "$tmp_dir/"
      fi
    done
  fi

  rm -rf "$run_dir"
  cp -r "$src_dir" "$run_dir"
  chmod -R u+rwX "$run_dir"
  mkdir -p "$run_dir/src"

  for file in "$tmp_dir"/*; do
    if [ -e "$file" ]; then
      cp -a "$file" "$run_dir/src/"
    fi
  done

  rm -rf "$tmp_dir"
  echo "${version}" > "$marker"
fi

cd "$run_dir/src"

args=(--gui "''${CLIPCASCADE_GUI:-true}")

# In Wayland sessions use wl-clipboard mode. In X11 sessions keep xclip mode.
if [ "''${CLIPCASCADE_XMODE:-auto}" = "auto" ]; then
  if [ -n "''${WAYLAND_DISPLAY:-}" ]; then
    args+=(--xmode false)
  fi
else
  args+=(--xmode "''${CLIPCASCADE_XMODE}")
fi

if [ -n "''${CLIPCASCADE_POLLING:-}" ]; then
  args+=(--polling "''${CLIPCASCADE_POLLING}")
fi

exec ${pythonEnv}/bin/python3 ./main.py "''${args[@]}" "$@"
SCRIPT
      chmod +x "$out/bin/clipcascade"

      runHook postInstall
    '';
  };
in
{
  options.programs.clipcascade = {
    enable = lib.mkEnableOption "ClipCascade client";

    user = lib.mkOption {
      type = lib.types.str;
      default = username;
      description = "Home Manager user for which ClipCascade should be installed.";
    };

    autostart = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Start ClipCascade automatically with a graphical session.";
    };

    version = lib.mkOption {
      type = lib.types.str;
      default = "3.2.0";
      description = "ClipCascade version/tag to fetch from GitHub.";
    };

    hash = lib.mkOption {
      type = lib.types.str;
      default = "sha256-xGJZ0rkGtqQz+mngFPj9Nd1guNzokcvr2k7QNDPeRDo=";
      description = "Hash of the fetched ClipCascade source.";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "--polling" "1.5" ];
      description = "Extra arguments passed to ClipCascade.";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${cfg.user} = { lib, pkgs, ... }:
      let
        autostartScript = pkgs.writeShellScript "clipcascade-autostart" ''
          ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd \
            DISPLAY \
            WAYLAND_DISPLAY \
            XAUTHORITY \
            XDG_CURRENT_DESKTOP \
            XDG_SESSION_TYPE \
            XDG_SESSION_DESKTOP \
            DESKTOP_SESSION \
            HYPRLAND_INSTANCE_SIGNATURE \
            SWAYSOCK \
            DBUS_SESSION_BUS_ADDRESS \
            PATH || true

          ${pkgs.systemd}/bin/systemctl --user start clipcascade.service
        '';
      in
      {
        home.packages = [ clipcascadePkg ];

        systemd.user.services.clipcascade = {
          Unit = {
            Description = "ClipCascade clipboard sync client";
            Documentation = "https://github.com/Sathvik-Rao/ClipCascade";
            PartOf = [ "graphical-session.target" ];
            After = [ "graphical-session.target" ];
          };

          Service = {
            Type = "simple";
            ExecStart = "${clipcascadePkg}/bin/clipcascade ${lib.escapeShellArgs cfg.extraArgs}";
            Restart = "on-failure";
            RestartSec = 3;
            Environment = [
              "PYSTRAY_BACKEND=appindicator"
              "GDK_BACKEND=wayland,x11"
              "CLIPCASCADE_GUI=true"
              "CLIPCASCADE_XMODE=auto"
            ];
          };

          Install = lib.mkIf cfg.autostart {
            WantedBy = [ "graphical-session.target" ];
          };
        };

        xdg.configFile."autostart/clipcascade.desktop" = lib.mkIf cfg.autostart {
          text = ''
            [Desktop Entry]
            Type=Application
            Name=ClipCascade
            Comment=Clipboard sync client
            Exec=${autostartScript}
            Terminal=false
            StartupNotify=false
            X-GNOME-Autostart-enabled=true
          '';
        };
      };
  };
}
