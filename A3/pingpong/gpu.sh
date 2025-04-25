#!/bin/bash

# Update path to OSU
PATH_TO_OSU=../osu-benchmarks/mpi
# Path to multisend benchmark in which 1 rank sends data to N-1 ranks
PATH_TO_MULTISEND=../osu-benchmarks/multisend/multi_send_host
# Number of iterations and skip iterations
NUM_ITER="-i 10000 -x 200"
# Use GPU Buffers
GPU_ARGS="-d ze D D"

# Env variables
export FI_CXI_RDZV_THRESHOLD=131072
export EnableImplicitScaling=0
export NEOReadDebugKeys=1
export ZE_ENABLE_PCI_ID_DEVICE_ORDER=1
export MPIR_CVAR_GPU_USE_IMMEDIATE_COMMAND_LIST=1

# Enable GPU RDMA
export MPIR_CVAR_CH4_OFI_ENABLE_HMEM=1
export MPIR_CVAR_CH4_OFI_ENABLE_MR_HMEM=0
export MPIR_CVAR_CH4_OFI_GPU_RDMA_THRESHOLD=0


mpiexec -np 2 -ppn 1  --cpu-bind list:2   $PATH_TO_OSU/pt2pt/osu_latency -m 0:0 $NUM_ITER $GPU_ARGS  
mpiexec -np 2 -ppn 1  --cpu-bind list:2   $PATH_TO_OSU/pt2pt/osu_latency -m 4096:4096 $NUM_ITER $GPU_ARGS  
mpiexec -np 2 -ppn 1  --cpu-bind list:2   $PATH_TO_OSU/pt2pt/osu_latency -m 65536:65536 $NUM_ITER $GPU_ARGS  
