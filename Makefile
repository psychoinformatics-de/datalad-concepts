all: mkdocs-site build/context.jsonld

build/context.jsonld: src/linkml/root.yaml
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
		src/linkml/root.yaml
	touch $@

extra-docs: extra-docs-stamp
extra-docs-stamp:
	mkdir -p build/linkml-docs
	cp -r src/extra-docs/* build/linkml-docs

mkdocs-site: mkdocs-site-stamp
mkdocs-site-stamp: linkml-docs extra-docs
	mkdocs build
	touch $@

lint: src/linkml/root.yaml
	linkml-lint \
		--config .linkmllint.yaml \
		--max-warnings 0 \
		$<

validate: validate-datalad-dataset
validate-datalad-dataset:
	linkml-validate --target-class DataladDataset -s src/linkml/datalad-datasets.yaml src/examples/datalad-dataset.yaml

clean:
	rm -rf build
	rm -f *-stamp

.PHONY: clean linkml-docs extra-docs  mkdocs-site lint validate
