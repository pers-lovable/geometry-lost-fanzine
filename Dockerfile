FROM debian:11-slim AS fanzine-base-build

RUN apt-get -y update \
    && apt-get -y install emacs-nox \
    texlive-latex-base texlive-latex-extra texlive-extra-utils \
    texlive-latex-recommended texlive-font-utils rsync make python3.10 \
    python3-numpy python3-pip gettext-base inkscape make \
    && pip3 install --no-cache-dir qrcode[pil]

COPY src /app/src
COPY assets /app/assets
COPY articles /app/articles
COPY fanzine.org /app/
COPY Makefile /app/

WORKDIR /app



###############################################################################
# The purpose of separating the installation above from the build
# process here is that Docker caching will speed up fail/retry work
# with the build.

FROM fanzine-base-build AS build

RUN make



###############################################################################
FROM debian:11-slim

COPY --from=build /app/output/fanzine.pdf /app/output/fanzine.pdf
COPY --from=build /app/output/fanzine.booklet.pdf /app/output/fanzine.booklet.pdf
COPY --from=build /app/output/org-pdf-latex-output.txt /app/output/org-pdf-latex-output.txt
