{ pkgs, ... }:

{
  programs.nixvim = {
    extraPackages = with pkgs; [
      nixfmt-rfc-style # Форматтер Nix-кода, команда nixfmt
      stylua # Форматтер Lua
      ruff # Быстрый Python formatter/import sorter
      clang-tools # clang-format для C/C++
      rustfmt # Форматтер Rust
      shfmt # Форматтер sh/bash
      fish # Даёт fish_indent для fish-скриптов
      nodePackages.prettier # Форматтер JSON/YAML/HTML/CSS/JS/TS
      tex-fmt # Форматтер LaTeX/.tex
    ];

    plugins.conform-nvim = {
      enable = true; # Включить conform.nvim

      callSetup = true; # Явно сгенерировать require("conform").setup(...)

      settings = {
        formatters_by_ft = {
          nix = [
            "nixfmt"
          ]; # Nix

          lua = [
            "stylua"
          ]; # Lua

          python = [
            "ruff_organize_imports"
            "ruff_format"
          ]; # Python: сначала imports, потом форматирование

          c = [
            "clang_format"
          ]; # C

          cpp = [
            "clang_format"
          ]; # C++

          rust = [
            "rustfmt"
          ]; # Rust

          sh = [
            "shfmt"
          ]; # POSIX shell

          bash = [
            "shfmt"
          ]; # Bash

          fish = [
            "fish_indent"
          ]; # Fish shell

          tex = [
          	"tex-fmt"
          ]; # LaTeX/.tex

          json = [
            "prettier"
          ]; # JSON

          jsonc = [
            "prettier"
          ]; # JSON с комментариями

          yaml = [
            "prettier"
          ]; # YAML

          html = [
            "prettier"
          ]; # HTML

          css = [
            "prettier"
          ]; # CSS

          javascript = [
            "prettier"
          ]; # JavaScript

          typescript = [
            "prettier"
          ]; # TypeScript
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
        notify_no_formatters = false; # Не шуметь, если для filetype нет formatter-а

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
