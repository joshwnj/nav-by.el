;;; nav-by.el --- Easy navigation.

;; Copyright (C) 2015 Josh Johnston

;; Author: Josh Johnston <josh@x-team.com>
;; Keywords: navigation

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

(defvar nav-by/mode-map
  (let ((map (make-sparse-keymap)))
    ;; suppress all printing characters
    (suppress-keymap map)
    map))

(defun nav-by/define-keys (map)
  ;; exit nav mode
  (define-key map (kbd "C-n") 'nav-by/off)

  (define-key map (kbd "SPC l") (lambda () (interactive)(nav-by/set-type-2 "line")))
  (define-key map (kbd "/") 'nav-by/set-type)

  (define-key map (kbd ",") 'nav-by/prev)
  (define-key map (kbd ".") 'nav-by/next)
)

(defun nav-by/reload-keys ()
  (interactive)
  (nav-by/define-keys nav-by/mode-map))

;; reload keys once to start
(nav-by/reload-keys)

(defvar nav-by/reenable-after-minibuffer nil
  "Tell whether to reenable Nav mode after exiting minibuffer.")

;; ----

(defvar nav-by/amount 1
  "Amount to move by (only applies to line movement at the moment)")

(defvar nav-by/next-func 'next-line
  "Function to call for forward movement")

(defvar nav-by/prev-func 'previous-line
  "Function to call for backward movement")

;; wrappers around line movement functions, so we can set the amount
(defun nav-by/next-line ()
  (next-line nav-by/amount))

(defun nav-by/previous-line ()
  (previous-line nav-by/amount))

(defun nav-by/set-type (amount)
  (interactive "p")
  (setq nav-by/amount amount)
  (let ((type (ido-completing-read "Nav by: " (list "line" "paragraph" "error" "mark" "search"))))
    (nav-by/set-type-2 type)))

(defun nav-by/set-type-2 (type)
  (cond

    ((equal type "line")
      (progn
        (setq nav-by/next-func 'nav-by/next-line)
        (setq nav-by/prev-func 'nav-by/previous-line)))

    ((equal type "paragraph")
      (progn
        (setq nav-by/next-func 'forward-paragraph)
        (setq nav-by/prev-func 'backward-paragraph)))

    ((equal type "error")
      (progn
        (setq nav-by/next-func 'next-error)
        (setq nav-by/prev-func 'previous-error)))

    ((equal type "mark")
      (progn
        (setq nav-by/next-func 'forward-mark)
        (setq nav-by/prev-func 'backward-mark)))

    ((equal type "search")
      (progn
        (setq nav-by/next-func 'isearch-repeat-forward)
        (setq nav-by/prev-func 'isearch-repeat-backward)))

    (t (message "Unknown type: %s" type))))

(defun nav-by/move (func amount)
  (setq nav-by/amount
    (cond
      ;; 0: reset
      ((equal 0 amount) 1)
      ;; 1: no change
      ((equal 1 amount) nav-by/amount)
      ;; default: set value
      (t amount)))
  (funcall func))

(defun nav-by/next (amount)
  (interactive "p")
  (nav-by/move nav-by/next-func amount))

(defun nav-by/prev (amount)
  (interactive "p")
  (nav-by/move nav-by/prev-func amount))

;; when you do a search, automatically choose "nav by search"
(defun nav-by/on-isearch ()
  "Run when isearch mode starts"
  (interactive)
  (nav-by/set-type-2 "search"))

(add-hook 'isearch-mode-hook 'nav-by/on-isearch)

;; when you get a compilation buffer, automatically choose "nav by error" (for things like grep, lint, etc)
(defun nav-by/on-compilation-buffer ()
  "Run when we get a new compilation buffer"
  (interactive)
  (nav-by/set-type-2 "error"))

(add-hook 'compilation-filter-hook 'nav-by/on-compilation-buffer)

;; ----
;;;###autoload
(define-minor-mode nav-by/nav-mode
  "Toggle Nav mode."
  :keymap nav-by/mode-map
  :init-value nil
  :lighter " NAV")

(defun nav-by/on ()
  "Turn on Nav mode."
  (interactive)
  (nav-by/nav-mode 1))

(defun nav-by/off ()
  "Turn off Nav mode."
  (interactive)
  (nav-by/nav-mode -1)
  (setq nav-by/reenable-after-minibuffer nil))

(defun nav-by/temp-disable ()
  "Temporarily disable Nav mode while we're in the minibuffer"
  (if (eq nav-by/nav-mode t)
      (progn
        (nav-by/off)
        (setq nav-by/reenable-after-minibuffer t))))

(defun nav-by/reenable ()
  "Re-enable Nav mode if it was temporarily disabled."
  (if (eq nav-by/reenable-after-minibuffer t)
      (progn
        (nav-by/on))))

;; disable when we're in the minibuffer
(add-hook 'minibuffer-setup-hook 'nav-by/temp-disable)
(add-hook 'minibuffer-exit-hook 'nav-by/reenable)

(global-set-key (kbd "C-n") 'nav-by/on)

;; enter Nav mode when mark is activated
(add-hook 'activate-mark-hook 'nav-by/on)

(provide 'nav-by)

;;; nav-by.el ends here
