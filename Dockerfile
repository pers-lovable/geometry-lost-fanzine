FROM debian:11-slim AS fanzine-base-build

RUN apt-get -y update \
    && apt-get -y install emacs-nox texlive-latex-base texlive-latex-extra texlive-latex-recommended texlive-font-utils



FROM fanzine-base-build


ADD org2pdf.el /app/

CMD env TEXMFOUTPUT=/outputdir emacs --batch --load /app/org2pdf.el
