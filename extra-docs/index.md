
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

## Latest schema releases

- [Things (v1)](s/things/v1/index.md): foundational schema to describe any "thing"

## Schema development

ALL CONTENT HERE IS UNRELEASED AND MAY CHANGE ANY TIME

- [Things schema](s/things/unreleased/index.md)
- [Types schema](s/types/unreleased/index.md)
- [Properties schema](s/properties/unreleased/index.md)
- [Identifiers schema](s/identifiers/unreleased/index.md)
- [Roles schema](s/roles/unreleased/index.md)
- [Spatial schema](s/spatial/unreleased/index.md)
- [Temporal schema](s/itemporal/unreleased/index.md)
- [Provenance schema](s/prov/unreleased/index.md)
- [Resources schema](s/resources/unreleased/index.md)
- [Publications schema](s/publications/unreleased/index.md)
- [Social schema](s/social/unreleased/index.md)
- [Electronic distributions schema](s/edistributions/unreleased/index.md)


See sources on [GitHub](https://github.com/psychoinformatics-de/datalad-concepts)


# Knowledge base/graph dump specification

This [specification ](/dump-things) is a companion of the [Things](s/things) schema and its derivatives and extensions.
It defines a data structure for dumping arbitrarily complex information, expressed in these data models, in a version-controllable fashion directly on a filesystem.
