# Dump-Things

This knowledge base/graph dump specification, and a companion of the [Things](/s/things) schema and its derivatives and extensions.
It defines a data structure for dumping arbitrarily complex information, expressed in these data models, in a version-controllable fashion directly on a filesystem.


## Example

/dump
 /config.<format>
 /myschema-v3-fmta
   /Person
     /<id>.<format>


## Configuration file

Directory property declaration

- `schema` (each directory can have a different schema (version))
- `format` (declare rather than discover)
- `idfx` (function to forward-map record identifiers to get file names)

## Record ID transformation methods

Hash the whole ID with a given algorithm is a good catch-all.
But it does not give human-readable names.

For homogeneous CURIE identifiers, it could work to just take the part after the prefix and mangle slashes.
This could be applied to things like `doi:...` or `orcid:...` identifiers.

## TODO

- file format for config file
- filesystem safeguard for class names (practically following PascalCase conventions)
- filesystem safeguard for identifiers (even `:` from a curie would be forbidden on windows, but it would still be helpful to have somewhat human-readable names)
- dissolve inline declarations of relation objects
