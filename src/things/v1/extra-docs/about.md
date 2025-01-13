# About the `things` schema

This schema aims to define a lean data structure that can express arbitrarily
detailed information in a relatively flat structure. It achieves this by
following a few basic principle.

- every "thing" is required to have *one* unique identifier
- linking instead of nesting
- qualified relationships
- schema class type designator

Each of these aspects is detailed in the following sections.

## Every `thing` must have an identifier

The `Thing` class, the main class of the schema, has an `id` slot, which takes a URI or CURIE.
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
