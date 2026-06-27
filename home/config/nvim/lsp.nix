{ theme, ... }:

let
  colors = theme.colors;
in
{
  programs.nixvim = {
    plugins = {
      lsp = {
        enable = true; # Включает nvim-lspconfig через nixvim

        inlayHints = true; # Включает встроенные подсказки типов/параметров, если сервер их поддерживает

        capabilities = ''
          capabilities.textDocument.completion.completionItem.snippetSupport = true
        ''; # Разрешает LSP отдавать сниппеты в меню автодополнения

        servers = {
          nixd = {
            enable = true; # LSP для Nix/NixOS/Home Manager/flakes
            packageFallback = true; # Локальный nixd из devshell сможет переопределить nixvim-версию

            rootMarkers = [
              "flake.nix"
              ".git"
            ]; # Корень проекта искать по flake.nix или git
          };

          lua_ls = {
            enable = true; # LSP для Lua, нужен для конфигов Neovim/плагинов

            settings = {
              Lua = {
                runtime = {
                  version = "LuaJIT"; # Neovim использует LuaJIT
                };

                diagnostics = {
                  globals = [
                    "vim"
                  ]; # Не ругаться на глобальную переменную vim
                };

                workspace = {
                  checkThirdParty = false; # Не спрашивать про сторонние Lua-библиотеки
                };

                telemetry = {
                  enable = false; # Отключить телеметрию LuaLS
                };
              };
            };
          };

          pyright = {
            enable = true; # LSP для Python

            settings = {
              python = {
                analysis = {
                  autoSearchPaths = true; # Автоматически искать import paths
                  useLibraryCodeForTypes = true; # Использовать код библиотек для типов
                  typeCheckingMode = "basic"; # Мягкая проверка типов, не слишком шумная
                  diagnosticMode = "workspace"; # Проверять весь workspace, а не только открытый файл
                };
              };
            };
          };

          clangd = {
            enable = true; # LSP для C/C++

            packageFallback = true; # Позволяет devshell-версии clangd иметь приоритет

            cmd = [
              "clangd"
              "--background-index"
              "--clang-tidy"
              "--completion-style=detailed"
              "--header-insertion=iwyu"
            ]; # Индексация проекта, clang-tidy, подробные дополнения, подсказки include
          };

          texlab = {
            enable = true; # LSP для LaTeX/BibTeX

            settings = {
              texlab = {
                build = {
                  executable = "latexmk"; # Сборщик LaTeX-документов
                  args = [
                    "-lualatex"
                    "-interaction=nonstopmode"
                    "-shell-escape"
                    "-synctex=1"
                    "%f"
                  ]; # LuaLaTeX + SyncTeX, чтобы потом прыгать между PDF и .tex

                  onSave = true; # Не собирать автоматически при каждом сохранении
                  forwardSearchAfter = false; # Forward search настроим отдельно в latex.nix
                };

                chktex = {
                  onOpenAndSave = false; # Не включать шумный chktex автоматически
                  onEdit = false; # Не проверять LaTeX на каждый ввод
                };
              };
            };
          };

          marksman = {
            enable = true; # LSP для Markdown: ссылки, заголовки, diagnostics
          };

          bashls = {
            enable = true; # LSP для shell-скриптов
          };

          jsonls = {
            enable = true; # LSP для JSON
          };

          yamlls = {
            enable = true; # LSP для YAML
          };

          html = {
            enable = true; # LSP для HTML
          };

          cssls = {
            enable = true; # LSP для CSS
          };

          taplo = {
            enable = true; # LSP для TOML
          };

          rust_analyzer = {
            enable = true; # LSP для Rust

            installCargo = true; # Скачивать cargo автоматически
            installRustc = true; # Скачивать rustc автоматически

            packageFallback = true; # rust-analyzer из devshell сможет переопределить версию nixvim

            rootMarkers = [
              "Cargo.toml" # Обычный Rust-проект
              "flake.nix" # Rust-проект с Nix flake
              ".git" # Запасной вариант
            ]; # По этим файлам определяется корень проекта

            settings = {
              rust-analyzer = {
                cargo = {
                  allTargets = true; # Анализировать lib/bin/tests/examples/benches

                  buildScripts = {
                    enable = true; # Запускать build.rs для точного анализа
                  };

                  features = "all"; # Включить все Cargo features
                };

                check = {
                  command = "clippy"; # Вместо cargo check использовать cargo clippy
                  allTargets = true; # Проверять все targets
                  features = "all"; # Проверять со всеми features
                };

                procMacro = {
                  enable = true; # Включить proc-macro, нужно для derive-макросов
                };

                inlayHints = {
                  bindingModeHints = {
                    enable = false; # Не показывать лишний шум для ref/mut binding
                  };

                  closureReturnTypeHints = {
                    enable = "with_block"; # Показывать типы возврата у сложных closure
                  };

                  lifetimeElisionHints = {
                    enable = "skip_trivial"; # Показывать жизненный цикл только где это полезно
                  };

                  typeHints = {
                    enable = true; # Подсказки типов переменных
                  };

                  parameterHints = {
                    enable = true; # Подсказки имён параметров
                  };
                };
              };
            };
          };
        };
      };

      "blink-cmp" = {
        enable = true; # Красивый движок автодополнения
      };
    };

    extraConfigLua = ''
      vim.diagnostic.config({
        virtual_text = {
          prefix = "●",
          spacing = 4,
        }, -- Короткие inline diagnostics прямо в коде

        virtual_lines = false, -- Не занимать много места строками diagnostics

        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.INFO] = "",
            [vim.diagnostic.severity.HINT] = "󰌵",
          },
        }, -- Иконки ошибок слева в signcolumn

        underline = true, -- Подчёркивать проблемный участок кода

        update_in_insert = false, -- Не обновлять diagnostics прямо во время ввода

        severity_sort = true, -- Сначала показывать более серьёзные ошибки

        float = {
          border = "rounded",
          source = true,
        }, -- Красивое floating-окно diagnostics с источником ошибки
      })

      vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = "${colors.errorBright}", bg = "NONE" })
      vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", { fg = "${colors.warningBright}", bg = "NONE" })
      vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo", { fg = "${colors.blueBright}", bg = "NONE" })
      vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint", { fg = "${colors.aquaBright}", bg = "NONE" })
    ''; # Цвета diagnostics берутся theme.nix
  };
}
