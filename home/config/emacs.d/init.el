;;; init.el --- entry point -*- lexical-binding: t; -*-

;; Папка с модулями конфигурации: ~/.emacs.d/lisp/*.el
(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

;; backup в отдельную директорию
(setq make-backup-files t
      backup-directory-alist '(("." . "~/.cache/emacs/backups/"))
      delete-old-versions t
      kept-new-versions 10
      kept-old-versions 2
      version-control t)

;; transient в отдельную директорию (как backup)
(let ((dir "~/.cache/emacs/transient/"))
  (make-directory dir t)
  (setq transient-history-file (expand-file-name "history.el" dir)
        transient-levels-file  (expand-file-name "levels.el"  dir)
        transient-values-file  (expand-file-name "values.el"  dir)))

(make-directory "~/.cache/emacs/backups/" t)

;; Базовая инициализация пакетов и use-package
(require 'core)

;; Custom (генерируется Emacs). Загружаем рано, чтобы не спрашивало про safe-themes
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file 'noerror 'nomessage))

;; Модули (разнесены по смыслу)
(require 'ui)
(require 'minibuffer)
(require 'dev)
(require 'langs)
(require 'system)
(require 'keys)

(provide 'init)
;;; init.el ends here
