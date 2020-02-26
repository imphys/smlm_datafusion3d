#include <cub/cub.cuh>
#include "kernels.cuh"

extern "C"
__global__ void
ExpDist(const double *A, const double *B,
                 int m, int n, const double *scale_A, const double *scale_B, double *cross_term) {

    //2-dimensional with double precision
    ExpDist_tiled<double, 2>(A, B, m, n, scale_A, scale_B, cross_term);

}

extern "C"
__global__ void
ExpDist3D(const double *A, const double *B,
                 int m, int n, const double *scale_A, const double *scale_B, double *cross_term) {

    //3-dimensional with double precision
    ExpDist3D_tiled<double, 3>(A, B, m, n, scale_A, scale_B, cross_term);

}

extern "C"
__global__ void
ExpDist_column(const double *A, const double *B,
                 int m, int n, const double *scale_A, const double *scale_B, double *cross_term) {

    //2-dimensional with double precision
    //ExpDist_tiled_column<double, 2>(A, B, m, n, scale_A, scale_B, cross_term);

}

extern "C"
__global__ void
ExpDist_column3D(const double *A, const double *B,
                 int m, int n, const double *scale_A, const double *scale_B, double *cross_term) {


    return;
}

/*
 * Reduce the per thread block cross terms computed in the GaussTransform kernel to single value
 *
 * This kernel is designed to run as single-thread block, because the number of terms to reduce is
 * of size n or m, which is expected to be around 2000 or so. The number of items to reduce
 * is passed as the last argument 'nblocks', which corresponds to the number of thread blocks used
 * by the first kernel.
 */
extern "C"
__global__ void reduce_cross_term(double *output, double *d_cross_term, int m, int n, int nblocks) {

    int tx = threadIdx.x;
    // Specialize BlockReduce for a 1D block of block_size threads on type double
    typedef cub::BlockReduce<double, block_size> BlockReduce;
    // Allocate shared memory for BlockReduce
    __shared__ typename BlockReduce::TempStorage temp_storage;

    double cross_term = 0.0;
    for (int i=tx; i<nblocks; i+=block_size) {
        cross_term += d_cross_term[i];
    }

    //reduce to single value within thread block
    cross_term = BlockReduce(temp_storage).Sum(cross_term);

    //thread 0 writes output
    if (tx == 0) {
        output[0] = cross_term;
    }

}


extern "C"
__global__ void rotate_scales_double(double *rotated_scales, const int n, const double *scale_B, double const * rotation_matrix, double const * rotation_matrix_transposed) {

    int x = blockIdx.x * block_size_x + threadIdx.x;

    if (x < n) {
        rotate_scale(rotated_scales, rotation_matrix, rotation_matrix_transposed, n, x, scale_B);
    }

}

extern "C"
__global__ void rotate_B_double(double *rotated_B, const int n, const double *B, double const * rotation_matrix) {

    int x = blockIdx.x * block_size_x + threadIdx.x;

    if (x < n) {
        rotate_B_point(rotated_B, rotation_matrix, x, B);
    }

}
