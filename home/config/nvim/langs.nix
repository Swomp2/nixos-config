{ ... }:
{
  programs.nixvim = {
    plugins = {
      guess-indent = {
        enable = true; # Автоматически определяет стиль отступов в чужих проектах
      };

      treesitter-context = {
        enable = true; # Показывает сверху текущий контекст: функцию, class, section и т.д.
      };

      rainbow-delimiters = {
        enable = true; # Разные цвета для вложенных (), [], {}, удобно в Nix/Lua/Rust/C++
      };
    };

    files = {
      "ftplugin/nix.lua" = {
        localOpts = {
          expandtab = true; # Tab заменяется пробелами
          tabstop = 2; # Видимая ширина tab
          shiftwidth = 2; # Размер автоотступа
          softtabstop = 2; # Поведение Tab/Backspace при вводе
          commentstring = "# %s"; # Формат комментария для gc/comment.nvim
          textwidth = 100; # Условная граница длины строки
        };
      };

      "ftplugin/lua.lua" = {
        localOpts = {
          expandtab = true; # Lua обычно пишется пробелами
          tabstop = 2; # Ширина tab
          shiftwidth = 2; # Отступ 2 пробела
          softtabstop = 2; # Удобный ввод отступов
          commentstring = "-- %s"; # Lua-комментарий
          textwidth = 100; # Ограничитель строки
        };
      };

      "ftplugin/python.lua" = {
        localOpts = {
          expandtab = true; # Python требует пробелы вместо tab
          tabstop = 4; # Python-отступ визуально 4 пробела
          shiftwidth = 4; # Автоотступ 4 пробела
          softtabstop = 4; # Tab/Backspace работают по 4 пробела
          commentstring = "# %s"; # Python-комментарий
          textwidth = 88; # Под black
        };
      };

      "ftplugin/rust.lua" = {
        localOpts = {
          expandtab = true; # Rustfmt использует пробелы
          tabstop = 4; # Ширина tab
          shiftwidth = 4; # Отступ 4 пробела
          softtabstop = 4; # Ввод отступа 4 пробела
          commentstring = "// %s"; # Rust-комментарий
          textwidth = 100; # Условная граница строки
        };
      };

      "ftplugin/c.lua" = {
        localOpts = {
          expandtab = true; # Пробелы вместо tab
          tabstop = 4; # Ширина tab
          shiftwidth = 4; # Отступ 4 пробела
          softtabstop = 4; # Ввод отступов
          cindent = true; # Встроенные C-отступы
          commentstring = "// %s"; # C/C++-стиль комментария
          textwidth = 100; # Граница строки
        };
      };

      "ftplugin/cpp.lua" = {
        localOpts = {
          expandtab = true; # Пробелы вместо tab
          tabstop = 4; # Ширина tab
          shiftwidth = 4; # Отступ 4 пробела
          softtabstop = 4; # Ввод отступов
          cindent = true; # Встроенные C/C++-отступы
          commentstring = "// %s"; # C++ комментарий
          textwidth = 100; # Граница строки
        };
      };

      "ftplugin/fish.lua" = {
        localOpts = {
          expandtab = true; # fish-скрипты пишем пробелами
          tabstop = 4; # Видимая ширина tab
          shiftwidth = 4; # Отступ 4 пробела
          softtabstop = 4; # Ввод отступов
          commentstring = "# %s"; # fish-комментарий
        };
      };

      "ftplugin/sh.lua" = {
        localOpts = {
          expandtab = true; # Shell-скрипты без настоящих tab
          tabstop = 2; # Компактный отступ
          shiftwidth = 2; # Автоотступ 2 пробела
          softtabstop = 2; # Ввод отступов
          commentstring = "# %s"; # Shell-комментарий
        };
      };

      "ftplugin/bash.lua" = {
        localOpts = {
          expandtab = true; # Bash-скрипты пробелами
          tabstop = 2; # Ширина tab
          shiftwidth = 2; # Отступ 2 пробела
          softtabstop = 2; # Ввод отступов
          commentstring = "# %s"; # Bash-комментарий
        };
      };

      "ftplugin/json.lua" = {
        localOpts = {
          expandtab = true; # JSON пробелами
          tabstop = 2; # Ширина tab
          shiftwidth = 2; # Отступ 2 пробела
          softtabstop = 2; # Ввод отступов
          conceallevel = 0; # Не скрывать кавычки/символы в JSON
        };
      };

      "ftplugin/yaml.lua" = {
        localOpts = {
          expandtab = true; # YAML нельзя нормально писать tab-ами
          tabstop = 2; # Ширина tab
          shiftwidth = 2; # YAML-отступ 2 пробела
          softtabstop = 2; # Ввод отступов
          commentstring = "# %s"; # YAML-комментарий
        };
      };

      "ftplugin/toml.lua" = {
        localOpts = {
          expandtab = true; # TOML пробелами
          tabstop = 2; # Ширина tab
          shiftwidth = 2; # Отступ 2 пробела
          softtabstop = 2; # Ввод отступов
          commentstring = "# %s"; # TOML-комментарий
        };
      };

      "ftplugin/html.lua" = {
        localOpts = {
          expandtab = true; # HTML пробелами
          tabstop = 2; # Ширина tab
          shiftwidth = 2; # Отступ 2 пробела
          softtabstop = 2; # Ввод отступов
        };
      };

      "ftplugin/css.lua" = {
        localOpts = {
          expandtab = true; # CSS пробелами
          tabstop = 2; # Ширина tab
          shiftwidth = 2; # Отступ 2 пробела
          softtabstop = 2; # Ввод отступов
          commentstring = "/* %s */"; # CSS-комментарий
        };
      };

      "ftplugin/javascript.lua" = {
        localOpts = {
          expandtab = true; # JS пробелами
          tabstop = 2; # Ширина tab
          shiftwidth = 2; # Отступ 2 пробела
          softtabstop = 2; # Ввод отступов
          commentstring = "// %s"; # JS-комментарий
        };
      };

      "ftplugin/typescript.lua" = {
        localOpts = {
          expandtab = true; # TS пробелами
          tabstop = 2; # Ширина tab
          shiftwidth = 2; # Отступ 2 пробела
          softtabstop = 2; # Ввод отступов
          commentstring = "// %s"; # TS-комментарий
        };
      };

      "ftplugin/markdown.lua" = {
        localOpts = {
          wrap = true; # В Markdown длинные строки лучше визуально переносить
          linebreak = true; # Переносить по словам
          breakindent = true; # Сохранять визуальный отступ при переносе
          textwidth = 100; # Условная ширина текста
          commentstring = "<!-- %s -->"; # HTML-комментарий внутри Markdown
        };
      };

      "ftplugin/tex.lua" = {
        localOpts = {
          wrap = true; # В LaTeX текст удобнее читать с переносами
          linebreak = true; # Переносить по словам
          breakindent = true; # Сохранять визуальный отступ

          conceallevel = 2; # Красивее отображать LaTeX-разметку
          concealcursor = "nc"; # Conceal в normal/command модах, не мешает insert моду

          textwidth = 100; # Условная граница строки
          commentstring = "% %s"; # LaTeX-комментарий
        };
      };

      "ftplugin/bib.lua" = {
        localOpts = {
          expandtab = true; # BibTeX пробелами
          tabstop = 2; # Ширина tab
          shiftwidth = 2; # Отступ 2 пробела
          softtabstop = 2; # Ввод отступов
          commentstring = "% %s"; # BibTeX-комментарий
        };
      };

      "ftplugin/make.lua" = {
        localOpts = {
          expandtab = false; # Makefile требует настоящие tab в рецептах
          tabstop = 8; # Классическая ширина tab для Makefile
          shiftwidth = 8; # Отступ tab-ом
          softtabstop = 0; # Не имитировать tab пробелами
          commentstring = "# %s"; # Makefile-комментарий
        };
      };

      "ftplugin/gitcommit.lua" = {
        localOpts = {
          wrap = true; # Commit message удобно переносить
          linebreak = true; # Перенос по словам
          spell = false; # Не включаем spell, чтобы не ловить шум от русского/английского
          textwidth = 72; # Классическая ширина тела commit message
        };
      };
    };
  };
}
