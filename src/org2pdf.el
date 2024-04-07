(defun make-pdf (data-dir output-dir report-source-file)
  (interactive)
  (customize-set-variable 'org-export-with-sub-superscripts nil)
  (customize-set-variable 'org-export-with-emphasize nil)
  ;; Why copy all source files to the output directory first?
  ;; At export time, the current working directory needs to be the output directory.
  ;; At export time, all org-links and includes need to be resolvable.
  ;; So unless we want to hard code directory names in org-modes links and includes
  ;; to point to the source directory, we can solve it by copying the source files
  ;; into the output directory.
  (shell-command (concat "rsync -va --protect-args " data-dir "/* " output-dir "/"))

  (let ((default-directory output-dir))
    (find-file report-source-file)
    (set-buffer report-source-file)
    (add-to-list 'org-latex-default-packages-alist "\\PassOptionsToPackage{hyphens}{url}")
    (customize-set-value 'org-latex-hyperref-template "\\hypersetup{\n pdfauthor={%a},\n pdftitle={%t},\n pdfkeywords={%k}, pdfsubject={%d},\n pdfcreator={%c},\n pdflang={%L},\n colorlinks=true,urlcolor=white,linkcolor=white}\n"))
    (org-latex-export-to-pdf))


(let*
    ((data-dir (or (getenv "DATA_DIR") "/data"))
     (output-dir (or (getenv "OUTPUT_DIR") "/outputdir"))
     (report-source-file (or (getenv "REPORT_SOURCE_FILE") "fanzine.org")))
  (make-pdf data-dir output-dir report-source-file)
  (switch-to-buffer "*Org PDF LaTeX Output*")
  (write-file (concat output-dir "/org-pdf-latex-output.txt" nil)))
