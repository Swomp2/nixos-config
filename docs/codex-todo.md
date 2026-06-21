# Codex TODO

## Manual checks required

1. Log into both PC and laptop sessions and visually check:
   - Waybar states;
   - Wofi selection/focus;
   - Dunst low/normal/critical notifications;
   - Wlogout icons;
   - Hyprlock;
   - Flatpak cursor and Logseq Wayland mode.
2. Run one bemenu launcher from each category, especially wallpaper picker and
   Wi-Fi password prompt.
3. Review the 56 unread Home Manager news items reported by the build.
4. Check server container health only during a planned maintenance window; no
   containers were started by this audit.

## Unverified items

- Current Docker image tags were not compared with latest official registry
  releases. Updating tags can change data formats/runtime behavior and was
  intentionally not automated.
- Vendored MPV Lua scripts/shaders were not matched against upstream revisions.
- Raw MPV colors still duplicate part of the Gruvbox palette. Converting the
  recursively copied MPV directory into generated/substituted files needs a
  separate design decision.
- Live rendering parity cannot be fully proven by evaluation/build alone.

## Device-specific duplicates not merged

Похожий файл найден, но не объединён: различия могут быть device-specific.
Требует ручной проверки.

- `disko/{pc,laptop,server,vm}.nix`
- `hosts/{pc,laptop,server,vm}/configuration.nix`
- generated hardware configuration files
- `home/config/hypr/hyprland-{pc,laptop}.nix`
- `modules/regreet/hyprland-regreet-{pc,laptop}.nix`
- PC/laptop Waybar module settings
- PC/laptop performance, battery, Bluetooth, audio, input and monitor settings
- desktop/server base, packages, hardware and security modules

## Risky changes not applied

- Do not delete or merge VM files until deciding whether VM should become a
  real flake output.
- Do not delete `modules/server/keys/pc (восстановлен).pub` until confirming it
  is an obsolete key; it is currently not referenced by `security.nix`.
- Do not narrow `modules/desktop.nix` from `allowUnfree = true` to the flake
  predicate without checking all desktop packages.
- Do not reorder every package list mechanically; profile collision precedence
  and existing semantic grouping need review.
- Do not remove repeated Wayland/cursor/Electron variables across system,
  Home Manager, UWSM and Flatpak layers.
- Do not change monitor/input/keybind values, firewall ports, SSH policy, disk
  layout, Secure Boot, secrets, Docker tags or server dependency edges without
  separate testing.
- Do not change `system.stateVersion` or `home.stateVersion`.
- Do not run switch as part of this audit.

## Suggested future improvements

- Decide whether to expose `vm` as `nixosConfigurations.vm` and possibly
  `homeConfigurations.vm`; currently the files are unreachable.
- Add a small automated check that evaluates all five declared targets.
- Consider a deliberate second pass on comments: retain only rationale and
  constraints, after confirming which Russian comments are useful to the
  maintainer.
- Consider splitting very large server files (`nextcloud.nix`, `nginx.nix`) only
  if future maintenance becomes difficult; no split is currently required.
- Review password hashes committed in `flake.nix` and decide whether a secrets
  system is preferable. No secret handling was changed automatically.

## Commands to run

Commands below use Fish syntax and do not activate configuration:

```fish
nix fmt --no-write-lock-file -- --ci
nix flake check --no-write-lock-file path:.

nixos-rebuild dry-build --no-write-lock-file --flake path:.#pc
nixos-rebuild dry-build --no-write-lock-file --flake path:.#laptop
nixos-rebuild dry-build --no-write-lock-file --flake path:.#server

home-manager build --no-write-lock-file --flake path:.#pc
home-manager build --no-write-lock-file --flake path:.#laptop

git diff --check
git diff -- flake.lock
git status --short
```

`path:.` is intentional while new files are untracked: unlike the Git flake
reference, it includes all files in the working directory. After staging the
new files, `.#pc`, `.#laptop` and `.#server` may be used normally.

For the manual runtime stage, run switch commands only after reviewing the diff
and only by a separate explicit decision.
