#!/bin/sh -x                                                                                                                                                                                                                       
#PBS -l select=512                                                                                                                                                                                                                 
#PBS -l walltime=1:00:00                                                                                                                                                                                                           
#PBS -q prod                                                                                                                                                                                                                       
#PBS -k doe                                                                                                                                                                                                                        
#PBS -A Performance                                                                                                                                                                                                                

cd ${PBS_O_WORKDIR}

cd gemm_benchmarking

OMP_NUM_THREADS=51 mpirun -n $(( $(wc -l < $PBS_NODEFILE) * 2)) -ppn 2 --cpu-bind=list:1-51:53-103 ./set_hbm.sh ./gemm cpu
