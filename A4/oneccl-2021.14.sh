#!/bin/bash
mkdir -p /path/to/job/output
qsub -l select=1    -l walltime=05:00:00 -l filesystems=flare -q lustre_scaling oneccl-2021.14.submit 
qsub -l select=2    -l walltime=05:00:00 -l filesystems=flare -q lustre_scaling oneccl-2021.14.submit 
qsub -l select=4    -l walltime=05:00:00 -l filesystems=flare -q lustre_scaling oneccl-2021.14.submit 
qsub -l select=8    -l walltime=05:00:00 -l filesystems=flare -q lustre_scaling oneccl-2021.14.submit 
qsub -l select=16   -l walltime=05:00:00 -l filesystems=flare -q lustre_scaling oneccl-2021.14.submit 
qsub -l select=32   -l walltime=05:00:00 -l filesystems=flare -q lustre_scaling oneccl-2021.14.submit 
qsub -l select=64   -l walltime=05:00:00 -l filesystems=flare -q prod           oneccl-2021.14.submit 
qsub -l select=128  -l walltime=05:00:00 -l filesystems=flare -q prod           oneccl-2021.14.submit 
qsub -l select=256  -l walltime=05:00:00 -l filesystems=flare -q prod           oneccl-2021.14.submit 
qsub -l select=512  -l walltime=05:00:00 -l filesystems=flare -q prod           oneccl-2021.14.submit 
qsub -l select=1024 -l walltime=05:00:00 -l filesystems=flare -q prod           oneccl-2021.14.submit 
qsub -l select=2048 -l walltime=05:00:00 -l filesystems=flare -q prod           oneccl-2021.14.submit 
qsub -l select=4096 -l walltime=05:00:00 -l filesystems=flare -q prod-large     oneccl-2021.14.submit 
qsub -l select=8192 -l walltime=05:00:00 -l filesystems=flare -q prod-large     oneccl-2021.14.submit 
