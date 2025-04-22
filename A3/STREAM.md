# Build / run

For one node result:
```
mpicxx -Wall -O3 -qopenmp -qopt-streaming-stores always -xCORE-AVX512 -qopt-zmm-usage=high triad.cpp -o triad_cpu
# DDR
OMP_NUM_THREADS=51 mpirun -n 2 --cpu-bind=list:1-51:53-103 --mem-bind=list:0:1 ./triad_cpu cpu
# HBM
OMP_NUM_THREADS=51 mpirun -n 2 --cpu-bind=list:1-51:53-103 --mem-bind=list:2:3 ./triad_cpu cpu

# GPU
mpicxx -fiopenmp -fopenmp-targets=spir64 -DRUN_GPU triad.cpp -o triad_gpu
mpirun -n 12 gpu_tile_compact.sh ./triad_gpu gpu
```

# Example output for GPU

```
$ mpirun -n 12 gpu_tile_compact.sh ./triad_gpu gpu
Result For stream (sample size: 6)
-Min 1995.9 GByte/s
-Q1 2057.85 GByte/s
-Q2(median) 2061.22 GByte/s
-Q3 2064.54 GByte/s
-Max 2068.79 GByte/s
```

# Result obtained (2024/08/27)

``` 
Name              | SOW        | Measured
2 Tile-GPU        | 2.6 TB/s   | 2.1 TB/s
1 socket-CPU HBM  | 0.95 TB/s  | 0.64 TB/s
1 socket-CPU DDR  | 0.24 TB/s  | 0.25 TB/s
```

## Tips

- At compile time,  you can pass `-DSAVE`. Result will be save in a `stream.txt`
- At compile time, you can pass set `-DITER_MAX` to increase the number of iteration.

