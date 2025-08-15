
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

- [Things (v1)](s/things/v1/index.md): foundational schema to describe any "thing"

### Development

ALL CONTENT HERE IS UNRELEASED AND MAY CHANGE ANY TIME

- [Things schema](s/things/unreleased/index.md)
- [Types schema](s/types/unreleased/index.md)
- [Properties schema](s/properties/unreleased/index.md)
- [Identifiers schema](s/identifiers/unreleased/index.md)
- [Common properties mixin](s/common-mixin/unreleased/index.md)
- [Social mixin](s/social-mixin/unreleased/index.md)
- [Resources mixin](s/resources-mixin/unreleased/index.md)
- [Provenance mixin](s/prov-mixin/unreleased/index.md)

## Graph-oriented schema components

### Development

ALL CONTENT HERE IS UNRELEASED AND MAY CHANGE ANY TIME

- [Roles schema](s/roles/unreleased/index.md)
- [Spatial schema](s/spatial/unreleased/index.md)
- [Temporal schema](s/itemporal/unreleased/index.md)
- [Provenance schema](s/prov/unreleased/index.md)
- [Resources schema](s/resources/unreleased/index.md)
- [Publications schema](s/publications/unreleased/index.md)
- [Social schema](s/social/unreleased/index.md)
- [Electronic distributions schema](s/edistributions/unreleased/index.md)

## Flexbile Low-complexity Annotation Technique (FLAT) schema components

While these schemas typically provide the same concepts as their graph-oriented counterparts, they nevertheless differ substantially.
Where the graph-oriented schemas aim for maximum expressiveness, these FLAT schemas aim for being maximally lean and orthogonal with respect to other FLAT schema components.
This is achieved by reducing the included slots to bare necessities, and by avoiding class inheritance from other (even closely related) concepts.
As a result, the FLAT schemas are most suitable for mix-and-match composition of schemas geared towards (meta)data submission systems and form generation.
They minimizes the required cognitive complexity for providing complete records in a particular context, by avoiding the forced inclusion of meaningful, but undesired concepts and relationships.
This simplification typically comes with the need to further subclass and extend these base concepts for any given application context.

- [FLAT base schema](s/flat/unreleased/index.md)
- [Social schema](s/flat-social/unreleased/index.md)
- [Provenance schema](s/flat-prov/unreleased/index.md)

## Related tools and specifications

### Knowledge base/graph dump specification

This [specification ](/dump-things) is a companion of the [Things](s/things) schema and its derivatives and extensions.
It defines a data structure for dumping arbitrarily complex information, expressed in these data models, in a version-controllable fashion directly on a filesystem.
