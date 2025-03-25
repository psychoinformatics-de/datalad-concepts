# Dump-Things

---

version: unreleased

---


This is a knowledge base/graph dump specification, and a companion of the [Things](/s/things) schema and its derivatives and extensions.

It defines a data structure for dumping arbitrarily complex information, expressed in these data models, in a version-controllable fashion directly on a filesystem.

The data structure also allows for storing related information, such as the schema specifications themselves.


## Example

```text
/metadata             | arbitrarily named root directory
 /.dumpthings.yaml    | global configuration
 /myschema-v3-fmta    | data record collection, compliant with one particular schema
   /.dumpthings.yaml  | configuration for a data record collection
   /Person            | data model record collection (for one particular class)
     /<id>.<format>   | an individual data record
```


## Directory structure

Three types of directories are distinguish:

- root directory
- data record collection compliant with one particular schema
- data record collection for one particular data model

### Root directory

All files and directories described in this specification are contained in an arbitrarily named root directory.

The root directory **must** contain a `.dumpthings.yaml` configuration file.

### Data record collection (for one schema)

Data record collection directories are arbitrarily named.
Any number of record collection directories **can** coexist in a single dump.
The corresponding directories **must** be direct subdirectories of the dump's root directory.
Each collection directory **must** contain a `.dumpthings.yaml` configuration file, specifying (among other things) the schema this particular collection is compliant with.

### Data model record collection (for one data model/class)

Data model record collection directories **must** be named after the class that defines the respective model in the given schema.
Any number of data model directories **can** coexist in a record collection.
The corresponding directories **must** be direct subdirectories of the record collection's root directory.
Depending on the choice of record file identifier type, this directory **may** contain an arbitrary number of additional subdirectory levels.

In order to avoid issues with file system compatibility, it is recommended to use simple "PascalCase" class names in a schema.
There **may** be support for a class name to directory mapping in a future version of this specification.
But also for reasons of compatibility with code generators it is recommended to keep the class names aligned with established conventions across programming languages.

## Configuration file

All configuration files **must** be named `.dumpthings.yaml`.
The configuration file format is [YAML](https://yaml.org).
However, the content of configuration files are simple key/value mappings, keeping it feasible to read configuration files without dedicated YAML IO libraries.

Two different types of configuration files are distinguished, depending on their location in the directory structure:

- dump-global configuration
- record collection configuration

### Dump-global (top-level) configuration file

This file **must** declare the configuration `type` to be `collections`.
There **must** be the declaration of compliance with a major version of this specification.

Here is an example of a complete and valid configuration:

```yaml
type: collections
version: 1
```

### Record collection configuration file

This file **must** declare the configuration `type` to be `records`.
There **must** be the declaration of compliance with a major version of this specification.

The configuration **must** declare the `schema` all data records are compliant with.
A schema **must** be identified either by a URL, or be a local relative path.
A relative path **must** be given in POSIX conventions.
A relative path **must not** point outside the collection directory (i.e., **must not** contain `..` path elements.

The configuration **must** declare the file `format` of all record files.
The format label can be arbitrary (i.e., there is no official list), but it **must** match the file name extension of all record files.

The configuration **must** declare an mapping function that is used to compute file path and file name from a record's identifier (`pid`).
The mapping function label **must** match one of the methods listed under [ID mapping methods](#record-id-mapping-methods).

Here is an example of a complete and valid configuration:

```yaml
type: records
version: 1
schema: .schema.yaml
format: yaml
idfx: digest-md5
```

## Record ID mapping methods

A record ID mapping method is an algorithm that takes the identifier (`pid`) of a data record on a `Thing`, and produces a file name (with a potential path-prefix) for the record to be stored at (or where it can be read from).

Record IDs are processed in their literal form, with no implied preprocessing or resolution before they are passed to a transformation method.

The full record file name is created by appending `.<format>` to the returned file name, where `<format>` is the `format` value declared in the collection configuration file.

The following methods are recognized:

### digest-md5

Returns the hex digest of the MD5 hash of the record identifier.

### digest-md5-p3

Like `digest-md5`, but after the first three characters of the hex digest a POSIX directory separator (`/`) is inserted.
This method can help to limit the number of records per directory.

### digest-sha1

Like `digest-md5`, but using a SHA1 hash.

### digest-sha1-p3

Like `digest-md5-p3`, but using a SHA1 hash.

### after-last-colon

All characters prior to, and including, the last colon (`:`) are stripped.
The remainder of the identifier is returned as the file name.

A method that can be of utility for generating human-readable/recognizable file names.
When, for example, identifiers take the form of `orcid:...` or `doi:...`, the resulting filename represent [ORCID](https://orcid.org)s, or [DOI](https://doi.org)s.

This method does not safeguard against non-portable filenames, nor does it guarantee uniqueness of filenames (e.g. in case of identical remainders, but different, stripped prefixes).

## Notes on IO implementations

The `things` schema supports inlining other `Thing` records in a `Thing`'s `relations` slot.

Any "write" IO implementation for this dump format **should** extract such inlined records, and store them into dedicated files -- one for each individual record.
Previously inlined records would then be referenced by their `pid` only.
