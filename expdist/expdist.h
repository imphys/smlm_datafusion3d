#pragma once

#include <stdint.h>
#include <cuda_runtime.h>

class GPUExpDist {
    public:
        GPUExpDist(int max_n, int argdim);
        ~GPUExpDist();
        double compute(const double *A, const double *B, int m, int n, const double *scale_A, const double *scale_B);
        double compute(const double *A, const double *B, int m, int n, const double *scale_A, const double *scale_B, const double *rotation_matrix);
        int dim;
        int max_n;
        int scale_A_dim;
        int scale_B_dim;
    private:
        double *d_A;
        double *d_B;
        double *d_scale_A;
        double *d_scale_B;
        double *d_scale_B_temp;
        double *d_cross_term;

        cudaEvent_t event;
        cudaStream_t stream;
        cudaStream_t stream_b;
};


