# DataLad Concept Ontology

_WORK IN PROGRESS_

https://concepts.datalad.org

## How to...

Install (in a virtualenv)

```
pip install -r requirements.txt
```

Build docs:

```
make
```

Serve docs locally

```
mkdocs serve
```

Presently, this work require a patched linkml installation. The patch(es) are
listed in `patches/`. The script `tools/patch_linkml` documents how they need
to be applied. This script can be used to patch a local installation, and is
also executed in the GitHub actions that validate the included data models.


## Acknowledgements

This work was funded by

- Deutsche Forschungsgemeinschaft (DFG, German Research Foundation) under grant SFB 1451 ([431549029](https://gepris.dfg.de/gepris/projekt/431549029), INF project)
- [MKW-NRW: Ministerium für Kultur und Wissenschaft des Landes Nordrhein-Westfalen](https://www.mkw.nrw) under the Kooperationsplattformen 2022 program, grant number: KP22-106A
