# this is a shell monster that will fail with exit(125) if a command produces
# stderr output
FAILIF_STDERR=bash -c 'fail_if_stderr() (rc=$$({("$$@" 2>&1 >&3 3>&- 4>&-; echo "$$?" >&4) | grep '^' >&2 3>&- 4>&-; } 4>&1); err=$$?; [ "$$rc" -eq 0 ] || exit "$$rc"; [ "$$err" -ne 0 ] || exit 125 ) 3>&1; fail_if_stderr $$@' FAILIF_STDERR

# no execution when only command printed is wanted
ifneq (,$(filter n,$(MAKEFLAGS)))
FAILIF_STDERR=: FAILIF_STDERR
endif


try:
	${FAILIF_STDERR} bash -c 'exit 12'

all: mkdocs-site build/context.jsonld

build/context.jsonld: src/linkml/schemas/ontology.yaml
	mkdir -p build
	gen-jsonld-context \
		--prefixes \
		--model \
		--mergeimports \
		$< > $@

build/linkml-docs: \
	build/linkml-docs/datalad-dataset-components \
	build/linkml-docs/ontology
build/linkml-docs/%: src/linkml/schemas/%.yaml src/extra-docs/%-schema
	export OUTDIR=$$([ "$*" = "ontology" ] && echo $@ || echo build/linkml-docs/schemas/$*) && \
	gen-doc \
		--hierarchical-class-view \
		--include-top-level-diagram \
		--diagram-type er_diagram \
		--metadata \
		--format markdown \
		--example-directory src/examples/$* \
		-d $$OUTDIR \
		$< \
	&& (cp -r src/extra-docs/$*-schema/*.md $$OUTDIR || true)
	# try to inject any extra-docs (if any exist)

build/mkdocs-site: build/linkml-docs src/extra-docs/*.md
	# top-level content
	cp -r src/extra-docs/*.md $<
	mkdocs build

check: check-models check-validation

# add additional schemas to lint here
check-models: \
	check-model-datalad-dataset-components \
	check-model-ontology
check-model-%: src/linkml/schemas/%.yaml
	@echo [Check $<]
	@echo "Run linter"
	@linkml-lint \
		--config .linkmllint.yaml \
		--max-warnings 0 \
		$<
# generate various output formats, they all have the potential to
# reveal "hidden" issues
	@echo Generate a JSON-LD context
	@${FAILIF_STDERR} gen-jsonld-context \
		--prefixes \
		--model \
		--mergeimports \
		$< > /dev/null
	@echo Generate JSON schema
	@${FAILIF_STDERR} gen-json-schema $< > /dev/null
	@echo Generate OWL
	@${FAILIF_STDERR} gen-owl $< > /dev/null
	@echo Generate Python classes
	@${FAILIF_STDERR} gen-python $< | python

# within check-validation, conversion targets must come before the
# respective validation targets, because some tests rely on these
# converted formats
check-validation: \
	convert-examples-datalad-dataset-components \
	check-validation-datalad-dataset-components \
	convert-examples-ontology
check-validation-%:
	$(MAKE) check-valid-validation-$* check-invalid-validation-$*
check-valid-validation-%: tests/%-schema/validation src/linkml/schemas/%.yaml
	@for ex in $</*.valid.cfg.yaml; do \
		echo "Validate $$ex" ; \
		linkml-validate --config "$$ex" ; \
	done
check-invalid-validation-%: tests/%-schema/validation src/linkml/schemas/%.yaml
	@for ex in $</*.invalid.cfg.yaml; do \
		echo "(In)validate $$ex" ; \
		linkml-validate --config "$$ex" && UNEXPECTEDLY VALID || true; \
	done

convert-examples: \
	convert-examples-datalad-dataset-components \
	convert-examples-ontology
convert-examples-%: src/linkml/schemas/%.yaml src/examples/%
	# loop over all examples, skip the schema file itself
	for ex in $^/*.yaml; do \
		[ "$$ex" = "$<" ] && continue; \
		echo "Converting $$ex" ; \
		for outf in json rdf; do \
			linkml-convert \
				-s "$<" \
				--target-class-from-path \
				--infer \
				-t "$$outf" \
				"$$ex" \
				> $${ex%.yaml}.$${outf}.tmp && \
			mv $${ex%.yaml}.$${outf}.tmp $${ex%.yaml}.$${outf} ; \
		done \
	done
	@git --no-pager diff -- $^
	@if [ -n "$$(git diff -- $^)" ]; then \
		echo -n 'ERROR: Unexpected modification of example output. ' ; \
   		echo 'Inspect and commit changes shown above!' ; \
		exit 22 ; \
	fi


clean:
	rm -rf build
	rm -f *-stamp

.PHONY: clean check check-models check-examples convert-examples
