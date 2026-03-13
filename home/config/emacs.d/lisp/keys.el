;;; keys.el --- your global keybindings -*- lexical-binding: t; -*-

(defvar my/global-keys
  '(("C-x C-u" . dired-sidebar-toggle-sidebar)
    ("C-y"     . terminal-here-launch)
    ;;; Вставка/копирование/вырезание текста
    ("C-f"     . find-file)
    ("C-x C-c" . kill-ring-save)
    ("C-x C-v" . yank)
    ("C-x C-x" . kill-region)
    ;;; Управление окнами
    ("C-x C-s" . windmove-swap-states-right)
    ("C-x C-h" . windmove-swap-states-left)
    ("C-x C-t" . windmove-swap-states-up)
    ("C-x C-n" . windmove-swap-states-down)
    ("M-w"     . split-window-horizontally)
    ("M-v"     . split-window-vertically)
    ;;; Перемещение между окнами
    ("M-h"     . windmove-left)
    ("M-n"     . windmove-down)
    ("M-t"     . windmove-up)
    ("M-s"     . windmove-right)
    ("C-p"     . other-window)
    ;;; Перемещение по тексту
    ("C-h"     . backward-word)
    ("C-s"     . forward-word)
    ("C-n"     . next-line)
    ("C-t"     . previous-line)
    ("C-d"     . backward-char)
    ("C--"     . forward-char)
    ("C-g"     . goto-line)
    ("C-r"     . goto-char)
    ("C-'"     . isearch-forward)
    ("C-,"     . isearch-backward)
    ("C-u"     . scroll-up-command)
    ("C-e"     . scroll-down-command)
    ("C-o"     . move-end-of-line)
    ("C-a"     . move-beginning-of-line)
    ;;; Magit
    ("C-c g"   . magit-status)
    ("C-c M-g" . magit-dispatch)
    ;;; Всё остальное
    ("C-c c"   . my/compile-maybe-make)
    ("C-x C-w" . set-mark-command)
    ("C-b"     . undo)
    ("C-w"     . save-buffer)
    ("C-k"     . kill-buffer)
    ("C-l"     . list-buffers)
    ("C-;"     . comment-dwim)
    ("C-j"     . delete-other-windows)
    ("C-."     . switch-to-buffer)
    ;;; Для nix
    ("C-c n c" . my/nix-flake-check)
    ("C-c n b" . my/nix-flake-build)
    ("C-c n s" . my/nix-flake-show)))

;; ---------------------------------------
;; My keys: override ALL major/minor modes
;; ---------------------------------------

(defvar my/override-keys-map (make-sparse-keymap))

(define-minor-mode my/override-keys-mode
  "Global keymap that overrides major/minor modes."
  :global t
  :keymap my/override-keys-map)

;; emulation maps are searched BEFORE minor/major mode maps
(defvar my/override-keys--emulation-alist
  `((my/override-keys-mode . ,my/override-keys-map)))

(add-to-list 'emulation-mode-map-alists 'my/override-keys--emulation-alist)
(my/override-keys-mode 1)

(dolist (kb my/global-keys)
  (keymap-set my/override-keys-map (car kb) (cdr kb)))

(when (fboundp 'winner-mode)
  (winner-mode 1))

(defun my/dired-toggle-hidden ()
  "Переключить скрытие точечных файлов через dired-omit-mode."
  (interactive)
  (with-eval-after-load 'dired (require 'dired-x))
  (cond
   ((derived-mode-p 'dired-mode)
    (dired-omit-mode 'toggle)
    (revert-buffer nil t))
   ((and (fboundp 'dired-sidebar-showing-sidebar-p)
         (dired-sidebar-showing-sidebar-p))
    (dired-sidebar-jump-to-sidebar)
    (dired-omit-mode 'toggle)
    (revert-buffer nil t))
   (t
    (message "Открой dired/dired-sidebar, потом нажми C-c h"))))

(keymap-set my/override-keys-map "C-c h" #'my/dired-toggle-hidden)

(with-eval-after-load 'dired
  (define-key dired-mode-map (kbd "C-c h") #'my/dired-toggle-hidden))

(with-eval-after-load 'dired-sidebar
  (when (boundp 'dired-sidebar-mode-map)
    (define-key dired-sidebar-mode-map (kbd "C-c h") #'my/dired-toggle-hidden)))

(provide 'keys)
;;; keys.el ends here
