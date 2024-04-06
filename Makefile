.ONESHELL:
.SUFFIXES:            # Delete the default suffixes
.SUFFIXES: .svg .png


IMAGENAME          = fanzine-builder
REPORT_SOURCE_FILE = fanzine.org
REPORT             = $(addsuffix .pdf,$(basename $(REPORT_SOURCE_FILE)))
OUTPUT_DIR         = $(PWD)/output
IMAGES             = geometry-lost.png geometric-man.png geometry-failed.png

# comment in to compile locally w/o podman
#RUN_LOCAL          = 1



all: build $(REPORT)



build:
ifndef RUN_LOCAL
	podman build -t $(IMAGENAME) .
endif



$(REPORT): clean $(OUTPUT_DIR) $(IMAGES)
ifdef RUN_LOCAL
	env REPORT_SOURCE_FILE=$(REPORT_SOURCE_FILE) OUTPUT_DIR=$(OUTPUT_DIR) DATA_DIR=$(PWD) TEXMFOUTPUT=$(OUTPUT_DIR) emacs --batch --load org2pdf.el
else
	podman run --rm -i -e DATA_DIR=/data -e OUTPUT_DIR=/outputdir -e REPORT_SOURCE_FILE -v $(PWD):/data:Z -v $(OUTPUT_DIR):/outputdir:Z  $(IMAGENAME)
endif



clean:
	rm -rf $(OUTPUT_DIR)



$(OUTPUT_DIR):
	mkdir -p $@



.svg.png:
	inkscape $< -o $@
