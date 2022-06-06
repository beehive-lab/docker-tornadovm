## Build for Intel Platforms

./build.sh --intel-jdk17
./run_intel_openjdk.sh tornado -version
./run_intel_openjdk.sh tornado --version
./run_intel_openjdk.sh tornado --threadInfo -cp example/target/example-1.0-SNAPSHOT.jar example.MatrixMultiplication


./build.sh --intel-graalVM-JDK17
./run_intel_graalvm.sh tornado --version
./run_intel_graalvm.sh tornado -version
./run_intel_graalvm.sh tornado --threadInfo -cp example/target/example-1.0-SNAPSHOT.jar example.MatrixMultiplication

