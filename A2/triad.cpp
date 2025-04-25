#include <algorithm>
#include <assert.h>
#include <chrono>
#include <fstream>
#include <functional>
#include <iostream>
#include <limits>
#include <mpi.h>
#include <omp.h>
#include <random>
#include <vector>

#ifndef ITER_MAX
#define ITER_MAX 5000
#endif

// Communicator for a Pair of rank
// Useful for measuring Bi-Socket BW, and 2 Tile-GPU
MPI_Comm MPI_SUB_COMM;
MPI_Comm MPI_SUB_COMM_GATHER;

/*
 * Benchmark Utilities
 */

void bench(unsigned long *min_time, std::string bench_type, int globalWI, double *Aptr,
           double *Bptr, double *Cptr) {

  MPI_Barrier(MPI_SUB_COMM);

  // Save start and end
  const unsigned long l_start = std::chrono::duration_cast<std::chrono::nanoseconds>(
                                    std::chrono::high_resolution_clock::now().time_since_epoch())
                                    .count();

  if (bench_type == "cpu") {
#pragma omp parallel for
    for (int i = 0; i < globalWI; i++)
      Aptr[i] = 2.0 * Bptr[i] + Cptr[i];
  } else if (bench_type == "gpu") {
#pragma omp target teams distribute parallel for
    for (int i = 0; i < globalWI; i++)
      Aptr[i] = 2.0 * Bptr[i] + Cptr[i];
  }

  const unsigned long l_end = std::chrono::duration_cast<std::chrono::nanoseconds>(
                                  std::chrono::high_resolution_clock::now().time_since_epoch())
                                  .count();

  unsigned long start, end;
  MPI_Allreduce(&l_start, &start, 1, MPI_UNSIGNED_LONG, MPI_MIN, MPI_SUB_COMM);
  MPI_Allreduce(&l_end, &end, 1, MPI_UNSIGNED_LONG, MPI_MAX, MPI_SUB_COMM);

  unsigned long time = end - start;
  if (time <= *min_time) {
    *min_time = time;
  }
}

bool almost_equal(double x, double y, int ulp) {
  return std::abs(x - y) <= std::numeric_limits<double>::epsilon() * std::abs(x + y) * ulp ||
         std::abs(x - y) < std::numeric_limits<double>::min();
}

template <typename T1, typename T2> typename T1::value_type quant(const T1 &x, T2 q) {
  assert(q >= 0.0 && q <= 1.0);

  const auto n = x.size();
  const auto id = (n - 1) * q;
  const auto lo = floor(id);
  const auto hi = ceil(id);
  const auto qs = x[lo];
  const auto h = (id - lo);

  return (1.0 - h) * qs + h * x[hi];
}

int run(int globalWI, std::string name, std::string bench_type) {

  std::vector<double> A(globalWI), B(globalWI), C(globalWI);
  std::srand(0);
  std::generate(B.begin(), B.end(), std::rand);
  std::generate(C.begin(), C.end(), std::rand);
  double *Aptr{A.data()};
  double *Bptr{B.data()};
  double *Cptr{C.data()};

  unsigned long min_time = std::numeric_limits<unsigned long>::max();
  int errors = 0;

  if (bench_type == "gpu") {
#pragma omp target enter data map(alloc : Aptr[ : globalWI])                                       \
    map(to : Bptr[ : globalWI], Cptr[ : globalWI])
  }

  for (int iter = 0; iter < ITER_MAX; iter++) {
    bench(&min_time, bench_type, globalWI, Aptr, Bptr, Cptr);
  }
  if (bench_type == "gpu") {
#pragma omp target exit data map(from : Aptr[ : globalWI])
  }

  for (int i = 0; i < globalWI; i++) {
    assert(almost_equal(Aptr[i], 2.0 * Bptr[i] + Cptr[i], 10));
  }
  // Now do a gather
  int root_rank = 0;
  int world_rank;
  MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);

  if (world_rank == root_rank) {
    int gather_size;
    MPI_Comm_size(MPI_SUB_COMM_GATHER, &gather_size);

    std::vector<double> bw(gather_size);
    {
      std::vector<unsigned long> min_times(gather_size);
      MPI_Gather(&min_time, 1, MPI_UNSIGNED_LONG, min_times.data(), 1, MPI_UNSIGNED_LONG, root_rank,
                 MPI_SUB_COMM_GATHER);
      {
        int sub_size;
        MPI_Comm_size(MPI_SUB_COMM, &sub_size);
        std::transform(min_times.begin(), min_times.end(), bw.begin(), [&](unsigned long val) {
          return (3. * globalWI * sub_size * sizeof(double)) / val;
        });
      }
#ifdef SAVE
      {
        std::string filename = name + ".txt";
        std::ofstream fout(filename.c_str());
        for (auto const &x : bw)
          fout << x << '\n';
      }
#endif
      std::sort(bw.begin(), bw.end());
    }
    std::cout << "Result For " << name << " (sample size: " << gather_size << ")" << std::endl;
    std::cout << "-Min " << bw.front() << " GByte/s" << std::endl;
    std::cout << "-Q1 " << quant(bw, 0.25) << " GByte/s" << std::endl;
    std::cout << "-Q2(median) " << quant(bw, 0.50) << " GByte/s" << std::endl;
    std::cout << "-Q3 " << quant(bw, 0.75) << " GByte/s" << std::endl;
    std::cout << "-Max " << bw.back() << " GByte/s" << std::endl;

  } else if (MPI_SUB_COMM_GATHER != MPI_COMM_NULL) {
    MPI_Gather(&min_time, 1, MPI_UNSIGNED_LONG, NULL, 0, MPI_UNSIGNED_LONG, root_rank,
               MPI_SUB_COMM_GATHER);
  }

  int mpi_errors = 0;
  MPI_Reduce(&errors, &mpi_errors, 1, MPI_INT, MPI_SUM, 0, MPI_COMM_WORLD);
  return mpi_errors;
}

/*
 * Main
 */

int main(int argc, char **argv) {

  MPI_Init(NULL, NULL);

  int my_rank;
  MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);

  std::string bench_type{argv[1]};

  if (bench_type == "gpu") {
    // Best of two Tiles
    MPI_Comm_split(MPI_COMM_WORLD, my_rank / 2, 0, &MPI_SUB_COMM);

    int world_size;
    MPI_Comm_size(MPI_COMM_WORLD, &world_size);
    std::vector<int> ranks(world_size / 2);
    {
      int n = -2;
      std::generate(ranks.begin(), ranks.end(), [&n] { return n += 2; });
    }
    {
      MPI_Group world_group;
      MPI_Comm_group(MPI_COMM_WORLD, &world_group);
      MPI_Group new_group;
      MPI_Group_incl(world_group, ranks.size(), ranks.data(), &new_group);
      MPI_Comm_create(MPI_COMM_WORLD, new_group, &MPI_SUB_COMM_GATHER);
    }
  } else if (bench_type == "cpu") {
    MPI_Comm_split(MPI_COMM_WORLD, my_rank, 0, &MPI_SUB_COMM);
    MPI_SUB_COMM_GATHER = MPI_COMM_WORLD;
  }

  int errors = 0;
  if (bench_type == "cpu") {
    // = 128*2*10^6 Bytes (LL2+LL3) * 4 (STREAM factor) / 8 (doubles)
    errors += run(128'000'000, "stream", bench_type);
  } else if (bench_type == "gpu") {
    // = 204*10^6 Bytes (LLC) * 4 (STREAM factor) / 8 (doubles)
    errors += run(102'000'000, "stream", bench_type);
  }
  MPI_Finalize();
  return errors;
}
