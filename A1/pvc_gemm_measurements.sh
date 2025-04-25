#!/bin/sh -x                                                                                                                                                                                                                       
#PBS -l select=512                                                                                                                                                                                                                 
#PBS -l walltime=1:00:00                                                                                                                                                                                                           
#PBS -q prod                                                                                                                                                                                                                       
#PBS -k doe                                                                                                                                                                                                                        
#PBS -A Performance
#PBS -l filesystems=flare:home

cd ${PBS_O_WORKDIR}

cd gemm_benchmarking

OMP_NUM_THREADS=8 mpirun -n $(( $(wc -l < $PBS_NODEFILE) * 12)) -ppn 12 --cpu-bind list:1-8:9-16:17-24:25-32:33-40:41-48:52-59:60-67:68-75:76-83:84-91:92-99 gpu_tile_compact.sh ./gemm gpu
