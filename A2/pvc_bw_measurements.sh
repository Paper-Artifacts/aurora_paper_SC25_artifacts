#!/bin/sh -x
#PBS -l select=512
#PBS -l walltime=1:00:00
#PBS -q prod
#PBS -k doe
#PBS -A Performance
#PBS -l filesystems=flare:home

cd ${PBS_O_WORKDIR}

mpirun -n $(( $(wc -l < $PBS_NODEFILE) * 12)) -ppn 12 gpu_tile_compact.sh ./triad_gpu gpu
