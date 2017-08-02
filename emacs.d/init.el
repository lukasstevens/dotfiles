(require 'package)
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (url (concat (if no-ssl "http" "https") "://melpa.org/packages/")))
  (add-to-list 'package-archives (cons "melpa" url) t))
(when (< emacs-major-version 24)
  (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))
(package-initialize)

(if (not (package-installed-p 'use-package))
    (progn
      (package-refresh-contents)
      (package-install 'use-package)))

(require 'use-package)

;; Custom
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(inhibit-startup-screen t)
 '(package-selected-packages
   (quote
    (base16-theme atom-one-dark-theme use-package nlinum evil))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; Evil Mode
(use-package evil
  :ensure t
  :config (evil-mode t))

;; Disable swap and autosave
(setq auto-save-default nil)
(setq make-backup-files nil)

;; Line numbers
(use-package nlinum
  :ensure t
  :config
  (global-nlinum-mode t)
  (nlinum-relative-setup-evil)
  (nlinum-relative-on))

;; Color theme
(use-package base16-theme
  :ensure t)
(setq base16-theme-256-color-source "terminal")
(load-theme 'base16-default-dark t)
(set-face-background 'mode-line "black")
(set-face-foreground 'linum "white")
(set-face-background 'linum "brightblack")

;(use-package atom-one-dark-theme
;  :ensure t)
;(load-theme 'atom-one-dark t)
