#include <math.h>

//definition
#include "expdist_ref.h"
#include "expdist_ref.cu"



//use openmp just for measuring time
#include <omp.h>


//extern C interface
extern "C" {

float call_expdist(double *cost, const double *A, const double *B, int m, int n, int dim, const double *scale_A, const double *scale_B) {
    *cost = expdist(A, B, m, n, dim, scale_A, scale_B);
    return 0.0;
}


float time_expdist(double *cost, const double *A, const double *B, int m, int n, int dim, const double *scale_A, const double *scale_B) {
    double start = omp_get_wtime();
    *cost = expdist(A, B, m, n, dim, scale_A, scale_B);
    return (float)((omp_get_wtime() - start)*1e3);
}






float call_expdist3D_double(double *cost, const double *A, const double *B, int m, int n, int dim, const double *scale_A, const double *scale_B) {
    *cost = expdist3D(A, B, m, n, scale_A, scale_B);
    return 0.0;
}


float call_rotate_scales_double(double *rotated_scales, const double *rotation_matrix, const int n, const double *scale_B) {
    rotate_scales(rotated_scales, rotation_matrix, n, scale_B);
    return 0.0;
}


float time_expdist3D_double(double *cost, const double *A, const double *B, int m, int n, int dim, const double *scale_A, const double *scale_B) {
    double start = omp_get_wtime();
    *cost = expdist3D(A, B, m, n, scale_A, scale_B);
    return (float)((omp_get_wtime() - start)*1e3);
}


float call_expdist3D_float(float *cost, const float *A, const float *B, int m, int n, int dim, const float *scale_A, const float *scale_B) {
    *cost = expdist3D(A, B, m, n, scale_A, scale_B);
    return 0.0;
}


float time_expdist3D_float(float *cost, const float *A, const float *B, int m, int n, int dim, const float *scale_A, const float *scale_B) {
    double start = omp_get_wtime();
    *cost = expdist3D(A, B, m, n, scale_A, scale_B);
    return (float)((omp_get_wtime() - start)*1e3);
}


}

