# About the `things` schema

This schema aims to define a lean data structure that can express arbitrarily
detailed information in a relatively flat structure. It achieves this by
following a few basic principles:

- every "thing" is required to have *one* unique identifier
- linking instead of nesting
- schema class type designator
- qualified relationships

Each of these aspects is detailed in the following sections.

## Every `thing` must have an identifier

The `Thing` class, the main class of the schema, has an `pid` slot, which takes a URI or CURIE.
This slot is required, hence any instance of such a class must have a URI or CURIE identifier specified to be valid.
This is a strong requirement, and an essential pillar for the schema, which will become clear in the following sections.

### What if there is no identifier?

For many types of "things" identification systems have been developed (countries, institutions, publications, researchers, etc.).
However, not every conceivable "thing" comes with a (globally) unique identifier.
In such cases it can help to define an arbitrary, but dedicated namespace, and assign unique identifiers in that space.

A concrete example could be a research consortium and its contributors.
Typically, such a consortium has a website with a dedicated domain.
If the domain is `example.org`, and the name of a contributor is Elena Piscopia, a suitable identifier could be `https://example.org/contributors/elena-piscopia`.
If a webpage on that person would be available at this address, the identifier would even resolve to more (human-readable) information, but this is not required.

With this approach, identifiers for anything and everything can be generated.
However, this approach also requires to establish a process that guarantees that no two different "things" are assigned the same identifier.

### What if there is more than one identifier?

The one-identifier-and-one-identifier-only requirement only applies to the mechanics of the `things` schema and the `pid` slot of the `Thing` class in particular.
Beyond that, there is no constraint on the nature and number of identifiers associated with a `Thing`.
Such identifiers are attributes of a `Thing` and can be expressed as such.
The schema documentation contains [an example](/s/things/v1/Thing#example-thing-02-identifiers) showing how this can be done via the `has_attributes` slot of a `Thing`. For schema development, the [identifiers extension schema](/s/identifiers) is worth a look.
It provides a dedicated slot and class for representing identifiers.


## Linking, not nesting

In order to keep the structure of data records reasonably shallow, relationships between things are declared by referencing another thing's identifier, rather than by inlining a `Thing` record.
Making this possible is the reason for having a required `pid` slot in the `Thing` class.

There is only one exception to this rule: the `relations` slot. Here, other `Thing` records can be inlined. The purpose of this slot is to largely avoid the need for a top-level, array-like data structure that can hold any number of data records. Using the `relations` slot, it is possible to represent arbitrarily rich information in a monolithic data structure.

There is one other case of record-inlining in the `things` schema (besides few association helper classes): attributes.
Attributes are information that are not things (which would have an identifier), but nevertheless describe a `Thing`.
An example of such an attribute is the mass of a physical object.
A dedicated `AttributeSpecification` class defines how attributes are expressed.

## Type designator slot

The `relations` slot for inlining `Thing` records has a range of `Thing` (expects records of type `Thing`).
This implies a limitation on the validation of such records.
For example, a `Thing` may actually be a `InventoryItem`, using a data model defined in a derived schema.
Such an `InventoryItem` may define additional slots with their own constraints, and it should be possible to perform a targeted validation of such records.

For this purpose, `Thing` provides a `type` slot.
This slots takes an identifier of a schema class (including classes in derived schemas), which provide the effective data model for validation.

Moreover, a set of `mappings` slots can be used to map a(n implicit) type of a data record to external schemas and terminologies, without requiring any and all concepts to be represented by a dedicated schema class.

## Qualified relationships

[Qualified relation](https://patterns.dataincubator.org/book/qualified-relation.html) is an essential pattern used by the `things` schema, and also its derivatives and extensions.
Within the `things` schema it is used by the `characterized_by` slot (and to some degree also for `has_attributes`) for characterizing the relationship between things.
The relationship between two things is qualified via an inline `Statement` that assigns a predicate to the relationship between a subject-thing, and a related object-thing.
See the [example for a topic annotation](/s/things/v1/Thing#example-thing-03-topic) for a concrete demo.
