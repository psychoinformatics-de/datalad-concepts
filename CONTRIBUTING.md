# CONTRIBUTING

Thanks for contributing!
We welcome any and all kinds of contribution, including:
- bug fixes and code contributions
- ideas for new features
- testing
- documentation improvements
- general suggestions on how we can do better
- ...


## Development environment setup

This project is using [hatch](https://hatch.pypa.io), a modern Python project manager.
Please refer to their [official documentation](https://hatch.pypa.io/latest/install/) for installation instructions for your system.

After installation, you can use ``hatch`` to execute specific tasks, which are defined in ``pyproject.toml`` (see individual subheadings below).
Alternatively, ``hatch`` can provide you with a development shell with the necessary packages:

```
hatch shell
```

Presently, this work require a patched linkml installation.
The patch(es) are listed in `patches/`.
The script `tools/patch_linkml` documents how they need to be applied.
``hatch`` automatically applies the patch post installation, and as long as you're using a hatch environment or hatch based check/script, there is nothing you need to do.
However, if you need to do it outside of `hatch`, run the following command to patch manually:

```
bash tools/patch_linkml
```

### Documentation

- To *build* the documentation locally, run

```
hatch run docs:build
```

- To *serve* the documentation locally, run

```
hatch run docs:serve
```

### Model checks

This repo uses a [schema linter](https://linkml.io/linkml/schemas/linter.html) with a configuration in ``.linkmllint.yaml`` to first validate schemas (=models) against the [LinkML Metamodel](https://linkml.io/linkml/schemas/metamodel.html) and then linting them.
At the same time, the check will also generate various other output formats (JSON-LD context, JSON schema, owl, and Python classes) from the ``<model-name>.yaml`` files to potentially reveal "hidden" issues.


- To perform this check on *all models*, run

```
hatch run check:models
```

- To perform this check on a *specific model*, e.g., ``flat-data/unreleased.yaml``, run

```
hatch shell
make checkmodel/flat-data/unreleased
```

### Switching import locations

Although most rules will perform this action automatically, the following command allows to switch from a remote-URL import to an import from a local file (which is relevant when, for example, there is no remote URL yet to import from, or you are testing local changes):

```
make imports-local
```

Its opposite command, reverting imports back to remote URLs, is

```
make imports-remote
```

### Example conversion

Each schema has example data used for testing.
An example data file corresponds to a class from the schema file.
The file organization looks as follows:

```
src
└── schema-name
    ├── unreleased
    │   ├── examples        <- contains data that gets validated
    │   │   ├── class-name.json
    │   │   ├── class-name.rdf
    │   │   └── class-name.yaml     <- starting format
    │   ├── extra-docs
    │   │   └── about.md
    │   └── validation       <- files with required configurations
    │       ├── class-name.invalid.cfg.yaml
    │       └── class-name.valid.cfg.yaml      
    └── unreleased.yaml             <- the schema file
```

The command 

```
hatch run check:examples
```

performs the following: It 

- validates example data within ``examples`` according to configurations in ``validation``
- converts example ``.yaml`` data into ``.json`` and ``.rdf``

For other formats, e.g., ``ttl``, ``linkml-convert`` can be used to convert data from one form to another, following a schema:

```
hatch shell
linkml convert -o ds.ttl -s src/flat-data/unreleased.yaml --target-class-from-path --infer src/flat-data/unreleased/examples/Dataset-1.yaml
```


## Useful hints for a contribution workflow

* Patches get regularly updated, and they are not re-applied automatically in an existing hatch environments. If in doubt, wipe the environment and re-create it, for example using ``hatch env prune``.

* Because LinkML allows imports from other schemas, there may be more to the classes or slots you see defined in any given file.
In order to figure out easily which slots are available or even required, we recommend that you **render the documentation locally**, as this allows you to browse through the classes and discover also information that comes from other schemas. 

* A broad swipe of checks for any new or existing component can be achieved with the following command composition (where one replaces ``component`` with the schema name):

```
export component=flat-data; make checkmodel/$component/unreleased convertexamples/$component/unreleased checkvalidation/$component/unreleased
```
