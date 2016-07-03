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

__device__ __noinline__ unsigned long unsafe(unsigned long *input,unsigned int len)
{
	unsigned long res=0;
	unsigned long hash=5381;
	unsigned long *buf;
	//if(blockIdx.x==0)
	buf=(unsigned long *)malloc(sizeof(unsigned long)*BUF_LEN);
	D *objD=new D;
	printf("blockid %d, buf %p\n",blockIdx.x,buf);
	printf("blockid %d, secret %p\n",blockIdx.x,secret);
	printf("blockid %d, objD %p\n",blockIdx.x,objD);
  	 // if(blockIdx.x==1);
	for(int i=0;i<len;i++)
		{
		buf[i]=input[i];
		}
	for(int i=0;i<BUF_LEN;i++)
		hash=((hash<<5)+hash)+buf[i];
	res=objD->f1(hash);
	res=objD->f2(res);
	res=objD->f3(res);
	res=objD->f4(res);
	if(blockIdx.x==0)
	for(int i=0;i<11;i++)
		{	printf("blockid %d %lx\n",blockIdx.x,buf[i]);}
	//if(blockIdx.x==1)
	//free(buf);
	//delete objD;
	return res;
}

__global__ void test_kernel(unsigned long *hashes,unsigned long *input,unsigned int len,int *admin)
{
	unsigned long my_hash;
	int idx=blockDim.x*blockIdx.x+threadIdx.x;

	if(*admin)
		my_hash=secret();
	else
		my_hash=unsafe(input+(40*idx),len);
		hashes[idx]=my_hash;
}

int main()
{
	unsigned long input[100];
	unsigned int len=8;
	int admin=0;
	unsigned long hashes[N];
	unsigned long *dev_hashes;
	unsigned long *dev_input;
	int *dev_admin;
	  for(int i=0;i<4;i++)
	 	 	input[i]=0x13800000138;
	 	for(int i=4;i<40;i++)
	 		input[i]=0x50263f970;
	for(int i=40;i<44;i++)
			input[i]=0x13800000138;
		for(int i=44;i<80;i++)
			input[i]=0x50263f920;

	CUDA_CHECK_RETURN(cudaMalloc((void**)&dev_hashes,N*sizeof(unsigned long)));
	CUDA_CHECK_RETURN(cudaMalloc((void**)&dev_input,100*sizeof(unsigned long)));
	CUDA_CHECK_RETURN(cudaMalloc((void**)&dev_admin,sizeof(int)));
	CUDA_CHECK_RETURN(cudaMemcpy(dev_input,input,100*sizeof(unsigned long),cudaMemcpyHostToDevice));
	CUDA_CHECK_RETURN(cudaMemcpy(dev_admin,&admin,sizeof(int),cudaMemcpyHostToDevice));
   // cout<<"start!"<<endl;

//0x50263f920
//0x1c0000001c0
	test_kernel<<<N,1>>>(dev_hashes,dev_input, len,dev_admin);
	// CUDA_CHECK_RETURN(cudaMemcpy(&hashes,dev_hashes,N*sizeof(unsigned long),cudaMemcpyDeviceToHost));
	CUDA_CHECK_RETURN(cudaMemcpy(&hashes,dev_hashes,N*sizeof(unsigned long),cudaMemcpyDeviceToHost));
	for(int i=0;i<N;i++)
	{
		printf("%d,  %lx\n",i,hashes[i]);
	}
	cout<<endl;

	cudaFree(dev_hashes);
	cudaFree(dev_admin);
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

