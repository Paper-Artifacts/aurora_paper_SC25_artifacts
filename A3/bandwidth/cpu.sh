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


################# CPU INTER NODE BANDWIDTH 1-1 #########################
# 1 ranks sends data to another rank across node
mpiexec -np 2 -ppn 1 --cpu-bind list:2   $PATH_TO_OSU/pt2pt/osu_mbw_mr -m 524288:524288 $NUM_ITER

################# CPU INTER NODE BANDWIDTH 1-4 #########################
# Enable NIC hashing. Allows a single rank to utilize all available NICs
export MPIR_CVAR_CH4_OFI_ENABLE_MULTI_NIC_HASHING=1
# Max of 4 NICs are used in this test according to SOW
export MPIR_CVAR_CH4_OFI_MAX_NICS=4
# Measures bandwidth when 1 rank send data to 4 ranks across nodes
mpiexec -n 5 -ppn 1  --cpu-bind list:2 $PATH_TO_MULTISEND
