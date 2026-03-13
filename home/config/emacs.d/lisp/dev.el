;;; dev.el --- completion, diagnostics, LSP glue -*- lexical-binding: t; -*-

;; ----------------------------
;; Подсказки клавиш
;; ----------------------------

(use-package which-key
  :demand t
  :config
  (which-key-mode 1)
  (which-key-setup-minibuffer)
  (setq which-key-popup-type 'minibuffer))

;; ----------------------------
;; Проекты
;; ----------------------------

(use-package projectile
  :demand t
  :config
  (projectile-mode +1)
  ;; Явно считаем Nix- и Git-корни полноценными проектами
  (dolist (marker '("flake.nix" "shell.nix" "default.nix" ".git" ".projectile"))
    (add-to-list 'projectile-project-root-files marker))
  (define-key projectile-mode-map (kbd "C-c p") #'projectile-command-map))

;; ----------------------------
;; Сборка проекта: make если есть Makefile
;; ----------------------------

(require 'cl-lib)

(defun my/project-make-dir ()
  "Найти ближайшую вверх директорию с Makefile/makefile/GNUmakefile"
  (let* ((start (or (buffer-file-name) default-directory))
         (start-dir (file-name-directory start))
         (names '("Makefile" "makefile" "GNUmakefile")))
    (locate-dominating-file
     start-dir
     (lambda (dir)
       (cl-some (lambda (n) (file-exists-p (expand-file-name n dir))) names)))))

(defcustom my/make-build-command "make"
  "Команда для сборки через Makefile (build)."
  :type 'string)

(defcustom my/make-run-command "make clean && make && make run"
  "Команда полного цикла сборки/запуска через Makefile."
  :type 'string)

(defun my/compile-maybe-make-build ()
  "Если найден Makefile вверх по дереву — запустить `my/make-build-command`, иначе обычный `compile`."
  (interactive)
  (require 'compile)
  (let ((make-dir (my/project-make-dir)))
    (if make-dir
        (let ((default-directory make-dir))
          (compile my/make-build-command))
      (call-interactively #'compile))))

(defun my/compile-maybe-make ()
  "Если найден Makefile вверх по дереву — запустить `my/make-run-command`, иначе обычный `compile`."
  (interactive)
  (require 'compile)
  (let ((make-dir (my/project-make-dir)))
    (if make-dir
        (let ((default-directory make-dir))
          (compile my/make-run-command))
      (call-interactively #'compile))))

;; ----------------------------
;; Автодополнение
;; ----------------------------

(use-package company
  :demand t
  :custom
  (company-idle-delay 0.01)
  (company-minimum-prefix-length 1)
  :config
  (setq company-backends '(company-capf))
  (global-company-mode 1))

(with-eval-after-load 'company
  (define-key company-active-map (kbd "TAB") #'company-complete-selection)
  (define-key company-active-map (kbd "<tab>") #'company-complete-selection)
  (define-key company-active-map (kbd "RET") #'company-complete-selection)
  (define-key company-active-map (kbd "<return>") #'company-complete-selection)

  (with-eval-after-load 'company
    ;; TAB/RET должны реально "принять" кандидата, иначе хуки могут не сработать
    (define-key company-active-map (kbd "TAB") #'company-complete-selection)
    (define-key company-active-map (kbd "<tab>") #'company-complete-selection)
    (define-key company-active-map (kbd "RET") #'company-complete-selection)
    (define-key company-active-map (kbd "<return>") #'company-complete-selection)

    (defun my/company--candidate-is-callable-p (candidate)
      "Определить, что CANDIDATE — функция/метод/конструктор по annotation."
      (let* ((ann (ignore-errors (company-call-backend 'annotation candidate)))
             (s   (downcase (or ann ""))))
	(or (string-match-p "method" s)
            (string-match-p "function" s)
            (string-match-p "constructor" s))))

    (defun my/company--maybe-insert-parens (candidate &rest _)
      "Если completion был function/method/ctor — добавить () и поставить курсор внутрь."
      (when (and (stringp candidate)
		 (my/company--candidate-is-callable-p candidate)
		 (not (nth 3 (syntax-ppss)))   ; строка
		 (not (nth 4 (syntax-ppss))))  ; комментарий
	(cond
	 ;; уже есть скобка после (например, пришло snippet'ом)
	 ((eq (char-after) ?\() nil)
	 ;; вставляем ()
	 (t (insert "()") (backward-char 1)))))

    ;; company вызывает этот хук после успешной вставки кандидата, передаёт candidate аргументом
    (add-hook 'company-completion-finished-hook #'my/company--maybe-insert-parens)))

(use-package company-quickhelp
  :after company
  :custom
  (company-quickhelp-delay 0.2)
  :config
  (company-quickhelp-mode 1))

(with-eval-after-load 'company
  ;; VS Codium-like: TAB/RET принимают выбранный кандидат
  (define-key company-active-map (kbd "TAB") #'company-complete-selection)
  (define-key company-active-map (kbd "<tab>") #'company-complete-selection)
  (define-key company-active-map (kbd "RET") #'company-complete-selection)
  (define-key company-active-map (kbd "<return>") #'company-complete-selection)

  ;; Автоскобки после completion для function/method/constructor (LSP/eglot)
  (defcustom my/company-parens-excluded-modes
    '(emacs-lisp-mode lisp-mode lisp-data-mode scheme-mode clojure-mode)
    "Режимы, где foo() после completion обычно не нужно."
    :type '(repeat symbol))

  (defun my/company--eglot-kind (cand)
    "Вернуть LSP CompletionItem.kind для кандидата, если есть."
    (let ((item (and (stringp cand) (get-text-property 0 'eglot--lsp-item cand))))
      (when (listp item) (plist-get item :kind))))

  (defun my/company--callable-candidate-p (cand)
    (let* ((kind1 (my/company--eglot-kind cand))
           (kind2 (ignore-errors (company-call-backend 'kind cand)))
           (ann   (ignore-errors (company-call-backend 'annotation cand)))
           (s     (downcase (or ann ""))))
      (or (memq kind1 '(2 3 4)) ; Method/Function/Constructor (LSP)
          (memq kind2 '(method function constructor))
          (string-match-p "method" s)
          (string-match-p "function" s)
          (string-match-p "constructor" s))))

  (defun my/company--maybe-insert-parens (cand &rest _)
    "После completion вставить (), если это функция/метод/конструктор."
    (when (and (stringp cand)
               (not (memq major-mode my/company-parens-excluded-modes))
               (my/company--callable-candidate-p cand)
               (not (nth 3 (syntax-ppss)))
               (not (nth 4 (syntax-ppss)))
               (not (eq (char-after) ?\())))
    (insert "()")
    (backward-char 1))

  (add-hook 'company-completion-finished-hook #'my/company--maybe-insert-parens))

(with-eval-after-load 'company
  ;; company-files не должен быть в :with у company-capf, иначе он не сможет
  ;; сам определить prefix и не будет дополнять пути
  (setq company-backends
        '((company-capf :with company-yasnippet)
          company-files))

  ;; Если раньше где-то добавляли принудительный приоритет backend-ов (например,
  ;; чтобы команды из PATH шли строго первыми) — убираем, иначе это ломает
  ;; "самое релевантное — сверху"
  (setq company-transformers
        (delq 'company-sort-by-backend-importance company-transformers)))


;; ----------------------------
;; Релевантная сортировка подсказок
;; ----------------------------

;; "Самое релевантное — первым": запоминает, что ты выбирал недавно/часто,
;; и поднимает это наверх. Статистика сохраняется между сессиями
(use-package prescient
  :after company
  :config
  (setq prescient-sort-full-matches-first t)
  (prescient-persist-mode 1))

(use-package company-prescient
  :after (company prescient)
  :config
  (company-prescient-mode 1))

;; ----------------------------
;; Подсказки команд/функций для shell-скриптов
;; ----------------------------

(use-package company-shell
  :after company
  :config

  (defun my/company-fish-setup ()
    (setq-local company-backends
                '((company-capf :with company-shell company-fish-shell company-shell-env company-yasnippet)
                  company-files)))

  (add-hook 'sh-mode-hook   #'my/company-sh-setup)
  (add-hook 'fish-mode-hook #'my/company-fish-setup))

(with-eval-after-load 'company
  ;; company-files не должен быть в :with у company-capf, иначе он не сможет
  ;; сам определить prefix и не будет дополнять пути
  (setq company-backends
        '((company-capf :with company-yasnippet)
          company-files)))

;; ----------------------------
;; Shell completion: сначала команды из $PATH, потом функции/переменные/LSP
;; ----------------------------

(use-package emmet-mode
  :hook ((html-mode html-ts-mode mhtml-mode web-mode css-mode css-ts-mode scss-mode) . emmet-mode)
  :config
  ;; если хочешь как в редакторах: Tab расширяет
  (define-key emmet-mode-keymap (kbd "TAB") #'emmet-expand-line)
  (define-key emmet-mode-keymap (kbd "<tab>") #'emmet-expand-line))

(use-package js2-mode
  :defer t
  :demand t)

(defun my/company--prefer-path-commands ()
  "Сделать `company-shell` приоритетнее остальных backend-ов."
  (unless (memq 'company-sort-by-backend-importance company-transformers)
    (setq-local company-transformers
                (cons 'company-sort-by-backend-importance company-transformers))))

(defun my/company-backends-sh ()
  "sh/bash: команды (PATH) -> всё остальное."
  (my/company--prefer-path-commands)
  (setq-local company-backends
              '((company-shell :with company-shell-env company-capf company-yasnippet)
                company-files)))

(defun my/company-backends-fish ()
  "fish: команды (PATH) -> всё остальное (env, fish-функции, LSP)."
  (my/company--prefer-path-commands)
  (setq-local company-backends
              '((company-shell :with company-shell-env company-fish-shell company-capf company-yasnippet)
                company-files)))

(add-hook 'sh-mode-hook      #'my/company-backends-sh)
(add-hook 'sh-ts-mode-hook   #'my/company-backends-sh)
(add-hook 'bash-ts-mode-hook #'my/company-backends-sh)

(add-hook 'fish-mode-hook    #'my/company-backends-fish)

;; ----------------------------
;; Сниппеты
;; ----------------------------

(use-package yasnippet
  :demand t
  :config
  ;; свои сниппеты
  (add-to-list 'yas-snippet-dirs (expand-file-name "snippets" user-emacs-directory))

  ;; везде
  (yas-global-mode 1)

  ;; не включать в минибуфере
  (add-hook 'minibuffer-setup-hook (lambda () (yas-minor-mode -1))))

(defun my/yas-add-snippets-from-package (library-name)
  "Добавляет <pkg>/snippets в yas-snippet-dirs, если такая папка существует"
  (let* ((lib (locate-library library-name))
         (pkgdir (and lib (file-name-directory lib)))
         (snipdir (and pkgdir (expand-file-name "snippets" pkgdir))))
    (when (and snipdir (file-directory-p snipdir))
      (add-to-list 'yas-snippet-dirs snipdir t))))

(use-package yasnippet-snippets
  :after yasnippet
  :demand t
  :config
  (my/yas-add-snippets-from-package "yasnippet-snippets"))

(use-package yasnippet-classic-snippets
  :after yasnippet
  :demand t
  :config
  (my/yas-add-snippets-from-package "yasnippet-classic-snippets"))

(with-eval-after-load 'yasnippet
  ;; AUCTeX: .tex -> LaTeX-mode, а сниппеты часто в latex-mode/tex-mode
  (add-hook 'LaTeX-mode-hook
            (lambda ()
              (yas-activate-extra-mode 'latex-mode)
              (yas-activate-extra-mode 'tex-mode)))
  (yas-reload-all))

;; ----------------------------
;; LSP + диагностика
;; ----------------------------

(use-package eglot
  :ensure nil
  :defer t
  :custom
  (eglot-autoshutdown t))

(with-eval-after-load 'eglot
  (add-to-list 'eglot-stay-out-of "company")

  ;; typescript-language-server: автоимпорты из package.json + вызов функции как snippet
  ;; completeFunctionCalls = как в VSCode: вставляет () и аргументы через snippet
  (setq-default eglot-workspace-configuration
                (append
                 (default-value 'eglot-workspace-configuration)
                 '(:completions (:completeFunctionCalls t)
				:typescript (:preferences
					     (:includeCompletionsForModuleExports t
										  :includeCompletionsForImportStatements t
										  :includePackageJsonAutoImports "on"
										  :allowIncompleteCompletions t
										  :includeCompletionsWithSnippetText t))
				:javascript (:preferences
					     (:includeCompletionsForModuleExports t
										  :includeCompletionsForImportStatements t
										  :includePackageJsonAutoImports "on"
										  :allowIncompleteCompletions t
										  :includeCompletionsWithSnippetText t)))))
  
  (defun my/eglot-ignore-no-information (orig server method &rest args)
    (condition-case err
        (apply orig server method args)
      (jsonrpc-error
       (let ((msg (alist-get 'jsonrpc-error-message (cdr err))))
         (if (and (stringp msg)
                  (string-match-p "No information available" msg)
                  (member method '("textDocument/hover" "completionItem/resolve"
                                   "textDocument/signatureHelp")))
             nil
           (signal (car err) (cdr err)))))))
  (advice-add 'eglot--request :around #'my/eglot-ignore-no-information))

(with-eval-after-load 'eglot
  (setq-default eglot-workspace-configuration
		(append
		 (default-value 'eglot-workspace-configuration)
		 '(:typescript (:preferences
				(:includeCompletionsForModuleExports t
								     :includeCompletionsForImportStatements t
								     :includePackageJsonAutoImports "on"
								     :allowIncompleteCompletions t))
			       :javascript (:preferences
					    (:includeCompletionsForModuleExports t
										 :includeCompletionsForImportStatements t
										 :includePackageJsonAutoImports "on"
										 :allowIncompleteCompletions t))))))

;; ----------------------------
;; VS Codium-like: () after LSP function completion
;; ----------------------------

(defcustom my/company-add-parens-after-func-completion t
  "Если t — после выбора completion от LSP для function/method/ctor вставлять ()."
  :type 'boolean)

(defcustom my/company-parens-excluded-modes
  '(emacs-lisp-mode lisp-mode lisp-data-mode scheme-mode clojure-mode)
  "Режимы, где foo() после completion обычно не нужно."
  :type '(repeat symbol))

(defun my/company--eglot-completion-kind (candidate)
  "Вернуть LSP kind (число) для CANDIDATE, если это completion от Eglot."
  (when (and (bound-and-true-p eglot-managed-mode)
             (stringp candidate)
             (boundp 'company-candidates))
    (let* ((cand (or (cl-find candidate company-candidates :test #'string=)
                     candidate))
           (item (get-text-property 0 'eglot--lsp-item cand)))
      (when (listp item)
        (plist-get item :kind)))))

(defun my/company--maybe-insert-parens (candidate)
  "После completion вставить (), если это function/method/ctor от LSP."
  (when (and my/company-add-parens-after-func-completion
             (not (memq major-mode my/company-parens-excluded-modes))
             (not (nth 3 (syntax-ppss)))   ; string
             (not (nth 4 (syntax-ppss)))) ; comment
    (let ((kind (my/company--eglot-completion-kind candidate)))
      ;; LSP CompletionItemKind: Method=2, Function=3, Constructor=4
      (when (memq kind '(2 3 4))
        (cond
         ((eq (char-after) ?\() nil)
         ((and (eq (char-before) ?\() (eq (char-after) ?\))) nil)
         ((and (eq (char-before) ?\))
               (>= (point) (+ (point-min) 2))
               (eq (char-before (1- (point))) ?\()))
         (backward-char 1))
        (t
         (insert "()")
         (backward-char 1))))))

(with-eval-after-load 'company
  (add-hook 'company-completion-finished-hook #'my/company--maybe-insert-parens))

(use-package flycheck
  :demand t
  :custom
  (flycheck-check-syntax-automatically '(save idle-change mode-enabled))
  (flycheck-idle-change-delay 0.5)
  (flycheck-display-errors-delay 0.15)
  :config
  (global-flycheck-mode 1))

(use-package flycheck-eglot
  :after (flycheck eglot)
  :config
  (global-flycheck-eglot-mode 1))

(use-package sideline
  :defer t
  :custom
  (sideline-backends-right '((sideline-flycheck . down)))
  (sideline-format-right "%s")
  (sideline-order-right 'down)
  (sideline-priority 100))

(use-package sideline-flycheck
  :after (sideline flycheck)
  :hook (flycheck-mode . sideline-mode))

(use-package flycheck-posframe
  :after flycheck
  :custom
  (flycheck-posframe-position 'window-bottom-left-corner)
  :config
  (flycheck-posframe-mode 1))

(use-package eldoc-box
  :hook (eglot-managed-mode . eldoc-box-hover-mode))

;; ----------------------------
;; Форматирование
;; ----------------------------

(use-package python-black
  :after python
  :hook (python-mode . python-black-on-save-mode-enable-dwim))

;; ----------------------------
;; Автоотступы
;; ----------------------------

(use-package aggressive-indent
  :hook (prog-mode . my/aggressive-indent-maybe))

(defun my/aggressive-indent-maybe ()
  "Включать aggressive-indent в prog-mode, кроме Makefile-режимов"
  (unless (derived-mode-p 'makefile-mode
                          'makefile-gmake-mode
                          'makefile-automake-mode
                          'makefile-bsdmake-mode
                          'makefile-imake-mode)
    (aggressive-indent-mode 1)))

(use-package reformatter)

(reformatter-define my/prettier
  :program "prettier"
  :args (list "--stdin-filepath"
              (or (buffer-file-name) (buffer-name))))

;; ----------------------------
;; Git: Magit
;; ----------------------------

(use-package transient
  :init
  (let ((dir (expand-file-name "transient/" "~/.cache/emacs/")))
    (make-directory dir t)
    (setq transient-history-file (expand-file-name "history.el" dir)
          transient-levels-file  (expand-file-name "levels.el"  dir)
          transient-values-file  (expand-file-name "values.el"  dir)))
  :custom
  ;; transient-меню (то, что Magit показывает снизу) держим снизу отдельным слотом,
  ;; чтобы не конфликтовало с твоим compilation (slot 0)
  (transient-display-buffer-action
   '(display-buffer-in-side-window
     (side . bottom)
     (slot . 1)
     (window-height . 0.33))))

(use-package magit
  :commands (magit-status magit-dispatch magit-file-dispatch)
  :init
  ;; чтобы Magit не пытался навязать свои глобальные бинды (типа C-x g)
  (setq magit-define-global-key-bindings nil)
  :custom
  ;; статус на весь фрейм, выход из Magit возвращает прежнюю раскладку окон
  (magit-display-buffer-function #'magit-display-buffer-fullframe-status-v1)
  (magit-save-repository-buffers 'dontask)
  (magit-diff-refine-hunk 'all)
  :config
  ;; номера строк в Magit не нужны
  (add-hook 'magit-mode-hook (lambda () (display-line-numbers-mode -1))))

(with-eval-after-load 'projectile
  ;; удобный вход в Magit из projectile-command-map
  ;; C-c p v (если ты пользуешься этим префиксом)
  (keymap-set projectile-command-map "v" #'magit-status))

(defcustom my/company-add-parens-after-lsp-functions t
  "Если t — после LSP completion для function/method/ctor вставлять ()."
  :type 'boolean)

(defcustom my/company-parens-excluded-modes
  '(sh-mode sh-ts-mode bash-ts-mode fish-mode makefile-mode
	    emacs-lisp-mode lisp-mode scheme-mode clojure-mode)
  "Режимы, где foo() после completion обычно не нужно."
  :type '(repeat symbol))

(defun my/company--eglot-lsp-kind (candidate)
  (let* ((cand (or (and (boundp 'company-candidates)
                        (cl-find candidate company-candidates :test #'string=))
                   candidate))
         (item (and (stringp cand) (get-text-property 0 'eglot--lsp-item cand))))
    (when (listp item)
      (plist-get item :kind))))

(defun my/company--maybe-add-parens (candidate)
  (when (and my/company-add-parens-after-lsp-functions
             (bound-and-true-p eglot-managed-mode)
             (not (memq major-mode my/company-parens-excluded-modes))
             (not (nth 3 (syntax-ppss)))   ; string
             (not (nth 4 (syntax-ppss)))) ; comment
    (let ((kind (my/company--eglot-lsp-kind candidate)))
      (when (memq kind '(2 3 4))          ; Method / Function / Constructor
        (unless (or (eq (char-after) ?\() ; уже есть (
                    (eq (char-before) ?\()) ; уже вставили foo(
          (insert "()")
          (backward-char 1))))))

(with-eval-after-load 'company
  (add-hook 'company-completion-finished-hook #'my/company--maybe-add-parens))

(use-package envrc
  :demand t
  :config
  (envrc-global-mode))

(provide 'dev)
;;; dev.el ends here
