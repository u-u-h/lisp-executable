;; Copyright (c) 2011, Mark Cox
;; All rights reserved.

;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions are
;; met:

;; - Redistributions of source code must retain the above copyright
;;   notice, this list of conditions and the following disclaimer.

;; - Redistributions in binary form must reproduce the above copyright
;;   notice, this list of conditions and the following disclaimer in the
;;   documentation and/or other materials provided with the distribution.

;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
;; "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
;; LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
;; A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
;; HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
;; SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
;; LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
;; DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
;; THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
;; (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
;; OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

(in-package "LISP-EXECUTABLE.TESTS")

(define-program example-program (&options help)
  (cond
    (help
     (format *standard-output* "Help has arrived"))
    (t
     (format *standard-output* "You are doomed!")))
  (terpri))

(define-test create-executable
  (let ((filename (merge-pathnames (make-pathname :name (string-downcase (symbol-name (gensym "lisp-executable-create-executable-test-filename")))
						  :directory '(:relative "tests"))
				   (directory-namestring (asdf:component-pathname (asdf:find-system "lisp-executable-tests"))))))
    (assert-false (probe-file filename))
    (with-output-to-string (lisp-executable:*lisp-machine-output-stream*)
      (unwind-protect
	   (progn
	     (lisp-executable:create-executable 'example-program filename :asdf-system "lisp-executable-tests")
	     (unless (probe-file filename)
	       (pprint-logical-block (*standard-output* nil :prefix ";; ")
		 (write-string (get-output-stream-string lisp-executable:*lisp-machine-output-stream*))))
	     (assert-true (probe-file filename)))
	(map nil #'(lambda (filename)		     
		     (when (probe-file filename)
		       (delete-file filename)))
	     (lisp-executable:executable-files filename))
	(assert-false (probe-file filename))))))