## Schema development

### Composition

The aim of this development is to provide a collection of "narrowly" scoped schemas with a minimal number of elements, and a clearly defined purpose.
Individual schemas should be reusable in a focused manner, rather than needlessly imposing the complexity of the entire collection on a given use-case.
Schemas may build on other schemas (imports) to maximize homogeneity of data models across all covered use cases, thereby facilitating accessibility and interoperability.

### Versioning

Schemas are versioned to maximize longevity of availability and utility for historic data.

Whenever a schema or a dependency of a schema undergoes a breaking change, the version of the schema is bumped.
All previous versions of a schema remain available, and an effort is made to maintain technical compatibility with the underlying software tooling.
However, continued (even non-breaking) schema improvements may be limited to current versions.

A breaking change is:

- the removal of a schema element (class, slot, ...)
- a change in the schema element URI
- a change that impacts the structure of schema-compliant data records

Due to the particular nature of [LinkML](https://linkml.io/linkml) the following changes are also breaking:

- addition of a top-level schema element (class, slot, type, etc.)
- moving a schema element from a downstream schema to an upstream schema

This is implied by any schema sharing a single, non-scoped namespace with any and all of its imported schemas (upstream schemas).

### Prefix management

Any schema must (re)define all structurally relevant prefixes.
This also includes the prefixes of any of its imported dependencies.
Structurally relevant are, at minimum, prefixes that are used in `uri` slot values, such as `class_uri` and `slot_uri`.
A schema must declare such structurally relevant prefixes under `emit_prefixes`.
This list generally contains the deduplicated set of "emitted" prefixes of all schema dependencies, and those of the respective top-level schema.

## Acknowledgements

This work was funded, in part, by

- Deutsche Forschungsgemeinschaft (DFG, German Research Foundation) under grant TRR 379 ([546006540](https://gepris.dfg.de/gepris/projekt/546006540), Q02 project)
- Deutsche Forschungsgemeinschaft (DFG, German Research Foundation) under grant SFB 1451 ([431549029](https://gepris.dfg.de/gepris/projekt/431549029), INF project)
- [MKW-NRW: Ministerium für Kultur und Wissenschaft des Landes Nordrhein-Westfalen](https://www.mkw.nrw) under the Kooperationsplattformen 2022 program, grant number: KP22-106A
