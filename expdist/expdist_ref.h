#pragma once

double expdist(const double *A, const double *B, int m, int n, int dim, const double *scale_A, const double *scale_B);


template <typename T>
T expdist3D(const T *A, const T *B, const int m, const int n, const T *scale_A, const T *scale_B);


template <typename T>
void rotate_scales(T *rotated_scales, const T *rotation_matrix, const int n, const T *scale_B);



template <typename T>
void rotate_B(T *rotated_B, const T *rotation_matrix, const int n, const T *B);


