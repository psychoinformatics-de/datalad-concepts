# Metadata schema for describing a distribution of a dataset

This schema is centered on the concept of a [Distribution](https://www.w3.org/TR/vocab-dcat-3/#Class:Distribution): a specific representation of a dataset, in the form of a (collection of) file(s), in a specific format.

Rather than modeling a `Distribution` as a property of a [Dataset](https://www.w3.org/TR/vocab-dcat-3/#Class:Dataset) (more abstract, format-flexible), this schema is focused on the inverse `is_distribution_of`, to link a concrete distribution to its dataset concept.

This choice of directionality makes this schema particularly suitable for systems with metadata capabilities that are limited to or focused on annotation of concrete files in a storage system.

## "Open world" attitude

### Relationships

The schema is built on three foundational classes (taken from PROV-O):

- `Agent`
- `Activity`
- `Entity`

Linking concrete instances of these classes via qualified relationships is the key pattern promoted by this schema.
For example, describing the relationship of a `Distribution` (entity) the `Resource` (entity) it is a distribution of is done by defining the `Resource` instance within the `relation` property declaration of the `Distribution`.
The relationship is then qualified by referencing the `Resource` instance (by its identifier) via the `Distribution`'s `is_distribution_of` property.

When there is no suitable, dedicated property available to characterize a relationship, the `qualified_relation` property can be used.
Here, the object (entity) is related to the subject (entity) via a declaration of the kind of influence the object had on the subject by means of particular roles.
Roles can be any kind of (external) identifier, thereby enabling arbitrary precision and fit to specialized use cases, without a need to inflate the number of properties in the schema.

Relationships between other combinations of the three foundational classes can also be specified.
For example influences of agents on an entity via `attributed_to` and `qualified_attribution`, using the same pattern.

TODO: how to declare relationships when no dedicated support for a particular type combination exists.

### Types

Properties that are used as containers to define related objects support the declaration of specific subtypes of the respective range-defining class.
For example, `attributed_to` accepts any `Agent`, but specialized classes maybe be more suitable in particular contexts.
Such a derived class can be indicated via the `schema_type` property.
If declared, it is then used for data structure definition and validation for this particular record.

Independent of this structure-focused type declaration, the `type` property can be used to detail the semantics of an object.
For example, a scientific journal can be sufficiently described using the basic `Entity` schema class, but 
it is still useful to declare its `type` to be, for example, `obo:NCIT_C93226` (peer-reviewed scientific journal).

### Custom properties

The schema provides a limited set of classes and properties that aim to capture a wide range of use cases in a generic fashion that balances schema complexity and applicability to particular scenarios.

Whenever more specialized properties are required and desired for detailing an `Agent`, `Activity`, or `Entity` the `has_property` property and the associated `Property` and `QuantitativeProperty` classes can be used.
For example, the `Publication` schema class does not offer detailed bibliographic properties focused on scientific journal publications, because it aims to capture any kind of publication equally well.

Arbitrary custom properties can be defined by declaring property `type`, associated `value`, and `range` (type of the value).
Here is an example that declare the number of pages (of a journal article):

```
property:
  - type: bibo:numPages
    name: Number of pages
    value: "17"
    type: xsd:nonNegativeInteger
```

The associated `Property` class is permissive.
Properties can be declared without any type definitions (and just a `name` or `description` instead).

This approach works best for property values with simple data types.
However, `value` can also be `xsd:anyURI` to reference arbitrary (externally defined) concepts.

## Identifiers

Identifiers play a key role in this schema. Any `Agent`, `Activity`, or `Entity` has to have an IRI.
This IRI makes it possible to refer to definitions across potentially detached metadata documents (for example attached to individual files in a storage system that has no metadata capabilities beyond annotation of individual files).

The schema makes no assumption about the nature of these identifiers, beyond them being IRIs.
For many use cases suitable identifiers and registries readily exist: DOI for publications, ROR for research organizations, ORCID for researchers, to name a few.
This can and should be used whenever possible.
However, sometimes no identifiers are available, and there are no resources for establishing a persistent identification schema properly.
For such cases, the schema provide three built-in prefixes that map to exemplary IRI prefixes.
These prefixes can be used to establish an implicit identification schema that is local to a particular scope.

- `exthisns`: A custom umbrella namespace relevant in the context of a dataset
- `exthisds`: A custom namespace that is unique to the particular dataset that is being described
- `exthisver`: A custom namespace that is unique to the particular version of the dataset that is being described

The `exthisns` namespace is the most important one.
It can be used to declare and refer to definitions of an `Agent`, `Activity`, or `Entity` using a "localized" identification concept for which no setup for dereferenceable IRIs exists (yet).
For example the identification of people in a consortium that spans multiple organizations, where a global identifier like ORCID cannot be required.

Likewise, `exthisds` and `exthisdsver` can be used as abstract (yet undetermined) namespace references in **store** metadata records.
This can be useful when a suitable schema for persistent datasets and/or dataset version identifier does not yet exist, at the time for creation of such records.

### Identifiers for data entities and contextual entities

This schema does not require, but enables a formal/visible distinction of identifiers for data entities (e.g., files) and contextual entities (e.g., people, licenses, grants), as done, for example in the [RO-crate specification](https://www.researchobject.org/ro-crate/specification.html).

For example, in order to identify a file in a distribution of a particular version of a dataset, the identifier `exthisdsver:./some/file.txt` can be used.
The `./` would indicate a data entity.
The `exthisdsver` declares the scope of this localized identifier to be that of this particular version of the dataset.

A custom license can be assigned an identifier `exthisdsver:#customlicense`.
The `#` would indicate a contextual entity.
Again, the `exthisdsver` declares the scope of this localized identifier to be that of this particular version of the dataset.
This makes it possible to declare custom license terms for a particular data distribution at hand, without having to be concerned with the analysis of term changes across versions that would require a new identifier.
