/*
 ============================================================================
 Name        : structoverflow.cu
 Author      : 
 Version     :
 Copyright   : Your copyright notice
 Description : CUDA compute reciprocals
 ============================================================================
 */
#include <stdio.h>
#include <iostream>
#include <numeric>
#include <stdlib.h>
using namespace std;
#define BUF_LEN 6
static void CheckCudaErrorAux (const char *, unsigned, const char *, cudaError_t);
#define CUDA_CHECK_RETURN(value) CheckCudaErrorAux(__FILE__,__LINE__, #value, value)
__device__ __noinline__ void normal()
{
	printf("normal!\n");
}
__device__ __noinline__ void secret()
{
	 printf("Hello Admin!\n");
}


struct unsafe
{
	unsigned long buf[BUF_LEN];
    void (*normal)();
};
__device__ __noinline__ void init(struct unsafe *data)
{
 data->normal=normal;
}
__global__ void test_kernel(unsigned long *input,int len,int admin)
{
	struct unsafe cu;
	init(&cu);
	for(int i=0;i<len;i++)
			cu.buf[i]=input[i];
	cu.normal();
	secret();
printf("%p",secret);

}
int main(void)
{
	unsigned long input[10];
	unsigned long *dev_input;
	int len=6;
	int admin=0;
	for(int i=0;i<10;i++)
	{
		input[i]=0xb2140;//this is secret（） address
	}
	CUDA_CHECK_RETURN(cudaMalloc((void**)&dev_input,10*sizeof(unsigned long)));
	CUDA_CHECK_RETURN(cudaMemcpy(dev_input,input,10*sizeof(unsigned long),cudaMemcpyHostToDevice));
	test_kernel<<<1,1>>>(dev_input,len,admin);
	cudaFree(dev_input);
	return 0;
}

/**
 * Check the return value of the CUDA runtime API call and exit
 * the application if the call has failed.
 */
static void CheckCudaErrorAux (const char *file, unsigned line, const char *statement, cudaError_t err)
{
	if (err == cudaSuccess)
		return;
	std::cerr << statement<<" returned " << cudaGetErrorString(err) << "("<<err<< ") at "<<file<<":"<<line << std::endl;
	exit (1);
}

