
# "Low-tech" metadata schemas

For many use cases metadata concepts are complex. Producing and consuming
such metadata involves sophisticated tooling, which implies a considerable
technical threshold for adopting metadata-focused workflows.

The schemas provided here aim to lower this threshold with an approach to
expressing rich and semantically precise metadata in relatively simple data
structures -- data structures that can be reasonably read from files and
processed in scripts with loops and conditionals, rather than requiring databases
and specific query languages implemented in targeted libraries.

All schemas are implemented in [LinkML](https://linkml.io), connecting to a
rich ecosystem for data modeling, validation, and transformation. LinkML
[bridges](https://linkml.io/linkml/intro/overview.html#a-bridge-between-frameworks)
between the worlds of structured data in plain text files, relational
databases and knowledge graphs if and when needed, so metadata workflows can
stay as simple as possible.

## Foundational schema components

The sources for all schemas are on [GitHub](https://github.com/psychoinformatics-de/datalad-concepts).

### Latest releases

- [Things (v2)](s/things/v2/index.md): foundational schema to describe any "thing"
- [Things properties add-on (v1)](s/things-properties/v1/index.md)
- [Things data add-on (v1)](s/things-data/v1/index.md)
- [Things study add-on (v1)](s/things-study/v1/index.md)
- [Things resources add-on (v1)](s/things-resources/v1/index.md)
- [Things rules add-on (v1)](s/things-rules/v1/index.md)
- [Things distributions add-on (v1)](s/things-distributions/v1/index.md)
- [Things social add-on (v1)](s/things-social/v1/index.md)
- [Things files add-on (v1)](s/things-files/v1/index.md)
- [Things publications add-on (v1)](s/things-publications/v1/index.md)
- [Things provenance add-on (v1)](s/things-prov/v1/index.md)

### Previous versions

- [Things (v1)](s/things/v1/index.md)
- [Types (v1)](s/types/v1/index.md): this functionality has been merged into the
  `things` schema directly

## Application schema demonstrators

The following example documents how the provided schema components can be
combined in to complete schemes for particular purposes. This demonstrator
is **not** intended to be reusable as a building block for derived schemas.

- [Research information](s/demo-research-information/unreleased/index.md)

### Deprecated components

[Empirical data](s/demo-empirical-data/unreleased/index.md) was a demonstrator
of an early schema development. It has been completely superseded the any
demonstrator listed above.

#### Flexible Low-complexity Annotation Technique (FLAT) schema components

These schema componts have deprecated. Their functionality and design aspects
have been incorporated in the latest released of the `things` schema collection.

These FLAT schemas aimed for being maximally lean and orthogonal with respect to
other FLAT schema components.  This is achieved by reducing the included slots
to bare necessities, and by avoiding class inheritance from other (even closely
related) concepts.  As a result, the FLAT schemas are most suitable for
mix-and-match composition of schemas geared towards (meta)data submission
systems and form generation.  They minimizes the required cognitive complexity
for providing complete records in a particular context, by avoiding the forced
inclusion of meaningful, but undesired concepts and relationships.  This
simplification typically comes with the need to further subclass and extend
these base concepts for any given application context.  The provided
demonstrator schemas illustrator this concept.

- [FLAT base schema](s/flat/unreleased/index.md)
- [Social schema](s/flat-social/unreleased/index.md)
- [Provenance schema](s/flat-prov/unreleased/index.md)
- [Resources schema](s/flat-resources/unreleased/index.md)
- [Study schema](s/flat-study/unreleased/index.md)
- [Files schema](s/flat-files/unreleased/index.md)
- [Publications schema](s/flat-publications/unreleased/index.md)

The deprecated schemas above were built on the following, also deprecated,
schema components.

- [Identifiers schema](s/identifiers/unreleased/index.md)
- [Common properties mixin](s/common-mixin/unreleased/index.md)
- [Files mixin](s/files-mixin/unreleased/index.md)
- [Provenance mixin](s/prov-mixin/unreleased/index.md)
- [Publications mixin](s/publications-mixin/unreleased/index.md)
- [Quantities mixin](s/quantities-mixin/unreleased/index.md)
- [Relations mixin](s/relations-mixin/unreleased/index.md)
- [Resources mixin](s/resources-mixin/unreleased/index.md)
- [Social mixin](s/social-mixin/unreleased/index.md)
- [Spatial properties mixin](s/spatial-mixin/unreleased/index.md)
- [Study mixin](s/study-mixin/unreleased/index.md)
- [Temporal properties mixin](s/temporal-mixin/unreleased/index.md)
- [Versions mixin](s/versions-mixin/unreleased/index.md)

The following examples documented how the FLAT schema components can be
combined in to complete schemes for particular purposes.

- [Research assets](s/demo-research-assets/unreleased/index.md)
- [Research software engineering group](s/demo-rse-group/unreleased/index.md)


## Related tools and specifications

### Knowledge base/graph dump specification

This [specification ](/dump-things-storage) is a companion of the [Things](s/things) schema and its derivatives and extensions.
It defines a data structure for dumping arbitrarily complex information, expressed in these data models, in a version-controllable fashion directly on a file-system.

### Storage API implementation: dump-things-service

This Python software package provides an HTTP-based API to store and retrieve metadata records.
It supports authenticated access to multi-schema, multi-collection API endpoints with built-in validation.
The API is fully auto-generated based on a schema built from the schema components available on this site
Among the support storage back-ends is plain file-system storage compliant with the [dump-things specification ](/dump-things-storage).

Check out [dump-things-service on PyPI](https://pypi.org/project/dump-things-service)

### SHACL-based form generation and metadata editing

This is a [VueJS](https://vuejs.org)-based browser tool that enabled client-side retrieval, editing, and submitting of metadata records.
It auto-builds a customizable UI from [SHACL](https://www.w3.org/TR/shacl) and [OWL](https://www.w3.org/TR/owl-ref) specifications, such as those provided for the schemas available on this site. Records are consumed and submitted in [Terse RDF Triple Language (Turtle)](https://en.wikipedia.org/wiki/Turtle_(syntax) (supported by, for example, [dump-things-service](https://pypi.org/project/dump-things-service) API endpoint).

Check out [shacl-vue on GitHub](https://psychoinformatics-de.github.io/shacl-vue/docs)

## Acknowledgements

This work was funded, in part, by

- Deutsche Forschungsgemeinschaft (DFG, German Research Foundation) under grant TRR 379 ([546006540](https://gepris.dfg.de/gepris/projekt/546006540), Q02 project)
- Deutsche Forschungsgemeinschaft (DFG, German Research Foundation) under grant SFB 1451 ([431549029](https://gepris.dfg.de/gepris/projekt/431549029), INF project)
- [MKW-NRW: Ministerium für Kultur und Wissenschaft des Landes Nordrhein-Westfalen](https://www.mkw.nrw) under the Kooperationsplattformen 2022 program, grant number: KP22-106A
