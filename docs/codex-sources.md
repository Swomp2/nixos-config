# Codex sources

## Nix/NixOS/nixpkgs

- [Nix 2.34 flake reference](https://nix.dev/manual/nix/2.34/command-ref/new-cli/nix3-flake.html)
  - Проверено: flake inputs/outputs, `nix flake show`, lock semantics.
  - Вывод: outputs должны вычисляться как attrset; `formatter` является
    стандартным consumer-specific flake output.
- [Official Nixfmt repository](https://github.com/NixOS/nixfmt)
  - Проверено: project-wide integration with `nix fmt`.
  - Вывод: текущий официальный README рекомендует `nixfmt-tree` для `nix fmt`.
    Pinned nixpkgs также предупреждает, что `nixfmt-rfc-style` теперь alias
    `nixfmt`.
- [NixOS Manual 26.05](https://nixos.org/manual/nixos/stable/)
  - Проверено: module/configuration model, system builds, state version policy.
  - Вывод: state versions and system behavior were not changed.
- [Nixpkgs Manual](https://nixos.org/manual/nixpkgs/stable/)
  - Проверено: package sets/import configuration.
  - Вывод: stable and unstable package sets remain separate.
- [NixOS options search](https://search.nixos.org/options)
  - Проверено вместе с full target evaluation: NixOS options used by current
    configurations exist in pinned nixpkgs.
- [NixOS packages search](https://search.nixos.org/packages)
  - Проверено: formatter/package naming.
- Local `flake.lock`
  - Stable nixpkgs: `a0374025a863d007d98e3297f6aa46cc3141c2f0`.
  - Unstable nixpkgs: `9ae611a455b90cf061d8f332b977e387bda8e1ca`.
  - Вывод: lock file was sufficient and was not modified.

## Home Manager

- [Home Manager Manual](https://nix-community.github.io/home-manager/)
  - Проверено: standalone vs NixOS module use and build workflow.
  - Вывод: standalone Home Manager cannot rely on a non-null `osConfig`.
- [Home Manager options](https://nix-community.github.io/home-manager/options.xhtml)
  - Проверено: option names used by desktop modules.
- [Pinned Home Manager repository](https://github.com/nix-community/home-manager/tree/release-26.05)
  - Locked revision: `8355f0a16b2dbb06a97959a918af5b239bbe05ae`.
- [Waybar module source](https://github.com/nix-community/home-manager/blob/release-26.05/modules/programs/waybar.nix)
  - Вывод: `programs.waybar.settings` and `style` remain module-owned.
- [Dunst module source](https://github.com/nix-community/home-manager/blob/release-26.05/modules/services/dunst.nix)
  - Вывод: duplicate enable definition was unnecessary; generated sections
    preserve low/normal/critical values.
- [Wofi module source](https://github.com/nix-community/home-manager/blob/release-26.05/modules/programs/wofi.nix)
  - Вывод: explicit `home.packages = [ wofi ]` was redundant.
- [GTK module source](https://github.com/nix-community/home-manager/blob/release-26.05/modules/misc/gtk.nix)
  - Вывод: existing GTK package/name/cursor settings remain valid.

## Hyprland

- [Pinned Hyprland v0.55.4 repository](https://github.com/hyprwm/Hyprland/tree/v0.55.4)
  - Locked revision: `a0136d8c04687bb36eb8a28eb9d1ff92aea99704`.
- [Hyprland variables](https://wiki.hypr.land/Configuring/Variables/)
  - Проверено: `general`, `decoration`, blur, input, opacity and color syntax.
  - Вывод: token substitution preserves valid `rgb(...)`, integer and float
    values.
- [Hyprland monitors](https://wiki.hypr.land/Configuring/Monitors/)
  - Проверено: monitor settings are device-specific.
  - Вывод: no monitor value was changed or merged.
- [Hyprland window rules](https://wiki.hypr.land/Configuring/Window-Rules/)
  - Проверено: existing rules remain untouched except filename normalization.
- [Hyprland plugin documentation](https://wiki.hypr.land/Plugins/Using-Plugins/)
  - Проверено: plugin loading remains intact.
- [hypr-dynamic-cursors](https://github.com/VirtCode/hypr-dynamic-cursors)
  - Locked revision: `da447486c84e0be81f2cdd208af1ef92469f0a88`.
  - Вывод: plugin settings and package pin were not changed.

## Waybar

- [Official Waybar repository](https://github.com/Alexays/Waybar)
- [Waybar styling documentation](https://github.com/Alexays/Waybar/wiki/Styling)
  - Проверено: GTK CSS file, `window#waybar`, module IDs and state classes.
  - Вывод: common CSS can be generated once; laptop-specific selectors remain
    conditional.
- [Hyprland workspaces man source](https://github.com/Alexays/Waybar/blob/master/man/waybar-hyprland-workspaces.5.scd)
- [Battery module man source](https://github.com/Alexays/Waybar/blob/master/man/waybar-battery.5.scd)
  - Вывод: module composition and state names were preserved.

## Dunst

- [Official Dunst documentation](https://dunst-project.org/documentation/)
  - Проверено: global settings, urgency sections, color/frame/icon options.
  - Вывод: low and normal may share one generated attrset without changing the
    resulting `dunstrc`.

## Wofi/Rofi

- [Official Wofi repository](https://hg.sr.ht/~scoopta/wofi)
  - Проверено: Wofi remains the configured launcher; no replacement with Rofi.
- [Home Manager Wofi module](https://github.com/nix-community/home-manager/blob/release-26.05/modules/programs/wofi.nix)
  - Вывод: CSS token substitution and duplicate selector merge preserve the
    generated style.
- Rofi не используется и не анализировался как active component.

## GTK/Qt

- [GTK CSS overview](https://docs.gtk.org/gtk3/css-overview.html)
  - Проверено: Waybar/Wofi styles use GTK CSS semantics.
- [Home Manager GTK source](https://github.com/nix-community/home-manager/blob/release-26.05/modules/misc/gtk.nix)
- [Home Manager Qt source](https://github.com/nix-community/home-manager/blob/release-26.05/modules/misc/qt.nix)
- [Kvantum official repository](https://github.com/tsujan/Kvantum)
  - Вывод: Gruvbox GTK/Papirus/cursor/Kvantum selections were centralized but
    not changed.

## Flatpak/UWSM/Wayland

- [nix-flatpak official repository](https://github.com/gmodena/nix-flatpak)
  - Locked revision: `440818969ac2cbd77bfe025e884d0aa528991374`.
  - Проверено: Home Manager module, remotes/packages/overrides ownership.
  - Вывод: cursor overrides and timezone remain, but timezone is now available
    in standalone Home Manager.
- [UWSM official repository](https://github.com/Vladimir-csp/uwsm)
  - Проверено: `uwsm/env`, activation environment and `uwsm app` launcher use.
  - Вывод: repeated system/UWSM variables and Wofi-to-`uwsm app` flow are
    intentional and retained.
- [Hyprland systemd startup](https://wiki.hypr.land/Useful-Utilities/Systemd-start/)
- [xdg-desktop-portal-hyprland](https://wiki.hypr.land/Hypr-Ecosystem/xdg-desktop-portal-hyprland/)
  - Вывод: portal package/integration and restart command were not changed.

## systemd

- [systemd.unit](https://www.freedesktop.org/software/systemd/man/latest/systemd.unit.html)
- [systemd.service](https://www.freedesktop.org/software/systemd/man/latest/systemd.service.html)
- [systemd.special](https://www.freedesktop.org/software/systemd/man/latest/systemd.special.html)
- [tmpfiles.d](https://www.freedesktop.org/software/systemd/man/latest/tmpfiles.d.html)
  - Проверено: dependency fields, graphical-session target, oneshot service and
    tmpfiles structure.
  - Вывод: dependency/order/restart/security behavior was not changed; only
    formatting and whitespace were normalized.

## Other flake inputs

- [disko](https://github.com/nix-community/disko)
  - Locked revision: `ff8702b4de27f72b4c78573dfb89ec74e36abdf1`.
  - Вывод: all disk layouts are device-specific and untouched semantically.
- [Lanzaboote](https://github.com/nix-community/lanzaboote)
  - Locked revision: `e8c096ade12ec9130ff931b0f0e25d2f1bc63607`.
  - Вывод: Secure Boot configuration was not changed.
- [Home Manager](https://github.com/nix-community/home-manager)
  - Locked revision listed above.
- [Hyprland](https://github.com/hyprwm/Hyprland)
  - Locked revision listed above.
- [hypr-dynamic-cursors](https://github.com/VirtCode/hypr-dynamic-cursors)
  - Locked revision listed above.
- [nix-flatpak](https://github.com/gmodena/nix-flatpak)
  - Locked revision listed above.

Additional official project sources inspected for custom modules:

- [ClipCascade](https://github.com/Sathvik-Rao/ClipCascade)
- [AdGuard VPN CLI](https://github.com/AdguardTeam/AdGuardVPNCLI)

No version, hash, installer channel or runtime policy was changed.

## Unverified assumptions

- Docker image tags were intentionally not updated. Their newest/supported tags
  must be checked against each official registry before any future change.
- Runtime visual parity is inferred from identical generated CSS/config values
  and successful builds. A live PC/laptop session smoke test remains manual.
- Wofi upstream documentation availability is limited; no unsupported Wofi
  option change was applied.
