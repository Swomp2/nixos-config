# Codex changes

## Summary

- Added persistent audit documentation.
- Added a shared Gruvbox design system without changing visual values.
- Added and ran the official project-wide Nix formatter.
- Fixed standalone Home Manager targets.
- Removed only proven harmful duplication.
- Preserved all host/server/device-specific behavior.

## Changed files

### File: theme.nix

- Change: added semantic colors, fonts, spacing, borders, opacity, cursor,
  GTK/Qt names and Hyprland color helper.
- Reason: one source of truth for repeated desktop values.
- Source: Hyprland variables, Waybar styling, Dunst and Home Manager module
  documentation.
- Verification: all targets evaluate; both Home Manager targets build;
  generated config values inspected.

### File: flake.nix

- Change: added `theme`, `timeZone`, and
  `formatter.${system} = pkgsStable.nixfmt-tree`; passed shared arguments to
  NixOS and standalone Home Manager constructors.
- Reason: shared configuration, valid standalone Home Manager and reproducible
  project formatting.
- Source: Nix flake reference and official Nixfmt README.
- Verification: `nix flake show`, `nix flake check`, all target eval/build
  commands passed.

### Files: all `.nix` files

- Change: formatted with `nix fmt`/Nixfmt.
- Reason: remove mixed tabs/alignment/list/function formatting.
- Source: official Nixfmt.
- Verification: formatter CI pass processed 79 files with `0 changed`;
  `git diff --check` is clean.

### Files: modules/base.nix, modules/server/base.nix

- Change: use shared `timeZone`.
- Reason: remove repeated value and make it available to standalone Home
  Manager.
- Source: NixOS `time.timeZone` evaluation.
- Verification: all three NixOS targets evaluate and dry-build.

### File: modules/system-home-manager.nix

- Change: forwards `theme` and `timeZone` via Home Manager
  `extraSpecialArgs`.
- Reason: integrated and standalone Home Manager use identical shared values.
- Source: Home Manager module integration.
- Verification: integrated NixOS and standalone Home Manager targets pass.

### Files: modules/desktop.nix, modules/regreet/*.nix

- Change: cursor, Qt, GTK/icon and font values now use theme tokens.
- Reason: remove repeated values without visual changes.
- Source: NixOS/Home Manager options and Hyprland/ReGreet generated config.
- Verification: PC/laptop NixOS evaluation and dry-build pass.

### File: home/flatpak.nix

- Change: replaced `osConfig.time.timeZone` with shared `timeZone`; cursor values
  use theme.
- Reason: standalone Home Manager has `osConfig = null`; both declared home
  outputs previously failed while evaluating nix-flatpak systemd files.
- Source: Home Manager standalone semantics and nix-flatpak module.
- Verification: both `activationPackage.drvPath` values evaluate and both
  targets build.

### File: home/desktop.nix

- Change: GTK/Qt/cursor values use tokens; duplicate Starship enable and
  explicit Wofi/Wlogout/Atuin packages removed.
- Reason: these programs are already owned by their Home Manager modules.
- Source: Home Manager program modules.
- Verification: Home Manager PC/laptop builds pass.

### File: home/common.nix

- Change: generated one shared bemenu theme; removed recursive deployment of
  `home/config/btop` source.
- Reason: remove repeated CLI flags and avoid installing `btop.nix` as a runtime
  config file while `programs.btop` already owns btop configuration.
- Source: Home Manager `xdg.configFile` and `programs.btop` behavior.
- Verification: Fish parse, Home Manager builds, generated wrapper inspection.

### Files: home/config/bemenu/{cliphist,screenshot,wifi,wallpapers}.fish

- Change: use shared generated theme variables/arguments.
- Reason: remove exact repeated colors/font/border flags.
- Source: existing bemenu behavior; no command semantics changed.
- Verification: `fish --no-execute`; built wrappers source generated theme with
  the original values.

### File: home/config/hypr/common.nix

- Change: owns all shared Hyprland imports; uses theme border/radius/opacity.
- Reason: remove duplicated import lists from PC/laptop profiles.
- Source: Hyprland variable/color documentation.
- Verification: PC/laptop Home Manager builds and NixOS dry-builds pass.

### Files: home/config/hypr/hyprland-{pc,laptop}.nix

- Change: import only `common.nix`; device monitor/input/binds remain local.
- Reason: isolate shared vs device-specific configuration.
- Source: Hyprland monitor/input documentation.
- Verification: generated PC/laptop Hyprland configurations build.

### Files: home/config/hypr/common-binds.nix,
home/config/hypr/env-vars.nix, home/config/hypr/win-rules.nix

- Change: renamed from camelCase filenames; references updated.
- Reason: consistent kebab-case filenames.
- Source: repository style requirement.
- Verification: no old filename references remain; targets build.

### Files: home/config/hypr/hyprlock.nix, home/config/hypr/env-vars.nix

- Change: colors/fonts/cursor use tokens; `/home/swomp` replaced by shared
  `homeDir`.
- Reason: remove repeated username/theme values.
- Source: Home Manager extra arguments and Hyprland/Hyprlock configuration.
- Verification: generated Home Manager files build.

### File: home/config/hypr/autostart.nix

- Change: removed duplicate `services.dunst.enable`.
- Reason: `home/config/dunst/dunst.nix` already owns the option.
- Source: Home Manager Dunst module.
- Verification: generated Dunst service exists in laptop build.

### File: home/config/waybar/style.nix

- Change: added shared CSS generator with conditional laptop-only selectors.
- Reason: remove large harmful PC/laptop CSS duplication.
- Source: official Waybar styling and module class documentation.
- Verification: generated PC/laptop styles inspected; values and device-only
  selectors are correct.

### Files: home/config/waybar/waybar.nix,
home/config/waybar-laptop/waybar.nix

- Change: use shared style helper; module composition remains host-specific.
- Reason: share visual layer without merging device behavior.
- Source: Waybar/Home Manager documentation.
- Verification: both Home Manager builds pass.

### Files: home/config/dunst/dunst.nix,
home/config/kitty/kitty.nix, home/config/starship/starship.nix,
home/config/wlogout/wlogout.nix, home/config/wofi/wofi.nix

- Change: replaced repeated palette/font/border values with tokens; merged
  duplicate Dunst urgency and Wofi selector blocks.
- Reason: common design system and removal of harmful local duplication.
- Source: corresponding official modules/project documentation.
- Verification: generated Dunst/Wofi CSS inspected; Home Manager builds pass.

### Files: modules/server/docker/postgres.nix,
modules/server/docker/redis.nix, modules/server/docker/synapse.nix

- Change: removed tabs/trailing whitespace inside shell strings.
- Reason: clean diff and consistent script indentation.
- Source: shell/systemd service structure; no commands changed.
- Verification: `git diff --check`, server evaluation and dry-build pass.

### Files: docs/codex-analysis.md, docs/codex-sources.md,
docs/codex-changes.md, docs/codex-todo.md

- Change: created persistent analysis, source, change and manual-task records.
- Reason: preserve audit results in the repository.
- Source: task requirements.
- Verification: included in final diff and formatter/whitespace checks.
