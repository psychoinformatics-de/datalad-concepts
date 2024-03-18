# Metadata schema for describing (a version of) a dataset

## Why?

There are many existing ways to describe datasets.
This schema specification is no competition for them.
It builds on related efforts and specifically aims to address a few key aspects:

- **Be structurally simple** to aid both production and consumption of schema compliant data by humans and machines alike.
- **Be semantically open** with little required vocabulary, and the flexibility to accept already existing metadata without requiring a term mapping.
- **Enable programmatic access to distributed data resources** by supporting compartmentalized data distributions with the possibility of individually redundant hosting.

## How?

The schema is centered around the [DatasetVersionObject](../DatasetVersionObject) class.
This class is a schema-specific implementation of the [Dataset](/ontology/Dataset) concept, which is itself built on the foundational components of the [W3C Data Catalog Vocabulary](https://www.w3.org/TR/vocab-dcat-3/), and the [W3C PROV Ontology](The PROV Ontology).

Any data record compliant with this schema is an instance of the [DatasetVersionObject](../DatasetVersionObject) class.
It serves as a uniform container for representing any aspects related to a dataset.
These largely fall into the three main categories defined by PROV-O:

- [Agent](/ontology/Agent)
- [Activity](/ontology/Activity)
- [Entity](/ontology/Entity)


### Design principles

#### Conceptual distinction of a semantic concept and its structural representation

The schema employs a set of classes that define key metadata objects.
These are all derived from the [MetadataObject](../MetadataObject) class.
Importantly, the object classes primarily define the *structure* of a metadata object (referencing vs. inlining related objects; identification approach; object type declaration, etc.), and otherwise expose a single concept (class) defined in the [DataLad Concepts Ontology (DLCO)](/ontology).

Technically, this is implemented using linkml's `mixin` declaration.

This conceptual distinction is exercised to enable straightforward structural conversion of data records.
Using linklm, documents can be converted to RDF using one schema's definitions of these object classes.
Subsequently, the RDF documents can be (structurally) mapped automatically onto a different schema that implements the same object classes in a different way.


#### Conceptual distinction of a dataset and its distribution

This schema follows the common approach of distinguishing a conceptual dataset from a concrete data distribution representing a dataset in a specific form or format.


#### Data (structure) type identification

This schema aims to minimize the precision of `range` declarations for individual properties in order to maximize expressiveness and applicability to "unforeseen" use cases.
To avoid a negative impact of this flexibility (or vagueness) on the ability to perform in-depth record validation, the schema employs a type annotation pattern.

Some properties can capture a broad range of metadata objects.
One example is `was_attributed_to`, which is applicable to any `Agent` related to a dataset.
However, relevant agents can come in many variants (people, organizations, running software, etc.) that substantially differ in terms of key properties to be described.

The schema support this with a `meta_type` property that is used to indicate
which object class a particular record conforms to.
This is implemented as a [linkml type designator](https://linkml.io/linkml/schemas/type-designators.html#type-designators).

```yaml
was_attributed_to:
  - meta_type: dlco:ResearchContributorObject
    name: Jane Doe
    orcid: 0000-0002-6047-XXXX
  - meta_type: dlco:OrganizationObject
    name: Some university
```
 

#### Use of document-local identifiers for efficient implementation of the "qualified-relation pattern"

It is generally preferable to identify any and all things using globally unique, resolvable identifiers.
However, in the context of this schema such identifiers are not required.
This is the case, in order to be able to easily express aspects where identifiers are not (readily) available.
At the same time, a method to reference information within a document is essential for avoiding duplication, and ensuring clarity.

For example, an individual person may need to be associated with a variety of dataset aspects: an author of the dataset and a related publication, a member of an organization, a trigger agent for an associated activity, etc.

To support referencing the schema uses a `meta_code` property, which is implemented as a [linkml identifier](https://linkml.io/linkml/schemas/slots.html#identifiers).
This property takes a "code" that needs to be unique within a document, and can be used to refer to the respective object.
Technically, this is equivalent to a [relative IRI](https://www.rfc-editor.org/rfc/rfc3987#section-6.5releative) as used in JSON-LD (implicit `@base` prefix).

```yaml
was_attributed_to:
  - meta_type: dlco:Person
    meta_code: agt_jdoe
    name: Jane Doe
```

The (inlined) specification of Agents, Activities, and Entities are their identification with a `meta_code` property is done via the most basic relational properties of the [DatasetVersionObject](../DatasetVersionObject) class:

- [was_attributed_to](/ontology/was_attributed_to) for [Agents](/ontology/Agent)
- [was_generated_by](/ontology/was_generated_by) for [Activities](/ontology/Activity)
- [relation](/ontology/relation) for [Entities](/ontology/Entity)

These properties serve as flexible containers.
Types of individual items are declared via the `meta_type` property to enable detailed validation (see above).

The specific nature of the relationships with a dataset (or other items) is specified using a [qualified relation pattern](https://patterns.dataincubator.org/book/qualified-relation.html).

- [qualified_attribution](/ontology/qualified_attribution) for [Agents](/ontology/Agent)
- [qualified_relation](/ontology/qualified_relation) for [Entities](/ontology/Entity)

These properties enable the specification of particular roles via an open
"vocabulary" that accepts any (compact) URI.
The following example shows how a person can be identified as an author (`marcrel:aut`), and a data controller (`dpv:DataController`) of a dataset.
Both role attributions use external, established vocabularies ([MARC relator](https://id.loc.gov/vocabulary/relators.html) and the [Data Privacy Vocabulary](https://w3c.github.io/dpv/dpv)).
Other vocabularies can be used in the same way.

```yaml
was_attributed_to:
  - meta_type: dlco:Person
    meta_code: agt_jdoe
    name: Jane Doe
qualified_attribution:
  - agent: agt_jdoe
    had_role:
      - marcrel:aut
      - dpv:DataController
```

### Design concerns

#### Why do `identifier` values have to have a `meta_id`?

The schema does not require the use of globally unique identifiers to reference
metadata objects (see document on `meta_code` above). However, when an
identifier is given, this is required, because global (not document-local),
actionable identification is the key use case that `identifier` provides over
`meta_code`.

When given identifier is not in an immediately HTTP accessible form, many identifier
schemes can be encoded as dereferenceable HTTP IRIs (example: ORCID 0000-0002-1825-0097
can be expressed as http://orcid.org/0000-0002-1825-0097).

When this is not possible, the schema provides a custom `dlns` namespace prefix
to be used for ad-hoc URI construction, and a dedicated `IdentifierObject`

```yaml
identifier:
  dlns:people/carberry:
    notation: carberry_js
    schema_agency: Society of ambiguous names
```

See https://www.w3.org/TR/vocab-dcat-3/#dereferenceable-identifiers for more general
information.

#### Why does `dlco:Property` not support a value IRI specification?

If a custom property aims to establish a particular relationship to another
concept, as it would be identified by an IRI (URI or CURIE), this should be
documented with the common qualified-relation pattern.

For example, indicating that a dataset linked to a repeated measures study
design create a relation to the concept of a repeated measure design
(`obo:OBI_0500002`), and qualify the relation to be a study design
(`obo:OBI_0500000`).

```yaml
relation:
  - meta_type: dlco:Entity
    meta_code: rmd
    identifier: obo:OBI_0500002
qualified_relation:
  - entity: rmd
    had_role: obo:OBI_0500000
```
