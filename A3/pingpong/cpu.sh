#!/bin/bash

# Update path to OSU
PATH_TO_OSU=../osu-benchmarks/mpi
# Path to multisend benchmark in which 1 rank sends data to N-1 ranks
PATH_TO_MULTISEND=../osu-benchmarks/multisend/multi_send_host
# Number of iterations and skip iterations
NUM_ITER="-i 10000 -x 200"

# Env variables
export MPIR_CVAR_ENABLE_GPU=0
export FI_CXI_RDZV_THRESHOLD=131072

mpiexec -np 2 -ppn 1  --cpu-bind list:2   $PATH_TO_OSU/pt2pt/osu_latency -m 0:0 $NUM_ITER
mpiexec -np 2 -ppn 1  --cpu-bind list:2   $PATH_TO_OSU/pt2pt/osu_latency -m 4094:4094 $NUM_ITER
mpiexec -np 2 -ppn 1  --cpu-bind list:2   $PATH_TO_OSU/pt2pt/osu_latency -m 65536:65536 $NUM_ITER
