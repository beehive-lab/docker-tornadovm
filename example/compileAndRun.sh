#!/bin/bash 

mvn clean package
tornado --devices
tornado -cp target/example-1.0-SNAPSHOT.jar example.MatrixMultiplication
