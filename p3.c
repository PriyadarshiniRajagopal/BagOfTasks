#include<stdlib.h>
#include<stdio.h>
#include<math.h>
#include"task.h"
//TODO: malloc everything- make sure there aren't any garbage values in the structure at any point
int T;
int M;
int sort;

extern void caller();//does all the cuda functions before making the kernel call
//int global_taskId=0;

int main(int argc, char *argv[])
{

if(argc<4)
   {
     printf("Very few parameters\n");
     exit(0);
   }
T=atoi(argv[2]);
M=atoi(argv[1]);
sort=atoi(argv[3]);	
caller();
return 0;
}

