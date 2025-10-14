# Usage considerations

The schema building blocks provided here can be use with a lot of flexibility.
Nevertheless, some usage patterns may result in more efficient workflows than
others.

This page illustrates a few aspects that may be worth evaluating when building
metadata systems.

## A proposal of a metadata system of focused, interoperable components

The system uses a layered approach to orchestrate different metadata providing
and consuming processes, such that they all contribute to and are informed by
an integrated and curated knowledge base.

Human and machine users interact directly with individual UIs and APIs that
are purpose-built for specific applications and capabilities. Each of them
uses their own data models. Each system allows for submission of additional
or edited records to a staging area where submissions can be subjected to
verification and curation, before they are accepted.

Metadata records from each system can be losslessly transformed to be compliant
with a generic use case agnostic data model. This generic data model
facilitates the integration of information across applications and workflows.
Transformed metadata records are, again, submitted for curation and integration
into a central knowledge base.

This central knowledge base can be queried to produce integrated reports.
Knowledge base records can also be exported to the data models of individual
metadata systems to inform particular applications.

```mermaid
flowchart LR
    USER1[User 1]
    USER2[User 2]
    USER3[User 3]
    MACH1[Machine 1]
    KG[Knowledge graph<br>*generic data model*]
    KGSUBMIT[Submission<br>*generic data model*]
    subgraph Metadata system 1
    SYS1[System 1 records<br>*custom data model 1*]
    SYS1SUBMIT[Submission<br>*custom data model 1*]
    SYS1-->|inform|SYS1SUBMIT
    SYS1SUBMIT-->|curation|SYS1
    end
    subgraph Metadata system 2
    SYS2[System 2 records <br>*custom data model 2*]
    SYS2SUBMIT[Submission<br>*custom data model 2*]
    SYS2-->|inform|SYS2SUBMIT
    SYS2SUBMIT-->|curation|SYS2
    end
    subgraph Integrated Knowledge
    KGSUBMIT-->|curation|KG
    end
    USER1-->|add/edit|SYS1SUBMIT
    SYS1-->|retrieve|USER1
    USER3 -->|add/edit|SYS2SUBMIT
    MACH1 -->|add|SYS2SUBMIT
    SYS2-->|retrieve|USER3
    USER2-->|add/edit|SYS1SUBMIT & SYS2SUBMIT

    SYS1 & SYS2 -->|transform|KGSUBMIT
    KG -->|filter/transform|SYS1 & SYS2

    SYS1 ~~~ SYS2
    SYS1 & SYS2 ~~~ KGSUBMIT
    USER1 ~~~ USER2 ~~~ USER3
```

## Curation workflows

Depending on the nature of the metadata and the respective audiences for producing
consuming metadata, curation workflow differ substantially. The following sections
collect some ideas and constraints to keep in mind when designing such workflows
in this context.

### Design schemas to reduce churn

Data models should be designed to prefer linkage to broader, more slowly evolving,
less context constrained entities. For example, the relationship between a
container-type entity and its parts could be implemented by a `part_of`
relationship, rather than a list of `parts` in the container. This enables
the addition of a new part via the creation of a single, additional record
-- as opposed to having to create the new record, and then also having to update
the part-list.

This design choice does not limit the on-demand construction of part-lists
for "runtime" representations of knowledge for query-focused applications.
But it reduces to load on data curation workflows, by reducing the number of
events that require knowledge merge operations, in favor of plain additions.

However, not in all cases the "part" is the most constraint entity. For example,
a file can be a member in more than one archive. In such cases, it can be more
efficient to use a "static" part record, and track parts in the respective
containers.

### PIDs also require curation

Persistent identifiers (PID) play a key role in this metadata concept. Data
models and vocabularies can change flexibly, but records still describe one and
the same `Thing` when the PID is identical.

Persistent identifiers allow referencing entities in contexts where not all
information about an entity is available. One can reference a `Person` without
having to reveal possibly sensitive information about that `Person` at the same
time. For example, a public `Person` record about an academic may only contain
a name and a work contact email (equivalent to the information available on
a corresponding author in a journal publication). At the same time, an internal
`Person` record would have additional information, like a private cell phone number.
The public record can be generated from the richer, internal record by stripping
information.

#### PIDs may require mapping

However, an identifier itself can also carry information. For example, an ORCID
identifier typically can be used to reveal the name of a person. Hence when an
ORCID is used as the PID for a metadata record, any place where the identifier
is mentioned, also reveals the name of the person.  If the identifier used for
an internal, protected record and a corresponding public record are the same,
cross-referencing may be enabled unintentionally.

In such cases, it can be necessary to maintain mapping tables for PIDs of the
same entity in different contexts.

Maintaining a separate PID mapping is also an instrument to aid (future)
anonymization of records. When the mapping is destroyed (and other conditions
are fulfilled too), a PID-based re-identification is potentially made impossible.

#### PIDs may require curation

When metadata records are submitted by non-experts these records already need to have
PIDs in order to enable submission of multiple, interlinked records. It is advisable
to use dedicated (actually only temporarily persistent) PIDs for this purpose.

The reason is that a submitter cannot necessarily be trusted to use the PID of an
existing record to make further statements. Instead, they may create a new record,
with the same information as an existing one, and consequently use a new PID to link
information to this entity. While a curation could keep both records, and declare them
"same as" of each other, this needlessly inflates the number of records, increases
the maintenance load, and complicates queries.

Instead, curation could merge the two records found to be on the same entity,
and retain only the already existing one, and therefore just one relevant PID.
Subsequently, all PID references of the duplicate record in the submission
could be replaced with this original PID.

Using a dedicated PID space for pre-curation PIDs, such as
`myconsortium:pending/<random-id>` can help the curation process by making them easier
to detect. Moreover, using random, auto-generated PIDs for new, pre-curation
records also eases the tasks for submitters. They do not have to learn and follow
possible rules for PID generations, such as using particular PID systems for certain
types of records (e.g., DOIs for publications, ORCID for researchers, ROR IDs for
organizations, RRIDs for resources, etc). This task could be left to professional
curators.

## DataLad datasets as a PID provider

PIDs play an essential role for the schemas provider here. Quoting
[Wikipedia](https://en.wikipedia.org/wiki/Persistent_identifier):

> An important aspect of persistent identifiers is that "persistence is purely
> a matter of service". That means that persistent identifiers are only
> persistent to the degree that someone commits to resolving them for users. No
> identifier can be inherently persistent, however many persistent identifiers
> are created within institutionally administered systems with the aim to
> maximise longevity.

In order to address this, PIDs often need to be minted upon request by a dedicated
service, which is then maintaining an index that supports this PID resolution.

DataLad offers a different approach. A DataLad dataset offers two types of PIDs
that are built into any dataset -- and are therefore readily available without
requiring a dedicated PID issuing service to be established (or maintained).

1. globally unique random identifiers, persistent by convention
2. content-defined unique identifiers, persistent by definition

Type (1) is used to identify datasets and dataset content locations. Every
DataLad dataset carries a
[UUID-4](https://en.wikipedia.org/wiki/Universally_unique_identifier#Version_4_(random))
identifier that is persistent across dataset versions. In addition, each
configured git-annex accessible location within the network of dataset clones
is also identified with a UUID.

Type (2) is used to identify dataset content (files), and dataset versions
(commits). In general, these identifiers are deterministically defined by the
dataset content the refer to (checksums).

Based on the unconditional availability of these identifiers, services can be
built and operated that make them actionable, and resolve to locations or
descriptions as desired. Importantly, given the decentralized approach of data
management taken by DataLad (git-annex and Git), this approach avoid issues
of PID ownership, or even the requirement of canonical locations for some
information. One example service that implements this is the [DataLad dataset
registry](https://registry.datalad.org) which indexes 15k+ unique datasets,
with 400M+ files of ~2PB total size.

### Using DataLad PIDs for non-DataLad entities

Not all entities relevant in the context of a DataLad dataset are immediately
covered by the two identifier types described above. An artist of some songs
in a music collection, or a subject in a study that yielded a respective dataset
are not represented explicitly in a DataLad dataset.

However, type (1) and type (2) PIDs can be used as a "root" of an ad-hoc
namespace that enables a dataset curator to "mint" globally unique PIDs as
necessary. Importantly, when combined with a deterministic convention for
generating sub-identifiers in this namespace, PIDs can be (re-)generated
deterministically in a future process, or by other agents.

*An example:* Let `datalad:09ca86c1-a8e4-11f0-a779-dc97ba1c2528` be the PID of a
particular DataLad dataset. It refers to a Dataset in the
[DCAT](https://www.w3.org/TR/vocab-dcat-3/#Class:Dataset) sense: "A collection
of data, published or curated by a single agent, and available for access or
download in one or more representations.".  It is a version-less, conceptual
entity. The `datalad` prefix can point to a respective resolver service.

By convention, `datalad:09ca86c1-a8e4-11f0-a779-dc97ba1c2528/ns/` can be
a dataset-local namespace root. Furthermore, also by convention,
`datalad:09ca86c1-a8e4-11f0-a779-dc97ba1c2528/ns/subjects/001` may be used
as a PID for a particular subject entity relevant in that dataset's context.

Likewise by convention, `datalad:09ca86c1-a8e4-11f0-a779-dc97ba1c2528/path/`
could be the root of another namespace for the dataset-internal organization by
means of directories and file names. The PID
`datalad:09ca86c1-a8e4-11f0-a779-dc97ba1c2528/path/sub-001/data.json` could be
used to annotate a particular (conceptual) location with structural metadata,
for example that `data.json` is associated with a "subject 001"
(`.../ns/subject/001`).

Such conventions may be adopted more broadly by a community. For example, for
dataset using the [BIDS standard](https://bids.neuroimaging.io), it may be
useful to claim a namespace for [its
entities](https://bids-specification.readthedocs.io/en/stable/appendices/entities.html),
and have `datalad:09ca86c1-a8e4-11f0-a779-dc97ba1c2528/bids/sub-001` be a
dataset-specific subject identifier, and
`datalad:09ca86c1-a8e4-11f0-a779-dc97ba1c2528/bids/space-unheardof` be the PID
of a dataset-specific image coordinate space.

Lastly, for scenarios where conceptual reorganizations or redefinitions are
possible, the PID generation scheme should including a version identifier
component, for example,
`datalad:09ca86c1-a8e4-11f0-a779-dc97ba1c2528/v2/path/`. Alternatively, a
convention could be to generate a new UUID root identifier, and declare the
previous one as a [previous
version](https://www.w3.org/TR/vocab-dcat-3/#Property:resource_previous_version).
