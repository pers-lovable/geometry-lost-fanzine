# AGENTS.md — Geometry Lost Fanzine

Quick orientation for AI agents and assistants working on this repo.

## What this project is

A small fanzine called **"Geometry Lost #2"**, produced entirely as a PDF using
Emacs org-mode, LaTeX, Python, and Docker. Two output PDFs are generated:

- `output/fanzine.pdf` — standard A4 document
- `output/fanzine.booklet.pdf` — A4 landscape booklet layout (for print-and-fold)

## Repository layout

```
fanzine.org                # Main document — orchestrates everything
articles/                  # One org file per article (included into fanzine.org)
  sthlm-geometry.org       # Short poem, page 1 (1 page)
  geometric-man.org        # Short story "Leo the quantum librarian", page 2
  geometric-metafors.org   # Three prose metaphors about geometry
  geometrical-dreams.org   # Article about an Amiga demo from 1991 (2 pages)
  boullee.org              # Essay on Étienne-Louis Boullée, page 10 (4 pages)
assets/                    # Images referenced by articles and the title page
  geometry-lost.{svg,png}  # Cover image shown on the title page
  geometric-man.{svg,png}  # Interlude art
  geometry-failed.{svg,png}# Interlude art
  geo.png                  # Screenshot used in geometrical-dreams article
  qrcode.png               # QR code used in geometrical-dreams article
  Boullée_*.jpg            # Three Boullée architecture images for boullee article
  Newton_memorial_boullee.jpg
  Etienne-Louis_Boullée,_*.jpg
src/
  gen_shapes.py            # Generates 5 geometric shape EPS files
  gen_shape_permutations.sh# Picks random shape combos for page corner decorations
  org2pdf.el               # Emacs Lisp that drives org-mode's LaTeX export
Makefile                   # Orchestrates the full build pipeline
Dockerfile                 # Multi-stage Docker build for reproducible builds
.github/workflows/build.yml# GitHub Actions CI — builds on push to main
.gitlab-ci.yml             # Original GitLab CI (superseded by GitHub Actions)
fanzine-todos.org          # Project todo list (mostly done, low relevance)
```

## Build pipeline

`make` runs these steps in order:

1. **clean** — deletes `output/`
2. **mkdir** — creates `output/`
3. **shapes** — `python3 src/gen_shapes.py output/` → writes 5 EPS files:
   - `output/shape_0.eps` — tetartoid
   - `output/shape_1.eps` — regular dodecahedron
   - `output/shape_2.eps` — pyritohedron
   - `output/shape_3.eps` — icosahedron
   - `output/shape_4.eps` — cube
4. **copy-files** — `rsync ./ output/` — copies all source into `output/`
   (necessary because org-mode resolves `#+INCLUDE` and image links relative
   to the working directory at export time)
5. **shapes.sh** — `gen_shape_permutations.sh 4 > output/shapes.sh` — produces
   a shell script that sets `SHAPE0`…`SHAPE99` env vars, each being a random
   triple like `{shape_2.eps}{shape_0.eps}{shape_4.eps}`
6. **instantiate** — `. output/shapes.sh && envsubst < fanzine.org > fanzine.org.rand_shapes.org`
   — substitutes `$SHAPE0`, `$SHAPE1`, etc. literals in `fanzine.org` with the
   actual EPS filenames
7. **emacs** — `emacs --batch --load src/org2pdf.el` (with CWD = `output/`) —
   exports the instantiated org file to PDF via LaTeX;
   saves the LaTeX log to `output/org-pdf-latex-output.txt`
8. **rename** — moves the generated PDF to `output/fanzine.pdf`
9. **booklet** — `pdfjam --booklet true --landscape` → `output/fanzine.booklet.pdf`

To build with Docker (no local deps needed):

```bash
make all-container   # uses podman; copies PDFs to output/
```

Or directly with Docker:

```bash
docker build -t fanzine-builder .
docker create --name x fanzine-builder
docker cp x:/app/output/fanzine.pdf .
docker rm x
```

## Page structure and numbering

The title page uses `\pagenumbering{gobble}` (no number shown). All other
page numbers are **hardcoded** with `\setcounter{page}{N}` because the
unnumbered interlude pages in the middle would otherwise break auto-counting.

| Section             | Printed page(s) | Notes                                      |
|---------------------|-----------------|--------------------------------------------|
| Title page          | —               | gobble; shows cover image via `\maketitlehookd` |
| sthlm-geometry      | 1               | poem, ~1 page                              |
| geometric-man       | 2               | short story, several pages                 |
| geometric-metafors  | continues       | no explicit `\setcounter`                  |
| geometrical-dreams  | continues       | contains an internal `\newpage`            |
| Interlude           | —               | gobble; geometric-man.png + geometry-failed.png side by side |
| boullee             | 10              | essay, 4 pages                             |

**When adding or removing unnumbered pages** (gobble interlude pages), all
subsequent `\setcounter{page}{N}` values must be decremented or incremented
accordingly. This has been a source of bugs before — be careful.

## Per-page visual decoration (the shapes system)

Every page has:
- A **white rounded-corner border rectangle** drawn by TikZ
- **Three geometric shapes** (2.5 cm each) in the NE, SE, and SW corners

This is implemented via `\SetBgImage{file1}{file2}{file3}` (defined in
`fanzine.org` using the `background` package + TikZ). The three file arguments
are EPS files generated by `gen_shapes.py`.

`fanzine.org` uses placeholder variables `$SHAPE0`, `$SHAPE1`, … which are
substituted at build time (step 6 above). Each build randomizes which shape
goes in which corner, giving every print run a unique look.

`\SetBgImage{}{}{}` with empty args suppresses the corner images but still
draws the border. This works but produces LaTeX warnings about missing files —
there's a TODO to fix this with conditionals.

`\AtEndDocument{\SetBgImage{}{}{}}` ensures the background is cleared cleanly
on the final page.

## LaTeX styling (fanzine.org preamble)

Key choices set via `#+LaTeX_HEADER:`:

| Setting | Value |
|---------|-------|
| Page background color | dark gray `rgb(0.35, 0.35, 0.35)` |
| Text color | white `rgb(1, 1, 1)` |
| Hyperlink colors | white (both `urlcolor` and `linkcolor`) |
| Section numbering | disabled (`\setcounter{secnumdepth}{0}`) |
| Subscripts/superscripts | disabled in org export |
| Title block | left-aligned, Large font, via `titling` package hooks |
| Cover image | injected after the date via `\maketitlehookd` |

## Image paths — a gotcha

Because the build always runs with CWD = `output/`, paths must be relative to
that directory:

- In `fanzine.org` (lives at `output/fanzine.org.rand_shapes.org`):
  use `assets/filename.png`
- In `articles/*.org` (live at `output/articles/`):
  use `../assets/filename.png`

The `fanzine.org` file references article-relative paths in `#+INCLUDE`
directives. These resolve correctly because the articles are also copied to
`output/articles/` by the rsync step.

## CI/CD

GitHub Actions (`.github/workflows/build.yml`) triggers on push to `main`:
1. Builds the Docker image
2. Extracts `fanzine.pdf` and `fanzine.booklet.pdf` from the image
3. Uploads them as workflow artifacts
4. Creates a GitHub Release tagged with the short commit SHA

The original GitLab CI (`.gitlab-ci.yml`) is still in the repo but no longer
the active pipeline.

## Local dependencies (without Docker)

If building locally (not via Docker), you need:
- `emacs-nox`
- `texlive-latex-base`, `texlive-latex-extra`, `texlive-extra-utils`,
  `texlive-latex-recommended`, `texlive-font-utils`
- `python3` with `numpy`
- `inkscape` (for SVG → PNG conversion via `make .svg.png` rule)
- `rsync`, `make`, `gettext-base` (for `envsubst`)
- `pdfjam` (part of `texlive-extra-utils`)
