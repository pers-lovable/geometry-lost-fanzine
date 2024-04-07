FROM debian:11-slim AS fanzine-base-build

RUN apt-get -y update \
    && apt-get -y install emacs-nox \
    texlive-latex-base texlive-latex-extra texlive-latex-recommended \
    texlive-font-utils rsync make python3.10 python3-numpy \
    gettext-base inkscape make

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

RUN echo "CHECK0" ; ls -l && make



###############################################################################
FROM debian:11-slim

COPY --from=build /app/output/fanzine.pdf /app/output/fanzine.pdf
