# TornadoVM for NVIDIA GPUs: {{BACKEND_NAME}} backend, JDK {{JDK}}

[TornadoVM](https://www.tornadovm.org/) runs Java programs on GPUs. This image ships the prebuilt TornadoVM release SDK with the **{{BACKEND_NAME}}** backend on **Eclipse Temurin JDK {{JDK}}**{{JDK_NOTE}}.

Source and issues: [beehive-lab/docker-tornadovm](https://github.com/beehive-lab/docker-tornadovm)

## Tags

- `latest`: the most recent TornadoVM release
- `X.Y.Z` (e.g. `{{VERSION}}`): a specific TornadoVM release

## Prerequisites

- An NVIDIA GPU, with a host driver that supports CUDA 13
- The [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html), registered with Docker:

```bash
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

## Quick start

```bash
docker pull {{IMAGE}}:latest

# List the devices TornadoVM can use
docker run --rm --runtime=nvidia {{IMAGE}}:latest tornado --devices
```

## Run your application

The container works in `/data`. Mount the directory that holds your jar there:

```bash
docker run --rm --runtime=nvidia \
  --user "$(id -u):$(id -g)" \
  -v "$PWD":/data \
  {{IMAGE}}:latest \
  tornado --threadInfo -cp my-app.jar com.example.Main
```

- `--runtime=nvidia` exposes the GPU and the host driver to the container. `--gpus all` also works.
- `--user` makes files the program writes to `/data` belong to you instead of root.
- `tornado` is a wrapper around `java` that adds the TornadoVM options. Use `--jvm="..."` to pass JVM flags, e.g. `tornado --jvm="-Xmx16g" -cp my-app.jar com.example.Main`.
- Useful TornadoVM flags: `--devices` (list devices), `--threadInfo` (show where each task ran), `--printKernel` (print the generated {{KERNEL_LANG}} kernel).

**Compile your application against the same TornadoVM release as the image.** The API is on Maven Central:

```xml
<dependency>
  <groupId>io.github.beehive-lab</groupId>
  <artifactId>tornado-api</artifactId>
  <version>{{VERSION}}-jdk21</version>
</dependency>
```

An application built against another release fails with `Kernel entry ... has no writeReplace()`.

You can also compile inside the image, which uses the TornadoVM API jars it ships:

```bash
docker run --rm --user "$(id -u):$(id -g)" -v "$PWD":/data {{IMAGE}}:latest \
  bash -c 'javac -cp "$TORNADOVM_HOME/share/java/tornado/*" -d classes $(find src -name "*.java")'
```

## Try the example

The source repository has a matrix multiplication example and a runner script:

```bash
git clone https://github.com/beehive-lab/docker-tornadovm
cd docker-tornadovm
TORNADOVM_IMAGE={{SHORT}} ./run_nvidia.sh tornado --threadInfo \
  -cp example/target/example-1.0-SNAPSHOT.jar example.MatrixMultiplication 512
```

The output should end with `Verification true`.

## Other images

| Image | Backend | JDK |
|-------|---------|-----|
| [`beehivelab/tornadovm-nvidia-cuda-jdk21`](https://hub.docker.com/r/beehivelab/tornadovm-nvidia-cuda-jdk21) | CUDA (PTX) | 21 |
| [`beehivelab/tornadovm-nvidia-cuda-jdk25`](https://hub.docker.com/r/beehivelab/tornadovm-nvidia-cuda-jdk25) | CUDA (PTX) | 25 (LTS) |
| [`beehivelab/tornadovm-nvidia-cuda-jdk27`](https://hub.docker.com/r/beehivelab/tornadovm-nvidia-cuda-jdk27) | CUDA (PTX) | 27 |
| [`beehivelab/tornadovm-nvidia-opencl-jdk21`](https://hub.docker.com/r/beehivelab/tornadovm-nvidia-opencl-jdk21) | OpenCL | 21 |
| [`beehivelab/tornadovm-nvidia-opencl-jdk25`](https://hub.docker.com/r/beehivelab/tornadovm-nvidia-opencl-jdk25) | OpenCL | 25 (LTS) |
| [`beehivelab/tornadovm-nvidia-opencl-jdk27`](https://hub.docker.com/r/beehivelab/tornadovm-nvidia-opencl-jdk27) | OpenCL | 27 |

## Troubleshooting

- **`unknown or invalid runtime name: nvidia`**: the NVIDIA Container Toolkit is not installed or not registered with Docker (see Prerequisites).
- **No devices listed, or driver errors**: the host driver is too old. Check the CUDA version that `nvidia-smi` reports on the host.

## License

TornadoVM and these images are developed at [The University of Manchester](https://www.manchester.ac.uk/) and released under the [Apache 2.0](https://github.com/beehive-lab/docker-tornadovm/blob/master/LICENSE) license. Images built on `nvidia/cuda` are also subject to the [NVIDIA Deep Learning Container License](https://developer.nvidia.com/ngc/nvidia-deep-learning-container-license).
