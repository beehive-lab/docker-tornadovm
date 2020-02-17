
cat run_nvidia.sh

./run_nvidia.sh tornado uk.ac.manchester.tornado.drivers.opencl.TornadoDeviceOutput

./run_nvidia.sh javac.py example/MatrixMultiplication.java

./run_nvidia.sh tornado example/MatrixMultiplication

./run_nvidia.sh tornado --printKernel example/MatrixMultiplication

./run_nvidia.sh tornado --printKernel --debug example/MatrixMultiplication


