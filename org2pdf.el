(defun make-pdf (data-dir output-dir report-source-file)
  (interactive)
  (customize-set-variable 'org-export-with-sub-superscripts nil)
  (customize-set-variable 'org-export-with-emphasize nil)
  (let ((default-directory data-dir))
    (find-file report-source-file)
    (set-buffer report-source-file)
    (add-to-list 'org-latex-default-packages-alist "\\PassOptionsToPackage{hyphens}{url}")
    (customize-set-value 'org-latex-hyperref-template "\\hypersetup{\n pdfauthor={%a},\n pdftitle={%t},\n pdfkeywords={%k}, pdfsubject={%d},\n pdfcreator={%c},\n pdflang={%L},\n colorlinks=true,urlcolor=blue,linkcolor=blue}\n"))
  (let ((default-directory output-dir))
    (org-latex-export-to-pdf)))


(let*
    ((data-dir (or (getenv "DATA_DIR") "/data"))
     (output-dir (or (getenv "OUTPUT_DIR") "/outputdir"))
     (report-source-file (or (getenv "REPORT_SOURCE_FILE") "fanzine.org")))

  ;;(ignore-errors (or (make-pdf) t))
  (make-pdf data-dir output-dir report-source-file)

  (switch-to-buffer "*Org PDF LaTeX Output*")
  ;;(write-file "output/org-pdf-latex-output.txt" nil)
  (write-file (concat output-dir "/org-pdf-latex-output.txt" nil)))
