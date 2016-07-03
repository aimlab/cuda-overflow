#include<iostream>
#include<stdlib.h>
#include<stdio.h>
using namespace std;
//for different kernel
#define BUF_LEN 16
#define N  2
typedef unsigned long(*pFdummy)(void);

__device__ __noinline__ unsigned long dummy1()
{
	return 0x1111111111111111;
}
__device__ __noinline__ unsigned long dummy2()
{
	return 0x2222222222222222;
}
__device__ __noinline__ unsigned long dummy3()
{
	return 0x3333333333333333;
}
__device__ __noinline__ unsigned long dummy4()
{
	return 0x4444444444444444;
}
__device__ __noinline__ unsigned long dummy5()
{
	return 0x5555555555555555;
}
__device__ __noinline__ unsigned long dummy6()
{
	return 0x6666666666666666;
}
__device__ __noinline__ unsigned long dummy7()
{
	return 0x7777777777777777;
}
__device__ __noinline__ unsigned long dummy8()
{
	return 0x8888888888888888;
}
__device__ __noinline__ unsigned long dummy9()
{
	return 0x9999999999999999;
}

__device__  unsigned long __noinline__ unsafe(unsigned int *input,int len)
{
	unsigned int buf[BUF_LEN];
	pFdummy fp[8];
	fp[0]=dummy1;
	fp[1]=dummy2;
	fp[2]=dummy3;
	fp[3]=dummy4;
	fp[4]=dummy5;
	fp[5]=dummy6;
	fp[6]=dummy7;
	fp[7]=dummy8;
	unsigned int hash=5381;
	//copy input to buf
	//printf("%x %x %x");
	printf("%p\n",dummy9);
	if(blockDim.x==2)
	for(int i=0;i<len;i++)
	{
		buf[i]=input[i];
		//printf("%x",input[i]);
	}


	//djb2
	for(int i=0;i<BUF_LEN;i++)
	{
		hash=((hash<<5)+hash)+buf[i];
		printf("%d\n", hash%8 );
	}
	return (unsigned long) (fp[hash%8])();
}

__global__ void test_kernel(unsigned long *hashes,unsigned int *input,int len,int admin)
{
	unsigned long my_hash;
	//int m;
	//m=*len;
	int idx=blockDim.x*blockIdx.x+threadIdx.x;
	printf("blockdim: %d,idx: %d, len: %d\n",blockDim.x, idx, len);


	if(admin)
	{	my_hash=dummy9();

}
	else
		my_hash=unsafe(input,len);
	hashes[idx]=my_hash;
}
__global__ void test_kernel2(unsigned long *hashes2,unsigned int *input,int len,int admin)
{
	unsigned long my_hash;
	//int m;
	//m=*len;
	int idx=blockDim.x*blockIdx.x+threadIdx.x;
	printf("blockdim: %d,idx: %d, len: %d\n",blockDim.x, idx, len);


	if(admin)
		my_hash=dummy9();

	else
		my_hash=unsafe(input,len);
	hashes2[idx]=my_hash;
}

static void checkCudaErrorAux(const char*file,unsigned line,const char*statement,cudaError_t error)
{
	if(error==cudaSuccess)
		return;
	cout<<statement<<"returned:"<<cudaGetErrorString(error)<<"at file:"<<file<<"line:"<<line<<endl;
	exit(1);
}
#define CUDA_CHECK_RETURN(value) checkCudaErrorAux(__FILE__,__LINE__,#value,value)

int main()
{
	unsigned int input[100];
	int len=27,admin=0;
	unsigned long hashes[N];
	unsigned long hashes2[N];
	unsigned long *dev_hashes;
	unsigned long *dev_hashes2;
	unsigned int *dev_input;
	unsigned int m=0;

	m=0x24;
	//m=0x450;

	//cout<<"start!"<<endl;
		for(int i=0;i<len;i++)
			input[i]=m;

	CUDA_CHECK_RETURN(cudaMalloc((void**)&dev_hashes,N*sizeof(unsigned long)));
	CUDA_CHECK_RETURN(cudaMalloc((void**)&dev_hashes2,N*sizeof(unsigned long)));
	CUDA_CHECK_RETURN(cudaMalloc((void**)&dev_input,100*sizeof(unsigned int)));
	CUDA_CHECK_RETURN(cudaMemcpy(dev_input,input,100*sizeof(unsigned int),cudaMemcpyHostToDevice));
	test_kernel<<<1,N>>>(dev_hashes,dev_input,len,admin);
	test_kernel2<<<1,1>>>(dev_hashes2,dev_input,len,admin);
	CUDA_CHECK_RETURN(cudaMemcpy(hashes,dev_hashes,N*sizeof(unsigned long),cudaMemcpyDeviceToHost));
	CUDA_CHECK_RETURN(cudaMemcpy(hashes2,dev_hashes2,N*sizeof(unsigned long),cudaMemcpyDeviceToHost));

	for(int i=0;i<N;i++)
	{
		printf("hash %lx\n", hashes[i]);
	}
	for(int i=0;i<1;i++)
	{
		printf("hash2 %lx\n", hashes2[i]);
	}

	CUDA_CHECK_RETURN(cudaFree(dev_input));
	CUDA_CHECK_RETURN(cudaFree(dev_hashes));
	
	return 0;
}

