
/*
 *  This file will contain a couple of functions to be used with 3x3 matrices
 */

template<typename T>
__host__ __device__
T determinant(T (&matrix)[9]){
    // calculates determinant
    T temp = 0;
    temp =       matrix[0]*(matrix[4]*matrix[8]-matrix[7]*matrix[5]);
    temp = temp- matrix[3]*(matrix[1]*matrix[8]-matrix[7]*matrix[2]);
    temp = temp+ matrix[6]*(matrix[1]*matrix[5]-matrix[4]*matrix[2]);     
    return temp; 
}

template<typename T>
__host__ __device__
void invert_matrix(T (&inverted)[9], T (&matrix)[9]) {
    // matrix,    pointer to 3x3 matrix which needs to be inverted
    // inverted,  pointer to 3x3 matrix which will store the result
    T det;
    det = determinant(matrix);
    inverted[0] =  (matrix[4]*matrix[8]-matrix[7]*matrix[5])/det;
    inverted[1] = -(matrix[1]*matrix[8]-matrix[7]*matrix[2])/det;
    inverted[2] =  (matrix[1]*matrix[5]-matrix[4]*matrix[2])/det;          
    inverted[3] = -(matrix[3]*matrix[8]-matrix[6]*matrix[5])/det;
    inverted[4] =  (matrix[0]*matrix[8]-matrix[6]*matrix[2])/det;
    inverted[5] = -(matrix[0]*matrix[5]-matrix[3]*matrix[2])/det;
    inverted[6] =  (matrix[3]*matrix[7]-matrix[6]*matrix[4])/det;
    inverted[7] = -(matrix[0]*matrix[7]-matrix[6]*matrix[1])/det;
    inverted[8] =  (matrix[0]*matrix[4]-matrix[3]*matrix[1])/det;
}

template<typename T, int sz, int s>
__host__ __device__
void multiply_matrix(T (&output)[s*s], const T (&a)[sz], const T (&b)[sz]) {
    // calculates matrix product of two square matrices
    // out=A*B
    for (int i=0; i<s*s; i++) {
        output[i] = 0;
    }
    for (int i=0; i<s; i++) {
        for (int j=0; j<s; j++) {
            for (int k=0; k<s; k++) {
                output[i*s+j] += a[i*s+k] * b[k*s+j];
            }
        }
    }
}


// output = Ax
template<typename T, int s>
__host__ __device__
void multiply_matrix_vector(T (&output)[s], const T (&A)[s*s], const T (&x)[s]) {
    // calculates matrix vector product, out = Ax 
    for (int i=0; i<s; i++) {
        output[i] = 0;
    }
    for (int i=0; i<s; i++) {
        for (int j=0; j<s; j++) {
            output[i] += A[i*s+j]*x[j]; 
        }
    }
}


template<typename T, int sz, int s>
__host__ __device__
void transpose_matrix(T (&output)[s*s], const T (&A)[sz]) {
    for (int i=0; i<s; i++) {
        for (int j=0; j<s; j++) {
            output[j*s+i] = A[i*s+j];
        }
    }
}

template<typename T, int s>
__host__ __device__
void zero_matrix(T (&output)[s]) {
    for (int i=0; i<s; i++) {
        output[i] = 0;
    }
}


template<typename T, int s>
__host__ __device__
void dot_product(T &output, const T (&a)[s], const T (&b)[s]) {
    // calculates dot product of two vectors (a and b) of length s
    output = 0;
    for (int i=0; i<s; i++) {
        output += a[i] * b[i];
    }
}


template<typename T, int s>
__host__ __device__
void add_matrix(T (&output)[s], const T (&a)[s], const T (&b)[s]) {
    // add two square matrices
    for (int i=0; i<s; i++) {
        output[i] = a[i] + b[i];
    } 
}

template <typename T>
__host__ __device__
void load_matrix(T (&p2)[9], const T *p1, int i){
    /* load all points from the ii th matrix of p1 3x3xN, into p2*/
       p2[0] = p1[i*9];
       p2[1] = p1[1+i*9];
       p2[2] = p1[2+i*9];
       p2[3] = p1[3+i*9];
       p2[4] = p1[4+i*9];
       p2[5] = p1[5+i*9];
       p2[6] = p1[6+i*9];
       p2[7] = p1[7+i*9];
       p2[8] = p1[8+i*9];
}


