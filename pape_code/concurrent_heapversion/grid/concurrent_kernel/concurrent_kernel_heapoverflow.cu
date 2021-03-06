#include <stdio.h>
#include <iostream>
#include <numeric>
#include <stdlib.h>
using namespace std;
static void CheckCudaErrorAux (const char *, unsigned, const char *, cudaError_t);
#define CUDA_CHECK_RETURN(value) CheckCudaErrorAux(__FILE__,__LINE__, #value, value)

#define BUF_LEN 8
#define N 2
class B
{
public:
	__device__ virtual unsigned long f1(unsigned int hash)
	{return 0;}
	__device__ virtual unsigned long f2(unsigned int hash)
		{return 0;}
	__device__ virtual unsigned long f3(unsigned int hash)
		{return 0;}
	__device__ virtual unsigned long f4(unsigned int hash)
		{return 0;}
};

class D:public B
{
public:
	__device__ __noinline__ unsigned long f1(unsigned int hash);
	__device__ __noinline__ unsigned long f2(unsigned int hash);
	__device__ __noinline__ unsigned long f3(unsigned int hash);
	__device__ __noinline__ unsigned long f4(unsigned int hash);
};

__device__ __noinline__ unsigned long D::f1(unsigned int hash)
{return hash;}
__device__ __noinline__ unsigned long D::f2(unsigned int hash)
{return 2*hash;}
__device__ __noinline__ unsigned long D::f3(unsigned int hash)
{return 3*hash;}
__device__ __noinline__ unsigned long D::f4(unsigned int hash)
{return 4*hash;}

__device__ __noinline__ unsigned long secret()
{
	 printf("Hello Admin!\n");
	return 0x9999999999999999;
}
__device__ void sleep(int64_t num_cycles)
{
    int64_t cycles = 0;
    int64_t start = clock64();
    while(cycles < num_cycles) {
        cycles = clock64() - start;
    }
}
__device__ __noinline__ unsigned long unsafe(unsigned long *input,unsigned int len)
{
	
	unsigned long res=0;
	unsigned long hash=5381;
	unsigned long *buf;
	
	buf=(unsigned long *)malloc(sizeof(unsigned long)*BUF_LEN);
	D *objD=new D;
if(blockDim.x==2)
	sleep(1000000);
	printf("blockdim %d,thread %d,buf %p\n",blockDim.x,threadIdx.x,buf);
	printf("blockdim %d,thread %d,secret %p\n",blockDim.x,threadIdx.x,secret);
	printf("blockdim %d,thread %d,objD %p\n",blockDim.x,threadIdx.x,objD);
  
	if(blockDim.x==2&&threadIdx.x==0)
	for(int i=0;i<len;i++)
		{
		buf[i]=input[i];
		}
	if(blockDim.x==1)
	sleep(10000000);
	for(int i=0;i<BUF_LEN;i++)
		hash=((hash<<5)+hash)+buf[i];
	res=objD->f1(hash);
	res=objD->f2(res);
	res=objD->f3(res);
	res=objD->f4(res);
	if(blockDim.x==1)
	for(int i=0;i<11;i++)
		{	printf("blockdim %d %lx\n",threadIdx.x,buf[i]);}


	return res;
}

__global__ void test_kernel(unsigned long *hashes,unsigned long *input,unsigned int len,int admin)
{
	unsigned long my_hash;
	int idx=blockDim.x*blockIdx.x+threadIdx.x;

	if(admin)
		my_hash=secret();
	else
		my_hash=unsafe(input,len);
		hashes[idx]=my_hash;
}
__global__ void test_kernel2(unsigned long *hashes2,unsigned long *input,unsigned int len,int admin)
{
	unsigned long my_hash;
	int idx=blockDim.x*blockIdx.x+threadIdx.x;

	if(admin)
		my_hash=secret();
	else
		my_hash=unsafe(input,len);
		hashes2[idx]=my_hash;
}

int main()
{
	unsigned long *input;
	unsigned long *input2;
	unsigned int len=71;
	int admin=0;
	unsigned long hashes[N];
	unsigned long hashes2[N];
	unsigned long *dev_hashes;
	unsigned long *dev_hashes2;
	unsigned long *dev_input;
	unsigned long *dev_input2;
	cudaStream_t stream1, stream2;
	cudaStreamCreate(&stream1);
	 cudaStreamCreate(&stream2);
	cudaMallocHost( &input, 100*sizeof(unsigned long) ) ;
	cudaMallocHost( &input2, 100*sizeof(unsigned long) ) ;
	  for(int i=0;i<4;i++)
	 	 	input[i]=0x14;
	 	for(int i=4;i<80;i++)
	 		input[i]=0x50263f920;
	for(int i=0;i<4;i++)
			input2[i]=0x14;
		for(int i=4;i<40;i++)
			input2[i]=0x51111110;

	CUDA_CHECK_RETURN(cudaMalloc((void**)&dev_hashes,N*sizeof(unsigned long)));
	CUDA_CHECK_RETURN(cudaMalloc((void**)&dev_hashes2,N*sizeof(unsigned long)));
	CUDA_CHECK_RETURN(cudaMalloc((void**)&dev_input,100*sizeof(unsigned long)));
	CUDA_CHECK_RETURN(cudaMalloc((void**)&dev_input2,100*sizeof(unsigned long)));
	CUDA_CHECK_RETURN(cudaMemcpyAsync(dev_input,input,100*sizeof(unsigned long),cudaMemcpyHostToDevice,stream1));
	CUDA_CHECK_RETURN(cudaMemcpyAsync(dev_input2,input2,100*sizeof(unsigned long),cudaMemcpyHostToDevice,stream2));
   // cout<<"start!"<<endl;

//0x50263f920
//0x1c0000001c0
	test_kernel<<<1,N,0,stream1>>>(dev_hashes,dev_input, len,admin);
	test_kernel2<<<1,1,0,stream2>>>(dev_hashes2,dev_input2, len,admin);
	// CUDA_CHECK_RETURN(cudaMemcpy(&hashes,dev_hashes,N*sizeof(unsigned long),cudaMemcpyDeviceToHost));
	CUDA_CHECK_RETURN(cudaMemcpyAsync(&hashes,dev_hashes,N*sizeof(unsigned long),cudaMemcpyDeviceToHost,stream1));
	CUDA_CHECK_RETURN(cudaMemcpyAsync(&hashes2,dev_hashes2,N*sizeof(unsigned long),cudaMemcpyDeviceToHost,stream2));
	for(int i=0;i<N;i++)
	{
		printf("%d,  %lx\n",i,hashes[i]);
	}
	for(int i=0;i<N;i++)
	{
		printf("hash2 %d,  %lx\n",i,hashes2[i]);
	}
	cout<<endl;

	cudaFree(dev_hashes);
	cudaFree(dev_hashes2);
	//cudaFree(dev_admin);
	cudaFree(dev_input);
	//CUDA_CHECK_RETURN(cudaFree(dev_hashes));
	//CUDA_CHECK_RETURN(cudaFree(dev_admin));
	//CUDA_CHECK_RETURN(cudaFree(dev_len));
	//CUDA_CHECK_RETURN(cudaFree(dev_input));

	return 0;
}


static void CheckCudaErrorAux (const char *file, unsigned line, const char *statement, cudaError_t err)
{
	if (err == cudaSuccess)
		return;
	std::cerr << statement<<" returned " << cudaGetErrorString(err) << "("<<err<< ") at "<<file<<":"<<line << std::endl;
	exit (1);
}


