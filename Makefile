.ONESHELL:
.SUFFIXES:            # Delete the default suffixes
.SUFFIXES: .svg .png


IMAGENAME          = fanzine-builder
REPORT_SOURCE_FILE = fanzine.org
REPORT             = $(addsuffix .pdf,$(basename $(REPORT_SOURCE_FILE)))
OUTPUT_DIR         = $(PWD)/output
IMAGES             = $(OUTPUT_DIR)/assets/geometry-lost.png $(OUTPUT_DIR)/assets/geometric-man.png $(OUTPUT_DIR)/assets/geometry-failed.png
NR_SHAPES          = 5 # stupid hack: this is the number of files produced by src/gen_shapes.py



all: $(REPORT)
	echo "INFO: BUILD COMPLETE" >&2



all-container: $(OUTPUT_DIR)
	podman build -t $(IMAGENAME) . \
	&& podman run --rm -i -v $(OUTPUT_DIR):/outputdir:Z $(IMAGENAME) cp /app/output/fanzine.pdf /outputdir/



# GENERAL NOTE:
#
# Why copy all source files to the output directory first? It makes
# this Makefile messy.
#
# It comes down to the way org-export works.
#
# At export time, the current working directory needs to be the output directory.
# At export time, all org-links and includes need to be resolvable.
# So unless we want to hard code directory names in org-modes links and includes
# to point to the source directory, we can solve it by copying the source files
# into the output directory.



INSTANTIATED_REPORT_SOURCE_FILE = $(REPORT_SOURCE_FILE).rand_shapes.org



$(REPORT): clean $(OUTPUT_DIR) shapes copy-files $(OUTPUT_DIR)/$(INSTANTIATED_REPORT_SOURCE_FILE) $(IMAGES)
	cd $(OUTPUT_DIR) \
	&& env REPORT_SOURCE_FILE=$(INSTANTIATED_REPORT_SOURCE_FILE) \
	    OUTPUT_DIR=$(OUTPUT_DIR) \
	    DATA_DIR=$(OUTPUT_DIR) \
	    TEXMFOUTPUT=$(OUTPUT_DIR) \
	    emacs --eval '(setq org-confirm-babel-evaluate nil)' --batch --load src/org2pdf.el \
	&& mv $(OUTPUT_DIR)/$(addsuffix .pdf,$(basename $(INSTANTIATED_REPORT_SOURCE_FILE))) $(OUTPUT_DIR)/$@



$(OUTPUT_DIR)/$(INSTANTIATED_REPORT_SOURCE_FILE): $(OUTPUT_DIR)/shapes.sh
	. $< \
	&& envsubst < $(REPORT_SOURCE_FILE) > $@



$(OUTPUT_DIR)/shapes.sh:
	bash src/gen_shape_permutations.sh $(shell expr $(NR_SHAPES) - 1) > $@



shapes:
	python3 src/gen_shapes.py $(OUTPUT_DIR)



clean:
	rm -rf $(OUTPUT_DIR)



copy-files: $(OUTPUT_DIR)
	rsync -va --protect-args './' '$</'



$(OUTPUT_DIR):
	mkdir -p $@



.svg.png:
	inkscape $< -o $@
