#include <stdio.h>

/*
    expdist   Computes the bhattacharya cost function for two given point set

    SYNOPSIS:
    D = expdist(A, B, m, n, dim, scale_A, scale_B);

    INPUT
        A
            The first particle containing the list of coordinates
        B
            The second particle containing the list of coordinates
        m
            Size of the particle A
        n
            Size of the particle B
        dim
            particles dimension (2D or 3D) 
        scale_A
            uncertainties of particle A 
        scale_B
            uncertainties of particle B 

    OUTPUT
        result
            The distance between particle A and B

    (C) Copyright 2017              Quantitative Imaging Group
        All rights reserved         Faculty of Applied Physics
                                    Delft University of Technology
                                    Lorentzweg 1
                                    2628 CJ Delft
                                    The Netherlands
    Hamidreza Heydarian and Ben van Werkhoven, Feb 2017
*/
#define SQR(X)  ((X)*(X))

#include <math.h>
/* #include <stdio.h> */


#include "expdist_functions.cu"





#ifdef WIN32
__declspec( dllexport )
#endif
double expdist(const double *A, const double *B, int m, int n, int dim, const double *scale_A, const double *scale_B)
{
    int i,j,d;
    int id, jd;
    double dist_ij, cross_term = 0;

    for (i=0;i<m;++i)
    {
        for (j=0;j<n;++j)
        {
            dist_ij = 0;
            for (d=0;d<dim;++d)
            {
                id = i + d * m;
                jd = j + d * n;
                dist_ij = dist_ij + SQR( A[id] - B[jd]);
            }
            cross_term += exp(-dist_ij/(scale_A[i] + scale_B[j]));
        }
    }

    return cross_term;
}




/*
 * The following function is a full 3D implementation of the Bhattacharya distance
 * scale_A is an array with 2 values per localization
 * scale_B contains the pre-rotated matrix of uncertainties for B
 */
template <typename T>
T expdist3D(const T *A, const T *B, const int m, const int n, const T *scale_A, const T *scale_B) {
    int i,j;
    T cross_term = 0.0;
    const int dim = 3;

    T pA[dim];
    T pB[dim];

    for (i=0; i<m; i++) {

        //prefetch point Ai
        for (int d=0; d<dim; d++) {
            int id = i + d * m;
            pA[d] = A[id];
        }

        //assume sigma in x and y are equal and scale_A only stores 2 values per localization
        T Sigma_i[9];
        zero_matrix(Sigma_i);
        Sigma_i[0] = scale_A[i*2+0];   // 0 1 2
        Sigma_i[4] = scale_A[i*2+0];   // 3 4 5
        Sigma_i[8] = scale_A[i*2+1];   // 6 7 8

        for (j=0; j<n; j++) {

            //prefetch point Bj
            for (int d=0; d<dim; d++) {
                int jd = j + d * n;
                pB[d] = B[jd];
            }

            //assume sigma_j has been rotated properly beforehand so that it can be used directly
            T Sigma_j[9];
            load_matrix(Sigma_j, scale_B, j);

            cross_term += compute_expdist_3D<T, 3>(pA, pB, Sigma_i, Sigma_j);
        }
    }

    return cross_term;
}


/*
 * This function rotates the uncertainties for the 3D bhattacharya distance
 *
 * It is assumed that the scale_B array contains 2 uncertainty values per localization in
 * the particle. One value for the uncertainty in X and Y and one for the uncertainty in Z (depth).
 *
 * The output array rotated_scales contains a 3x3 matrix for each localization.
 */
template <typename T>
void rotate_scales(T *rotated_scales, const T *rotation_matrix, const int n, const T *scale_B) {

    T transposed_rotation_matrix[9];
    transpose_matrix<T, 9, 3>(transposed_rotation_matrix, reinterpret_cast<const T(&)[9]>(*rotation_matrix));

    for (int i=0; i<n; i++) {

        rotate_scale(rotated_scales, rotation_matrix, transposed_rotation_matrix, i, scale_B);
    }

}

/*
 * This function rotates the coordinates of the localizations in the B particle for the 3D bhattacharya distance
 *
 * The output array rotated_B contains the x,y,z coordinates of each localization.
 */
template <typename T>
void rotate_B(T *rotated_B, const T *rotation_matrix, const int n, const T *B) {

    for (int i=0; i<n; i++) {
        rotate_B_point(rotated_B, rotation_matrix, i, B);
    }

}




template double expdist3D<double>(const double *A, const double *B, const int m, const int n, const double *scale_A, const double *scale_B);

template void rotate_scales<double>(double *rotated_scales, const double *rotation_matrix, const int n, const double *scale_B);
template void rotate_B<double>(double *rotated_B, const double *rotation_matrix, const int n, const double *B);





