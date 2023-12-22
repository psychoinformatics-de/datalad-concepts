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

build/context.jsonld: src/linkml/ontology.yaml
	mkdir -p build
	gen-jsonld-context \
		--prefixes \
		--model \
		--mergeimports \
		$< > $@

build/linkml-docs: \
	build/linkml-docs/ontology \
	build/linkml-docs/data-access-schema \
	build/linkml-docs/git-provenance-schema
build/linkml-docs/%: src/linkml/%.yaml src/extra-docs/%
	gen-doc \
		--mergeimports \
		--hierarchical-class-view \
		--use-slot-uris \
		--include-top-level-diagram \
		--diagram-type er_diagram \
		--metadata \
		--format markdown \
		--example-directory src/examples/$$(basename $@) \
		-d $@ \
		$<
	# try to inject any extra-docs (if any exist)
	-cp -r src/extra-docs/$$(basename $@)/*.md $@

build/mkdocs-site: build/linkml-docs src/extra-docs/*.md
	# top-level content
	cp -r src/extra-docs/*.md $<
	mkdocs build

# add additional schemas to lint here
check: \
	check-data-access-schema \
	check-git-provenance-schema \
	check-ontology
check-%: src/linkml/%.yaml
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

# add additional schemas to validate examples for here.
# each one needs to provide valid examples at
# src/examples/<schema-name>/* and invalid examples at
# src/counter-examples/<schema-name>/*.
#
# In particular the valid examples should follow the
# naming schema <class>-<example-name>.yaml to be
# usable as documentation examples for `gen-doc`
validate-examples: \
	validate-examples-data-access-schema \
	validate-examples-git-provenance-schema
validate-examples-%:
	$(MAKE) validate-valid-examples-$* validate-invalid-examples-$*
validate-valid-examples-%: src/linkml/%.yaml src/examples/%
	linkml-validate -s $^/*
validate-invalid-examples-%: src/linkml/%.yaml src/counter-examples/%
	# loop over all counter-examples, skip the schema file itself
	echo "Verify EXPECTED validation failures"
	@for ex in $^/*; do \
		[ "$$ex" = "$<" ] && continue; \
		linkml-validate -s $< $$ex && UNEXPECTEDLY VALID || true; \
	done

clean:
	rm -rf build
	rm -f *-stamp

.PHONY: clean check validate-examples
