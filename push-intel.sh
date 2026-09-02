#!/usr/bin/env bash
tag=6.0.0-jdk21
docker push beehivelab/tornadovm-intel-openjdk:$tag
docker push beehivelab/tornadovm-intel-openjdk:latest
docker push beehivelab/tornadovm-intel-graalvm:$tag
docker push beehivelab/tornadovm-intel-graalvm:latest
