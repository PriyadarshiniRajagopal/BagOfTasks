#include<stdio.h>
#include<math.h>
#include <cuda.h>
#include <stdlib.h>
#include"task.h"
#include<sys/time.h>
#include <unistd.h>

struct timeval total_start;
struct timeval total_end;
int large_tasks=0;
int small_tasks=0;
int medium_tasks=0;
long total_time;
int *done_d;
int *done=0;
int global_taskId=0;
extern int M;
extern int T;
extern int sort;
int ttasks ;
int NBLOCKS = 6;
int done_sm[6]={0};
int *done_sm_d;
int *tt_array;
long *time_array;
int numtask[6]={0};
__device__ int F=0 ;
int current_tasks = 0;
//int count[6][100000];
int done_array[6][100000];
int persm[6]={0};
__device__ int current_index[6]={0};

long calcDiffTime(struct timeval* strtTime, struct timeval* endTime)
{
    return(
        endTime->tv_sec*1000000 + endTime->tv_usec
        - strtTime->tv_sec*1000000 - strtTime->tv_usec
        );
  
}


typedef void* (*op_func_t) (void*);
//Small task to be executed

__device__ void* fs(void *a)
{
int i;
    //printf("Started executing a small task\n");
    for(i=99;i>0;i--);
   // printf("Finished executing a small task\n");
    return NULL;
}

//Medium task to be executed
__device__ void* fm(void *a)
{
    //printf("Started executing a medium task\n");
    int b,c,d;
    for(b=99999;b>0;b--)
       {
        for(c=99999;c>0;c--)
           {
            for(d=99999;d>0;d--);
           }
       }
    for(b=99999;b>0;b--)
       {
        for(c=99999;c>0;c--)
           {
            for(d=99999;d>0;d--);
           }
       }
    for(b=99999;b>0;b--)
       {
        for(c=99999;c>0;c--)
           {
            for(d=99999;d>0;d--);
           }
       }
    for(b=99999;b>0;b--)
       {
        for(c=99999;c>0;c--)
           {
            for(d=99999;d>0;d--);
           }
       }
    for(b=99999;b>0;b--)
       {
        for(c=99999;c>0;c--)
           {
            for(d=99999;d>0;d--);
           }
       }
    //printf("Finished executing a medium task\n");
    return NULL;
}

// large task that's going to be executed

__device__ void* fl(void *a)
{
    //printf("Started executing a large task\n");
    long int k;
    long int i;
    for(k=99999999999999999;k>0;k--)
       {
        i++;
       }
    for(k=99999999999999999;k>0;k--)
       {
        i++;
       }
    long long int p;
    long long int q;
    for(p=999999999999999;p>0;p--)
       {
        for(q=9999999999999999;q>0;q--)
           i++;
       }
    for(p=9999999999999999;p>0;p--)
       {
        for(q=9999999999999999;q>0;q--)
           i++;
       }
    for(p=999999999999999;p>0;p--)
       {
        for(q=9999999999999999;q>0;q--)
           i++;
       }
    for(p=999999999999999;p>0;p--)
       {
        for(q=9999999999999999;q>0;q--)
           i++;
       }
    for(p=999999999999999;p>0;p--)
       {
        for(q=9999999999999999;q>0;q--)
           i++;
       }
    //printf("Finished executing a large task\n");
    return NULL;
}

//Static pointers to device functions

__device__ op_func_t p_fl = fl;
__device__ op_func_t p_fm = fm;
__device__ op_func_t p_fs = fs;

op_func_t h_fl;
op_func_t h_fm;
op_func_t h_fs;

//Utility function that prints the final time of the program
void printTasks()
{
total_time = calcDiffTime(&total_start,&total_end);
   printf("total time taken  = %ld\n",total_time);


}

//Function to generate a random number within the range
int rand_range(int min_n, int max_n)
{
    return rand() % (max_n - min_n + 1) + min_n;
}

//Function to add tasks to sms randomly
void randomAdd(int total,int smid)
{
   int s,x,sm;int type;
   //srand(1);
   
   int mf,lf;mf=lf=0;
   for (s=0;s<total;s++)
      {
       if(smid == -1)
          sm = s%6;
       else
          sm = smid;
          if(lf<total/3)
             {
              lf++;
              large_tasks++;
              type=2;
             }
           else if(mf<total/3)
             {
              mf++;
              medium_tasks++; 
              type=1;
             }
           else
             {
              type=0;
              small_tasks++;
             }
          //type=rand_range(0,2);
          //printf("The type of function=%d\n",type);
          if(type==0)
            x=taskAdd(h_fs,NULL,sm);
          else if(type==1)
            x=taskAdd(h_fm,NULL,sm);
          else
            x=taskAdd(h_fl,NULL,sm);
          
          tt_array[x] = type;
      }
}

//Fucntion to add tasks into specific SMs
void sortedAdd(int total,int smid)
{
    // printf("The number of tasks that are going to be added=%d\n",total);
     int s,x;
     int sm;
     for(s=0;s<total;s++)
        {
         if(smid == -1)
            sm = s%6;
         else
            sm = smid;
         if(sm == 0 || sm ==1)
            {
            //printf("Sm %d has small tasks\n",sm);
            x=taskAdd(h_fs,NULL,sm);
            tt_array[x] = 0;
            small_tasks++;
            }
         else if (sm == 2 || sm == 3)
           {
            //printf("Sm %d has medium tasks\n",sm);
            x=taskAdd(h_fm,NULL,sm);
            tt_array[x] = 1;
            medium_tasks++;
           }
         else if(sm == 4 ||sm ==5)
           {
            //printf("Sm %d has large tasks\n",sm);
            x=taskAdd(h_fl,NULL,sm);
            tt_array[x] = 2;
            large_tasks++;
           }
        } 

}
/*Utility function : to Compute the total running time of all tasks, min, max and average
void computeStats()
{
   int p;
   long total=0;
   long min = 999999999;
   long max = 0;
   double average;
   for(p=0;p<ttasks;p++)
      total+=time_array[p];   
   average = (total/ttasks);
   printf("The total running time of %d tasks = %ld\n",ttasks,total);
   printf("The average running time per task is = %f\n",average);

  for(p=0;p<ttasks;p++)
     {
      if(time_array[p] < min)
         min=time_array[p];
      if(time_array[p] > max)
         max=time_array[p];
     }

   printf("The minimum running time of a task is = %ld\n",min);
   printf("The maximin running time of a task is = %ld\n",max);

}
*/

//Utility function to get the type of the task-small 0,medium 1,large 2
int getTaskType(int taskId)
{
 return tt_array[taskId];

}

//Utility function to check is a task has completed execution or not
int taskDone(int taskId)
{
   int p,q;
   for(p=0;p<6;p++)
      {
       for(q=0;q<numtask[p];q++)
          {
           if(taskQueue[p].task_array[q].taskId == taskId && taskQueue[p].task_array[q].isComplete == 1)
              return TRUE;
          }
      }
   return FALSE;
}

//The API to add tasks to the bag
int taskAdd(void *(*func) (void *), void *arg, int sm)
{
    //printf("A new task is going to be added to a queue for smid %d\n",sm);
    int i=taskQueue[sm].i;
    //printf("Going to add to sm %d index %d\n",sm,i);
    int taskId;
    tasks[sm][i].taskId= global_taskId;
    taskId=global_taskId;
    //printf("the taskId of the task added is =%d\n",tasks[sm][i].taskId);
    global_taskId++;
    tasks[sm][i].func = func;
    tasks[sm][i].arg = arg;
    tasks[sm][i].isComplete=0;
    tasks[sm][i].isDisp = 0;
    taskQueue[sm].isDone=0;
    //gettimeofday(&tasks[sm][i].start,NULL);
    taskQueue[sm].task_array[i]=tasks[sm][i];
    (i)++;
    (taskQueue[sm].i)++;
    numtask[sm]++;
    persm[sm]++;
    return taskId;

}
//The functions required to get the smid of the thread
__device__ uint get_smid(void)
{
      uint ret;
      asm("mov.u32 %0, %smid;" : "=r"(ret) );
      return ret;
}

__global__ void kern(int *sm)
{
      if (threadIdx.x==0)
        sm[blockIdx.x]=get_smid();
}


/*
The scheduler:Once a thread enters the scheduler, the smid of that thread is computed so that the thread can pick up the tasks for that SM 
and execute the corresponding large, medium or small sized functions. After execution, the isComplete flag is set to 1 for that particular task so that the CPU can confirm the task as completed on polling in a busy wait loop.
*/
__global__ void scheduler(taskQueue_t *queues,int T,int *done_sm)
{
    int smid=get_smid();//gets the smid of the block-each thread from the same block will have the same smid value
    task_t task;//The task that's going to be executed next
       
    int index=-1 ;
    long int wa2=0;
    long int wa=99999;
    //int prev;
    index=atomicAdd(&current_index[smid],1);
    while(F<T)
       {
        wa++;
         while(wa>1)
           {
            wa--;
           }
         
         printf("");
         printf("");
         if(index<queues[smid].i)//keep executing
           {
             task=queues[smid].task_array[index];
                
                void * (*fp) (void *)=task.func;
                void *arg = task.arg;
                fp(arg);
                //Upon task completion, set isComplete flag for the task to 1
                queues[smid].task_array[index].isComplete=1;
                atomicAdd(&F,1);//Increment the value of F
                index=atomicAdd(&current_index[smid],1);
                if(index>=queues[smid].i)//
                   {
                    done_sm[smid]=1;
                    index=queues[smid].i;
                   }
           }
      if(wa2 < 999999)
         break;
      }
 
}
//Function to increment done value on the CPU side for threads of an sm
void setTime(int smid)
{
int c2=0;
while(persm[smid] >0)
{
 done_array[smid][c2]++;
 persm[smid]--;
 c2=(c2+1)%M;
}

}
/*
Function to allocate memory on the host and device for taskQueue and queues_d respectively. Also device function pointers that are only on the gpu side are copied to the host side using cudaMemcpyFromSymbol.
*/
extern "C" void caller() {
    taskQueue_t *queues_d;//device copy 

    if(M>1000)
       M=1000;
    if(T>10000)
       T=10000;
    current_tasks = NBLOCKS * M;
    if(current_tasks > T)
       current_tasks=T;
    int r1,r2;
    for(r1=0;r1<6;r1++)
       {
        for(r2=0;r2<M;r2++)
           done_array[r1][r2]=0;
       }
    ttasks = T;//Initial number of tasks
    cudaStream_t stream1,stream2,stream3;
    //done = 0;//needs to be changed on the gpu side
    tt_array = (int *) malloc(ttasks * sizeof(long));
    time_array = (long *)malloc(ttasks * sizeof(long));
    //done_sm = (int *)malloc(6 * sizeof(int));
    //start = (struct timeval *) malloc(ttasks * sizeof(struct timeval));
    //end = (struct timeval *) malloc(ttasks *sizeof(struct timeval));
    //Copy device function pointer to host side
    cudaMemcpyFromSymbol(&h_fl, p_fl, sizeof(op_func_t));
    cudaMemcpyFromSymbol(&h_fm, p_fm, sizeof(op_func_t));
    cudaMemcpyFromSymbol(&h_fs, p_fs, sizeof(op_func_t));
    //int s;
    int c1;
    int setComplete=0;
    //PIN the host memory! Very important for the Async memcpy function!
    cudaMallocHost( (void **) &taskQueue,sizeof(taskQueue_t)*6);
    cudaMallocHost( (void **) &done,sizeof(int));
    cudaMallocHost( (void **) &done_sm,sizeof(int)*6);
    //Allocate memory on CPU for taskQueue and tasks
    //taskQueue=(taskQueue_t*)calloc(6,sizeof(struct taskQueue));
    //tasks=(task_t **)calloc(6,sizeof(task_t*));
    int i;
    cudaStreamCreate(&stream1);
    cudaStreamCreate(&stream2);
    cudaStreamCreate(&stream3);
    //for(i=0;i<6;i++)
       //tasks[i]=(task_t*)calloc(6*10000*NTHREADS*NBLOCKS,sizeof(task_t));
    for(i=0;i<6;i++)
       done_sm[i]=0;;    
    //Initialize all queues to have an initial index value of -1
    for(i=0;i<6;i++)
       taskQueue[i].i=0;
   
    //Adding tasks into the bag
     if(sort == 1)
        sortedAdd(current_tasks,-1);
     else
        randomAdd(current_tasks,-1);
    
    // Allocate memory on GPU
    cudaMalloc( (void **) &queues_d,sizeof(taskQueue_t)*6);
    cudaMalloc( (void **) &done_d, sizeof(int));
    cudaMalloc( (void **) &done_sm_d,sizeof(int)*6);
    // copy from CPU to GPU
    cudaMemcpy(done_sm_d,done_sm,sizeof(int)*6,cudaMemcpyHostToDevice);
    cudaMemcpy(queues_d,taskQueue,sizeof(taskQueue_t)*6,cudaMemcpyHostToDevice);
    //cudaMemcpy(done_d,done,sizeof(int),cudaMemcpyHostToDevice);

     //for(s=0;s<ttasks;s++) 
     //      gettimeofday(&start[s],NULL);
     gettimeofday(&total_start,NULL);
//    for(s=0;s<M*NBLOCKS;s++)
//       gettimeofday(&start[s],NULL);
    //Kernel call to schedule all threads in the queue
    scheduler<<< NBLOCKS, M,0,stream1 >>>(queues_d,T,done_sm_d);
    int sm_num;
    long int wa2=0;
    // copy back from GPU to CPU
    while(setComplete<6)
       {
        wa2++;
        cudaMemcpyAsync(done_sm,done_sm_d,sizeof(int)*6,cudaMemcpyDeviceToHost,stream2);
        //cudaMemcpyAsync(done,done_d,sizeof(int),cudaMemcpyDeviceToHost,stream2);
        sm_num=-1;
        setComplete=0;
        for(c1=0;c1<6;c1++)
        {
        if(done_sm[c1] == 1)
           {
            setComplete++;
            setTime(c1);
            if(sm_num==-1)
               sm_num=c1;
           }
         }
        
        if(sm_num!=-1 && current_tasks < T)
           {
           for (r1=0;r1<6;r1++)
             persm[r1]=0;
             //printf("sm%d going to add more tasks\n",sm_num);
            if(sort == 1)
               {
                int rem=T-(M*NBLOCKS);
                rem =rem/2;
                sortedAdd(rem,sm_num);
                //printf("The sm to which more tasks were added %d\n",sm_num);
                current_tasks+=rem;
                sm_num=-1;
                setComplete=0;
               }
            else
               {
                int rem=T-(M*NBLOCKS);
                rem=rem/2;
                randomAdd(rem,sm_num);
                done_sm[sm_num]=0;
                //printf("The sm to which more tasks were added %d\n",sm_num);
                current_tasks+=rem;
                sm_num=-1;
                setComplete=0;
               }
           cudaMemcpyAsync(queues_d,taskQueue,sizeof(taskQueue_t)*6,cudaMemcpyHostToDevice,stream2);
           }
         if(wa2 >99999)
            break;
       }
   cudaThreadSynchronize();
    printf("Done array\n");
    for(r1=0;r1<6;r1++)
       {
        for(r2=0;r2<M;r2++)
           {
            printf("%d\t",done_array[r1][r2]);
           }
        printf("\n");
       }
    
     gettimeofday(&total_end,NULL);
       

      printTasks();
      if(setComplete!=6)
         printf("FAIL%\n");
      else
         printf("PASS \n");
    // free GPU memory
    cudaFree(queues_d);
    cudaFree(taskQueue);
    cudaFree(done);
    cudaFree(done_d);
    cudaFree(done_sm);
    cudaFree(done_sm_d);
}

