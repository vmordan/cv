# Continuous Verification Framework

[![Apache 2.0 License](https://img.shields.io/badge/license-Apache--2-brightgreen.svg)](https://www.apache.org/licenses/LICENSE-2.0)

This framework aims at results analysis of continuous verification, which can be applied to software systems.

## Visualization of verification results

### Witness Visualizer

Witness Visualizer converts generic witnesses from [SV-COMP](https://sv-comp.sosy-lab.org) tools into user-friendly format.

#### Deployment

In order to install Witness Visualizer in the `<deployment directory>` execute the following command:

```bash
make install-witness-visualizer DEPLOY_DIR=<deployment directory>
```

#### Usage

After deployment Witness Visualizer can be used to convert witnesses from the `<deployment directory>` with command:

```
scripts/visualize_witnesses.py
```

Mandatory options:
* `-w` WITNESS, `--witness` WITNESS: path to the witness to be visualized;
* `-d` DIRECTORY, `--directory` DIRECTORY: directory with witnesses to be visualized (either `-w` or `-d` option must be specified);
* `-r` RESULT_DIR, `--result-dir` RESULT_DIR: directory, in which visualized witnesses will be placed in html format;
* `-s` SOURCE_DIR, `--source-dir` SOURCE_DIR: source files directory.

### Benchmark Visualizer

Benchmark Visualizer is a tool for visualizing benchmark verification results.

#### Deployment

1. Web-interface 

See instruction [docs/web_interface.txt](docs/web_interface.txt).

2. Control scripts

In order to install Benchmark Visualizer in the <deployment directory> execute the following command:

```shell
make install-benchmark-visualizer DEPLOY_DIR=<deployment directory>
```

#### Usage

See instruction [docs/benchmark_visualizer.md](docs/benchmark_visualizer.md).
