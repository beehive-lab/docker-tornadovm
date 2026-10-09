# ⚠️ Frozen: {{IMAGE}}

**This image is no longer maintained.** It is not rebuilt for new TornadoVM releases and does not receive security updates. The existing tags stay available, but new projects should not use it.

- **Last release:** {{LAST}}
- **Use instead:** {{REPLACEMENT}}

## Supported images

TornadoVM images for NVIDIA GPUs, built from the prebuilt TornadoVM release SDKs:

| Image | Backend | JDK |
|-------|---------|-----|
| [`beehivelab/tornadovm-nvidia-cuda-jdk21`](https://hub.docker.com/r/beehivelab/tornadovm-nvidia-cuda-jdk21) | CUDA (PTX) | 21 |
| [`beehivelab/tornadovm-nvidia-cuda-jdk25`](https://hub.docker.com/r/beehivelab/tornadovm-nvidia-cuda-jdk25) | CUDA (PTX) | 25 (LTS) |
| [`beehivelab/tornadovm-nvidia-cuda-jdk27`](https://hub.docker.com/r/beehivelab/tornadovm-nvidia-cuda-jdk27) | CUDA (PTX) | 27 |
| [`beehivelab/tornadovm-nvidia-opencl-jdk21`](https://hub.docker.com/r/beehivelab/tornadovm-nvidia-opencl-jdk21) | OpenCL | 21 |
| [`beehivelab/tornadovm-nvidia-opencl-jdk25`](https://hub.docker.com/r/beehivelab/tornadovm-nvidia-opencl-jdk25) | OpenCL | 25 (LTS) |
| [`beehivelab/tornadovm-nvidia-opencl-jdk27`](https://hub.docker.com/r/beehivelab/tornadovm-nvidia-opencl-jdk27) | OpenCL | 27 |

Each page has the instructions for running it.

## Using this image anyway

The instructions for the last release are in the source repository: [beehive-lab/docker-tornadovm]({{DOCS_URL}}). Pin a tag rather than `latest`, e.g. `docker pull {{IMAGE}}:{{PIN}}`.
