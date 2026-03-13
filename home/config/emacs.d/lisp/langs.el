;;; langs.el --- language-specific configuration -*- lexical-binding: t; -*-

;; ----------------------------
;; Python
;; ----------------------------

(use-package python
  :ensure nil)

(defcustom my/python-run-interpreter nil
  "Какой интерпретатор запускать при C-c C-c в python-mode.
Если nil — берём `python-shell-interpreter` или fallback на \"python3\"."
  :type '(choice (const :tag "Auto" nil) string))

(require 'comint)

(defcustom my/run-bottom-window-height 0.25
  "Высота нижнего окна (side-window) для интерактивного запуска."
  :type 'number)

(defun my/run--display-bottom (buf)
  (display-buffer
   buf
   `(display-buffer-reuse-window display-buffer-in-side-window
				 (side . bottom)
				 (slot . 0)
				 (window-height . ,my/run-bottom-window-height))))

(defun my/run--kill-proc (buf)
  (when (buffer-live-p buf)
    (let ((p (get-buffer-process buf)))
      (when (process-live-p p)
        (delete-process p)))))

(defun my/run--comint (buffer-name program args &optional dir tmpfile)
  "Запустить PROGRAM ARGS в comint-буфере BUFFER-NAME.
Если tmpfile не nil — удалить файл при завершении процесса."
  (let* ((buf (get-buffer-create buffer-name))
         (default-directory (or dir default-directory)))
    (my/run--kill-proc buf)
    (with-current-buffer buf (erase-buffer))
    (apply #'make-comint-in-buffer buffer-name buf program nil args)
    (with-current-buffer buf
      (setq-local comint-prompt-read-only t)
      (setq-local comint-scroll-to-bottom-on-input t)
      (setq-local comint-scroll-to-bottom-on-output t)
      (setq-local comint-move-point-for-output t))
    (let ((proc (get-buffer-process buf)))
      (when (and (process-live-p proc) tmpfile)
        (process-put proc 'my/tmpfile tmpfile)
        (set-process-sentinel
         proc
         (lambda (p _msg)
           (when (memq (process-status p) '(exit signal))
             (let ((f (process-get p 'my/tmpfile)))
               (when (and (stringp f) (file-exists-p f))
                 (ignore-errors (delete-file f)))))))))
    (my/run--display-bottom buf)
    buf))

(defun my/python-run-buffer ()
  "Сохранить буфер и запустить как: python -i file.py (интерактивно)."
  (interactive)
  (let* ((interp (or my/python-run-interpreter
                     (and (boundp 'python-shell-interpreter) python-shell-interpreter)
                     "python3"))
         (file (buffer-file-name))
         (tmp  (unless file (make-temp-file "emacs-py-" nil ".py")))
         (runfile (or file tmp)))
    (if file
        (save-buffer)
      (write-region (point-min) (point-max) tmp nil 'silent))
    (my/run--comint
     "*Run: Python*"
     interp
     (list "-i" runfile)
     (file-name-directory runfile)
     tmp)))

(with-eval-after-load 'eglot
  (when (executable-find "pyright-langserver")
    (add-to-list 'eglot-server-programs
                 '((python-mode python-ts-mode) . ("pyright-langserver" "--stdio")))))

;; ----- Company sorting: exact match first (within each backend) -----

(defun my/company--prefix-string ()
  (cond
   ((stringp company-prefix) company-prefix)
   ((consp company-prefix) (car company-prefix))
   (t nil)))

(defun my/company-exact-first-per-backend (cands)
  "Move exact/prefix matches to the top *within each backend*."
  (let ((pref (my/company--prefix-string)))
    (if (not (and (stringp pref) (> (length pref) 0)))
        cands
      (let* ((pref-down (downcase pref))
             (order nil)
             (groups (make-hash-table :test #'equal)))
        ;; group candidates by backend, preserve first-seen backend order
        (dolist (c cands)
          (let* ((b (or (get-text-property 0 'company-backend c) 'unknown))
                 (lst (gethash b groups)))
            (unless lst (push b order))
            (puthash b (cons c lst) groups)))
        (setq order (nreverse order))
        ;; reorder inside each backend: exact -> prefix -> rest
        (apply #'append
               (mapcar
                (lambda (b)
                  (let ((lst (nreverse (gethash b groups)))
                        exact prefix rest)
                    (dolist (c lst)
                      (let ((s (downcase (substring-no-properties c))))
                        (cond
                         ((string= s pref-down) (push c exact))
                         ((string-prefix-p pref-down s) (push c prefix))
                         (t (push c rest)))))
                    (append (nreverse exact) (nreverse prefix) (nreverse rest))))
                order))))))

(defun my/python-company-setup ()
  ;; Company: keywords -> snippets -> LSP(CAPF) -> dabbrev (и всё это выше файлов)
  (setq-local company-backends
              '((company-keywords
                 company-yasnippet
                 company-capf
                 :with company-dabbrev-code
                 :separate)
                company-files))

  ;; 1) держим важные backends выше :with  2) точные совпадения вверх  3) косметика по регистру
  (setq-local company-transformers
              '(company-sort-by-backend-importance
                my/company-exact-first-per-backend
                company-sort-prefer-same-case-prefix))

  ;; меньше мусора от dabbrev: только буферы того же major-mode
  (setq-local company-dabbrev-code-other-buffers t)
  (setq-local company-dabbrev-code-everywhere nil))

(defun my/python-setup ()
  (eglot-ensure)
  (my/python-company-setup)
  (local-set-key (kbd "C-c C-c") #'my/python-run-buffer))

;; python-base-mode-hook сработает и для python-mode, и для python-ts-mode
(add-hook 'python-base-mode-hook #'my/python-setup)

;; ----------------------------
;; JavaScript (Node) + LSP (typescript-language-server)
;; ----------------------------

(use-package js
  :ensure nil)

(with-eval-after-load 'eglot
  (when (executable-find "typescript-language-server")
    (add-to-list 'eglot-server-programs
                 '((js-mode js-ts-mode) . ("typescript-language-server" "--stdio")))))

(defun my/js-setup ()
  (when (executable-find "typescript-language-server")
    (eglot-ensure)))

(add-hook 'js-mode-hook    #'my/js-setup)
(add-hook 'js-ts-mode-hook #'my/js-setup)

;; ----------------------------
;; Rust
;; ----------------------------

(use-package rust-mode
  :mode "\\.rs\\'"
  :custom
  (rust-mode-treesitter-derive t)
  :hook
  (rust-mode . (lambda () (setq indent-tabs-mode nil))))

(with-eval-after-load 'eglot
  (when (executable-find "rust-analyzer")
    (add-to-list 'eglot-server-programs
                 '(rust-mode . ("rust-analyzer")))))

(add-hook 'rust-mode-hook #'eglot-ensure)

;; ----------------------------
;; Fish
;; ----------------------------

(use-package fish-mode
  :mode "\\.fish\\'")

;; ----------------------------
;; Nix / flakes
;; ----------------------------

(use-package nix-mode
  :mode (("\\.nix\\'" . nix-mode)
         ("flake\\.nix\\'" . nix-mode)
         ("shell\\.nix\\'" . nix-mode)
         ("default\\.nix\\'" . nix-mode))
  :interpreter ("nix" . nix-mode)
  :hook (nix-mode . my/nix-setup))

(with-eval-after-load 'eglot
  ;; Предпочитаем nixd, fallback на nil
  (cond
   ((executable-find "nixd")
    (add-to-list 'eglot-server-programs
                 '(nix-mode . ("nixd"))))
   ((executable-find "nil")
    (add-to-list 'eglot-server-programs
                 '(nix-mode . ("nil"))))))

(defcustom my/nix-format-program nil
  "Какой форматтер использовать для Nix.
nil = auto: alejandra -> nixfmt -> nixfmt-classic."
  :type '(choice (const :tag "Auto" nil) string))

(defun my/nix-format-command ()
  (or my/nix-format-program
      (executable-find "alejandra")
      (executable-find "nixfmt")
      (executable-find "nixfmt-classic")))

(with-eval-after-load 'reformatter
  (let ((fmt (my/nix-format-command)))
    (when fmt
      (reformatter-define my/nix-format
        :program fmt))))

(defun my/nix-project-root ()
  (or (locate-dominating-file default-directory "flake.nix")
      (locate-dominating-file default-directory "shell.nix")
      (locate-dominating-file default-directory "default.nix")
      default-directory))

(defun my/nix-compile-in-root (command)
  (let ((default-directory (file-name-as-directory (my/nix-project-root))))
    (compile command)))

(defun my/nix-flake-check ()
  "Запустить `nix flake check` из корня flake."
  (interactive)
  (my/nix-compile-in-root "nix flake check"))

(defun my/nix-flake-show ()
  "Показать outputs текущего flake."
  (interactive)
  (my/nix-compile-in-root "nix flake show"))

(defun my/nix-flake-build ()
  "Собрать default package текущего flake."
  (interactive)
  (my/nix-compile-in-root "nix build"))

(defun my/nix-flake-develop ()
  "Открыть shell c `nix develop` в корне проекта."
  (interactive)
  (let ((default-directory (file-name-as-directory (my/nix-project-root))))
    (terminal-here-launch)
    (message "Открой в терминале: nix develop")))

(defun my/nix-setup ()
  "Nix: LSP + форматирование + flake-команды."
  (setq-local indent-tabs-mode nil)
  (setq-local tab-width 2)

  ;; completion/hover/diagnostics/code actions
  (when (or (executable-find "nixd")
            (executable-find "nil"))
    (eglot-ensure))

  ;; format-on-save
  (when (fboundp 'my/nix-format-on-save-mode)
    (my/nix-format-on-save-mode 1))

  ;; как во многих IDE: C-c C-c = проверить flake
  (local-set-key (kbd "C-c C-c") #'my/nix-flake-check))

;; ----------------------------
;; Shell scripts (sh/bash) + LSP (bash-language-server)
;; ----------------------------

(use-package sh-script
  :ensure nil)

(with-eval-after-load 'eglot
  (when (executable-find "bash-language-server")
    (add-to-list 'eglot-server-programs
                 '((sh-mode sh-ts-mode bash-ts-mode)
                   . ("bash-language-server" "start")))))

(defun my/eglot-ensure-bash ()
  (when (executable-find "bash-language-server")
    (eglot-ensure)))

(add-hook 'sh-mode-hook      #'my/eglot-ensure-bash)
(add-hook 'sh-ts-mode-hook   #'my/eglot-ensure-bash)
(add-hook 'bash-ts-mode-hook #'my/eglot-ensure-bash)

;; ----------------------------
;; Fish + LSP (fish-lsp)
;; ----------------------------

(with-eval-after-load 'eglot
  (when (executable-find "fish-lsp")
    (add-to-list 'eglot-server-programs
                 '(fish-mode . ("fish-lsp" "start")))))

(defun my/eglot-ensure-fish ()
  (when (executable-find "fish-lsp")
    (eglot-ensure)))

(add-hook 'fish-mode-hook #'my/eglot-ensure-fish)

;; ----------------------------
;; Assembly (NASM/GAS) + LSP
;; ----------------------------

(use-package nasm-mode
  :mode ("\\.asm\\'" "\\.inc\\'"))

(with-eval-after-load 'eglot
  (when (executable-find "asm-lsp")
    (add-to-list 'eglot-server-programs
                 '((asm-mode nasm-mode) . ("asm-lsp")))))

(add-hook 'asm-mode-hook  #'eglot-ensure)
(add-hook 'nasm-mode-hook #'eglot-ensure)

;; ----------------------------
;; C/C++ (clangd) + LSP
;; ----------------------------

(use-package cc-mode
  :ensure nil)

(with-eval-after-load 'eglot
  (when (executable-find "clangd")
    (add-to-list 'eglot-server-programs
                 '((c-mode c++-mode) . ("clangd")))))

(add-hook 'c-mode-hook   #'eglot-ensure)
(add-hook 'c++-mode-hook #'eglot-ensure)

;; ----------------------------
;; C/C++ (clangd) + форматирование (clang-format)
;; ----------------------------

(use-package cc-mode
  :ensure nil)

;; Если Emacs 29+ и доступны tree-sitter режимы — используем их вместо cc-mode
(when (and (fboundp 'c-ts-mode) (fboundp 'c++-ts-mode))
  (add-to-list 'major-mode-remap-alist '(c-mode   . c-ts-mode))
  (add-to-list 'major-mode-remap-alist '(c++-mode . c++-ts-mode)))

(with-eval-after-load 'eglot
  (when (executable-find "clangd")
    (add-to-list 'eglot-server-programs
                 '((c-mode c-ts-mode c++-mode c++-ts-mode)
                   . ("clangd"
                      "--background-index"
                      "--clang-tidy"
                      "--completion-style=detailed"
                      "--header-insertion=iwyu")))))

;; clang-format через reformatter: добавит команды my/clang-format-buffer и режим my/clang-format-on-save-mode
(with-eval-after-load 'reformatter
  (when (executable-find "clang-format")
    (reformatter-define my/clang-format
      :program "clang-format"
      :args (list "-style=file"))))

(defun my/c-cpp-setup ()
  "C/C++: базовые отступы + eglot + автоформат."
  (setq-local indent-tabs-mode nil)
  (setq-local tab-width 4)

  ;; cc-mode использует c-basic-offset
  (when (boundp 'c-basic-offset)
    (setq-local c-basic-offset 4))

  ;; LSP
  (when (executable-find "clangd")
    (eglot-ensure))

  ;; автоформат перед сохранением (если clang-format есть)
  (when (and (fboundp 'my/clang-format-on-save-mode)
             (executable-find "clang-format"))
    (my/clang-format-on-save-mode 1))

  ;; C-c C-c -> make (в ближайшей папке с Makefile)
  (local-set-key (kbd "C-c C-c") #'my/compile-maybe-make-build))

(add-hook 'c-mode-hook      #'my/c-cpp-setup)
(add-hook 'c++-mode-hook    #'my/c-cpp-setup)
(add-hook 'c-ts-mode-hook   #'my/c-cpp-setup)
(add-hook 'c++-ts-mode-hook #'my/c-cpp-setup)

;; ----------------------------
;; LaTeX (AUCTeX) + LSP (texlab)
;; ----------------------------

(defun my/latex-setup ()
  (setq TeX-PDF-mode t)
  (TeX-source-correlate-mode 1)
  (TeX-fold-mode 1)
  (setq-local TeX-newline-function #'reindent-then-newline-and-indent)
  (electric-indent-local-mode 1)
  ;; по умолчанию AUCTeX может дописывать {} после макроса без аргументов
  (setq-local TeX-insert-braces t))

(use-package tex
  :ensure auctex
  :defer t
  :hook
  (LaTeX-mode . my/latex-setup)
  :custom
  (TeX-auto-save t)
  (TeX-parse-self t)
  (TeX-save-query nil)
  :config
  ;; VS Code latex-workshop.latex.tools/recipes -> AUCTeX TeX-command-list
  (with-eval-after-load 'tex

    ;; открывать PDF внутри Emacs через pdf-tools
    (setq TeX-view-program-selection '((output-pdf "PDF Tools"))
          TeX-view-program-list '(("PDF Tools" TeX-pdf-tools-sync-view))
          TeX-source-correlate-start-server t)

    ;; автообновлять уже открытый PDF-буфер после компиляции
    (add-hook 'TeX-after-compilation-finished-functions
	      #'TeX-revert-document-buffer)

    (defun my/latex-run-all-silent ()
      "Собрать до готовности и открыть viewer, не показывая *tex-shell*"
      (interactive)
      (save-buffer)
      (let ((TeX-show-compilation nil)
            (display-buffer-alist
             (cons '("\\*tex-shell\\*"
                     (display-buffer-no-window)
                     (allow-no-window . t))
                   display-buffer-alist)))
        (TeX-command-run-all nil)))
    
    (add-to-list 'TeX-command-list
		 '("LuaLatexMk+QPDF"
                   "latexmk -cd -synctex=1 -interaction=nonstopmode -file-line-error -shell-escape -lualatex -auxdir=Временное %s && qpdf --optimize-images --stream-data=compress --object-streams=generate --linearize %o --replace-input"
                   TeX-run-shell nil t
                   :help "latexmk (lualatex) then qpdf optimize (in-place)"))

    (add-to-list 'TeX-command-list
		 '("LatexMk"
                   "latexmk -cd -synctex=1 -interaction=nonstopmode -file-line-error -pdf -auxdir=Временное %s"
                   TeX-run-command nil t))

    (add-to-list 'TeX-command-list
		 '("LuaLatexMk"
                   "latexmk -cd -synctex=1 -interaction=nonstopmode -file-line-error -shell-escape -lualatex -auxdir=Временное %s"
                   TeX-run-command nil t))

    (add-to-list 'TeX-command-list
		 '("XeLatexMk"
                   "latexmk -cd -synctex=1 -interaction=nonstopmode -file-line-error -xelatex -auxdir=Временное %s"
                   TeX-run-command nil t))

    (add-to-list 'TeX-command-list
		 '("LatexMkRC"
                   "latexmk -cd -auxdir=Временное %s"
                   TeX-run-command nil t))

    ;; qpdf optimize (как в VS Code)
    (add-to-list 'TeX-command-list
		 '("QPDF optimize"
                   "qpdf --optimize-images --stream-data=compress --object-streams=generate --linearize %o --replace-input"
                   TeX-run-command nil t)))

  (add-hook 'LaTeX-mode-hook
            (lambda ()
              (setq-local TeX-command-default "LuaLatexMk+QPDF")
              (setq-local TeX-show-compilation nil)
              (local-set-key (kbd "C-c C-c") #'my/latex-run-all-silent))))

(use-package company-auctex
  :after (company tex)
  :config
  (company-auctex-init))

(use-package reftex
  :ensure nil
  :hook (LaTeX-mode . reftex-mode)
  :custom
  (reftex-plug-into-AUCTeX t))

(with-eval-after-load 'eglot
  (when (executable-find "texlab")
    (add-to-list 'eglot-server-programs
                 '((latex-mode LaTeX-mode tex-mode) . ("texlab")))))

(add-hook 'LaTeX-mode-hook #'eglot-ensure)

(defun my/latex-format-on-save ()
  "LaTeX: если есть LSP/форматтер — форматировать, иначе просто переиндентировать"
  (let ((formatted nil))
    (save-mark-and-excursion
      ;; 1) LSP formatting (eglot), если реально сработало
      (when (and (fboundp 'eglot-format-buffer)
                 (bound-and-true-p eglot--managed-mode))
        (setq formatted
              (condition-case _err
                  (progn (eglot-format-buffer) t)
                (error nil))))

      ;; 2) fallback: AUCTeX indent whole buffer
      (unless formatted
        (when (fboundp 'LaTeX-indent-buffer)
          (setq formatted
                (condition-case _err
                    (progn (LaTeX-indent-buffer) t)
                  (error nil)))))

      ;; 3) самый простой fallback
      (unless formatted
        (ignore-errors (indent-region (point-min) (point-max))))))

  ;; всегда полезно
  (delete-trailing-whitespace))

(add-hook 'LaTeX-mode-hook
          (lambda ()
            (add-hook 'before-save-hook #'my/latex-format-on-save nil t)))

(defun my/latex-company-paths ()
  ;; сначала file completion, потом auctex, потом capf (LSP/команды)
  (setq-local company-backends
              '(company-files
                company-auctex-files
                (company-capf :with company-yasnippet))))

(defun my/capf-front (fn)
  (setq-local completion-at-point-functions
              (cons fn (delq fn completion-at-point-functions))))

(defun my/capf-end (fn)
  (setq-local completion-at-point-functions
              (append (delq fn completion-at-point-functions) (list fn))))

(defun my/latex-capf-prefer-auctex ()
  (when (derived-mode-p 'TeX-mode)
    ;; AUCTeX вперёд
    (my/capf-front #'TeX--completion-at-point)
    (my/capf-front #'LaTeX--arguments-completion-at-point)
    ;; Eglot в конец
    (when (fboundp 'eglot-completion-at-point)
      (my/capf-end #'eglot-completion-at-point))))

(add-hook 'LaTeX-mode-hook #'my/latex-capf-prefer-auctex)
(add-hook 'eglot-managed-mode-hook #'my/latex-capf-prefer-auctex)

(add-hook 'LaTeX-mode-hook #'my/latex-company-paths)
(add-hook 'eglot-managed-mode-hook
          (lambda ()
            (when (derived-mode-p 'TeX-mode)
              (my/latex-company-paths))))

(defun my/latex-format-on-save ()
  "Автоформат LaTeX перед сохранением: отступы + хвостовые пробелы"
  (when (derived-mode-p 'latex-mode)
    (save-excursion
      ;; AUCTeX умеет нормальные отступы
      (cond
       ((fboundp 'LaTeX-indent-buffer)
        (LaTeX-indent-buffer))
       (t
        (indent-region (point-min) (point-max)))))
    (delete-trailing-whitespace)))

(add-hook 'LaTeX-mode-hook
          (lambda ()
            (add-hook 'before-save-hook #'my/latex-format-on-save nil t)))

;; AUCTeX: не показывать лог компиляции (ни *tex-shell*, ни *TeX Help*), открывать только PDF
(with-eval-after-load 'tex
  ;; никогда не показывать окна вывода AUCTeX
  (dolist (re '("\\*\\(tex-shell\\|TeX-shell\\|TeX Shell\\)\\*"
                "\\*TeX\\( \\|[-]\\).+\\*"
                "\\*AUCTeX\\( \\|[-]\\).+\\*"))
    (add-to-list 'display-buffer-alist
                 `(,re (display-buffer-no-window) (allow-no-window . t))))

  ;; AUCTeX не должен сам переключать тебя на логи/хелпы
  (setq TeX-show-compilation nil
        TeX-display-help nil)

  ;; PDF viewer + автообновление уже открытого PDF
  (setq TeX-view-program-selection '((output-pdf "PDF Tools"))
        TeX-view-program-list '(("PDF Tools" TeX-pdf-tools-sync-view))
        TeX-source-correlate-start-server t)
  (add-hook 'TeX-after-compilation-finished-functions #'TeX-revert-document-buffer)

  ;; C-c C-c: собрать до конца и открыть/обновить PDF
  (defun my/latex-build-and-view ()
    (interactive)
    (save-buffer)
    (TeX-command-run-all nil))

  (add-hook 'LaTeX-mode-hook
            (lambda ()
              (setq-local TeX-command-default "LuaLatexMk+QPDF")
              (setq-local TeX-show-compilation nil)
              (setq-local TeX-display-help nil)
              (local-set-key (kbd "C-c C-c") #'my/latex-build-and-view))))

;; никогда не показывать *Shell Command Output*
(add-to-list 'display-buffer-alist
             '("\\*Shell Command Output\\*"
               (display-buffer-no-window)
               (allow-no-window . t)))

;; на всякий случай, если где-то используется async-shell-command
(add-to-list 'display-buffer-alist
             '("\\*Async Shell Command\\*"
               (display-buffer-no-window)
               (allow-no-window . t)))

;; LaTeX: сделать " обычной кавычкой, как в prog-mode
(with-eval-after-load 'tex
  ;; убираем TeX-insert-quote с клавиши "
  (define-key TeX-mode-map (kbd "\"") #'self-insert-command)
  (when (boundp 'LaTeX-mode-map)
    (define-key LaTeX-mode-map (kbd "\"") #'self-insert-command)))

;; LaTeX: включить автопару кавычек именно в этом режиме
(add-hook 'LaTeX-mode-hook #'electric-pair-local-mode)

;; ----------------------------
;; Markdown + LSP (marksman) + format-on-save (prettier)
;; ----------------------------

(use-package markdown-mode
  :mode (("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :custom
  (markdown-fontify-code-blocks-natively t)
  :hook
  (markdown-mode . my/markdown-setup))

(with-eval-after-load 'eglot
  (when (executable-find "marksman")
    (add-to-list 'eglot-server-programs
                 '((markdown-mode markdown-ts-mode) . ("marksman" "server")))))

(defun my/markdown-setup ()
  (when (executable-find "marksman")
    (eglot-ensure))
  (when (executable-find "prettier")
    (my/prettier-on-save-mode 1)))

;; ----------------------------
;; PDF postprocess (ONLY for weasyprint): qpdf optimize (no encryption)
;; ----------------------------

(defun my/pdf-qpdf-optimize-inplace (pdf-path)
  "Оптимизировать/линеаризовать PDF in-place через qpdf (без шифрования)."
  (when (and (stringp pdf-path)
             (file-exists-p pdf-path)
             (executable-find "qpdf"))
    (call-process
     "qpdf" nil "*qpdf*" t
     "--optimize-images"
     "--stream-data=compress"
     "--object-streams=generate"
     "--linearize"
     pdf-path
     "--replace-input")))

;; ----------------------------
;; PDF metadata (ONLY for weasyprint outputs): set Creator/Producer via exiftool
;; ----------------------------

(defcustom my/pdf-meta-creator "My Document"
  "Значение поля Creator для PDF после weasyprint."
  :type 'string)

(defcustom my/pdf-meta-producer "My PDF Engine"
  "Значение поля Producer для PDF после weasyprint."
  :type 'string)

(defun my/pdf-set-metadata-exiftool (pdf-path)
  "Переписать Creator/Producer (и XMP аналоги) через exiftool, in-place."
  (when (and (stringp pdf-path)
             (file-exists-p pdf-path)
             (executable-find "exiftool"))
    (call-process
     "exiftool" nil "*exiftool*" t
     "-overwrite_original"
     (concat "-Creator=" my/pdf-meta-creator)
     (concat "-Producer=" my/pdf-meta-producer)
     ;; чтобы Okular не показывал старое из XMP
     (concat "-XMP:CreatorTool=" my/pdf-meta-creator)
     (concat "-XMP:Producer=" my/pdf-meta-producer)
     pdf-path)))

(setq my/pdf-meta-creator "Васильченко С.Е.")
(setq my/pdf-meta-producer "А не важно)")

;; ----------------------------
;; Markdown + LSP (marksman) + PDF (pandoc -> weasyprint)
;; ----------------------------

(use-package markdown-mode
  :mode (("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :hook (markdown-mode . my/markdown-setup))

(with-eval-after-load 'eglot
  (when (executable-find "marksman")
    (add-to-list 'eglot-server-programs
                 '((markdown-mode) . ("marksman" "server")))))

(defcustom my/markdown-weasy-css
  (expand-file-name "~/.config/weasyprint/markdown.css")
  "CSS по умолчанию для weasyprint"
  :type 'string)

(defun my/markdown--pdf-path ()
  (expand-file-name (concat (file-name-base (buffer-file-name)) ".pdf")
                    (file-name-directory (buffer-file-name))))

(defun my/markdown--project-css ()
  "Если рядом с file.md лежит file.css — используем его"
  (let* ((md (buffer-file-name))
         (css (concat (file-name-sans-extension md) ".css")))
    (when (file-exists-p css) css)))

(defun my/markdown--pick-css ()
  (or (my/markdown--project-css)
      (when (file-exists-p my/markdown-weasy-css) my/markdown-weasy-css)))

(defun my/markdown-build-pdf-weasyprint ()
  "Markdown -> HTML (pandoc) -> PDF (weasyprint) и открыть PDF справа"
  (interactive)
  (unless (buffer-file-name) (user-error "Буфер не привязан к файлу"))
  (unless (executable-find "pandoc") (user-error "Не найден pandoc"))
  (unless (executable-find "weasyprint") (user-error "Не найден weasyprint"))
  (save-buffer)
  (let* ((md   (buffer-file-name))
         (dir  (file-name-directory md))
         (pdf  (my/markdown--pdf-path))
         (html (make-temp-file (concat (file-name-base md) "-") nil ".html"))
         (css  (my/markdown--pick-css))
         (cmd  (mapconcat
                #'identity
                (delq nil
                      (list
                       (format "pandoc %s -o %s --standalone"
                               (shell-quote-argument md)
                               (shell-quote-argument html))
                       (format "weasyprint -u %s %s %s %s"
                               (shell-quote-argument dir)
                               (if css (format "-s %s" (shell-quote-argument css)) "")
                               (shell-quote-argument html)
                               (shell-quote-argument pdf))))
                " && ")))
    (let ((finish-fn
           (lambda (_buf msg)
             (unwind-protect
                 (if (and (stringp msg) (string-match-p "finished" msg) (file-exists-p pdf))
		     (progn
		       (my/pdf-set-metadata-exiftool pdf)
		       (my/pdf-qpdf-optimize-inplace pdf)
		       (let ((b (get-file-buffer pdf)))
			 (when b
			   (with-current-buffer b (revert-buffer nil t))))
		       (find-file-other-window pdf))
		   ;; если сборка упала — показать лог
                   (when (get-buffer "*md-build*")
                     (pop-to-buffer "*md-build*")))
               (when (file-exists-p html) (delete-file html))
               (remove-hook 'compilation-finish-functions finish-fn)))))
      (add-hook 'compilation-finish-functions finish-fn)
      (let ((compilation-buffer-name-function (lambda (_mode) "*md-build*"))
            (display-buffer-alist
             (cons '("\\*md-build\\*"
                     (display-buffer-no-window)
                     (allow-no-window . t))
                   display-buffer-alist)))
        (compile cmd)))))

(defun my/markdown-setup ()
  (when (executable-find "marksman") (eglot-ensure))
  ;; как в LaTeX: "собрать"
  (local-set-key (kbd "C-c C-c") #'my/markdown-build-pdf-weasyprint))

;; ----------------------------
;; Web: HTML/CSS/JavaScript + LSP (Eglot) + format-on-save (prettier)
;; ----------------------------

(defcustom my/node-run-interpreter nil
  "Какой Node запускать при C-c C-c в js-mode. Если nil — \"node\"."
  :type '(choice (const :tag "Auto" nil) string))

(defun my/node-run-buffer ()
  "Сохранить буфер и запустить как: node -i file.js (интерактивно)."
  (interactive)
  (let* ((node (or my/node-run-interpreter "node")))
    (unless (executable-find node)
      (user-error "Node не найден: %s" node))
    (let* ((file (buffer-file-name))
           (tmp  (unless file (make-temp-file "emacs-js-" nil ".js")))
           (runfile (or file tmp)))
      (if file
          (save-buffer)
        (write-region (point-min) (point-max) tmp nil 'silent))
      (my/run--comint
       "*Run: Node*"
       node
       (list "-i" runfile)
       (file-name-directory runfile)
       tmp))))

;; tree-sitter modes: включаем только если грамматика реально установлена
(when (fboundp 'treesit-ready-p)
  (when (treesit-ready-p 'css)
    (add-to-list 'major-mode-remap-alist '(css-mode . css-ts-mode)))
  (when (treesit-ready-p 'javascript)
    (add-to-list 'major-mode-remap-alist '(js-mode . js-ts-mode)))
  ;; для .html проще явно привязать расширения, т.к. по умолчанию часто включается mhtml-mode
  (when (treesit-ready-p 'html)
    (add-to-list 'auto-mode-alist '("\\.html?\\'" . html-ts-mode))
    (add-to-list 'auto-mode-alist '("\\.xhtml\\'" . html-ts-mode))
    (add-to-list 'auto-mode-alist '("\\.s?html\\'" . html-ts-mode))))

;; fallback HTML mode, если html-ts-mode недоступен
(unless (and (fboundp 'treesit-ready-p) (treesit-ready-p 'html))
  (add-to-list 'auto-mode-alist '("\\.html?\\'" . mhtml-mode))
  (add-to-list 'auto-mode-alist '("\\.xhtml\\'" . mhtml-mode))
  (add-to-list 'auto-mode-alist '("\\.s?html\\'" . mhtml-mode)))

(defun my/web--maybe-eglot ()
  (cond
   ((and (derived-mode-p 'css-mode 'css-ts-mode)
         (or (executable-find "vscode-css-language-server")
             (executable-find "css-languageserver")))
    (eglot-ensure))
   ((and (derived-mode-p 'html-mode 'html-ts-mode 'mhtml-mode)
         (or (executable-find "vscode-html-language-server")
             (executable-find "html-languageserver")))
    (eglot-ensure))
   ((and (derived-mode-p 'js-mode 'js-ts-mode)
         (executable-find "typescript-language-server"))
    (eglot-ensure))))

(defun my/web--maybe-prettier ()
  (when (executable-find "prettier")
    (my/prettier-on-save-mode 1)))

(defun my/css-setup ()
  (setq-local indent-tabs-mode nil)
  (setq-local tab-width 2)
  (when (boundp 'css-indent-offset)
    (setq-local css-indent-offset 2))
  (when (boundp 'css-ts-mode-indent-offset)
    (setq-local css-ts-mode-indent-offset 2))
  (my/web--maybe-prettier)
  (my/web--maybe-eglot))

(defun my/js-setup ()
  (local-set-key (kbd "C-c C-c") #'my/node-run-buffer)
  (setq-local indent-tabs-mode nil)
  (setq-local tab-width 2)
  (when (boundp 'js-indent-level)
    (setq-local js-indent-level 2))
  (my/web--maybe-prettier)
  (my/web--maybe-eglot))

(defun my/html-preview ()
  "Сохранить текущий HTML и открыть в браузере."
  (interactive)
  (unless (buffer-file-name) (user-error "Буфер не привязан к файлу"))
  (save-buffer)
  (browse-url-of-file (buffer-file-name)))

(defun my/html-setup ()
  (setq-local indent-tabs-mode nil)
  (setq-local tab-width 2)
  (when (boundp 'sgml-basic-offset)
    (setq-local sgml-basic-offset 2))
  (my/web--maybe-prettier)
  (my/web--maybe-eglot)
  ;; C-c C-c как "собрать/посмотреть"
  (local-set-key (kbd "C-c C-c") #'my/html-preview))

(use-package css-mode
  :ensure nil
  :mode (("\\.css\\'"  . css-mode)
         ("\\.scss\\'" . css-mode)
         ("\\.less\\'" . css-mode))
  :hook ((css-mode . my/css-setup)
         (css-ts-mode . my/css-setup)))

(use-package js
  :ensure nil
  :mode (("\\.js\\'"  . js-mode)
         ("\\.mjs\\'" . js-mode)
         ("\\.cjs\\'" . js-mode))
  :hook ((js-mode . my/js-setup)
         (js-ts-mode . my/js-setup)))

(use-package mhtml-mode
  :ensure nil
  :hook ((mhtml-mode . my/html-setup)
         (html-mode  . my/html-setup)
         (html-ts-mode . my/html-setup)))

(with-eval-after-load 'eglot
  ;; Для html/mhtml/ts-html — добавим явную привязку, чтобы Eglot не спрашивал команду
  ;; (сама команда/параметры совпадают с дефолтной базой Eglot)
  (add-to-list
   'eglot-server-programs
   `((mhtml-mode html-ts-mode) .
     ,(eglot-alternatives '(("vscode-html-language-server" "--stdio")
                            ("html-languageserver" "--stdio"))))))

;; ----------------------------
;; QML / Quickshell: qml-mode + Eglot (qmlls) + format-on-save (qmlformat)
;; ВСТАВИТЬ В langs.el
;; ----------------------------

(use-package qml-mode
  :mode (("\\.qml\\'"        . qml-mode)
         ("\\.qmltypes\\'"   . qml-mode)
         ("\\.qmlproject\\'" . qml-mode)))

(with-eval-after-load 'eglot
  (let ((prog (or (executable-find "qmlls")
                  (executable-find "pyside6-qmlls"))))
    (when prog
      (add-to-list 'eglot-server-programs
                   `(qml-mode . (,prog))))))

(with-eval-after-load 'reformatter
  (let ((prog (or (executable-find "qmlformat")
                  (executable-find "pyside6-qmlformat"))))
    (when prog
      (reformatter-define my/qmlformat
        :program prog
        :args (list "--stdin-filepath"
                    (or (buffer-file-name) (buffer-name)))))))

(defun my/qml-setup ()
  "QML / Quickshell: LSP + formatter + sane indent."
  (setq-local indent-tabs-mode nil)
  (setq-local tab-width 4)
  (when (boundp 'qml-indent-offset)
    (setq-local qml-indent-offset 4))

  (when (or (executable-find "qmlls")
            (executable-find "pyside6-qmlls"))
    (eglot-ensure))

  (when (and (or (executable-find "qmlformat")
                 (executable-find "pyside6-qmlformat"))
             (fboundp 'my/qmlformat-on-save-mode))
    (my/qmlformat-on-save-mode 1))

  (when (fboundp 'my/qmlformat-buffer)
    (local-set-key (kbd "C-c C-f") #'my/qmlformat-buffer)))

(add-hook 'qml-mode-hook #'my/qml-setup)

;; ----------------------------
;; Makefile: tabs, wrapping, LSP, formatting (mbake)
;; ----------------------------

(with-eval-after-load 'eglot
  (when (executable-find "make-language-server")
    (add-to-list 'eglot-server-programs
                 '((makefile-mode makefile-gmake-mode makefile-makepp-mode)
                   . ("make-language-server"))))
  ;; fallback (если entrypoint другой)
  (when (and (not (executable-find "make-language-server"))
             (executable-find "autotools-language-server"))
    (add-to-list 'eglot-server-programs
                 '((makefile-mode makefile-gmake-mode makefile-makepp-mode)
                   . ("autotools-language-server")))))

(defun my/makefile--mbake-format-string (s)
  "Format Makefile content S using mbake; return formatted string or nil on failure."
  (when (and (executable-find "mbake") (stringp s))
    (let* ((tmp (make-temp-file "mbake-" nil ".mk"))
           (log (get-buffer-create "*mbake*"))
           (rc 0)
           (out nil))
      (unwind-protect
          (progn
            (with-temp-file tmp (insert s))
            (with-current-buffer log (erase-buffer))
            (setq rc (call-process "mbake" nil log nil "format" tmp))
            (when (and (integerp rc) (= rc 0) (file-exists-p tmp))
              (setq out (with-temp-buffer
                          (insert-file-contents tmp)
                          (buffer-string)))))
        (when (file-exists-p tmp) (delete-file tmp)))
      out)))

(defun my/makefile-format-buffer ()
  "Format current Makefile buffer with mbake."
  (interactive)
  (let ((formatted (my/makefile--mbake-format-string (buffer-string))))
    (unless formatted
      (user-error "mbake format failed (см. буфер *mbake*)"))
    (let ((p (point)))
      (erase-buffer)
      (insert formatted)
      (goto-char (min p (point-max))))))

(defun my/makefile-format-on-save ()
  (when (derived-mode-p 'makefile-mode 'makefile-gmake-mode 'makefile-makepp-mode)
    (when (executable-find "mbake")
      (my/makefile-format-buffer))))

;; защита: если где-то глобально включён untabify/whitespace-cleanup на save — в Makefile не трогать
(defun my/skip-cleanup-tabs-in-makefiles (orig &rest args)
  (if (derived-mode-p 'makefile-mode 'makefile-gmake-mode 'makefile-makepp-mode)
      nil
    (apply orig args)))

(with-eval-after-load 'whitespace
  (advice-add 'whitespace-cleanup :around #'my/skip-cleanup-tabs-in-makefiles)
  (advice-add 'whitespace-cleanup-region :around #'my/skip-cleanup-tabs-in-makefiles))

(advice-add 'untabify :around #'my/skip-cleanup-tabs-in-makefiles)

(add-hook 'makefile-mode-hook
          (lambda ()
            ;; make recipes требуют TAB по умолчанию
            (setq-local indent-tabs-mode t)
            (setq-local tab-width 8)

            ;; переносы: только визуально
            (auto-fill-mode -1)
            (visual-line-mode 1)

            ;; LSP
            (when (or (executable-find "make-language-server")
                      (executable-find "autotools-language-server"))
              (eglot-ensure))

            ;; форматирование mbake
            (add-hook 'before-save-hook #'my/makefile-format-on-save nil t)))

(provide 'langs)
;;; langs.el ends here
