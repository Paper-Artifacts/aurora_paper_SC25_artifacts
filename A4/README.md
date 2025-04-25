# OneCCL 2021.14 Benchmark Artifact

This repository contains scripts and example module files for reproducing the *oneCCL 2021.14* allreduce performance experiments described in our paper. By following the instructions here, you can build and package oneCCL, then submit batch jobs at various node counts to collect performance metrics for multiple allreduce algorithms (e.g., **rabenseifner**, **ring**, **recursive_doubling**, etc.).

## Contents

```
.
├── modulefiles
│   └── oneccl
│       └── 2021.14.lua         # Example module file for oneCCL 2021.14
├── oneccl-2021.14.sh           # Helper script for submitting multiple PBS jobs (various node counts)
├── oneccl-2021.14.submit       # PBS submission script to run oneCCL allreduce tests
└── README.md                   # This file
```

## 1. Prerequisites

1. **HPC System Requirements**  
   - A multi-node cluster or HPC system with a job scheduling system (e.g., PBS, Slurm, etc.).  
   - Intel Data Center GPU Max Series or a compatible GPU environment (or you can adapt these scripts for other GPU vendors if oneCCL supports them).  
   - MPI implementation compatible with oneCCL (e.g., Intel MPI, MPICH, or MVAPICH2).  

2. **Software & Tools**  
   - **oneCCL 2021.14** sources: [https://github.com/uxlfoundation/oneCCL](https://github.com/uxlfoundation/oneCCL)  
   - **C/C++ compiler** (supporting C++17 or later)  
   - **ClusterShell (`clush`)** if you want to use the provided file-distribution mechanism. If you do not have `clush`, you can replace the relevant lines with another method of transferring files to compute nodes.  
   - **PBS** job submission environment for the example scripts (`qsub`).  
   - **Module environment** (e.g., Lmod or Environment Modules) if you plan to use the `module use` and `module load` commands.  

> **Note:** If you do not have these exact tools (PBS, clush, etc.) you may need to modify the scripts to match your local scheduler, environment modules, or file-distribution mechanisms.

## 2. Building oneCCL and Creating the Distributable Tarball

### A. Clone and Build oneCCL 2021.14

1. Clone the oneCCL repository (or download the appropriate release tarball):
   ```bash
   git clone https://github.com/uxlfoundation/oneCCL.git
   cd oneCCL
   git checkout 2021.14  # or your desired release/tag/branch
   ```

2. Configure and build oneCCL (the following is a generic outline; refer to oneCCL documentation for details):
   ```bash
   mkdir build && cd build
   cmake .. -DCMAKE_CXX_COMPILER=mpicxx -DCMAKE_C_COMPILER=mpicc \
            -DCMAKE_INSTALL_PREFIX=/path/to/your/oneccl/install
   make -j
   make install
   ```
   Adjust the compiler and paths as needed for your system.

### B. Create the oneCCL Tarball

Once built, you can create a tarball from your install directory (or your build directory if you prefer). For example:
```bash
cd /path/to/your/oneccl/install
tar czf oneccl-2021.14.tgz *
```
This tarball (`oneccl-2021.14.tgz`) is what the scripts will distribute to each compute node during the job runs.

> **Tip:** Place the resulting tarball in a known location or copy it into this repository. Then edit the scripts (below) to reference the correct path.

## 3. Editing the Scripts

### A. `modulefiles/oneccl/2021.14.lua`
- This file is an example module definition that sets environment variables needed for **oneCCL**.  
- Update any paths (e.g., `prepend_path`, `setenv`) to point to your actual oneCCL install directory.  
- If your site uses a different module naming convention, rename the file or modify accordingly.

### B. `oneccl-2021.14.submit`
- This is the PBS job script that:
  1. Reserves compute nodes.
  2. Distributes and unpacks the `oneccl-2021.14.tgz` file to all compute nodes (via `clush`).
  3. Loads the oneCCL module (`module load oneccl/2021.14`).
  4. Sets environment variables for CPU and GPU binding.
  5. Runs the oneCCL benchmark with different allreduce algorithms.
  6. Gathers and compresses results.

- **Key areas to modify**:
  - `#PBS -A <account>` and other PBS directives (e.g., `-q prod`, `-l walltime`, etc.) according to your site policies.  
  - Paths under `JOB_DIR`, `ONECCL_TARBALL`, `module use /path/to/oneccl/modulefiles`, etc.  
  - Environment variables like `ZE_AFFINITY_MASK`, `GPUS_PER_NODE`, `CPU_BIND`, etc., if your GPU counts or CPU topology differ.

- **File-distribution mechanism**:  
  - The script uses `clush` for distributing the tarball. If `clush` is not available, replace those lines with your own method for copying files to compute nodes (e.g., `pdsh`, `dsh`, or even an NFS-shared directory).

### C. `oneccl-2021.14.sh`
- This helper script submits multiple jobs with increasing node counts, from 1 to 8192 (powers of two).  
- **Key areas to modify**:
  - The `qsub` lines that specify node count (`-l select=N`) and job queue (`-q ...`).  
  - The location of the output directory (`/path/to/job/output` should match the path in the submit script), etc.  
  - You can remove or add lines if you want fewer or more node counts.

> **Note:** This script assumes you want to run all tests sequentially at different scales. You can also submit them individually if you only need certain scales.

## 4. Running the Benchmark

After editing the paths and modules in both scripts:

1. **Load your environment** (MPI, compilers, etc.):  
   ```bash
   module load mpi/your-version
   # Possibly load other modules needed for GPU usage
   ```

2. **Ensure the oneCCL tarball is accessible** at the path set in `oneccl-2021.14.submit`.  

3. **Submit the jobs** using the helper script:
   ```bash
   chmod +x oneccl-2021.14.sh
   ./oneccl-2021.14.sh
   ```
   This will create multiple PBS jobs for different node counts. Logs and results (CSV files) will be placed in the specified output directory once each job completes.

4. **Check job status** (e.g., `qstat`, `showq`, etc.) until the jobs finish.

## 5. Analyzing Outputs

- The script compresses all outputs and logs into a tarball (e.g., `out_<JOBID>.tar.gz`).  
- Each run produces:
  - A `.csv` file containing timing measurements for each allreduce algorithm.  
  - A `.txt` file with stdout logs for that run.  
- Once you retrieve these tarballs, you can unpack them and analyze the CSV files in your favorite plotting or data-processing tool (e.g., Python pandas, R, gnuplot, etc.).

Example performance analysis might compare the runtime or throughput of the different allreduce algorithms across increasing node counts.

## 6. Troubleshooting & Tips

- If the job fails early:
  - Verify the paths to `clush` and `oneccl-2021.14.tgz` are correct.
  - Ensure your module files load properly (run `module use` and `module load` commands interactively to check for errors).
  - Check if the job scheduler requires specific flags for GPU usage or memory.  
- If you do not have permission to create directories in `/tmp` on compute nodes or prefer a different location, change the references to `/tmp` in the script to another suitable directory.  
- If your system does not support the same CPU binding or GPU mask environment variables, remove or adjust the lines accordingly.

## 7. References

- **oneCCL GitHub**:  
  [https://github.com/uxlfoundation/oneCCL](https://github.com/uxlfoundation/oneCCL)  
  Refer to official documentation for detailed build and usage instructions.
- **MPI Implementations**:  
  - [MPICH](https://github.com/pmodels/mpich)  
  - [Intel MPI](https://www.intel.com/content/www/us/en/developer/tools/oneapi/mpi-library.html)  
  - [MVAPICH2](https://mvapich.cse.ohio-state.edu/)  
- **ClusterShell**:  
  [https://github.com/cea-hpc/clustershell](https://github.com/cea-hpc/clustershell)

---
