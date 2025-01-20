# DataLad Concepts Toolkit

[![Hatch project](https://img.shields.io/badge/%F0%9F%A5%9A-Hatch-4051b5.svg)](https://github.com/pypa/hatch)

This toolkit provides generic components for metadata-driven workflows that
need not depends on services, databases, and a complex technology stack.
See https://concepts.datalad.org for more information.

-----

## Table of Contents

- [Development](#development)
- [License](#license)

## Development

This project uses [hatch](https://github.com/pypa/hatch) for managing
local development environments.

Presently, this work require a patched linkml installation. The patch(es) are
listed in `patches/`. The script `tools/patch_linkml` documents how they need
to be applied. This script can be used to patch a local installation, and is
also executed by `hatch` when installing environments, and in the GitHub actions
that validate the included data models.

## License

This project is distributed under the terms of the [MIT](https://spdx.org/licenses/MIT.html) license.

## Acknowledgements

This work was funded, in part, by

- Deutsche Forschungsgemeinschaft (DFG, German Research Foundation) under grant TRR 379 ([546006540](https://gepris.dfg.de/gepris/projekt/546006540), Q02 project)
- Deutsche Forschungsgemeinschaft (DFG, German Research Foundation) under grant SFB 1451 ([431549029](https://gepris.dfg.de/gepris/projekt/431549029), INF project)
- [MKW-NRW: Ministerium für Kultur und Wissenschaft des Landes Nordrhein-Westfalen](https://www.mkw.nrw) under the Kooperationsplattformen 2022 program, grant number: KP22-106A
