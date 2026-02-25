.ONESHELL:
.SUFFIXES:            # Delete the default suffixes
.SUFFIXES: .svg .png


IMAGENAME          = fanzine-builder
REPORT_SOURCE_FILE = fanzine.org
REPORT             = $(addsuffix .pdf,$(basename $(REPORT_SOURCE_FILE)))
REPORT_BOOKLET     = $(addsuffix .booklet.pdf,$(basename $(REPORT)))
OUTPUT_DIR         = $(PWD)/output
IMAGES             = $(OUTPUT_DIR)/assets/geometry-lost.png $(OUTPUT_DIR)/assets/geometric-man.png $(OUTPUT_DIR)/assets/geometry-failed.png
NR_SHAPES          = 5 # stupid hack: this is the number of files produced by src/gen_shapes.py

QR_CODES = assets/qrcode.png \
           assets/qrcode-geometry-hyperhouse.png \
           assets/qrcode-sthlm-geometry.png \
           assets/qrcode-geometric-metafors.png



all: $(REPORT) $(REPORT_BOOKLET)
	echo "INFO: BUILD COMPLETE" >&2



all-container: $(OUTPUT_DIR)
	podman build -t $(IMAGENAME) . \
	&& podman run --rm -i -v $(OUTPUT_DIR):/outputdir:Z $(IMAGENAME) bash -c "cp /app/output/fanzine.*pdf /outputdir/"



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



$(REPORT_BOOKLET): $(REPORT)
	pdfjam --paper a4paper --booklet true --landscape --outfile $(OUTPUT_DIR)/$@ $(OUTPUT_DIR)/$<



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



copy-files: $(OUTPUT_DIR) $(QR_CODES)
	rsync -va --protect-args './' '$</'



assets/qrcode.png:
	python3 src/gen_qrcode.py https://www.youtube.com/watch?v=UKfq2jX8Qe4 $@

assets/qrcode-geometry-hyperhouse.png:
	python3 src/gen_qrcode.py https://soundcloud.com/joakimv/geometry-hyperhouse $@

assets/qrcode-sthlm-geometry.png:
	python3 src/gen_qrcode.py https://soundcloud.com/joakimv/city-of-lost-geometry $@

assets/qrcode-geometric-metafors.png:
	python3 src/gen_qrcode.py https://soundcloud.com/joakimv/geometric-metaphors $@

qrcodes: $(QR_CODES)



$(OUTPUT_DIR):
	mkdir -p $@



.svg.png:
	inkscape $< -o $@
