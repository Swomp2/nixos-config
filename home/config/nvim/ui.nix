{ theme, ... }:

let
  colors = theme.colors;
in
{
  programs.nixvim = {
    colorschemes.gruvbox = {
      enable = true; # Включить gruvbox.nvim

      settings = {
        terminal_colors = true; # Цвета gruvbox для встроенного terminal buffer

        undercurl = true; # Волнистое подчёркивание diagnostics
        underline = true; # Обычное подчёркивание
        bold = true; # Разрешить жирный текст

        italic = {
          strings = false; # Строки без курсива
          emphasis = true; # Markdown emphasis курсивом
          comments = true; # Комментарии курсивом
          operators = false; # Операторы без курсива
          folds = true; # Fold-текст курсивом
        };

        strikethrough = true; # Разрешить зачёркивание
        invert_selection = false; # Не инвертировать visual selection
        invert_signs = false; # Не инвертировать signcolumn
        invert_tabline = false; # Не инвертировать tabline/bufferline

        inverse = true; # Инверсия для search/diff/statusline/error-групп

        contrast = "hard"; # Тёмный контраст под bg #282828

        transparent_mode = theme.opacity.terminal < 1.0; # Если opacity.terminal меньше 1.0, фон Neovim прозрачный

        palette_overrides = {
          dark0 = colors.bg; # Основной фон
          dark1 = colors.bgAlt; # Вторичный фон
          dark2 = colors.bgMuted; # Приглушённый фон

          light0 = colors.fgStrong; # Яркий текст
          light1 = colors.fg; # Обычный текст
          gray = colors.muted; # Приглушённый текст

          neutral_orange = colors.accent; # Главный акцент
          bright_orange = colors.accent; # Яркий акцент

          neutral_yellow = colors.warning; # Warning
          bright_yellow = colors.warningBright; # Яркий warning

          neutral_red = colors.error; # Error
          bright_red = colors.errorBright; # Яркий error

          neutral_green = colors.green; # Green
          bright_green = colors.greenBright; # Bright green

          neutral_blue = colors.blue; # Blue
          bright_blue = colors.blueBright; # Bright blue

          neutral_purple = colors.purple; # Purple
          bright_purple = colors.purpleBright; # Bright purple

          neutral_aqua = colors.aqua; # Aqua
          bright_aqua = colors.aquaBright; # Bright aqua
        };

        overrides = {
          Normal = {
            fg = colors.fg; # Основной текст
            bg = "NONE"; # Прозрачный фон
          };

          NormalFloat = {
            fg = colors.fg; # Текст floating-окон
            bg = colors.bgAlt; # Фон floating-окон
          };

          FloatBorder = {
            fg = colors.accent; # Рамка floating-окон
            bg = colors.bgAlt; # Фон рамки
          };

          CursorLine = {
            bg = colors.bgAlt; # Подсветка текущей строки
          };

          Visual = {
            bg = colors.bgMuted; # Выделение текста
          };

          Search = {
            fg = colors.bg; # Текст найденного
            bg = colors.warningBright; # Фон найденного
          };

          IncSearch = {
            fg = colors.bg; # Текст текущего совпадения
            bg = colors.accent; # Фон текущего совпадения
          };

          SignColumn = {
            bg = "NONE"; # Прозрачная колонка знаков
          };

          DiagnosticError = {
            fg = colors.errorBright; # LSP error
          };

          DiagnosticWarn = {
            fg = colors.warningBright; # LSP warning
          };

          DiagnosticInfo = {
            fg = colors.blueBright; # LSP info
          };

          DiagnosticHint = {
            fg = colors.aquaBright; # LSP hint
          };

          NvimTreeNormal = {
            fg = colors.fg; # Текст дерева файлов
            bg = "NONE"; # Прозрачный фон дерева
          };

          NvimTreeFolderName = {
            fg = colors.blueBright; # Папки
          };

          NvimTreeOpenedFolderName = {
            fg = colors.accent; # Открытая папка
            bold = true;
          };

          TelescopeNormal = {
            fg = colors.fg; # Текст Telescope
            bg = colors.bgAlt; # Фон Telescope
          };

          TelescopeBorder = {
            fg = colors.accent; # Рамка Telescope
            bg = colors.bgAlt; # Фон рамки
          };

          TelescopeSelection = {
            fg = colors.fgStrong; # Выбранная строка
            bg = colors.bgMuted; # Фон выбранной строки
            bold = true;
          };
        };
      };
    };

    plugins = {
      web-devicons = {
        enable = true; # Иконки файлов
      };

      lualine = {
        enable = true; # Statusline

        settings = {
          options = {
            theme = "gruvbox"; # lualine сам берёт dark/light по opts.background
            icons_enabled = true; # Иконки в statusline
            globalstatus = true; # Один statusline на весь экран

            component_separators = {
              left = "│"; # Разделитель компонентов
              right = "│";
            };

            section_separators = {
              left = ""; # Powerline-разделитель
              right = "";
            };
          };

          sections = {
            lualine_a = [ "mode" ]; # NORMAL/INSERT/VISUAL
            lualine_b = [
              "branch"
              "diff"
            ]; # Git-ветка и diff
            lualine_c = [ "filename" ]; # Имя файла
            lualine_x = [
              "diagnostics"
              "encoding"
              "filetype"
            ]; # LSP/кодировка/тип
            lualine_y = [ "progress" ]; # Позиция в файле
            lualine_z = [ "location" ]; # Строка:колонка
          };
        };
      };

      bufferline = {
        enable = true; # Верхняя строка буферов

        settings = {
          options = {
            mode = "buffers"; # Показывать буферы
            diagnostics = "nvim_lsp"; # Diagnostics от LSP
            separator_style = "slant"; # Скошенные разделители
            show_buffer_close_icons = false; # Без крестиков на буферах
            show_close_icon = false; # Без общего крестика
            always_show_bufferline = true; # Показывать всегда

            offsets = [
              {
                filetype = "NvimTree"; # Отступ под дерево файлов
                text = "Файлы"; # Заголовок дерева
                text_align = "center"; # Центрировать
                separator = true; # Разделитель
              }
            ];
          };

          highlights = {
            fill = {
              bg = colors.bg; # Фон пустой части bufferline
            };

            background = {
              fg = colors.muted; # Неактивные буферы
              bg = colors.bg;
            };

            buffer_selected = {
              fg = colors.fgStrong; # Активный буфер
              bg = colors.bgAlt;
              bold = true;
            };

            separator = {
              fg = colors.bg; # Разделители
              bg = colors.bg;
            };

            separator_selected = {
              fg = colors.bg;
              bg = colors.bgAlt;
            };
          };
        };
      };

      dashboard = {
        enable = true; # Стартовый экран

        settings = {
          theme = "doom"; # Вид стартового экрана

          config = {
            header = [
              ""
              "███████╗██╗   ██╗██╗███╗   ███╗"
              "██╔════╝██║   ██║██║████╗ ████║"
              "███████╗██║   ██║██║██╔████╔██║"
              "╚════██║╚██╗ ██╔╝██║██║╚██╔╝██║"
              "███████║ ╚████╔╝ ██║██║ ╚═╝ ██║"
              "╚══════╝  ╚═══╝  ╚═╝╚═╝     ╚═╝"
              ""
            ]; # Заголовок без своих биндов
          };
        };
      };

      nvim-tree = {
        enable = true; # Дерево файлов

        settings = {
          hijack_cursor = true; # Курсор остаётся на имени файла
          sync_root_with_cwd = true; # Корень дерева = cwd

          view = {
            width = 34; # Ширина дерева
            side = "left"; # Слева
          };

          renderer = {
            group_empty = true; # Схлопывать пустые папки
            highlight_git = true; # Git-подсветка
            highlight_opened_files = "name"; # Подсветка открытого файла

            icons = {
              show = {
                file = true; # Иконки файлов
                folder = true; # Иконки папок
                folder_arrow = true; # Стрелки папок
                git = true; # Git-иконки
              };
            };
          };

          filters = {
            dotfiles = false; # Показывать скрытые файлы
            git_ignored = false; # Показывать ignored-файлы
          };

          git = {
            enable = true; # Git-интеграция
            ignore = false; # Не скрывать ignored-файлы
          };

          diagnostics = {
            enable = true; # LSP-ошибки в дереве
            show_on_dirs = true; # Показывать ошибки на папках
          };
        };
      };

      telescope = {
        enable = true; # Поиск файлов/текста/буферов

        settings = {
          defaults = {
            prompt_prefix = "  "; # Иконка поиска
            selection_caret = " "; # Иконка выбранного пункта
            path_display = [ "truncate" ]; # Обрезать длинные пути

            file_ignore_patterns = [
              ".git/"
              "node_modules/"
              "result"
              "target/"
              "build/"
            ]; # Исключения из поиска
          };
        };
      };

      treesitter = {
        enable = true; # Умная подсветка

        highlight.enable = true; # Подсветка
        indent.enable = true; # Отступы
        folding.enable = true; # Folding

        nixGrammars = true; # Грамматики через Nix
      };

      indent-blankline = {
        enable = true; # Линии отступов

        settings = {
          indent = {
            char = "│"; # Символ линии
          };

          scope = {
            show_start = false; # Не показывать начало scope
            show_end = false; # Не показывать конец scope
          };
        };
      };

      noice = {
        enable = true; # Красивые сообщения/командная строка

        settings = {
          presets = {
            bottom_search = false; # Поиск не внизу
            command_palette = true; # Командная строка по центру
            long_message_to_split = true; # Длинные сообщения в split
            inc_rename = false; # Без inc-rename
            lsp_doc_border = true; # Рамки у LSP popup
          };
        };
      };

      notify = {
        enable = true; # Красивые уведомления

        settings = {
          timeout = 2500; # Время показа
          stages = "fade_in_slide_out"; # Анимация
        };
      };

      gitsigns = {
        enable = true; # Git-знаки слева

        settings = {
          current_line_blame = true; # Blame текущей строки
          current_line_blame_opts = {
            delay = 700; # Задержка blame
          };
        };
      };

      trouble = {
        enable = true; # Красивый список diagnostics/references/quickfix
      };

      todo-comments = {
        enable = true; # Подсветка TODO/FIXME/HACK/NOTE
      };

      comment = {
        enable = true; # Комментирование gc
      };

      nvim-autopairs = {
        enable = true; # Автозакрытие скобок/кавычек

        settings = {
          check_ts = true; # Учитывать Treesitter
        };
      };

      colorizer = {
        enable = true; # Показывать реальные цвета прямо в коде, как в VS Code

        settings = {
          filetypes = [
            "*" # Включить почти для всех filetype

            "!dashboard" # Не нужно на стартовом экране
            "!NvimTree" # Не нужно в дереве файлов
            "!TelescopePrompt" # Не нужно в Telescope input
            "!Trouble" # Не нужно в Trouble
            "!help" # Не нужно в help-файлах
            "!lazy" # На случай lazy-like буферов
            "!mason" # На случай mason-like буферов
          ];

          user_commands = true; # Даёт команды :ColorizerToggle, :ColorizerReloadAllBuffers и т.д.

          lazy_load = false; # Включать сразу, а не ждать ручного attach

          options = {
            parsers = {
              css = true; # Включить весь CSS-набор: hex, names, rgb(), hsl(), oklch(), css vars

              css_fn = true; # CSS-функции: rgb(), rgba(), hsl(), hsla(), oklch() и т.п.

              hex = {
                default = true; # Все обычные hex-форматы
                rrggbb = true; # #RRGGBB
                rgb = true; # #RGB
                rrggbbaa = true; # #RRGGBBAA
                aarrggbb = true; # #AARRGGBB
              };

              names = {
                enable = true; # Цвета словами: red, blue, white, black и т.д.
                lowercase = true; # red
                camelcase = true; # LightBlue
                uppercase = false; # RED обычно слишком шумно
              };

              css_var = {
                enable = true; # Подсвечивать var(--color), если переменная найдена
                parsers = {
                  css = true; # Разбирать значения CSS-переменных как CSS-цвета
                };
              };

              tailwind = {
                enable = true; # Подсветка Tailwind-классов типа bg-red-500/text-stone-300
                lsp = false; # Без зависимости от tailwindcss-language-server
              };

              sass = {
                enable = true; # Sass/SCSS-переменные цветов
              };

              xcolor = {
                enable = true; # LaTeX/xcolor: red!50, blue!20 и похожие конструкции
              };
            };

            display = {
              mode = [
                "background" # Красить фон самого цвета
                "virtualtext" # Дополнительно показывать цветной маркер рядом
              ];

              virtualtext = {
                position = "after"; # Маркер после найденного цвета
              };
            };
          };
        };
      };
    };
  };
}
