# this is a shell monster that will fail with exit(125) if a command produces
# stderr output
FAILIF_STDERR=bash -c 'fail_if_stderr() (rc=$$({("$$@" 2>&1 >&3 3>&- 4>&-; echo "$$?" >&4) | grep '^' >&2 3>&- 4>&-; } 4>&1); err=$$?; [ "$$rc" -eq 0 ] || exit "$$rc"; [ "$$err" -ne 0 ] || exit 125 ) 3>&1; fail_if_stderr $$@' FAILIF_STDERR

# no execution when only command printed is wanted
ifneq (,$(filter n,$(MAKEFLAGS)))
FAILIF_STDERR=: FAILIF_STDERR
endif


try:
	${FAILIF_STDERR} bash -c 'exit 12'

all: build/mkdocs-site

build/linkml-docs: \
	build/linkml-docs/s/types/unreleased \
	build/linkml-docs/s/properties/unreleased \
	build/linkml-docs/s/things/unreleased \
	build/linkml-docs/s/things/v1 \
	build/linkml-docs/s/roles/unreleased \
	build/linkml-docs/s/spatial/unreleased \
	build/linkml-docs/s/temporal/unreleased \
	build/linkml-docs/s/prov/unreleased \
	build/linkml-docs/s/publications/unreleased \
	build/linkml-docs/s/resources/unreleased \
	build/linkml-docs/s/social/unreleased \
	build/linkml-docs/s/identifiers/unreleased \
	build/linkml-docs/s/edistributions/unreleased
build/linkml-docs/s/%: src/%.yaml src/%/extra-docs
	$(MAKE) imports-remote
	# take the YAML schema verbatim
	mkdir -p $(dir $@)
	cp $< $@.yaml
	$(MAKE) imports-local
	gen-doc \
		--hierarchical-class-view \
		--include-top-level-diagram \
		--diagram-type er_diagram \
		--metadata \
		--format markdown \
		--example-directory src/$*/examples/ \
		-d $@ \
		$< \
	&& (cp -r src/$*/extra-docs/*.md $@ || true)
	# try to inject any extra-docs (if any exist)
	# generate OWL
	gen-owl \
		-f owl \
		--mergeimports \
		$< > $@.owl.ttl
	# jsonld context
	gen-jsonld-context \
		--mergeimports \
		$< > $@.context.jsonld
	# SHACL with annotation needed to build UI specs
	# and excluding automatic addition of sh:order
	gen-shacl \
		--include-annotations \
		--exclude-order \
		$< > $@.shacl.ttl

build/mkdocs-site: build/linkml-docs extra-docs/*.md
	# top-level content
	cp -r extra-docs/*.md $<
	mkdocs build

check: check-models check-validation

# add additional schemas to lint here
check-models: \
	checkmodel/types/unreleased \
	checkmodel/properties/unreleased \
	checkmodel/things/unreleased \
	checkmodel/things/v1 \
	checkmodel/roles/unreleased \
	checkmodel/spatial/unreleased \
	checkmodel/temporal/unreleased \
	checkmodel/prov/unreleased \
	checkmodel/publications/unreleased \
	checkmodel/resources/unreleased \
	checkmodel/social/unreleased \
	checkmodel/identifiers/unreleased \
	checkmodel/edistributions/unreleased
checkmodel/%: src/%.yaml
	@echo [Check $<]
	@echo "Run linter"
	@linkml-lint \
		--config .linkmllint.yaml \
		--max-warnings 0 \
		--validate \
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
	convertexamples/things/unreleased \
	convertexamples/things/v1 \
	checkvalidation/things/unreleased \
	checkvalidation/things/v1 \
	convertexamples/roles/unreleased \
	checkvalidation/roles/unreleased \
	convertexamples/spatial/unreleased \
	checkvalidation/spatial/unreleased \
	convertexamples/temporal/unreleased \
	checkvalidation/temporal/unreleased \
	convertexamples/prov/unreleased \
	checkvalidation/prov/unreleased \
	convertexamples/publications/unreleased \
	checkvalidation/publications/unreleased \
	convertexamples/resources/unreleased \
	checkvalidation/resources/unreleased \
	convertexamples/social/unreleased \
	checkvalidation/social/unreleased \
	convertexamples/identifiers/unreleased \
	checkvalidation/identifiers/unreleased \
	convertexamples/edistributions/unreleased \
	checkvalidation/edistributions/unreleased
checkvalidation/%:
	$(MAKE) checkvalid/$* checkinvalid/$*
checkvalid/%: src/%/validation src/%.yaml
	@for ex in $</*.valid.cfg.yaml; do \
		echo "Validate $$ex" ; \
		linkml-validate --config "$$ex" || exit 5 ; \
	done
checkinvalid/%: src/%/validation src/%.yaml
	@for ex in $</*.invalid.cfg.yaml; do \
		echo "(In)validate $$ex" ; \
		linkml-validate --config "$$ex" && exit 5 || true; \
	done

convert-examples: \
	convertexamples/things/unreleased \
	convertexamples/things/v1 \
	convertexamples/roles/unreleased \
	convertexamples/spatial/unreleased \
	convertexamples/temporal/unreleased \
	convertexamples/prov/unreleased \
	convertexamples/publications/unreleased \
	convertexamples/resources/unreleased \
	convertexamples/social/unreleased \
	convertexamples/identifiers/unreleased \
	convertexamples/edistributions/unreleased
convertexamples/%: src/%.yaml src/%/examples
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
	@git --no-pager diff -- $(filter-out $<,$^)
	@if [ -n "$$(git diff -- $(filter-out $<,$^))" ]; then \
		echo -n 'ERROR: Unexpected modification of example output. ' ; \
   		echo 'Inspect and commit changes shown above!' ; \
		exit 22 ; \
	fi

imports-local:
	@echo "Switch to local imports"
	@sed -i -e 's,- dlschemas:\(.*/.*\)$$,- ../../src/\1,' src/*/*.yaml

imports-remote:
	@echo "Switch to remote imports"
	@sed -i -e 's,- \.\./\.\./src/\(.*/.*\)$$,- dlschemas:\1,' src/*/*.yaml

clean:
	rm -rf build
	rm -f *-stamp

.PHONY: clean check check-models check-validation convert-examples localrefs remoterefs
