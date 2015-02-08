#!/usr/bin/env bash
set -e
if [ -z "$EMACS" ] ; then
    EMACS="emacs"
fi
$EMACS -batch \
       $([[ $EMACS == "emacs23" ]] && echo -l dev/ert.el) \
       -l sln-mode.el \
       -l dev/sln-tests.el \
       -f ert-run-tests-batch-and-exit
if [[ $EMACS != "emacs23" ]]; then
    $EMACS -Q --batch \
	   --eval '(setq byte-compile-error-on-warn t)' \
	   -f batch-byte-compile sln-mode.el
fi
