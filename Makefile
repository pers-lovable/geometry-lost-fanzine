.ONESHELL:
.SUFFIXES:            # Delete the default suffixes
.SUFFIXES: .svg .png


IMAGENAME = fanzine-builder
OUTPUTDIR = $(PWD)/output
IMAGES    = geometry-lost.png geometric-man.png geometry-failed.png


all: build run

build:
	podman build -t $(IMAGENAME) .

run: clean $(OUTPUTDIR) $(IMAGES)
	podman run --rm -i -v $(PWD):/data:Z -v $(OUTPUTDIR):/outputdir:Z  $(IMAGENAME)

clean:
	rm -rf $(OUTPUTDIR)

$(OUTPUTDIR):
	mkdir -p $@

.svg.png:
	inkscape $< -o $@
