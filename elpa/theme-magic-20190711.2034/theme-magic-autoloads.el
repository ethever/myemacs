;;; theme-magic-autoloads.el --- automatically extracted autoloads
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "theme-magic" "theme-magic.el" (0 0 0 0))
;;; Generated autoloads from theme-magic.el

(autoload 'theme-magic-from-emacs "theme-magic" "\
Apply the current Emacs theme to the rest of Linux.

This method uses Pywal to set the theme. Ensure you have Pywal
installed and that its executable, `wal', is available.

See Pywal's documentation for more information:

  https://github.com/dylanaraps/pywal

Pywal is designed to be unobtrusive, so it only sets your theme
for the current session. You have to explicitly tell Pywal to
reload its theme on a fresh login, by calling \"wal -R\". To do
this automatically, place the line \"wal -R\" in your
\"~/.xprofile\" file (or whichever file starts programs on a
graphical login).

See `theme-magic--auto-extract-16-colors' to understand how this
method chooses colors for the Linux theme.

\(fn)" t nil)

(defvar theme-magic-export-theme-mode nil "\
Non-nil if Theme-Magic-Export-Theme mode is enabled.
See the `theme-magic-export-theme-mode' command
for a description of this minor mode.")

(custom-autoload 'theme-magic-export-theme-mode "theme-magic" nil)

(autoload 'theme-magic-export-theme-mode "theme-magic" "\
Automatically export the Emacs theme to all Linux terminals, using Pywal.

If this mode is active, the Linux theme will be updated
automatically when you change the Emacs theme.

Note that if an Emacs theme has already been set, it will not be
exported when this mode is activated. You must explicitly export
it, or change the theme again to trigger the auto-update.

Under the hood, this mode calls `theme-magic-from-emacs' when you
change the theme. See `theme-magic-from-emacs' for more
information.

\(fn &optional ARG)" t nil)

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "theme-magic" '("theme-magic-")))

;;;***

;;;### (autoloads nil nil ("theme-magic-pkg.el") (0 0 0 0))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; theme-magic-autoloads.el ends here
