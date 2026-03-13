;;; minibuffer.el --- ivy/swiper/smex -*- lexical-binding: t; -*-

;; Бинды не трогаем, пакеты подключаем без навязывания клавиш

(use-package ivy
  :demand t
  :custom
  (ivy-use-virtual-buffers t)
  (enable-recursive-minibuffers t)
  :config
  (ivy-mode 1))

(use-package swiper
  :after ivy
  :defer t)

(use-package smex
  :after ivy
  :defer t
  :config (smex-initialize))

(provide 'minibuffer)
;;; minibuffer.el ends here