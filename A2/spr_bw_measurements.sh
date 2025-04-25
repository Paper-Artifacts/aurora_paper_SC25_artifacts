#!/bin/sh -x
#PBS -l select=512
#PBS -l walltime=1:00:00
#PBS -q prod
#PBS -k doe
#PBS -A Performance
#PBS -l filesystems=flare:home

cd ${PBS_O_WORKDIR}

# DDR
OMP_NUM_THREADS=51 mpirun -n $(( $(wc -l < $PBS_NODEFILE) * 2)) -ppn 2 --cpu-bind=list:1-51:53-103 --mem-bind=list:0:1 ./triad_cpu cpu
# HBM
OMP_NUM_THREADS=51 mpirun -n $(( $(wc -l < $PBS_NODEFILE) * 2)) -ppn 2 --cpu-bind=list:1-51:53-103 --mem-bind=list:2:3 ./triad_cpu cpu
