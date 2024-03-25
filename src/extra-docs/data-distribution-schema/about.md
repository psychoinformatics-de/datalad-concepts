# Metadata schema for describing a distribution of a dataset

This schema is centered on the concept of a [Distribution](https://www.w3.org/TR/vocab-dcat-3/#Class:Distribution): a specific representation of a dataset, in the form of a (collection of) file(s), in a specific format.

Rather than modeling a `Distribution` as a property of a [Dataset](https://www.w3.org/TR/vocab-dcat-3/#Class:Dataset) (more abstract, format-flexible), this schema is focused on the inverse `is_distribution_of`, to link a concrete distribution to its dataset concept.

This choice of directionality makes this schema particularly suitable for systems with metadata capabilities that are limited to or focused on annotation of concrete files in a storage system.


## Identifiers

Identifiers play a key role in this schema. Any `Agent`, `Activity`, or `Entity` has to have an IRI.
This IRI makes it possible to refer to definitions across potentially detached metadata documents (for example attached to individual files in a storage system that has no metadata capabilities beyond annotation of individual files).

The schema makes no assumption about the nature of these identifiers, beyond them being IRIs.
For many use cases suitable identifiers and registries readily exist: DOI for publications, ROR for research organizations, ORCID for researchers, to name a few.
This can and should be used whenever possible.
However, sometimes no identifiers are available, and there are no resources for establishing a persistent identification schema properly.
For such cases, the schema provide three built-in prefixes that map to exemplary IRI prefixes.
These prefixes can be used to establish an implicit identification schema that is local to a particular scope.

- `thisns`: A custom umbrella namespace relevant in the context of a dataset
- `thisds`: A custom namespace that is unique to the particular dataset that is being described
- `thisver`: A custom namespace that is unique to the particular version of the dataset that is being described

The `thisns` namespace is the most important one.
It can be used to declare and refer to definitions of an `Agent`, `Activity`, or `Entity` using a "localized" identification concept for which no setup for dereferenceable IRIs exists (yet).
For example the identification of people in a consortium that spans multiple organizations, where a global identifier like ORCID cannot be required.

Likewise, `thisds` and `thisdsver` can be used as abstract (yet undetermined) namespace references in **store** metadata records.
This can be useful when a suitable schema for persistent datasets and/or dataset version identifier does not yet exist, at the time for creation of such records.

### Identifiers for data entities and contextual entities

This schema does not require, but enables a formal/visible distinction of identifiers for data entities (e.g., files) and contextual entities (e.g., people, licenses, grants), as done, for example in the [RO-crate specification](https://www.researchobject.org/ro-crate/specification.html).

For example, in order to identify a file in a distribution of a particular version of a dataset, the identifier `thisdsver:./some/file.txt` can be used.
The `./` would indicate a data entity.
The `thisdsver` declares the scope of this localized identifier to be that of this particular version of the dataset.

A custom license can be assigned an identifier `thisdsver:#customlicense`.
The `#` would indicate a contextual entity.
Again, the `thisdsver` declares the scope of this localized identifier to be that of this particular version of the dataset.
This makes it possible to declare custom license terms for a particular data distribution at hand, without having to be concerned with the analysis of term changes across versions that would require a new identifier.
