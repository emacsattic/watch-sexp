;;; watch-sexp.el --- Continously watch s-expressions

;; Copyright (C) 2007  Stefan Kamphausen

;; Author:  Stefan Kamphausen <http://www.skamphausen.de>
;; Keywords: 

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; 

;;; Code:

(defvar watch-sexp-buffer-name "*watch-sexp*")

(defvar watch-sexp-sexp-list ())

(defvar watch-sexp-window-config-register 9)

(defvar watch-sexp-timer-delay 1.0)
(defvar watch-sexp-timer nil)

;; FIXME: needs a major mode
;; emacs-lisp-mode might be a good idea for easy syntax highlighting.
;; A nice to have would be a keymap to remove items, the cursor is on;
;; but: on every redraw the cursor goes to point-min in that buffer.
;; Hm.
(defun watch-sexp-start-display ()
  (interactive)
  (window-configuration-to-register watch-sexp-window-config-register)
  (pop-to-buffer (get-buffer-create watch-sexp-buffer-name)) 
  (setq major-mode 'emacs-lisp-mode)
  (font-lock-mode 1)
  (setq mode-name "Watch Sexp")
  (when (timerp watch-sexp-timer)
    (cancel-timer watch-sexp-timer))
  (setq watch-sexp-timer (run-with-timer
                         watch-sexp-timer-delay
                         watch-sexp-timer-delay
                         #'watch-sexp-timer-callback)))

(defun watch-sexp-stop-watching ()
  (interactive)
  (when (timerp watch-sexp-timer)
    (cancel-timer watch-sexp-timer))
  (setq watch-sexp-timer nil))

(defun watch-sexp-clear-list ()
  (interactive)
  (setq watch-sexp-sexp-list ()))

(defun watch-sexp-stop ()
  (interactive)
  (watch-sexp-stop-watching)
  (kill-buffer (get-buffer-create watch-sexp-buffer-name))
  (jump-to-register watch-sexp-window-config-register))



(defun watch-sexp-timer-callback ()
  (interactive)
  (save-excursion
    (set-buffer (get-buffer-create watch-sexp-buffer-name))
    (delete-region (point-min) (point-max))
    (insert ";;; Watch Sexp Buffer\n\n")
    (dolist (sexp watch-sexp-sexp-list)
      (insert (format "\n(\"%s\"\n  %s)\n" 
                      sexp
;;                      (make-string (1+ (length (prin1-to-string sexp))) ?-) 
                      (prin1-to-string (eval sexp)))))))

;; FIXME: remove-if eq symbold
(defun watch-sexp-pop ()
  (interactive)
  (setq watch-sexp-sexp-list (cdr watch-sexp-sexp-list)))

(defun watch-sexp-add-sexp (sexp)
  (add-to-list 'watch-sexp-sexp-list sexp))

;; FIXME: user interface: highlight current sexp, watch region, allow
;; for direct input
(defun watch-sexp-add ()
  (interactive)
  (let ((sexp (sexp-at-point)))
    (watch-sexp-add-sexp sexp)
    ))


(setq aaa '(1 "rrp"))

(provide 'watch-sexp)
;;; watch-sexp.el ends here
