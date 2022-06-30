/*
 *    Copyright [2022] APT Group, Department of Computer Science,
 *    The University of Manchester.
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */
package example;

import uk.ac.manchester.tornado.api.GridScheduler;
import uk.ac.manchester.tornado.api.TaskSchedule;
import uk.ac.manchester.tornado.api.WorkerGrid;
import uk.ac.manchester.tornado.api.WorkerGrid2D;
import uk.ac.manchester.tornado.api.common.Access;
import uk.ac.manchester.tornado.api.common.TornadoDevice;
import uk.ac.manchester.tornado.api.runtime.TornadoRuntime;

import java.util.Random;
import java.util.stream.IntStream;

/**
 * How to run?
 *
 * <code>
 *     $ ../run_intel_openjdk.sh tornado --threadInfo -cp target/example-1.0-SNAPSHOT.jar example.PreBuiltExample 256
 * </code>
 */
public class PreBuiltExample {

    public static void main(String[] args) {
        int size = 512;
        if (args.length >= 1) {
            try {
                size = Integer.parseInt(args[0]);
            } catch (NumberFormatException nfe) {
                size = 512;
            }
        }

        float[] matrixA = new float[size * size];
        float[] matrixB = new float[size * size];
        float[] matrixC = new float[size * size];
        float[] resultSeq = new float[size * size];

        Random r = new Random();
        IntStream.range(0, size * size).parallel().forEach(idx -> {
            matrixA[idx] = r.nextFloat();
            matrixB[idx] = r.nextFloat();
        });


        // Get the default device
        TornadoDevice device = TornadoRuntime.getTornadoRuntime().getDriver(1).getDevice(1);

        String filePath = "mxm.cl";

        GridScheduler grid = new GridScheduler();
        WorkerGrid workerGrid = new WorkerGrid2D(size, size);
        workerGrid.setGlobalWork(size, size, 1);
        workerGrid.setLocalWork(64, 1, 1);
        grid.setWorkerGrid("s0.t0", workerGrid);

        TaskSchedule ts = new TaskSchedule("s0")
                .lockObjectsInMemory(matrixA, matrixB, matrixC)
                .prebuiltTask("t0",
                        "matrixMultiplication",
                        filePath,
                        new Object[] { matrixA, matrixB, matrixC, size},
                        new Access[] { Access.READ, Access.READ, Access.WRITE, Access.READ },
                        device,
                        new int[] { size, size })
                .streamOut(matrixC);

        // 1. Warm up Tornado
        for (int i = 0; i < MatrixMultiplication.WARMING_UP_ITERATIONS; i++) {
            ts.execute(grid);
        }

        // 2. Run parallel on the GPU with Tornado
        long start = System.currentTimeMillis();
        ts.execute(grid);
        long end = System.currentTimeMillis();

        // 2. Run the sequential code
        long startSequential = System.currentTimeMillis();
        MatrixMultiplication.matrixMultiplication(matrixA, matrixB, resultSeq, size);
        long endSequential = System.currentTimeMillis();

        // Compute Gigaflops and performance
        long msecGPUElapsedTime = (end - start);
        long msecCPUElaptedTime = (endSequential - startSequential);
        double flops = 2 * Math.pow(size, 3);
        double gpuGigaFlops = (1.0E-9 * flops) / (msecGPUElapsedTime / 1000.0f);
        double cpuGigaFlops = (1.0E-9 * flops) / (msecCPUElaptedTime / 1000.0f);

        String formatGPUFGlops = String.format("%.2f", gpuGigaFlops);
        String formatCPUFGlops = String.format("%.2f", cpuGigaFlops);

        System.out.println("\tCPU Execution: " + formatCPUFGlops + " GFlops, Total time = " + (endSequential - startSequential) + " ms");
        System.out.println("\tGPU Execution: " + formatGPUFGlops + " GFlops, Total Time = " + (end - start) + " ms");
        System.out.println("\tSpeedup: " + ((endSequential - startSequential) / (end - start)) + "x");

    }
}
