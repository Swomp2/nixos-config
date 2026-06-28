{ pkgs, ... }:

{
  programs.nixvim = {
    extraPackages = with pkgs; [
      pandoc # Конвертация Markdown -> PDF через LuaLaTeX
      python314Packages.weasyprint # Промежуточный html файл
      glow # Markdown-preview прямо в терминале/Neovim
    ];

    plugins = {
      render-markdown = {
        enable = true; # Красивый inline-render Markdown прямо в Neovim

        settings = {
          enabled = true; # Включить рендеринг по умолчанию
          render_modes = [
            "n" # Normal mode
            "c" # Command mode
            "t" # Terminal mode
          ]; # В insert mode Markdown остаётся более сырым и удобным для редактирования

          anti_conceal = {
            enabled = false; # Не показывать сырой markdown на строке курсора
          };

          debounce = 100; # Задержка обновления рендера
          file_types = [
            "markdown"
          ]; # Запускать только для Markdown

          max_file_size = 10.0; # Не рендерить очень большие Markdown-файлы

          heading = {
            enabled = true; # Красивые заголовки

            position = "overlay"; # Скрывать ## и накладывать красивые заголовки поверх

            sign = true; # Показывать знак в signcolumn
            icons = [
              "󰎤 "
              "󰎧 "
              "󰎪 "
              "󰎭 "
              "󰎱 "
              "󰎳 "
            ]; # Иконки уровней заголовков

            width = "block"; # Фон только под текстом заголовка, а не на всю строку

            left_pad = 0; # Без лишних отступов слева
            right_pad = 1; # И с небольшим отступом справа
          };

          code = {
            enabled = true; # Красиво отображать code blocks
            sign = true; # Показывать знак слева от code block
            width = "block"; # Блок кода занимает ширину блока, а не всей строки
            right_pad = 2; # Правый отступ внутри блока
          };

          bullet = {
            enabled = true; # Красивые маркеры списков
            icons = [
              "● "
              "○ "
              "◆ "
              "◇ "
            ]; # Разные маркеры для уровней вложенности
          };

          checkbox = {
            enabled = true; # Красивые чекбоксы
          };

          quote = {
            enabled = true; # Красивые blockquote/callout
            icon = "▋"; # Левый символ quote-блока
          };

          pipe_table = {
            enabled = true; # Красивое отображение Markdown-таблиц
            preset = "round"; # Скруглённые рамки таблиц
          };

          latex = {
            enabled = true; # Рендер LaTeX-блоков внутри Markdown
          };

          completions = {
            lsp = {
              enabled = true; # Completion для checkbox/callout через LSP-интеграцию render-markdown
            };
          };
        };
      };

      glow = {
        enable = true; # Markdown preview внутри Neovim через glow
      };
    };

    extraConfigLua = ''
      local pandoc = "${pkgs.pandoc}/bin/pandoc"
      local weasyprint = "${pkgs.weasyprint}/bin/weasyprint"
      local qpdf = "${pkgs.qpdf}/bin/qpdf"

      local function markdown_document()
        local file = vim.api.nvim_buf_get_name(0)

        if file == "" then
          vim.notify("Файл не сохранён", vim.log.levels.ERROR)
          return nil
        end

        if vim.fn.fnamemodify(file, ":e") ~= "md" then
          vim.notify("Текущий файл не .md", vim.log.levels.ERROR)
          return nil
        end

        return file
      end

      vim.api.nvim_create_user_command("MarkdownBuildQpdf", function()
        local doc = markdown_document()

        if not doc then
          return
        end

        local dir = vim.fn.fnamemodify(doc, ":p:h")
        local name = vim.fn.fnamemodify(doc, ":t:r")
        local css = dir .. "/" .. name .. ".css"
        local pdf = name .. ".pdf"

        if vim.fn.filereadable(css) == 0 then
          vim.notify("CSS-файл не найден: " .. css, vim.log.levels.ERROR)
          return
        end

        vim.notify("Pandoc: Markdown -> HTML -> PDF через CSS")

        vim.fn.jobstart({
          pandoc,
          doc,

          "--from=markdown",
          "--to=html5",
          "--standalone",

          "--css",
          css,

          "--pdf-engine",
          weasyprint,

          "--resource-path",
          dir,

          "-o",
          pdf,
        }, {
          cwd = dir,
          stdout_buffered = true,
          stderr_buffered = true,

          on_exit = function(_, code)
            if code ~= 0 then
              vim.notify("Pandoc/WeasyPrint завершился с ошибкой", vim.log.levels.ERROR)
              return
            end

            vim.notify("qpdf: оптимизация " .. pdf)

            vim.fn.jobstart({
              qpdf,
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
