#include<sys/time.h>

#define TRUE 1
#define FALSE 0

//Task TCB
typedef struct task
{
void *(*func) (void *);
//void (*func) (void);
void *arg;
int taskId;
int isComplete;
int isDisp;
//int type;//0=small,1=medium,2=large
struct timeval start;
struct timeval end;
long int diff;
}task_t;

//Task queue  
typedef struct taskQueue
{
int isDone;
//int isReceived;
int i;
task_t task_array[100000];
}taskQueue_t;

taskQueue_t *taskQueue;
task_t tasks[10][100000];
int taskDone(int taskId);
int taskAdd(void *(*func) (void *), void *arg, int sm);
