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

            packageFallback = true; # nixd из devshell сможет иметь приоритет

            rootMarkers = [
              "flake.nix"
              ".git"
            ];

            settings = {
              nixpkgs = {
                expr = ''
                  let
                    flake = builtins.getFlake (builtins.toString ./.);
                  in
                    import flake.inputs.nixpkgs {
                      system = "x86_64-linux";
                    }
                '';
              };

              formatting = {
                command = [ "nixfmt" ];
              };

              options = {
                nixos-pc = {
                  expr = "(builtins.getFlake (builtins.toString ./.)).nixosConfigurations.pc.options";
                };

                nixos-laptop = {
                  expr = "(builtins.getFlake (builtins.toString ./.)).nixosConfigurations.laptop.options";
                };

                nixos-server = {
                  expr = "(builtins.getFlake (builtins.toString ./.)).nixosConfigurations.server.options";
                };

                home-pc = {
                  expr = "(builtins.getFlake (builtins.toString ./.)).homeConfigurations.pc.options";
                };

                home-laptop = {
                  expr = "(builtins.getFlake (builtins.toString ./.)).homeConfigurations.laptop.options";
                };
              };
            };
          };

          lua_ls = {
            enable = true;
            packageFallback = true;

            settings = {
              runtime = {
                version = "LuaJIT";
              };

              diagnostics = {
                globals = [
                  "vim"
                ];
              };

              workspace = {
                checkThirdParty = false;
              };

              telemetry = {
                enable = false;
              };
            };
          };

          basedpyright = {
            enable = true;
            packageFallback = true;

            rootMarkers = [
              "pyproject.toml"
              "setup.py"
              "setup.cfg"
              "requirements.txt"
              ".venv"
              ".git"
            ];

            settings = {
              basedpyright = {
                disableOrganizeImports = true;

                analysis = {
                  autoSearchPaths = true;
                  useLibraryCodeForTypes = true;

                  # Для скорости. Если хочешь проверку всего проекта — поставь "workspace".
                  diagnosticMode = "openFilesOnly";

                  # Мягко. Для более строгой проверки потом можно поставить "standard".
                  typeCheckingMode = "basic";

                  inlayHints = {
                    variableTypes = true;
                    callArgumentNames = true;
                    functionReturnTypes = true;
                  };
                };
              };
            };
          };

          ruff = {
            enable = true;
            packageFallback = true;

            rootMarkers = [
              "pyproject.toml"
              "ruff.toml"
              ".ruff.toml"
              ".git"
            ];

            extraOptions = {
              init_options = {
                settings = {
                  configurationPreference = "filesystemFirst";
                  organizeImports = false;
                };
              };
            };
          };

          clangd = {
            enable = true;
            packageFallback = true;

            rootMarkers = [
              "compile_commands.json"
              "compile_flags.txt"
              "CMakeLists.txt"
              ".clangd"
              ".git"
            ];

            cmd = [
              "clangd"
              "--background-index"
              "--clang-tidy"
              "--completion-style=detailed"
              "--header-insertion=iwyu"
            ];
          };

          rust_analyzer = {
            enable = true;

            installCargo = true;
            installRustc = true;

            packageFallback = true;

            rootMarkers = [
              "Cargo.toml"
              "rust-project.json"
              "flake.nix"
              ".git"
            ];

            settings = {
              cargo = {
                allTargets = true;

                buildScripts = {
                  enable = true;
                };

                features = "all";
              };

              check = {
                command = "clippy";
                allTargets = true;
                features = "all";
              };

              procMacro = {
                enable = true;
              };

              inlayHints = {
                bindingModeHints = {
                  enable = false;
                };

                closureReturnTypeHints = {
                  enable = "with_block";
                };

                lifetimeElisionHints = {
                  enable = "skip_trivial";
                };

                typeHints = {
                  enable = true;
                };

                parameterHints = {
                  enable = true;
                };
              };
            };
          };

          texlab = {
            enable = true;
            packageFallback = true;

            rootMarkers = [
              ".latexmkrc"
              "latexmkrc"
              ".git"
            ];

            settings = {
              texlab = {
                build = {
                  executable = "latexmk";

                  args = [
                    "-lualatex"
                    "-interaction=nonstopmode"
                    "-shell-escape"
                    "-synctex=1"
                    "-auxdir=Временное"
                    "%f"
                  ];

                  onSave = false;
                  forwardSearchAfter = false;
                };

                chktex = {
                  onOpenAndSave = false;
                  onEdit = false;
                };
              };
            };
          };

          marksman = {
            enable = true;
            packageFallback = true;

            rootMarkers = [
              ".marksman.toml"
              ".git"
            ];
          };

          bashls = {
            enable = true;
            packageFallback = true;

            rootMarkers = [
              ".git"
            ];
          };

          fish_lsp = {
            enable = true;

            packageFallback = true;

            rootMarkers = [
              ".git"
            ];
          };

          jsonls = {
            enable = true;
            packageFallback = true;

            settings = {
              validate = {
                enable = true;
              };
            };
          };

          yamlls = {
            enable = true;
            packageFallback = true;

            settings = {
              validate = true;
              hover = true;
              completion = true;
              keyOrdering = false;

              format = {
                enable = false;
              };
            };
          };

          html = {
            enable = true;
            packageFallback = true;

            settings = {
              html = {
                format = {
                  enable = false;
                };

                hover = {
                  documentation = true;
                  references = true;
                };
              };
            };
          };

          cssls = {
            enable = true;
            packageFallback = true;

            settings = {
              css = {
                validate = true;
              };

              scss = {
                validate = true;
              };

              less = {
                validate = true;
              };
            };
          };

          taplo = {
            enable = true;
            packageFallback = true;

            rootMarkers = [
              ".taplo.toml"
              "taplo.toml"
              "Cargo.toml"
              ".git"
            ];
          };

          ts_ls = {
            enable = true;
            packageFallback = true;

            rootMarkers = [
              "package.json"
              "tsconfig.json"
              "jsconfig.json"
              ".git"
            ];

            settings = {
              javascript = {
                inlayHints = {
                  includeInlayEnumMemberValueHints = true;
                  includeInlayFunctionLikeReturnTypeHints = true;
                  includeInlayFunctionParameterTypeHints = true;
                  includeInlayParameterNameHints = "literals";
                  includeInlayPropertyDeclarationTypeHints = true;
                  includeInlayVariableTypeHints = false;
                };
              };

              typescript = {
                inlayHints = {
                  includeInlayEnumMemberValueHints = true;
                  includeInlayFunctionLikeReturnTypeHints = true;
                  includeInlayFunctionParameterTypeHints = true;
                  includeInlayParameterNameHints = "literals";
                  includeInlayPropertyDeclarationTypeHints = true;
                  includeInlayVariableTypeHints = false;
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
