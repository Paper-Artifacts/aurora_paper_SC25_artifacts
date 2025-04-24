#!/bin/bash

# Update path to OSU
PATH_TO_OSU=../osu-benchmarks/mpi
# Path to multisend benchmark in which 1 rank sends data to N-1 ranks
PATH_TO_MULTISEND_DEV=../osu-benchmarks/multisend/multi_send_device
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

# Load collective tuning file
module load mpich-config/collective-tuning/1024

# MPI_COMM_WORLD 
NODES=8192 
PPN=6 
NUM_RANKS=$(($NODES * $PPN)) 
BIND=list:2:15:28:54:67:80 
# 8B 
mpiexec -n $NUM_RANKS -ppn $PPN  --cpu-bind $BIND  ./wrapper.sh $PATH_TO_OSU/collective/osu_allreduce  -m 8:8 $NUM_ITER $GPU_ARGS 
 
# 2048B 
mpiexec -n $NUM_RANKS -ppn $PPN  --cpu-bind $BIND  ./wrapper.sh $PATH_TO_OSU/collective/osu_allreduce  -m 2048:2048 $NUM_ITER $GPU_ARGS 
