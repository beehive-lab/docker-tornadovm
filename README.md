# Docker for TornadoVM

[![](https://img.shields.io/badge/License-Apache%202.0-orange.svg)](https://opensource.org/licenses/Apache-2.0)

* TornadoVM Docker for **NVIDIA GPUs** (✅ **supported**, TornadoVM `7.2.0`): See [instructions](https://github.com/beehive-lab/docker-tornadovm#nvidia-gpus)
    * Backends: CUDA and OpenCL
    * JDKs supported:
	    * TornadoVM with Eclipse Temurin JDK 21
	    * TornadoVM with Eclipse Temurin JDK 25 (LTS)
	    * TornadoVM with Eclipse Temurin JDK 27 (latest)

* TornadoVM Docker for **Intel Integrated Graphics, Intel CPUs, and Intel FPGAs (Emulated Mode)** (⚠️ **deprecated**, no longer built or published): See [instructions](https://github.com/beehive-lab/docker-tornadovm#intel-integrated-graphics)
    * JDKs supported:
	    * TornadoVM with OpenJDK 21
		* TornadoVM with GraalVM 23.1.0 and JDK 21

* TornadoVM Docker for **Polyglot GraalVM Language Implementations** (⚠️ **deprecated**, frozen at v5.2.0-jdk21): See [instructions](https://github.com/beehive-lab/docker-tornadovm#polyglot-graalvm-language-implementations)
    * JDKs supported:
	    * TornadoVM with GraalVM 23.1.0 JDK 21

* TornadoVM Docker for **Intel GPUs, JVMCI-free JDK 27+** (⚠️ **deprecated**, no longer built or published): See [instructions](https://github.com/beehive-lab/docker-tornadovm#jdk-27-jvmci-free)

## Nvidia GPUs

### Prerequisites

The NVIDIA images need the NVIDIA Container Toolkit (the docker `nvidia` runtime) and:

* **CUDA images** (`*-cuda-*`): a Turing (compute capability 7.5) or newer GPU and a host driver that supports CUDA 13 (R580 or newer). CUDA 13 does not support Maxwell, Pascal or Volta GPUs.
* **OpenCL images** (`*-opencl-*`): any GPU supported by a current NVIDIA driver, including Pascal and Volta.

 More info here: [https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html).

### How to run?

#### 1) Pull an image

There is one image per TornadoVM backend and JDK, each built from the prebuilt TornadoVM release SDK and Eclipse Temurin. These are the only images that are currently built, tested and published:

| Image | Backend | JDK | TornadoVM SDK | Dockerfile |
|-------|---------|-----|---------------|------------|
| `beehivelab/tornadovm-nvidia-cuda-jdk21` | CUDA (PTX) | Temurin 21 | jdk21 | [`Dockerfile.nvidia.cuda.jdk21`](dockerFiles/Dockerfile.nvidia.cuda.jdk21) |
| `beehivelab/tornadovm-nvidia-cuda-jdk25` | CUDA (PTX) | Temurin 25 (LTS) | jdk22plus | [`Dockerfile.nvidia.cuda.jdk22plus`](dockerFiles/Dockerfile.nvidia.cuda.jdk22plus) |
| `beehivelab/tornadovm-nvidia-cuda-jdk27` | CUDA (PTX) | Temurin 27 | jdk22plus | [`Dockerfile.nvidia.cuda.jdk22plus`](dockerFiles/Dockerfile.nvidia.cuda.jdk22plus) |
| `beehivelab/tornadovm-nvidia-opencl-jdk21` | OpenCL | Temurin 21 | jdk21 | [`Dockerfile.nvidia.opencl.jdk21`](dockerFiles/Dockerfile.nvidia.opencl.jdk21) |
| `beehivelab/tornadovm-nvidia-opencl-jdk25` | OpenCL | Temurin 25 (LTS) | jdk22plus | [`Dockerfile.nvidia.opencl.jdk22plus`](dockerFiles/Dockerfile.nvidia.opencl.jdk22plus) |
| `beehivelab/tornadovm-nvidia-opencl-jdk27` | OpenCL | Temurin 27 | jdk22plus | [`Dockerfile.nvidia.opencl.jdk22plus`](dockerFiles/Dockerfile.nvidia.opencl.jdk22plus) |

The `jdk22plus` Dockerfiles take the JDK as a build argument (`JDK_VERSION`, default 25). The current LTS and the latest JDK are published; other JDKs from 22 up can be built locally, e.g. `./build.sh --nvidia-cuda-jdk26`, but are not tested or published. Non-LTS JDKs stop receiving security updates once the next release ships.

```bash
$ docker pull beehivelab/tornadovm-nvidia-cuda-jdk25:latest
```

Each image is tagged with the TornadoVM release version (e.g. `7.2.0`) and `latest`.

#### 2) Run an experiment

We provide a runner script that runs your Java programs with TornadoVM. Select the image with `TORNADOVM_IMAGE` (`cuda-jdk21`, `cuda-jdk25`, `cuda-jdk27`, `opencl-jdk21`, `opencl-jdk25` or `opencl-jdk27`; default `cuda-jdk25`). Here's an example:

```bash
$ git clone https://github.com/beehive-lab/docker-tornadovm
$ cd docker-tornadovm

## Run Matrix Multiplication - provided in the docker-tornadovm repository
$ ./run_nvidia.sh tornado -cp example/target/example-1.0-SNAPSHOT.jar example.MatrixMultiplication 512

## Same, on the OpenCL backend with JDK 21
$ TORNADOVM_IMAGE=opencl-jdk21 ./run_nvidia.sh tornado -cp example/target/example-1.0-SNAPSHOT.jar example.MatrixMultiplication 512
```

The example also runs a single-threaded CPU baseline 100 times, so large sizes (e.g. 2048) take tens of minutes.

Your application must be compiled against the same TornadoVM release as the image. TornadoVM is on Maven Central as `io.github.beehive-lab:tornado-api` (see [`example/pom.xml`](example/pom.xml)). Otherwise it fails with `Kernel entry ... has no writeReplace()`.

#### Build the images locally

```bash
$ ./build.sh --nvidia-cuda-jdk25   # or --nvidia-{cuda,opencl}-jdk{21,25,27}
$ TORNADOVM_VERSION=7.2.0 ./build.sh --nvidia-opencl-jdk25   # pick the TornadoVM release
```

#### Release a new version

Run the **Build, Test & Push Docker Images** GitHub workflow with the TornadoVM release version (e.g. `v7.2.0`). It builds and smoke-tests the six images above on a GPU runner. If `push_images` is checked, it then pushes them to Docker Hub and commits the version bump (via `bump-version.sh`, plus a rebuilt example jar) back to the branch.

#### Docker Hub pages

The Docker Hub overview pages are generated from [`dockerhub/active.md`](dockerhub/active.md) (supported images) and [`dockerhub/frozen.md`](dockerhub/frozen.md) (deprecated images, marked as frozen). The release workflow calls the **Update Docker Hub Descriptions** workflow after each push in which all images passed, which refreshes all pages. To update them by hand, run the **Update Docker Hub Descriptions** workflow, or `dockerhub/update-descriptions.sh <active|frozen|all>`. Add `--dry-run <dir>` to preview the pages locally.

### Deprecated Dockerfiles

These Dockerfiles are kept for reference and manual builds only. They are not built by the GitHub workflow, not updated by `bump-version.sh`, and not published any more.

| Dockerfile | Image | Notes |
|------------|-------|-------|
| [`Dockerfile.nvidia.jdk21`](dockerFiles/Dockerfile.nvidia.jdk21) | `beehivelab/tornadovm-nvidia-openjdk` | Source build, OpenCL. Replaced by `tornadovm-nvidia-opencl-jdk21` |
| [`Dockerfile.nvidia.graalvm.jdk21`](dockerFiles/Dockerfile.nvidia.graalvm.jdk21) | `beehivelab/tornadovm-nvidia-graalvm` | GraalVM 23.1.0 JDK 21 |
| [`Dockerfile.oneapi.intel.jdk21`](dockerFiles/Dockerfile.oneapi.intel.jdk21) | `beehivelab/tornadovm-intel-openjdk` | Intel GPUs/CPUs/FPGA emulation |
| [`Dockerfile.oneapi.intel.graalvm.jdk21`](dockerFiles/Dockerfile.oneapi.intel.graalvm.jdk21) | `beehivelab/tornadovm-intel-graalvm` | Intel, GraalVM 23.1.0 JDK 21 |
| [`Dockerfile.oneapi.intel.jdk22plus`](dockerFiles/Dockerfile.oneapi.intel.jdk22plus) | `beehivelab/tornadovm-intel-jdk22plus` | Experimental, unvalidated |
| [`polyglotImages/`](polyglotImages) | `beehivelab/tornadovm-polyglot-*` | Frozen at v5.2.0-jdk21 |

`beehivelab/tornadovm-nvidia-jdk22plus` has been replaced by the `tornadovm-nvidia-{cuda,opencl}-jdk{25,27}` images.

### Some options

```bash
# To see the generated kernel
$ ./run_nvidia.sh tornado --printKernel -cp example/target/example-1.0-SNAPSHOT.jar example.MatrixMultiplication

# To check some runtime info about the kernel execution and device
$ ./run_nvidia.sh tornado --threadInfo -cp example/target/example-1.0-SNAPSHOT.jar example.MatrixMultiplication
```

The `tornado` command is just an alias to the `java` command with all the parameters for TornadoVM execution. So you can pass any Java (OpenJDK or Hotspot) parameter.

```bash
$ ./run_nvidia.sh tornado --jvm="-Xmx16g -Xms16g" -cp example/target/example-1.0-SNAPSHOT.jar example.MatrixMultiplication
```

## Intel Integrated Graphics

> ⚠️ **Deprecated:** the Intel images (`tornadovm-intel-openjdk`, `tornadovm-intel-graalvm`) are no longer built or published. The instructions below apply to previously published tags and manual builds.

### Prerequisites

The `beehivelab/tornadovm-intel-openjdk` docker image Intel OpenCL driver for the integrated GPU installed.  More info here: [https://github.com/intel/compute-runtime](https://github.com/intel/compute-runtime).

### How to run?

#### 1) Pull the image

For the `beehivelab/tornadovm-intel-openjdk` image:
```bash
$ docker pull beehivelab/tornadovm-intel-openjdk:latest
```

This image uses the latest TornadoVM for Intel integrated graphics and OpenJDK 21.

#### 2) Run an experiment

We provide a runner script that compiles and run your Java programs with TornadoVM. Here's an example:

```bash
$ git clone https://github.com/beehive-lab/docker-tornadovm
$ cd docker-tornadovm

## Run Matrix Multiplication - provided in the docker-tornadovm repository
$ ./run_intel_openjdk.sh tornado -cp example/target/example-1.0-SNAPSHOT.jar example.MatrixMultiplication 256

Computing MxM of 256x256
	CPU Execution: 1.53 GFlops, Total time = 22 ms
	GPU Execution: 8.39 GFlops, Total Time = 4 ms
	Speedup: 5x
```

### Running on FPGAs (Emulation mode)? 

The TornadoVM docker image for the Intel platforms contain the FPGA in device `1:0`. 
To offload a Java application onto an FPGA, you can use the following command (example running the DFT application).

```bash
$ ./run_intel_openjdk.sh tornado --threadInfo  --jvm="-Ds0.t0.device=1:0" -m tornado.examples/uk.ac.manchester.tornado.examples.dynamic.DFTDynamic 256 default 1
WARNING: Using incubator modules: jdk.incubator.foreign, jdk.incubator.vector
Initialization time:  1066024424 ns
 
Task info: s0.t0
        Backend           : OPENCL
        Device            : Intel(R) FPGA Emulation Device CL_DEVICE_TYPE_ACCELERATOR (available)
        Dims              : 1
        Global work offset: [0]
        Global work size  : [256]
        Local  work size  : [64, 1, 1]
        Number of workgroups  : [4]
 
Total time:  276927741 ns 
 
Is valid?: true
 
Validation: SUCCESS 
```

### Using TornadoVM with GraalVM for Intel Integrated Graphics

With JDK 21:

```bash
$ docker pull beehivelab/tornadovm-intel-graalvm:latest
```

## Polyglot GraalVM Language Implementations

> ⚠️ **Deprecated.** Frozen at TornadoVM **v5.2.0-jdk21** — the last release with
> polyglot GraalVM Truffle-language support. No further updates are planned. See
> [`polyglotImages/README.md`](polyglotImages/README.md).

### Prerequisites

Currently, there are [three docker images](https://github.com/beehive-lab/docker-tornadovm/tree/master/polyglotImages) available that combine TornadoVM with polyglot GraalVM language implementations (GraalPy, GraalJS and TruffleRuby) and include the OpenCL drivers for NVIDIA GPUs.
The three docker images need the docker `nvidia` daemon.  More info here: [https://github.com/NVIDIA/nvidia-docker](https://github.com/NVIDIA/nvidia-docker).

### How to run?

#### 1) Pull the images. The images use the latest TornadoVM for NVIDIA GPUs and OpenJDK 21.

* For the `tornadovm-polyglot-graalpy-23.1.0-nvidia-opencl-container` image:
```bash
$ docker pull beehivelab/tornadovm-polyglot-graalpy-23.1.0-nvidia-opencl-container:latest
```

* For the `tornadovm-polyglot-graaljs-23.1.0-nvidia-opencl-container` image:
```bash
$ docker pull beehivelab/tornadovm-polyglot-graaljs-23.1.0-nvidia-opencl-container:latest
```

* For the `tornadovm-polyglot-truffleruby-23.1.0-nvidia-opencl-container` image:
```bash
$ docker pull beehivelab/tornadovm-polyglot-truffleruby-23.1.0-nvidia-opencl-container:latest
```

#### 2) Run an experiment

We provide a runner script for each image in order to compile and run your Python, JavaScript and Ruby programs with TornadoVM. Here's an example taken from [TornadoVM documentation](https://tornadovm.readthedocs.io/en/latest/truffle-languages.html#c-run-the-examples) that executes a matrix multiplication OpenCL kernel from Python, JavaScript and Ruby:

* Python:
```bash
$ git clone https://github.com/beehive-lab/docker-tornadovm
$ cd docker-tornadovm

## Launch the docker image with the NVIDIA OpenCL runtime
$ ./polyglotImages/polyglot-graalpy/tornadovm-polyglot-nvidia.sh

## Run Matrix Multiplication from a Python program.
$ ./polyglotImages/polyglot-graalpy/tornadovm-polyglot-nvidia.sh tornado --printKernel --truffle python example/polyglot-examples/mxmWithTornadoVM.py

## Launch the docker image with the Intel oneAPI runtime
$ ./polyglotImages/polyglot-graalpy/tornadovm-polyglot-intel.sh

## Run Matrix Multiplication from a Python program.
$ ./polyglotImages/polyglot-graalpy/tornadovm-polyglot-intel.sh tornado --printKernel --truffle python example/polyglot-examples/mxmWithTornadoVM.py
```

* JavaScript:
```bash
$ git clone https://github.com/beehive-lab/docker-tornadovm
$ cd docker-tornadovm

## Launch the docker image with the NVIDIA OpenCL runtime
$ ./polyglotImages/polyglot-graaljs/tornadovm-polyglot.sh

## Run Matrix Multiplication from a JavaScript program.
$ ./polyglotImages/polyglot-graaljs/tornadovm-polyglot.sh tornado --printKernel --truffle js example/polyglot-examples/mxmWithTornadoVM.js
```

* Ruby:
```bash
$ git clone https://github.com/beehive-lab/docker-tornadovm
$ cd docker-tornadovm

## Launch the docker image with the NVIDIA OpenCL runtime
$ ./polyglotImages/polyglot-truffleruby/tornadovm-polyglot.sh

## Run Matrix Multiplication from a Python program.
$ ./polyglotImages/polyglot-truffleruby/tornadovm-polyglot.sh tornado --printKernel --truffle ruby example/polyglot-examples/mxmWithTornadoVM.rb
```


## JDK 27+ (JVMCI-free)

⚠️ Deprecated: the Intel `tornadovm-intel-jdk22plus` image is no longer built or published. For JDK 22+ on NVIDIA GPUs, use the `*-jdk25` / `*-jdk27` images above.

```bash
$ ./build.sh --intel-jdk22plus   # manual build only (unvalidated)
```

Enjoy TornadoVM! 

Docker scripts have been inspired by [blang/latex-docker](https://github.com/blang/latex-docker)

## License

This project is developed at [The University of Manchester](https://www.manchester.ac.uk/), and it is fully open source under the [Apache 2](https://github.com/beehive-lab/docker-tornadovm/blob/master/LICENSE) license.

