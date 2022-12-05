.ONESHELL:
IMAGENAME = fanzine-builder
OUTPUTDIR = output

all: build run

build:
	if ! podman image inspect $(IMAGENAME) >/dev/null 2>/dev/null; then
		podman build -t $(IMAGENAME) .
	fi

run: $(OUTPUTDIR)/
	rm -f $(OUTPUTDIR)/report.pdf
	podman run --rm -i -v $(PWD):/data -v $(OUTPUTDIR):/outputdir  $(IMAGENAME)

clean:
	if podman image inspect $(IMAGENAME) >/dev/null 2>/dev/null; then
		podman rmi $(IMAGENAME)
	fi

$(OUTPUTDIR)/:
	mkdir $@
