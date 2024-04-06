FROM debian:11-slim AS fanzine-base-build

RUN apt-get -y update \
    && apt-get -y install emacs-nox texlive-latex-base texlive-latex-extra texlive-latex-recommended texlive-font-utils rsync



FROM fanzine-base-build


COPY src/org2pdf.el /app/

WORKDIR /data

CMD env TEXMFOUTPUT=/outputdir emacs --batch --load /app/org2pdf.el
