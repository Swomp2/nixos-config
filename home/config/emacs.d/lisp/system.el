;;; system.el --- OS integration (terminal, clipboard, etc.) -*- lexical-binding: t; -*-

(use-package terminal-here
  :commands (terminal-here-launch)
  :custom
  (terminal-here-linux-terminal-command 'konsole))

;; GUI Emacs сам работает с системным буфером обмена через window system
;; (на Wayland pgtk/gtk): kill/yank интегрируются с clipboard при select-enable-clipboard=t
(setq select-enable-clipboard t
      select-enable-primary nil)

(if (display-graphic-p)
    (setq interprogram-cut-function  #'gui-select-text
          interprogram-paste-function #'gui-selection-value)
  ;; В терминальном Emacs “системного” clipboard без внешних механизмов обычно нет
  (setq interprogram-cut-function nil
        interprogram-paste-function nil))

;; -----------------------------------------------------------------------------
;; Запоминать позицию курсора в файлах
;; -----------------------------------------------------------------------------

(use-package saveplace
  :ensure nil
  :init
  (save-place-mode 1)
  :custom
  (save-place-file (expand-file-name "saveplace" user-emacs-directory)))

(provide 'system)
;;; system.el ends here
