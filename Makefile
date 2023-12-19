all: mkdocs-site build/context.jsonld

build/context.jsonld: src/linkml/ontology.yaml
	mkdir -p build
	gen-jsonld-context \
		--prefixes \
		--model \
		--mergeimports \
		$< > $@

build/linkml-docs: build/linkml-docs/ontology build/linkml-docs/data-access-schema
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
lint: \
	lint-data-access-schema \
	lint-ontology
lint-%: src/linkml/%.yaml
	linkml-lint \
		--config .linkmllint.yaml \
		--max-warnings 0 \
		$<

# add additional schemas to validate examples for here.
# each one needs to provide valid examples at
# src/examples/<schema-name>/* and invalid examples at
# src/counter-examples/<schema-name>/*.
#
# In particular the valid examples should follow the
# naming schema <class>-<example-name>.yaml to be
# usable as documentation examples for `gen-doc`
validate-examples: \
	validate-examples-data-access-schema
validate-examples-%:
	$(MAKE) validate-valid-examples-$* validate-invalid-examples-$*
validate-valid-examples-%: src/linkml/%.yaml src/examples/%
	linkml-validate -s $^/*
validate-invalid-examples-%: src/linkml/%.yaml src/counter-examples/%
	# loop over all counter-examples, skip the schema file itself
	echo "Verify EXPECTED validation failures"
	for ex in $^/*; do \
		[ "$$ex" = "$<" ] && continue; \
		linkml-validate -s $< $$ex && UNEXPECTEDLY VALID || true; \
	done

clean:
	rm -rf build
	rm -f *-stamp

.PHONY: clean lint validate-examples
