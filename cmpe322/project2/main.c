#include <stdio.h>
#include <stdlib.h>
#include <time.h>	// timespec, clock_gettime(), CLOCK_REALTIME
#include <math.h>	// sqrt()
#include <pthread.h>	// pthread_t, pthread_create(), pthread_join(), pthread_exit()

#define TASK_NUM 10		// Number of tasks to be accomplished.
#define UPPER_LIMIT 10000	// Upper limit of integer range
#define LOWER_LIMIT 1000	// Lower limit of integer range

/* Prototypes */
void generate_ints(int arr[], int N);
int min(int arr[], int N);
int max(int arr[], int N);
int range(int arr[], int N);
int mode(int arr[], int N);
void quicksort(int arr[], int first, int last);
float median(int arr[], int N);
int sum(int arr[], int N);
float arith_mean(int arr[], int N);
float harmonic_mean(int arr[], int N);
float SD(int arr[], int N);
float IQR(int arr[], int N);
void *runner(void *param);

/* Hash table implementation */
typedef struct {
	int key;   
	int value;
} ITEM;

int hashfunction(int key, int size) {
	return key % size;
}

ITEM *search(ITEM *hashtable[], int key, int size) {
	int hash = hashfunction(key, size);
	while(hashtable[hash] != NULL) {
		if(hashtable[hash]->key == key)
			return hashtable[hash]; 
		hash++;
		hash %= size;
	}
	return NULL;
}

void insert(ITEM *hashtable[], int key, int value, int size) {
	ITEM *item = (ITEM*) malloc(sizeof(ITEM));
	item->key = key;
	item->value = value;  
   	int hash = hashfunction(key, size);

	while(hashtable[hash] != NULL) {
      		hash++;
      		hash %= size;
	}
	hashtable[hash] = item;

}

/* Structures for threads to use */
typedef struct {
	int N;			// Number of integers
	int *arr;		// İnteger array
	int task_num;		// Number of tasks thread has
	int *tasks;		// Array of tasks thread has
	int num_threads;	// Total number of threads
} DATA;

typedef struct {
	int min_val;
	int max_val;
	int range_val;
	int mode_val;
	float median_val;
	long int sum_val;
	float arith_mean_val;
	float harmonic_mean_val;
	float sd;
	float iqr;
} RESULT;

RESULT result; // Global RESULT. Threads reach and modify this variable.

/* Thread function */
void *runner(void *param) {
	DATA args = *(DATA*) param;
	int *randint_arr = args.arr;
	int N = args.N;
	
	for(int i = 0; i < args.task_num; i++) {
		int task_id = args.tasks[i];

		/* Distributing threads according to assigned tasks */		
		if(task_id == 0)
			result.min_val = min(randint_arr, N);
		else if(task_id == 1)
			result.max_val = max(randint_arr, N);
		else if(task_id == 2)
			result.range_val = range(randint_arr, N);
		else if(task_id == 3)
			result.mode_val = mode(randint_arr, N);
		else if(task_id == 4)
			result.median_val = median(randint_arr, N);
		else if(task_id == 5)
			result.sum_val = sum(randint_arr, N);
		else if(task_id == 6)
			result.arith_mean_val = arith_mean(randint_arr, N);
		else if(task_id == 7)
			result.harmonic_mean_val = harmonic_mean(randint_arr, N);	
		else if(task_id == 8)
			result.sd = SD(randint_arr, N);
		else if(task_id == 9)
			result.iqr = IQR(randint_arr, N);	
	}
	pthread_exit(NULL);	
}

int main(int argc, char *argv[]) {
	printf("Execution format: ./\"program name\" \"number_of_integers\" \"number_of_threads\"\n");	
	int num_threads = atoi(argv[2]); // Number of threads given as second argument.
	pthread_t threads[num_threads];	// Thread list.
	
	/* Time variables */
	struct timespec start, end;
	double cpu_time;

	/* Random integer generation */
	srand(time(NULL));
	int N = atoi(argv[1]);		// Number of integers to be created.
	int randint_arr[N];
	generate_ints(randint_arr, N);
	quicksort(randint_arr, 0, N-1); // Sort array

	/* Distributing number of tasks between threads. */
	int task_per_thread = TASK_NUM / num_threads;
	int num_excess = TASK_NUM % num_threads;	
	int task_tracker = 0;
	
	/* Parameters for threads */
	DATA args[num_threads];

	clock_gettime(CLOCK_REALTIME, &start);	// <--------- Time measurement starts here

	for(int i = 0; i < num_threads; i++) {
		args[i].N = N;
		args[i].arr = randint_arr;
		args[i].num_threads = num_threads;
		DATA *p = args+i;

		if(num_excess > 0) {
			args[i].task_num = task_per_thread + 1;
			num_excess--;
		}
		else {
			args[i].task_num = task_per_thread;
		}
		args[i].tasks = malloc(sizeof(int) * (args[i].task_num));
		for(int j = 0; j < args[i].task_num; j++) {
			args[i].tasks[j] = j+task_tracker;
		}
		task_tracker += args[i].task_num;
		/* Creating threads */
		pthread_create(&threads[i], NULL, runner, p);	
	}
	/* Joining threads */	
	for(int i = 0; i < num_threads; i++)
		pthread_join(threads[i], NULL);

	clock_gettime(CLOCK_REALTIME, &end);	// <--------- Time measurement ends here
	cpu_time = (end.tv_sec - start.tv_sec) + (end.tv_nsec - start.tv_nsec) / 1000000000.0;
	
	/* Write results into output file*/
	FILE *file = fopen("output1.txt", "w");
	fprintf(file, "%d\n%d\n%d\n%d\n%.5g\n%ld\n%.5g\n%.5g\n%.5g\n%.5g\n%.5g\n", 
		result.min_val, result.max_val, result.range_val, result.mode_val, result.median_val,
		result.sum_val, result.arith_mean_val, result.harmonic_mean_val, result.sd, result.iqr,
		cpu_time);
	fclose(file);
	return 0;
}

/* Functions for tasks. */

/* Generates random N integers between LOWER_LIMIT and UPPER_LIMIT */
void generate_ints(int arr[], int N) {
	for(int i = 0; i < N; i++) {
		int randint = rand() % (UPPER_LIMIT + 1 - LOWER_LIMIT) + LOWER_LIMIT;
		arr[i] = randint;
	}
}

int min(int arr[], int N) {
	int i, nextnum, minint = arr[0];
	for(i = 1; i < N; i++) {
		nextnum = arr[i];
		if(nextnum < minint)
			minint = nextnum;	
	}
	return minint;
}

int max(int arr[], int N) {
	int i, nextnum, maxint = arr[0];
	for(i = 1; i < N; i++) {
		nextnum = arr[i];
		if(nextnum > maxint)
			maxint = nextnum;	
	}
	return maxint;
}

int range(int arr[], int N) {
	int minint = min(arr, N);
	int maxint = max(arr, N);	
	return maxint - minint;
}

int mode(int arr[], int N) {
	int capacity = UPPER_LIMIT - LOWER_LIMIT + 1;
	ITEM *hashtable[capacity];
	int mode, max_count = 0;
	for(int i = 0; i < N; i++) {
		ITEM *pair = search(hashtable, arr[i], capacity);
		if(pair != NULL) {
			pair->value++;
			int value = pair->value;
			if(max_count < value){
				max_count = value;
				mode = arr[i];
			}
		}
		else {
			insert(hashtable, arr[i], 1, capacity);
			if(max_count < 1) {
				max_count = 1;
				mode = arr[i];
			}
		}
	}
	return mode;
}

void quicksort(int arr[], int first, int last){
	int i, j, pivot, temp;
	if(first < last){
	   	pivot = first;
	      	i = first;
	      	j = last;
	      	while(i < j){
	      		while((arr[i] <= arr[pivot]) && (i < last))
		 		i++;
		 	while(arr[j]>arr[pivot])
		 		j--;
		 	if(i < j){
		    		temp = arr[i];
		    		arr[i] = arr[j];
		    		arr[j] = temp;
		 	}
	      	}
	      	temp = arr[pivot];
	      	arr[pivot] = arr[j];
	      	arr[j] = temp;
	      	quicksort(arr, first, j-1);
	      	quicksort(arr, j+1, last);
	}
}

float median(int arr[], int N) {
	float median;
	if(N % 2 == 0)
		median = (arr[(N-1)/2] + arr[N/2]) / 2.0;
	else
		median = arr[N/2];	
	return median;
}

int sum(int arr[], int N) {
	int i, sum = 0;
	for(i = 0; i < N; i++) {
		sum += arr[i];	
	}
	return sum;
}

float arith_mean(int arr[], int N) {
	return (float)sum(arr, N) / N;
}

float harmonic_mean(int arr[], int N) {
	float sum = 0;
	for(int i = 0; i < N; i++)
		sum += (1.0 / arr[i]);
	return N / sum;
}

float SD(int arr[], int N) {
	int i;	
	float element, mean, sum = 0;	
	mean = arith_mean(arr, N);
	for(i = 0; i < N; i++) {
		element = (float)arr[i];
		sum += (element - mean) * (element - mean);
	}
	return sqrt(sum / (N-1));
}

float IQR(int arr[], int N){
	int i;
	int low_arr[N/2], high_arr[N/2];
	int mid_high_i, mid_low_i = (N / 2) - 1;
	if(N % 2 == 0)
		mid_high_i = mid_low_i + 1;	
	else
		mid_high_i = mid_low_i + 2;
	for(i = 0; i <= mid_low_i; i++)
		low_arr[i] = arr[i];	
	for(i = 0; i <= mid_low_i; i++)
		high_arr[i] = arr[i + mid_high_i];
	float med_low = median(low_arr, mid_low_i+1);
	float med_high = median(high_arr, mid_low_i+1);
	return med_high - med_low;
}
