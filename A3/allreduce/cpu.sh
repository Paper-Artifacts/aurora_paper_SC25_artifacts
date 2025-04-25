#!/bin/bash

# Update path to OSU
PATH_TO_OSU=../osu-benchmarks/mpi
# Number of iterations and skip iterations
NUM_ITER="-i 10000 -x 200"

# Env variables
export MPIR_CVAR_ENABLE_GPU=0
export FI_CXI_RDZV_THRESHOLD=131072

# Load collective tuning file
module load mpich-config/collective-tuning/1024

NODES=8192
PPN=2
NUM_RANKS=$(($NODES * PPN))

# 8B
mpiexec -n $NUM_RANKS -ppn $PPN -hostfile ./hostfile --cpu-bind list:2:58 $PATH_TO_OSU/collective/osu_allreduce -m 8:8 $NUM_ITER

# 2048B
mpiexec -n $NUM_RANKS -ppn $PPN -hostfile ./hostfile --cpu-bind list:2:58 $PATH_TO_OSU/collective/osu_allreduce -m 2048:2048 $NUM_ITER
