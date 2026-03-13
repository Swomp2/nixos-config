;;; ui.el --- appearance, theme, dashboard, sidebar -*- lexical-binding: t; -*-

;; ----------------------------
;; Базовый внешний вид
;; ----------------------------

;; Основной шрифт интерфейса
(when (display-graphic-p)
  (add-to-list 'default-frame-alist '(font . "Fira Code-11")))

;; Настоящие OTF-лигатуры (как в VS Code): HarfBuzz + composition tables
(use-package ligature
  :ensure t
  :if (display-graphic-p)
  :config
  ;; Базовые буквенные лигатуры (по желанию)
  (ligature-set-ligatures 't '("www" "ff" "fi" "ffi" "ffl" "fl" "ft" "fj" "Th"))

  ;; Главное: regexp-лигатуры для “растягиваемых” последовательностей
  (ligature-set-ligatures
   '(prog-mode LaTeX-mode tex-mode)
   `(
     ("=" ,(rx (+ (or ">" "<" "|" "/" "~" ":" "!" "="))))
     ("-" ,(rx (+ (or ">" "<" "|" "~" "-"))))
     ("<" ,(rx (+ (or "+" "*" "$" "<" ">" ":" "~" "!" "-" "/" "|" "="))))
     (">" ,(rx (+ (or ">" "<" "|" "/" ":" "=" "-"))))
     ("|" ,(rx (+ (or ">" "<" "|" "/" ":" "!" "}" "]" "-" "="))))
     ("/" ,(rx (+ (or ">" "<" "|" "/" "\\" "*" ":" "!" "="))))
     ("\\" ,(rx (or "/" (+ "\\"))))
     ("+" ,(rx (or ">" (+ "+"))))
     (":" ,(rx (or ">" "<" "=" "//" ":=" (+ ":"))))
     (";" ,(rx (+ ";")))
     ("&" ,(rx (+ "&")))
     ("!" ,(rx (+ (or "=" "!" "." ":" "~"))))
     ("?" ,(rx (or ":" "=" "." (+ "?"))))
     ("." ,(rx (or "=" "-" "?" ".=" ".<" (+ "."))))
     ("*" ,(rx (or ">" "/" ")" (+ "*"))))
     ("#" ,(rx (or ":" "=" "!" "(" "?" "[" "{" "_(" "_" (+ "#"))))
     ("~" ,(rx (or ">" "=" "-" "@" "~>" (+ "~"))))
     ("_" ,(rx (+ (or "_" "|"))))
     ;; Пара фиксированных, которые полезны в тексте
     "/*" "*/" "///" "://" "__"
     ))

  (global-ligature-mode t))

;; Плавная прокрутка (Emacs 29+)
(when (fboundp 'pixel-scroll-precision-mode)
  (pixel-scroll-precision-mode 1))

;; Колёсико/тачпад: стабильная скорость (без ускорения)
(setq mouse-wheel-progressive-speed nil)
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1)))

(global-display-line-numbers-mode 1)
(setq display-line-numbers-type 'relative)

;; В спец-буферах номера строк мешают (Magit, commit, transient)
(defun my/disable-line-numbers ()
  (display-line-numbers-mode -1))

(with-eval-after-load 'magit
  (add-hook 'magit-mode-hook #'my/disable-line-numbers))

(with-eval-after-load 'git-commit
  (add-hook 'git-commit-mode-hook #'my/disable-line-numbers))

(with-eval-after-load 'transient
  (add-hook 'transient-mode-hook #'my/disable-line-numbers))

(when (fboundp 'tool-bar-mode)   (tool-bar-mode -1))
(when (fboundp 'menu-bar-mode)   (menu-bar-mode -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

(electric-pair-mode 1)
(electric-indent-mode 1)

(use-package page-break-lines
  :hook (after-init . global-page-break-lines-mode))

;; ----------------------------
;; Иконки
;; ----------------------------

(use-package nerd-icons
  :defer t
  ;; Если иконки не отображаются:
  ;; M-x nerd-icons-install-fonts
  :custom
  (nerd-icons-font-family "Symbols Nerd Font Mono"))

(use-package all-the-icons :defer t)

(use-package nerd-icons-dired
  :after nerd-icons
  :hook (dired-mode . nerd-icons-dired-mode))

;; ----------------------------
;; Тема
;; ----------------------------

(use-package gruvbox-theme
  :demand t
  :config
  (load-theme 'gruvbox-dark-soft t))

;; ----------------------------
;; Dashboard
;; ----------------------------

(use-package recentf
  :ensure nil
  :init (recentf-mode 1)
  :custom
  (recentf-max-menu-items 25)
  (recentf-max-saved-items 25))

(use-package dashboard
  :demand t
  :after nerd-icons
  :custom
  (dashboard-startup-banner 'logo)
  (dashboard-banner-logo-title "Неужели можно это использовать как рабочий стол?")
  (dashboard-center-content t)
  (dashboard-vertically-center-content t)
  (dashboard-items '((recents  . 10)
                     (projects . 5)))
  (dashboard-navigation-cycle t)
  (dashboard-item-shortcuts '((recents  . "r")
                              (projects . "p")))
  (dashboard-display-icons-p t)
  (dashboard-icon-type 'nerd-icons)
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-startupify-list
        '(dashboard-insert-banner
          dashboard-insert-newline
          dashboard-insert-banner-title
          dashboard-insert-newline
          dashboard-insert-items
          dashboard-insert-newline))
  (setq initial-buffer-choice (lambda () (get-buffer-create "*Dashboard*"))))

;; ----------------------------
;; Modeline
;; ----------------------------

(use-package doom-modeline
  :demand t
  :custom
  (doom-modeline-icon t)
  (doom-modeline-major-mode-icon t)
  (doom-modeline-major-mode-color-icon t)
  (doom-modeline-buffer-state-icon t)
  (doom-modeline-buffer-file-name t)
  (doom-modeline-buffer-file-name-style 'auto)
  (doom-modeline-buffer-file-state-icon t)
  (doom-modeline-env-version t)
  :config
  (doom-modeline-mode 1))

;; ----------------------------
;; Файловая "панель": dired-sidebar
;; ----------------------------

(use-package dired
  :ensure nil
  :custom
  (dired-listing-switches "-alh --group-directories-first"))

(with-eval-after-load 'dired
  (require 'dired-x)
  ;; dotfiles скрываются через dired-omit-mode
  (setq dired-omit-files (concat dired-omit-files "\\|^\\..+$")))

(use-package dired-sidebar
  :commands (dired-sidebar-toggle-sidebar
             dired-sidebar-jump-to-sidebar
             dired-sidebar-showing-sidebar-p)
  :custom
  (dired-sidebar-width 35)
  (dired-sidebar-follow-file t)
  (dired-sidebar-use-custom-font t)
  (dired-sidebar-theme 'nerd-icons)
  (dired-default-directory "~/Документы/"))

;; ----------------------------
;; Scrolling: держать курсор по центру, но у начала/конца файла не «выталкивать» экран
;; ----------------------------

(setq scroll-margin 999)                 ; реальный размер ограничит maximum-scroll-margin
(setq maximum-scroll-margin 0.5)         ; максимум 1/2 высоты окна => курсор около середины
(setq scroll-conservatively 101)         ; не центрировать рывком, а докручивать минимально

(setq scroll-preserve-screen-position t) ; PgUp/PgDn стараются держать ту же вертикаль курсора
(setq scroll-error-top-bottom t)         ; когда дальше скроллить нельзя — идти в начало/конец файла

;; ----------------------------
;; Просмотр получившегося PDF файла
;; ----------------------------

(use-package pdf-tools
  :ensure t
  :config
  (pdf-tools-install))

(with-eval-after-load 'pdf-view
  (add-hook 'pdf-view-mode-hook (lambda () (display-line-numbers-mode -1))))

(with-eval-after-load 'pdf-view
  ;; всегда показывать страницу целиком
  (setq-default pdf-view-display-size 'fit-page)
  (add-hook 'pdf-view-mode-hook
            (lambda ()
              (setq-local pdf-view-display-size 'fit-page)
              (pdf-view-fit-page-to-window))))

;; -----------------------------------------------------------------------------
;; PDF Tools: открывать PDF справа, а не снизу
;; -----------------------------------------------------------------------------

(with-eval-after-load 'pdf-view
  (setq auto-revert-verbose nil)
  (add-hook 'pdf-view-mode-hook #'auto-revert-mode)
  (add-to-list 'display-buffer-alist
               '((derived-mode . pdf-view-mode)
                 (display-buffer-in-direction)
                 (direction . right)
                 (window-width . 0.5)
                 (inhibit-same-window . t))))

;; -----------------------------------------------------------------------------
;; Compilation: показывать снизу небольшим окном
;; -----------------------------------------------------------------------------
(add-to-list 'display-buffer-alist
             '("\\*compilation\\*"
               (display-buffer-reuse-window display-buffer-in-side-window)
               (side . bottom)
               (slot . 0)
               (window-height . 0.25)))

(add-to-list 'display-buffer-alist
             '("\\*Run: Python\\*"
               (display-buffer-reuse-window display-buffer-in-side-window)
               (side . bottom)
               (slot . 0)
               (window-height . 0.25)))

(add-to-list 'display-buffer-alist
             '("\\*Run: Node\\*"
               (display-buffer-reuse-window display-buffer-in-side-window)
               (side . bottom)
               (slot . 0)
               (window-height . 0.25)))

(provide 'ui)
;;; ui.el ends here
