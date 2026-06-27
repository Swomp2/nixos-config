{ ... }:
{
  programs.nixvim = {
    opts = {
      background = "dark"; # Явное включение тёмного режима для gruvbox/lualine

      number = true; # Номера строк
      relativenumber = true; # Относительные номера строк

      cursorline = true; # Подсвечивать строку с курсором
      cursorcolumn = false; # Не подсвечивать колонку

      mouse = "a"; # Включить мышь во всех режимах
      clipboard = "unnamedplus"; # Использовать системный буфер обмена

      expandtab = true; # tab превращается в пробелы
      tabstop = 2; # Ширина символа tab
      shiftwidth = 2; # Ширина автоотступа
      softtabstop = 2; # Как tab/backspace ведут себя при вводе
      smartindent = true; # Умные базовые отступы

      wrap = true; # Переносить длинные строки
      linebreak = true; # Переносить по словам

      ignorecase = true; # Поиск без учёта регистра
      smartcase = true; # Но если заглавная буква есть, то регистр учитывать

      termguicolors = true; # Нормальные 24 битные цвета
      signcolumn = "yes"; # Всегда показывать колонку знаков LSP/Git/DAP

      showmode = false; # Не показывать "-- INSERT --", это в lualine
      showcmd = false; # Не показывать вводимые команды внизу
      cmdheight = 0; # Скрыть командную строку, UI берёт noice.nvim

      splitright = true; # Вертикальные split-ы открывать справа
      splitbelow = true; # Горизонтальные split-ы открывать снизу

      scrolloff = 8; # Держать 8 строк вокруг курсора
      sidescrolloff = 8; # То же самое по горизонтали

      undofile = true; # Хранить undo между запусками nvim
      swapfile = false; # Не создавать .swp файлы
      backup = false; # Не создавать backup-файлы
      writebackup = false; # Не создавать временный backup при записи

      updatetime = 250; # Быстрее обновлять диагностику, гит
      timeoutlen = 500; # Время ожидания продолжения бинда

      pumheight = 12; # Макимальная высота меню автодополнения
      completeopt = [
        "menu" # Показывать меню автодополнения
        "menuone" # Показывать меню даже с одним вариантом
        "noselect" # Не выбирать вариант автоматически
      ];

      conceallevel = 2; # Красивое скрытие markdown/latex разметки
      laststatus = 3; # Одина общая статус линия

      list = true; # Показывать невидимые символы
      listchars = "tab:» ,trail:·,nbsp:␣"; # Отображение tab/пробелов

      fillchars = {
        eob = " ";
      };
    };

    extraConfigLua = ''
      vim.api.nvim_create_autocmd("BufReadPost", {
        desc = "Вернуть курсор на прошлое место при открытии файла",

        callback = function()
          local mark = vim.api.nvim_buf_get_mark(0, '"')
          local line_count = vim.api.nvim_buf_line_count(0)

          if mark[1] > 0 and mark[1] <= line_count then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
          end
        end,
      })
    '';
  };
}
