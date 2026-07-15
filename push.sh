#!/usr/bin/env bash
tag=5.0.0-jdk21
docker push beehivelab/tornadovm-nvidia-openjdk:$tag
docker push beehivelab/tornadovm-nvidia-openjdk:latest
docker push beehivelab/tornadovm-nvidia-graalvm:$tag
docker push beehivelab/tornadovm-nvidia-graalvm:latest
docker push beehivelab/tornadovm-intel-openjdk:$tag
docker push beehivelab/tornadovm-intel-openjdk:latest
docker push beehivelab/tornadovm-intel-graalvm:$tag
docker push beehivelab/tornadovm-intel-graalvm:latest
