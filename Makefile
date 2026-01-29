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
	build/linkml-docs/s/types/v1 \
	build/linkml-docs/s/common-mixin/unreleased \
	build/linkml-docs/s/relations-mixin/unreleased \
	build/linkml-docs/s/things/unreleased \
	build/linkml-docs/s/things/v1 \
	build/linkml-docs/s/things-properties/unreleased \
	build/linkml-docs/s/things-temporal/unreleased \
	build/linkml-docs/s/things-spatial/unreleased \
	build/linkml-docs/s/things-distributions/unreleased \
	build/linkml-docs/s/things-files/unreleased \
	build/linkml-docs/s/things-publications/unreleased \
	build/linkml-docs/s/flat/unreleased \
	build/linkml-docs/s/spatial-mixin/unreleased \
	build/linkml-docs/s/temporal-mixin/unreleased \
	build/linkml-docs/s/prov-mixin/unreleased \
	build/linkml-docs/s/flat-prov/unreleased \
	build/linkml-docs/s/publications-mixin/unreleased \
	build/linkml-docs/s/flat-publications/unreleased \
	build/linkml-docs/s/resources-mixin/unreleased \
	build/linkml-docs/s/flat-resources/unreleased \
	build/linkml-docs/s/social-mixin/unreleased \
	build/linkml-docs/s/flat-social/unreleased \
	build/linkml-docs/s/study-mixin/unreleased \
	build/linkml-docs/s/flat-study/unreleased \
	build/linkml-docs/s/identifiers/unreleased \
	build/linkml-docs/s/quantities-mixin/unreleased \
	build/linkml-docs/s/versions-mixin/unreleased \
	build/linkml-docs/s/files-mixin/unreleased \
	build/linkml-docs/s/flat-files/unreleased \
	build/linkml-docs/s/demo-empirical-data/unreleased \
	build/linkml-docs/s/demo-research-assets/unreleased \
	build/linkml-docs/s/demo-rse-group/unreleased
build/linkml-docs/s/%: src/%.yaml src/%/extra-docs
	$(MAKE) imports-remote
	# take the YAML schema verbatim
	mkdir -p $(dir $@)
	cp $< $@.yaml
	$(MAKE) imports-local
	gen-doc \
		--hierarchical-class-view \
		--metadata \
		--format markdown \
		--example-directory src/$*/examples/ \
		-d $@ \
		$< \
	&& (cp -r src/$*/extra-docs/*.md $@ || true)
	# try to inject any extra-docs (if any exist)
	schema="$<"; if [ "$${schema##*-mixin}" = "$<" ]; then \
		gen-owl \
			-f owl \
			--mergeimports \
			$< > $@.owl.ttl && \
		gen-jsonld-context \
			--mergeimports \
			$< > $@.context.jsonld && \
		gen-shacl \
			--include-annotations \
			--include-stripped-prefixes \
			--exclude-order \
			$< > $@.shacl.ttl ; \
		dump-things-create-merged-schema \
			$< > $@.static.yaml ; \
	fi

build/mkdocs-site: build/linkml-docs extra-docs/*.md
	# top-level content
	cp -r extra-docs/*.md $<
	mkdocs build

check: check-models check-validation

# add additional schemas to lint here
check-models: \
	checkmodel/types/unreleased \
	checkmodel/types/v1 \
	checkmodel/common-mixin/unreleased \
	checkmodel/relations-mixin/unreleased \
	checkmodel/things/unreleased \
	checkmodel/things/v1 \
	checkmodel/things-properties/unreleased \
	checkmodel/things-temporal/unreleased \
	checkmodel/things-spatial/unreleased \
	checkmodel/things-distributions/unreleased \
	checkmodel/things-files/unreleased \
	checkmodel/things-publications/unreleased \
	checkmodel/flat/unreleased \
	checkmodel/spatial-mixin/unreleased \
	checkmodel/temporal-mixin/unreleased \
	checkmodel/prov-mixin/unreleased \
	checkmodel/flat-prov/unreleased \
	checkmodel/publications-mixin/unreleased \
	checkmodel/flat-publications/unreleased \
	checkmodel/resources-mixin/unreleased \
	checkmodel/flat-resources/unreleased \
	checkmodel/social-mixin/unreleased \
	checkmodel/flat-social/unreleased \
	checkmodel/study-mixin/unreleased \
	checkmodel/flat-study/unreleased \
	checkmodel/identifiers/unreleased \
	checkmodel/quantities-mixin/unreleased \
	checkmodel/versions-mixin/unreleased \
	checkmodel/files-mixin/unreleased \
	checkmodel/flat-files/unreleased \
	checkmodel/demo-empirical-data/unreleased \
	checkmodel/demo-research-assets/unreleased \
	checkmodel/demo-rse-group/unreleased
checkmodel/%: src/%.yaml
	@echo [Check $<]
	@echo "Run linter"
	@linkml-lint \
		--config .linkmllint.yaml \
		--max-warnings 0 \
		--validate \
		$<
	schema="$<"; if [ "$${schema##*-mixin}" = "$<" ]; then $(MAKE) checkmodel-outputs/$*; else echo "Skipping mixin output tests"; fi

checkmodel-outputs/%: src/%.yaml
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
	@${FAILIF_STDERR} grep -q '^classes:' $< && ( gen-python $< | python ) || true

# within check-validation, conversion targets must come before the
# respective validation targets, because some tests rely on these
# converted formats
check-validation: \
	convertexamples/things/unreleased \
	convertexamples/things/v1 \
	checkvalidation/things/unreleased \
	checkvalidation/things/v1 \
	convertexamples/things-distributions/unreleased \
	checkvalidation/things-distributions/unreleased \
	convertexamples/things-files/unreleased \
	checkvalidation/things-files/unreleased \
	convertexamples/things-publications/unreleased \
	checkvalidation/things-publications/unreleased \
	convertexamples/flat/unreleased \
	checkvalidation/flat/unreleased \
	convertexamples/flat-prov/unreleased \
	checkvalidation/flat-prov/unreleased \
	convertexamples/flat-publications/unreleased \
	checkvalidation/flat-publications/unreleased \
	convertexamples/flat-resources/unreleased \
	checkvalidation/flat-resources/unreleased \
	convertexamples/flat-social/unreleased \
	checkvalidation/flat-social/unreleased \
	convertexamples/flat-study/unreleased \
	checkvalidation/flat-study/unreleased \
	convertexamples/identifiers/unreleased \
	checkvalidation/identifiers/unreleased \
	convertexamples/flat-files/unreleased \
	checkvalidation/flat-files/unreleased \
	convertexamples/demo-empirical-data/unreleased \
	checkvalidation/demo-empirical-data/unreleased \
	convertexamples/demo-research-assets/unreleased \
	checkvalidation/demo-research-assets/unreleased \
	convertexamples/demo-rse-group/unreleased \
	checkvalidation/demo-rse-group/unreleased
checkvalidation/%:
	$(MAKE) checkvalid/$* checkinvalid/$*
checkvalid/%: src/%/validation src/%.yaml
	@for ex in $(wildcard $</*.valid.cfg.yaml); do \
		echo "Validate $$ex" ; \
		linkml-validate --config "$$ex" || exit 5 ; \
	done
checkinvalid/%: src/%/validation src/%.yaml
	@for ex in $(wildcard $</*.invalid.cfg.yaml); do \
		echo "(In)validate $$ex" ; \
		linkml-validate --config "$$ex" && exit 5 || true; \
	done

convert-examples: \
	convertexamples/things/unreleased \
	convertexamples/things/v1 \
	convertexamples/things-distributions/unreleased \
	convertexamples/things-files/unreleased \
	convertexamples/things-publications/unreleased \
	convertexamples/flat/unreleased \
	convertexamples/flat-prov/unreleased \
	convertexamples/flat-publications/unreleased \
	convertexamples/flat-resources/unreleased \
	convertexamples/flat-social/unreleased \
	convertexamples/flat-study/unreleased \
	convertexamples/identifiers/unreleased \
	convertexamples/flat-files/unreleased \
	convertexamples/demo-empirical-data/unreleased \
	convertexamples/demo-research-assets/unreleased \
	convertexamples/demo-rse-group/unreleased
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
