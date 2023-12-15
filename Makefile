all: mkdocs-site build/context.jsonld

build/context.jsonld: src/linkml/ontology.yaml
	mkdir -p build
	gen-jsonld-context \
		--prefixes \
		--model \
		--mergeimports \
		$< > $@

linkml-docs: linkml-docs-stamp
linkml-docs-stamp:
	gen-doc \
		--mergeimports \
		--hierarchical-class-view \
		--use-slot-uris \
		--include-top-level-diagram \
		--diagram-type er_diagram \
		--metadata \
		--format markdown \
		-d build/linkml-docs \
		src/linkml/ontology.yaml
	touch $@

extra-docs: extra-docs-stamp
extra-docs-stamp:
	mkdir -p build/linkml-docs
	cp -r src/extra-docs/* build/linkml-docs

mkdocs-site: mkdocs-site-stamp
mkdocs-site-stamp: linkml-docs extra-docs
	mkdocs build
	touch $@

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

.PHONY: clean linkml-docs extra-docs  mkdocs-site lint validate
