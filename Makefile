.ONESHELL:
IMAGENAME = fanzine-builder
OUTPUTDIR = $(PWD)/output

all: build run

build:
	# if ! podman image inspect $(IMAGENAME) >/dev/null 2>/dev/null; then
	# 	podman build -t $(IMAGENAME) .
	# fi
	podman build -t $(IMAGENAME) .

run: $(OUTPUTDIR)/ images
	rm -f $(OUTPUTDIR)/fanzine.pdf
	podman run --rm -i -v $(PWD):/data:Z -v $(OUTPUTDIR):/outputdir:Z  $(IMAGENAME)

clean:
	if podman image inspect $(IMAGENAME) >/dev/null 2>/dev/null; then
		podman rmi $(IMAGENAME)
	fi

$(OUTPUTDIR)/:
	mkdir $@

images:
	inkscape geometry-lost.svg -o geometry-lost.png
	inkscape geometric-man.svg -o geometric-man.png
	inkscape geometry-failed.svg -o geometry-failed.png
