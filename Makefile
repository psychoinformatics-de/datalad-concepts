all: mkdocs-site build/context.jsonld

build/context.jsonld: src/linkml/ontology.yaml
	mkdir -p build
	gen-jsonld-context \
		--prefixes \
		--model \
		--mergeimports \
		$< > $@

build/linkml-docs: build/linkml-docs/ontology
build/linkml-docs/%: src/linkml/%.yaml src/extra-docs/%
	gen-doc \
		--mergeimports \
		--hierarchical-class-view \
		--use-slot-uris \
		--include-top-level-diagram \
		--diagram-type er_diagram \
		--metadata \
		--format markdown \
		-d $@ \
		$<
	# try to inject any extra-docs (if any exist)
	-cp -r src/extra-docs/$$(basename $@)/*.md $@

build/mkdocs-site: build/linkml-docs src/extra-docs/*.md
	# top-level content
	cp -r src/extra-docs/*.md $<
	mkdocs build

lint: lint-ontology lint-dataset-graph-schema
lint-ontology: src/linkml/ontology.yaml
	linkml-lint \
		--config .linkmllint.yaml \
		--max-warnings 0 \
		$<
lint-dataset-graph-schema: src/linkml/datalad-dataset-graph.yaml
	linkml-lint \
		--config .linkmllint.yaml \
		--max-warnings 0 \
		$<

validate: validate-datalad-dataset
validate-datalad-dataset:
	linkml-validate -s src/linkml/datalad-dataset-graph.yaml src/examples/datalad-dataset.yaml

clean:
	rm -rf build
	rm -f *-stamp

.PHONY: clean lint validate
