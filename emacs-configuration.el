;;; package --- Summary
;;; Commentary:
;;; Code:
(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")
			 ("org". "https://orgmode.org/elpa/")
))
(package-initialize)
;; Fetch the list of packages available
(unless package-archive-contents(package-refresh-contents))

;; Install use-package
(setq package-list '(use-package))
(dolist (package package-list)
(unless (package-installed-p package) (package-install package)))

;; Set colorscheme
(load-theme 'misterioso)

;; keybindings
(global-set-key (kbd "C-j") 'windmove-down)
(global-set-key (kbd "C-k") 'windmove-up)
(global-set-key (kbd "C-h") 'windmove-left)
(global-set-key (kbd "C-l") 'windmove-right)

(setq-default c-basic-offset 4)            ;; set 4 spaces indentation level (java, c, c++)
(show-paren-mode)                          ;; Highlight opening and closing delimeter
(electric-pair-mode)                       ;; Auto complete parens
(setq-default show-trailing-whitespace t)  ;; show trailing whitespace

(setq column-number-mode t)                ;; show column number at the bottom of the buffer
(setq line-number-mode t)                  ;; show line number at the bottom of the buffer
(global-display-line-numbers-mode)         ;; show line numbers at the beginning of the line

;; set braces and indentation style
(add-hook 'java-mode-hook (setq c-default-style "k&r"))
(add-hook 'c++-mode-hook (setq c-default-style "stroustrup"))

;; Maintain a list of recent files opened
(recentf-mode 1)
(setq recentf-max-saved-items 50)

;; Store all emacs specific files to ~/.cache
(setq user-cache-directory "~/.cache")
(setq backup-directory-alist `(("." . ,(expand-file-name "backups" user-cache-directory)))
      url-history-file (expand-file-name "url/history" user-cache-directory)
      auto-save-list-file-prefix (expand-file-name "auto-save-list/.saves-" user-cache-directory)
      projectile-known-projects-file (expand-file-name "projectile-bookmarks.eld" user-cache-directory))

(require 'use-package)
(use-package evil
  :ensure t
  :init
  (evil-mode 1)
)

(use-package treemacs-evil)

(require 'smooth-scrolling
  (smooth-scrolling-mode 1)
)

(use-package projectile
  :ensure t
  :init (projectile-mode +1)
  :config
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
)

;; Helm allows for easy completition of commands. Below, we will replace several of the built in functions
;; with helm versions and add keyboard shortcuts for couple of new useful commands.
(use-package helm
  :ensure t
  :init
  (helm-mode 1)
  (progn (setq helm-buffers-fuzzy-matching t))
  :bind
  (("M-x" . helm-M-x))
  (("C-x f" . helm-find-files))
  (("C-x b" . helm-buffers-list))
  (("C-x r" . helm-recentf))
  (("C-x g" . helm-grep-do-git-grep))
)

;; Helm descbinds helps to easily search for keyboard shortcuts for modes that are currently active
;; in the project.
(use-package helm-descbinds
  :ensure t
  :bind ("C-x h" . helm-decbinds)
)

;; Helm swoop allows to quickly search for text under cursor or new text within current file.
(use-package helm-swoop
  :ensure t
  :init
)
(global-set-key (kbd "C-c C-f") 'helm-swoop)

;; Fuzzy matching
(setq helm-swoop-use-fuzzy-match t)
(setq helm-multi-swoop-edit-save t)
(setq helm-swoop-split-with-multiple-windows t)
(setq helm-swoop-speed-or-color t)

(use-package which-key
  :ensure t
  :init
  (which-key-mode)
)

;;
;; Java specific stuff
;;
; Company: provides auto-completition
(use-package company :ensure t)

; Yasnippet: template system for emacs. It allows you to type abbreviation and complete the associated text
(use-package yasnippet :config (yas-global-mode))
(use-package yasnippet-snippets :ensure t)

;; FlyCheck: checks for errors in code at run-time.
(use-package flycheck
  :ensure t
  :init
  (global-flycheck-mode)
)

(use-package lsp-treemacs
  :after (lsp-mode treemacs-evil)
  :ensure t
  :commands lsp-treemacs-errors-list
  :bind (:map lsp-mode-map
         ("M-9" . lsp-treemacs-errors-list)))

(use-package lsp-ui
:ensure t
:after (lsp-mode)
:bind (:map lsp-ui-mode-map
         ([remap xref-find-definitions] . lsp-ui-peek-find-definitions)
         ([remap xref-find-references] . lsp-ui-peek-find-references))
:init (setq lsp-ui-doc-delay 1.5
      lsp-ui-doc-position 'bottom
	  lsp-ui-doc-max-width 100
))

(use-package helm-lsp
:ensure t
:after (lsp-mode)
:commands (helm-lsp-workspace-symbol)
:init (define-key lsp-mode-map [remap xref-find-apropos] #'helm-lsp-workspace-symbol))

(use-package lsp-mode
:ensure t
:hook (
   (lsp-mode . lsp-enable-which-key-integration)
   (java-mode . #'lsp-deferred)
)
:init (setq
    lsp-keymap-prefix "C-c l"              ; this is for which-key integration documentation, need to use lsp-mode-map
    lsp-enable-file-watchers nil
    read-process-output-max (* 1024 1024)  ; 1 mb
    lsp-completion-provider :capf
    lsp-idle-delay 0.500
)
:config
    (setq lsp-intelephense-multi-root nil) ; don't scan unnecessary projects
    (with-eval-after-load 'lsp-intelephense
    (setf (lsp--client-multi-root (gethash 'iph lsp-clients)) nil))
	(define-key lsp-mode-map (kbd "C-c l") lsp-command-map)
)

(use-package lsp-java
:ensure t
:config (add-hook 'java-mode-hook 'lsp))

(require 'lsp-java)
(add-hook 'java-mode-hook #'lsp)

(require 'lsp-java-boot)
(add-hook 'lsp-mode-hook #'lsp-lens-mode)
(add-hook 'java-mode-hook #'lsp-java-boot-lens-mode)

(provide 'emacs-configuration)
;;; emacs-configuration.el ends here
