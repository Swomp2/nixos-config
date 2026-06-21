# Codex analysis

## Scope

Проведён полный аудит текущей NixOS/Home Manager flake-конфигурации:

- `flake.nix`, `flake.lock` и реальные flake outputs;
- все 79 Nix-файлов, попавших в formatter;
- NixOS hosts, Home Manager profiles, imports и package lists;
- device-specific disk, hardware, monitor, input, audio и Waybar настройки;
- Hyprland, Waybar, Dunst, Wofi, GTK, Qt, Flatpak, UWSM и portals;
- systemd system/user units;
- Fish launchers, MPV config и рекурсивно устанавливаемые desktop assets;
- server, nginx, Docker containers, secrets generator и security modules;
- все прямые flake inputs и их закреплённые revisions.

Vendored MPV Lua scripts, shaders, fonts and images были инвентаризированы, но
не переформатировались и не переписывались: это сторонние runtime assets, а не
Nix/style source проекта.

## Current repository state

Исходное состояние на 2026-06-21:

- branch: `main`;
- `HEAD`: `e826faa` (`Обновление от 16 июня 2026 года.`);
- `git status --short --branch`: `## main...origin/main`;
- исходный `git diff` был пуст;
- `docs/` отсутствовал;
- в корне уже был ignored `result` symlink на старую PC generation; он не
  изменён.

После аудита рабочее дерево содержит только изменения этой задачи. `flake.lock`
не изменён; это подтверждено пустым `git diff -- flake.lock`.

## Official sources policy

Изменения options и generated config сверялись с:

- Nix/NixOS/nixpkgs/Home Manager manuals and module sources;
- текущими pinned inputs из `flake.lock`;
- официальными Hyprland, Waybar, Dunst, Wofi, UWSM и nix-flatpak sources;
- официальными repositories остальных прямых flake inputs;
- полным Nix evaluation текущих targets.

Если рекомендация не требовалась для безопасной правки или не была достаточно
подтверждена, она не применялась и перенесена в `docs/codex-todo.md`.

## Flake outputs

Подтверждены через `nix flake show` и `nix eval`:

- `nixosConfigurations.pc`
- `nixosConfigurations.laptop`
- `nixosConfigurations.server`
- `homeConfigurations.pc`
- `homeConfigurations.laptop`
- `formatter.x86_64-linux`

`flake show` отображает весь `homeConfigurations` attrset как `unknown`, поэтому
его реальные ключи дополнительно подтверждены:

```text
["laptop","pc"]
```

`hosts/vm/configuration.nix` и `home/vm.nix` существуют, но не входят в flake
outputs.

## Hosts and device-specific notes

- `pc`: два NVMe, LUKS + LVM, desktop-specific performance/audio, printer,
  Vial, DP-1 2560x1440@165, отдельные key modifiers and Waybar modules.
- `laptop`: один NVMe, LUKS + Btrfs, battery/power/Bluetooth/TLP logic,
  eDP-1 2048x1280@120, Dvorak variant, gestures, brightness and battery modules.
- `server`: отдельный disk layout, Intel graphics, networkd/static LAN,
  hardened SSH/firewall, nginx, Docker services and generated secrets.
- `vm`: отдельный virtual disk and QEMU guest profile, но output не объявлен.

Host-specific disk, hardware, monitor, input, network, firewall, service,
keybind and package decisions не объединялись.

## Current structure assessment

Структура проекта в целом нормальная:

- `hosts/` связывает device-specific configuration;
- `modules/` содержит общие system modules;
- `modules/server/` изолирует server role;
- `home/` отделяет shared and device-specific Home Manager configuration;
- `home/config/` хранит program-specific modules/assets;
- `disko/` корректно разделён по устройствам.

Радикальная перестройка директорий не нужна. Добавлены только root theme tokens,
общий Waybar style helper и точечная агрегация shared Hyprland imports.

## Style issues

Найдено:

- formatter output отсутствовал;
- Nix-код смешивал tabs/spaces, compact and expanded argument sets, alignment
  spaces and inconsistent list formatting;
- три shared Hyprland filenames использовали camelCase;
- package lists не имеют единой сортировки;
- много комментариев описывают действие, а не причину;
- в трёх server shell strings оставались tabs/trailing whitespace.

Исправлено:

- добавлен `formatter.x86_64-linux = pkgsStable.nixfmt-tree`;
- `nix fmt` применён ко всему Nix tree;
- `commonBinds.nix`, `envVars.nix`, `winRules.nix` переименованы в
  `common-binds.nix`, `env-vars.nix`, `win-rules.nix`;
- shell-string whitespace исправлен;
- очевидно дублирующие enable/config definitions удалены.

Package lists не переставлялись механически: порядок profile packages может
влиять на collisions, а часть списков намеренно сгруппирована по назначению.

## Theme/design-system issues

До аудита одинаковые Gruvbox values повторялись в Hyprland, Waybar, Dunst,
Wofi, Kitty, Wlogout, Starship, Flatpak, UWSM and bemenu scripts.

Добавлен `theme.nix` с:

- semantic colors;
- UI/mono/icon fonts and sizes;
- spacing;
- border radius/width;
- opacity;
- cursor names/size;
- GTK/Qt theme names;
- helper для Hyprland `rgb(...)`.

Существующий визуальный стиль не менялся. Сгенерированные CSS/config files
проверены после build: цвета, шрифты, размеры и состояния совпадают с исходными.

Raw MPV config и independent Fish shell colors оставлены локальными: их
механическая генерация из Nix изменила бы способ установки сторонних assets.

## Duplication analysis

### Harmful

- Waybar PC/laptop содержали почти идентичный CSS.
  - Тип дублирования: вредное.
  - Исправлено: общая часть вынесена в `home/config/waybar/style.nix`;
    laptop-only selectors сохранены отдельно.
- PC/laptop Hyprland profiles повторяли один список shared imports.
  - Тип дублирования: вредное.
  - Исправлено: shared imports перенесены в `home/config/hypr/common.nix`.
- Dunst low/normal urgency повторяли идентичный attrset.
  - Тип дублирования: вредное.
  - Исправлено: общий `normalUrgency`.
- bemenu scripts повторяли полный набор theme flags.
  - Тип дублирования: вредное.
  - Исправлено: generated `bemenu-theme.fish`.
- `Europe/Moscow` повторялся и Home Manager ошибочно читал его через
  `osConfig`.
  - Тип дублирования: вредное.
  - Исправлено: общий flake argument `timeZone`.
- `programs.starship.enable`, `services.dunst.enable`, explicit Wofi/Wlogout/
  Atuin packages and copied `btop.nix` source дублировали module ownership.
  - Тип дублирования: вредное.
  - Исправлено безопасным удалением лишних definitions.

### Permissible

- Общие packages присутствуют у разных hosts/scopes.
- Base settings частично повторяются между desktop and server roles.
- Тип дублирования: допустимое.
- Не объединено: roles and closure requirements различаются.

### Intentional

- Wayland/Electron/cursor variables присутствуют на system, Home Manager, UWSM
  and Flatpak sandbox layers.
- Regreet and user Hyprland sessions повторяют monitor/input values для разных
  consumers.
- Server containers повторяют dependency edges to network/secrets/storage
  preparation units.
- Тип дублирования: намеренное.
- Не удалено, чтобы сохранить UWSM activation environment, Flatpak overrides
  and service ordering.

### Unclear

- Unused VM files and `modules/server/keys/pc (восстановлен).pub`.
- Тип дублирования: неясно.
- Не удалено; требуется решение пользователя.

## Device-specific duplication

Похожий файл найден, но не объединён: различия могут быть device-specific.
Требует ручной проверки.

Это относится к:

- `disko/{pc,laptop,server,vm}.nix`;
- `hosts/*/configuration.nix` and generated hardware files;
- `home/config/hypr/hyprland-{pc,laptop}.nix`;
- `modules/regreet/hyprland-regreet-{pc,laptop}.nix`;
- PC/laptop Waybar module composition;
- `modules/performance-pc.nix` and `modules/laptop.nix`;
- desktop/server base, hardware, package and security modules.

## Changes applied

- Созданы четыре постоянных audit documents.
- Добавлена единая design system.
- Добавлен recursive formatter and formatted all Nix files.
- Исправлен standalone Home Manager evaluation bug:
  `osConfig = null` больше не используется в Flatpak timezone.
- Устранено только доказанное harmful duplication.
- Shared Hyprland filenames приведены к kebab-case.
- Home paths в Hyprshot/Hyprlock больше не hardcode username.
- Generated CSS/Fish configs проверены из built Home Manager generations.

## Changes intentionally not applied

- `flake.lock`, state versions, hostnames, usernames and password hashes.
- Disk layouts, Secure Boot/Lanzaboote, bootloader and TPM logic.
- Monitor/input/display values and keybind meaning.
- Firewall, exposed ports, SSH policy and server dependencies.
- Docker image tags.
- UWSM launch scheme, portals and repeated Wayland environment variables.
- Hyprland plugin list/config.
- MPV vendored scripts/shaders.
- Wholesale package sorting/removal.
- VM output creation or removal.

## Verification

Passed:

- `nix-instantiate --parse` for every `.nix` file;
- `fish --no-execute` for every bemenu Fish script;
- `nix fmt`;
- `nix fmt -- --ci`: 79 files, `0 changed`;
- `git diff --check`;
- `git diff -- flake.lock`: empty;
- `nix flake show --no-write-lock-file path:.`;
- `nix flake check --no-write-lock-file path:.`: all checks passed;
- evaluation of all three NixOS `system.build.toplevel.drvPath`;
- evaluation of both Home Manager `activationPackage.drvPath`;
- `nixos-rebuild dry-build` for `pc`, `laptop`, `server`;
- `home-manager build` for `pc`, `laptop` in `/tmp`;
- inspection of generated Waybar, Wofi, Dunst and bemenu outputs.

No `switch`, `boot`, `test`, `dry-activate` or activation command was executed.

## Risks

- Formatting creates a large diff across the repository, although formatter
  changes are syntactic only.
- Renames appear as delete + untracked until the user stages them; Git should
  detect them as renames after `git add`.
- Theme tokens add one shared dependency to desktop modules; all current targets
  evaluate and both standalone Home Manager targets build.
- A visual runtime smoke test still requires logging into PC/laptop sessions;
  build-time generated files match the original values.
- Docker/application runtime health was not tested because containers/services
  were not started.
