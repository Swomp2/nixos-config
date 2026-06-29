{ pkgs, ... }:

{
  programs.nixvim = {
    extraPackages = with pkgs; [
      nixfmt # Форматтер Nix-кода, команда nixfmt
      stylua # Форматтер Lua
      ruff # Быстрый Python formatter/import sorter
      clang-tools # clang-format для C/C++
      rustfmt # Форматтер Rust
      shfmt # Форматтер sh/bash
      shellcheck # Статический анализатор shell скриптов
      fish # Даёт fish_indent для fish-скриптов
      prettier # Форматтер JSON/YAML/HTML/CSS/JS/TS
      tex-fmt # Форматтер LaTeX/.tex
      taplo # Форматтер для TOML
    ];

    plugins.conform-nvim = {
      enable = true; # Включить conform.nvim

      callSetup = true; # Явно сгенерировать require("conform").setup(...)

      settings = {
        formatters_by_ft = {
          "*" = [
            "trim_whitespace" # Убирать пробелы в конце строк во всех файлах
            "trim_newlines" # Убирать лишние пустые строки в конце всех файлов
          ];

          nix = [ "nixfmt" ];

          lua = [
            "stylua"
          ];

          python = [
            "ruff_organize_imports"
            "ruff_format"
          ];

          c = [
            "clang_format"
          ];

          cpp = [
            "clang_format"
          ];

          rust = [
            "rustfmt"
          ];

          sh = [
            "shfmt"
          ];

          bash = [
            "shfmt"
          ];

          fish = [
            "fish_indent"
          ];

          json = [
            "prettier"
          ];

          jsonc = [
            "prettier"
          ];

          yaml = [
            "prettier"
          ];

          html = [
            "prettier"
          ];

          css = [
            "prettier"
          ];

          javascript = [
            "prettier"
          ];

          typescript = [
            "prettier"
          ];

          toml = [ "taplo" ];
        };

        default_format_opts = {
          lsp_format = "fallback"; # Если внешнего formatter-а нет, пробовать LSP formatting
          timeout_ms = 2000; # Максимум 2 секунды на форматирование
        };

        format_on_save = {
          lsp_format = "fallback"; # При сохранении тоже использовать LSP только как запасной вариант
          timeout_ms = 2000; # Не зависать дольше 2 секунд
        };

        notify_on_error = true; # Показывать ошибку, если formatter сломался
        notify_no_formatters = false; # Не шуметь, если для типа файла нет formatter-а

        formatters = {
          clang_format = {
            prepend_args = [
              "--fallback-style=LLVM"
            ]; # Если нет .clang-format, использовать LLVM-стиль
          };

          shfmt = {
            prepend_args = [
              "-i"
              "2"
            ]; # Отступ 2 пробела для sh/bash
          };

          prettier = {
            prepend_args = [
              "--tab-width"
              "2"
            ]; # Отступ 2 пробела для web/json/yaml
          };
        };
      };
    };

    extraConfigLua = ''
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
      -- Делает стандартный Vim-оператор gq совместимым с conform.nvim
    '';
  };
}
