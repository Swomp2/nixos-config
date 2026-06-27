{ pkgs, ... }:

{
  programs.nixvim = {
    extraPackages = with pkgs; [
      texliveFull # Даёт latexmk, lualatex, synctex и LaTeX-пакеты
      qpdf # Оптимизация PDF после сборки
      zathura # PDF viewer для VimTeX
    ];

    plugins.vimtex = {
      enable = true; # LaTeX-интеграция для Neovim

      settings = {
        mappings_enabled = false; # Не добавлять VimTeX-бинды
        imaps_enabled = false; # Не добавлять VimTeX insert-mode сокращения

        compiler_method = "latexmk"; # Основной сборщик — latexmk

        compiler_latexmk = {
          executable = "latexmk"; # Команда сборки

          continuous = 0; # Не запускать постоянную фоновую сборку
          callback = 1; # Получать статус сборки от latexmk

          aux_dir = "Временное"; # Аналог -auxdir=Временное
          out_dir = "."; # PDF остаётся рядом с .tex, как latex-workshop outDir=%DIR%

          options = [
            "-cd" # Перейти в директорию главного .tex файла
            "-synctex=1" # SyncTeX для переходов tex <-> pdf
            "-interaction=nonstopmode" # Не зависать на ошибках LaTeX
            "-file-line-error" # Ошибки в формате file:line
            "-shell-escape" # Как в lualatexmk из VS Code
            "-lualatex" # Сборка именно через LuaLaTeX
          ];
        };

        view_method = "zathura_simple"; # PDF viewer без xdotool, лучше под Wayland
        view_automatic = false; # Не открывать PDF автоматически после каждой сборки
        quickfix_mode = 0; # Не открывать quickfix автоматически
      };
    };

    extraConfigLua = ''
      local function latex_document()
        -- Если VimTeX нашёл главный .tex файл, используем его
        if vim.b.vimtex and vim.b.vimtex.tex and vim.b.vimtex.tex ~= "" then
          return vim.b.vimtex.tex
        end

        -- Иначе используем текущий открытый файл
        return vim.api.nvim_buf_get_name(0)
      end

      vim.api.nvim_create_user_command("LatexBuildQpdf", function()
        local doc = latex_document()

        if doc == "" then
          vim.notify("Файл не сохранён", vim.log.levels.ERROR)
          return
        end

        if vim.fn.fnamemodify(doc, ":e") ~= "tex" then
          vim.notify("Текущий файл не .tex", vim.log.levels.ERROR)
          return
        end

        local dir = vim.fn.fnamemodify(doc, ":p:h")
        local name = vim.fn.fnamemodify(doc, ":t:r")
        local pdf = name .. ".pdf"
        local auxdir = dir .. "/Временное"

        vim.fn.mkdir(auxdir, "p")

        vim.notify("LuaLaTeX: сборка " .. vim.fn.fnamemodify(doc, ":t"))

        vim.fn.jobstart({
          "latexmk",
          "-cd",
          "-synctex=1",
          "-interaction=nonstopmode",
          "-file-line-error",
          "-shell-escape",
          "-lualatex",
          "-auxdir=Временное",
          doc,
        }, {
          cwd = dir,
          stdout_buffered = true,
          stderr_buffered = true,

          on_exit = function(_, code)
            if code ~= 0 then
              vim.notify("LuaLaTeX завершился с ошибкой", vim.log.levels.ERROR)
              return
            end

            vim.notify("qpdf: оптимизация " .. pdf)

            vim.fn.jobstart({
              "qpdf",
              "--optimize-images",
              "--stream-data=compress",
              "--object-streams=generate",
              "--linearize",
              pdf,
              "--replace-input",
            }, {
              cwd = dir,
              stdout_buffered = true,
              stderr_buffered = true,

              on_exit = function(_, qcode)
                if qcode ~= 0 then
                  vim.notify("qpdf завершился с ошибкой", vim.log.levels.ERROR)
                  return
                end

                vim.notify("Готово: " .. dir .. "/" .. pdf)
              end,
            })
          end,
        })
      end, {})
    '';
  };
}
