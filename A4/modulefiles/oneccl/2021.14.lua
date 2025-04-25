-- -*- lua -*-
help([[
Intel® oneAPI Collective Communications Library (oneCCL)

This module sets the environment for oneCCL using a fixed installation root:
  /tmp/local/oneccl/oneccl-2021.14

The following environment variables and paths are configured:
  - CCL_ROOT           : oneCCL installation root.
  - CPATH              : oneCCL header directory.
  - INCLUDE            : oneCCL header directory.
  - C_INCLUDE_PATH     : oneCCL header directory.
  - CPLUS_INCLUDE_PATH : oneCCL header directory.
  - LD_LIBRARY_PATH    : oneCCL library directory.
  - LIBRARY_PATH       : oneCCL linker search path.
  - CMAKE_PREFIX_PATH  : oneCCL CMake configuration directory.
]])

whatis("Name: oneCCL (no MPI)")
whatis("Version: 2021.14")
whatis("Category: Library")
whatis("Description: Intel® oneAPI Collective Communications Library")

-- Fixed oneCCL installation root.
local root = "/tmp/local/oneccl/oneccl-2021.14"

-- Set the oneCCL installation root.
setenv("CCL_ROOT", root)

-- Prepend oneCCL paths.
prepend_path("CPATH",               pathJoin(root, "include"))
prepend_path("INCLUDE",             pathJoin(root, "include"))
prepend_path("C_INCLUDE_PATH",      pathJoin(root, "include"))
prepend_path("CPLUS_INCLUDE_PATH",  pathJoin(root, "include"))

prepend_path("LD_LIBRARY_PATH",     pathJoin(root, "lib"))
prepend_path("LIBRARY_PATH",        pathJoin(root, "lib"))
prepend_path("CMAKE_PREFIX_PATH",   pathJoin(root, "lib", "cmake", "oneCCL"))
