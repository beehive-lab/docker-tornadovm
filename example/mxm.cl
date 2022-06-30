#pragma OPENCL EXTENSION cl_khr_fp64 : enable  
__attribute__((reqd_work_group_size(64, 1, 1)))
__kernel void matrixMultiplication(__global long *_kernel_context, __constant uchar *_constant_region, __local uchar *_local_region, __global int *_atomics, __global uchar *A, __global uchar *B, __global uchar *C, __private int size)
{
  ulong ul_21, ul_2, ul_1, ul_0, ul_14, ul_29; 
  int i_17, i_16, i_9, i_10, i_7, i_5, i_6, i_3, i_4, i_33, i_31, i_32, i_30, i_25, i_24; 
  long l_26, l_11, l_27, l_20, l_18, l_19, l_12, l_28, l_13; 
  float f_8, f_23, f_22, f_15; 

  // BLOCK 0
  ul_0  =  (ulong) A;
  ul_1  =  (ulong) B;
  ul_2  =  (ulong) C;
  i_3  =  get_global_id(1);
  // BLOCK 1 MERGES [0 8 ]
  i_4  =  i_3;
  // BLOCK 2
  i_5  =  get_global_id(0);
  // BLOCK 3 MERGES [2 7 ]
  i_6  =  i_5;
  #pragma unroll 4
  for(;i_6 < 256;)
  {
    // BLOCK 4
    i_7  =  i_4 << 8;
    // BLOCK 5 MERGES [4 6 ]
    f_8  =  0.0F;
    i_9  =  0;
    for(;i_9 < 256;)
    {
      // BLOCK 6
      i_10  =  i_7 + i_9;
      l_11  =  (long) i_10;
      l_12  =  l_11 << 2;
      l_13  =  l_12 + 24L;
      ul_14  =  ul_0 + l_13;
      f_15  =  *((__global float *) ul_14);
      i_16  =  i_9 << 8;
      i_17  =  i_16 + i_6;
      l_18  =  (long) i_17;
      l_19  =  l_18 << 2;
      l_20  =  l_19 + 24L;
      ul_21  =  ul_1 + l_20;
      f_22  =  *((__global float *) ul_21);
      f_23  =  fma(f_15, f_22, f_8);
      i_24  =  i_9 + 1;
      f_8  =  f_23;
      i_9  =  i_24;
    }  // B6
    // BLOCK 7
    i_25  =  i_6 + i_7;
    l_26  =  (long) i_25;
    l_27  =  l_26 << 2;
    l_28  =  l_27 + 24L;
    ul_29  =  ul_2 + l_28;
    *((__global float *) ul_29)  =  f_8;
    i_30  =  get_global_size(0);
    i_31  =  i_30 + i_6;
    i_6  =  i_31;
  }  // B7
  // BLOCK 8
  i_32  =  get_global_size(1);
  i_33  =  i_32 + i_4;
  i_4  =  i_33;
  // BLOCK 9
  return;
}  //  kernel

