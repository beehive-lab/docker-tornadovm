![](https://img.shields.io/docker/pulls/beehivelab/tornado-gpu.svg)

# Docker for Tornado-GPU

## Prerequisites

The `tornado-gpu` docker image needs the docker `nvidia` daemon. 
More info here: [https://github.com/NVIDIA/nvidia-docker](https://github.com/NVIDIA/nvidia-docker).

## How to run?

1) Pull the image

```bash
$ docker pull beehivelab/tornado-gpu:latest
```

2) Run an experiment

```bash
$ ./run.sh javac.py example/MatrixMultiplication.java
$ ./run.sh tornado example/MatrixMultiplication 
```

Enjoy Tornado!! 

Docker scripts have been inspired by https://github.com/blang/latex-docker 
