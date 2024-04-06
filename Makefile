.ONESHELL:
.SUFFIXES:            # Delete the default suffixes
.SUFFIXES: .svg .png


IMAGENAME          = fanzine-builder
REPORT_SOURCE_FILE = fanzine.org
REPORT             = $(addsuffix .pdf,$(basename $(REPORT_SOURCE_FILE)))
OUTPUT_DIR         = $(PWD)/output
IMAGES             = geometry-lost.png geometric-man.png geometry-failed.png
NR_SHAPES          = 5

# comment in to compile locally w/o podman
RUN_LOCAL          = 1



all: build $(REPORT)



build:
ifndef RUN_LOCAL
	podman build -t $(IMAGENAME) .
endif



INSTANTIATED_REPORT_SOURCE_FILE = $(REPORT_SOURCE_FILE).rand_shapes.org

$(REPORT): clean $(OUTPUT_DIR) shapes $(INSTANTIATED_REPORT_SOURCE_FILE) $(IMAGES)
ifdef RUN_LOCAL
	env REPORT_SOURCE_FILE=$(INSTANTIATED_REPORT_SOURCE_FILE) \
	    OUTPUT_DIR=$(OUTPUT_DIR) \
	    DATA_DIR=$(PWD) \
	    TEXMFOUTPUT=$(OUTPUT_DIR) \
	    emacs --eval '(setq org-confirm-babel-evaluate nil)' --batch --load src/org2pdf.el
else
	podman run --rm -i -e DATA_DIR=/data -e OUTPUT_DIR=/outputdir -e REPORT_SOURCE_FILE=$(INSTANTIATED_REPORT_SOURCE_FILE) \
		-v $(PWD):/data:Z -v $(OUTPUT_DIR):/outputdir:Z  $(IMAGENAME)
endif
	mv $(OUTPUT_DIR)/$(addsuffix .pdf,$(basename $(INSTANTIATED_REPORT_SOURCE_FILE))) $(OUTPUT_DIR)/$@



$(INSTANTIATED_REPORT_SOURCE_FILE): $(OUTPUT_DIR)/shapes.sh
	. $< \
	&& envsubst < $(REPORT_SOURCE_FILE) > $@



$(OUTPUT_DIR)/shapes.sh:
	bash src/gen_shape_permutations.sh $(shell expr $(NR_SHAPES) - 1) > $@



shapes:
	python src/gen_shapes.py $(OUTPUT_DIR)


clean:
	rm -rf $(OUTPUT_DIR)



$(OUTPUT_DIR):
	mkdir -p $@



.svg.png:
	inkscape $< -o $@
