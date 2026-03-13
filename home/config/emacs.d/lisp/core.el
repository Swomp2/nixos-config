;;; core.el --- package system & base defaults -*- lexical-binding: t; -*-

(setq load-prefer-newer t)

(require 'package)

;; Не позволяем Emacs самому включать package.el до нашего кода
(setq package-enable-at-startup nil)

;; Репозитории пакетов
(setq package-archives
      '(("gnu"    . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa"  . "https://melpa.org/packages/")))

      (package-initialize)

;; Первый запуск: подтянуть список пакетов
(unless package-archive-contents
  (package-refresh-contents))

;; use-package
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)

;; По умолчанию ставим пакеты автоматически, если их нет
(setq use-package-always-ensure t)

;; Меньше шума от нативной компиляции пакетов
(when (boundp 'native-comp-async-report-warnings-errors)
  (setq native-comp-async-report-warnings-errors 'silent))

;; Производительность (без фанатизма)
(setq gc-cons-threshold 100000000)

;; Автосохранения: не спамим сообщениями
(setq auto-save-no-message t)

;; ----------------------------
;; Парные скобки + оборачивание активного региона
;; ----------------------------

(electric-pair-mode 1)

;; удобно: удалять пару одной Backspace между ними
(setq electric-pair-delete-adjacent-pairs t)

;; главное: при активном регионе нажатие ( [ { " ' оборачивает регион
;; это штатное поведение electric-pair-mode

(provide 'core)
;;; core.el ends here
