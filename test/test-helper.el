(require 'f)

(defvar sln-test-path
  (f-dirname (f-this-file)))

(defvar sln-code-path
  (f-parent sln-test-path))

(require 'sln-mode (f-expand "sln-mode.el" sln-code-path))
