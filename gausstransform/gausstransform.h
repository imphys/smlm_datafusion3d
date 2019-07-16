#pragma once

#ifdef WIN32
#define DLL_EXPORT __declspec(dllexport)
#else
#define DLL_EXPORT 
#endif

#include <stdint.h>
#include <cuda_runtime.h>

class GPUGaussTransform {
    public:
        DLL_EXPORT GPUGaussTransform(int max_n, int argdim);
        ~GPUGaussTransform();
        DLL_EXPORT double compute(const double *A, const double *B, int m, int n, double scale, double *grad);
        int dim;
        int max_n;
    private:
        double *d_A;
        double *d_B;
        double *d_grad;
        double *d_cross_term;

        cudaStream_t stream;
};


