#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>	// pthread_t, pthread_create(), pthread_join(), pthread_exit()
#include <unistd.h>		// sleep()
#include <stdatomic.h>	// atomic_int

/* Results of the prepayments */
typedef struct {
	atomic_int kevin;
	atomic_int bob;
	atomic_int stuart;
	atomic_int otto;
	atomic_int dave;
} Result;

/* Global Variables */
FILE* output_file;
Result result = {0,0,0,0,0};

/* Data of the prepayment of the customer*/
typedef struct {
	int customer_id;	// customer ID
	int sleep_time;		// sleep time
	int vtm_id;			// vending machine
	char* company_name;	// company name
	int amount;			// amount of the payment
} CustomerData;

/* Data of the VTM */
typedef struct {
	int vtm_id;			// vending machine
	int customer_id;	// customer ID
	char* company_name;	// company name
	int amount;			// amount of the payment
} VTMData;

/* Vending Machine Data*/
VTMData vtm_data[10];

/* Synchronization */
int vtm_active = 1;					// VTMs are active or not
int use_vtm[10] = {0};				// VTM is being used or not
pthread_barrier_t barrier;			// block threads until they all reach the barrier
pthread_mutex_t vtm_locks[10];		// VTM locks
pthread_cond_t vtm_cond[10];		// wait and signal conditions between customers and VTMs  
pthread_mutex_t vtm_cond_locks[10];	// locks to synchronize waiting and signaling

/* Customer Thread Function*/
void *customer_execution(void *param) {
	CustomerData args = *(CustomerData*) param;
	int customer_id = args.customer_id;
	int vtm_id = args.vtm_id-1;
	char *company_name = args.company_name;
	int amount = args.amount;

	pthread_barrier_wait(&barrier);	// wait until all customer threads reach here
	usleep(args.sleep_time * 1000);	// sleep for (sleep_time(ms) * 1000) microseconds

	/* critical section */
	pthread_mutex_lock(&vtm_locks[vtm_id]);	// lock vending machine that will be used

		vtm_data[vtm_id].customer_id = customer_id;				// id of the customer using the machine
		vtm_data[vtm_id].company_name = malloc(sizeof(char)*strlen(company_name));
		strcpy(vtm_data[vtm_id].company_name, company_name);	// company
		vtm_data[vtm_id].amount = amount;						// amount of the payment	

		/* lock this area and let the VTM run */
		pthread_mutex_lock(&vtm_cond_locks[vtm_id]);	
			
			use_vtm[vtm_id] = 1;
			pthread_cond_signal(&vtm_cond[vtm_id]);	// signal to vtm
			while(use_vtm[vtm_id] == 1)				// wait vtm
				pthread_cond_wait(&vtm_cond[vtm_id], &vtm_cond_locks[vtm_id]);

		pthread_mutex_unlock(&vtm_cond_locks[vtm_id]);
		/* unlock this area when the prepayment is done by the vtm */
	
	pthread_mutex_unlock(&vtm_locks[vtm_id]);// unlock vending machine that has been used
	/* end of critical section */

	pthread_exit(NULL);
}

/* Vending Thread Function*/
void *vtm_execution(void *param) {
	VTMData args = *(VTMData*) param;
	int vtm_id = args.vtm_id;			// id of the vtm
	outer: while(vtm_active == 1) {		// run loop until vtm_active is set to 0

		/* lock whole prepayment process */
		pthread_mutex_lock(&vtm_cond_locks[vtm_id]);

		while(use_vtm[vtm_id] == 0) {		// if the vtm is not being used, wait
			if (vtm_active == 0)			// if vtms are deactivated, exit
				pthread_exit(NULL);			
			pthread_cond_wait(&vtm_cond[vtm_id], &vtm_cond_locks[vtm_id]);	// wait until receiving signal from a customer
		}
						
		int customer_id = vtm_data[vtm_id].customer_id;
		char *company_name = vtm_data[vtm_id].company_name;
		int amount = vtm_data[vtm_id].amount;

		/* Since the result fields are atomic, no need to mutex locks */
		if(!strcmp(company_name, "Kevin")) {
			atomic_fetch_add(&result.kevin, amount);
		} 
		else if(!strcmp(company_name, "Bob")) {
			atomic_fetch_add(&result.bob, amount);
		}	
		else if(!strcmp(company_name, "Stuart")) {
			atomic_fetch_add(&result.stuart, amount);
		}
		else if(!strcmp(company_name, "Otto")) {
			 atomic_fetch_add(&result.otto, amount);
		}
		else if(!strcmp(company_name, "Dave")) {
			atomic_fetch_add(&result.dave, amount);
		}

		fprintf(output_file, "[VTM%d]: Customer%d,%dTL,%s\n", vtm_id+1, customer_id, amount, company_name);

		use_vtm[vtm_id] = 0;					// after handling prepayment, set VTM as not being used
		pthread_cond_signal(&vtm_cond[vtm_id]);	// process completion signal to customer
		
		pthread_mutex_unlock(&vtm_cond_locks[vtm_id]);
		/* now can unlock prepayment process */	
	}

	pthread_exit(NULL);	
}

int main(int argc, char *argv[]) {
	int NUM_OF_CUSTOMERS;		// number of customers

	/* I/O Files */
	char* input_file_name = argv[1];	// input file name
	FILE *input_file = fopen(input_file_name, "r");	// input file
	if (input_file == NULL) {
		perror("Error opening file\n");
		exit(1);
	}
	char output_file_name[264];
	char input_file_name_modified[256];
	strncpy(input_file_name_modified, input_file_name, strlen(input_file_name) - 4);
	sprintf(output_file_name, "%s_log.txt", input_file_name_modified);	// <input file name>_log.txt
	output_file = fopen(output_file_name,"w");

	char* line = NULL;
	size_t len = 0;
	ssize_t read;
	if((read = getline(&line, &len, input_file)) != -1)
		NUM_OF_CUSTOMERS = atoi(line);

	/* Initialize Mutex Locks */
	for(int i = 0; i < 10; i++)
		pthread_mutex_init(&vtm_locks[i], NULL);
	pthread_barrier_init(&barrier, NULL, NUM_OF_CUSTOMERS);

	/* Data and Threads */
	CustomerData customer_data[NUM_OF_CUSTOMERS];	// data array for each customer
	pthread_t customer_threads[NUM_OF_CUSTOMERS];	// customer thread list
	pthread_t vtm_threads[10];						// vending thread list
	
	/* Create VTM Threads */
	for(int i = 0; i<10; i++) {
		vtm_data[i].vtm_id = i;

		VTMData *p = vtm_data+i;
		pthread_create(&vtm_threads[i], NULL, vtm_execution, p);
	}

	/* Create Customer Threads */
	char *ptr, *delim = ",";
	for(int i = 0; (read = getline(&line, &len, input_file)) != -1; i++) {
		customer_data[i].customer_id = i+1;		
		ptr = strtok(line, delim);
		customer_data[i].sleep_time = atoi(ptr);
		ptr = strtok(NULL, delim);
		customer_data[i].vtm_id = atoi(ptr);
		ptr = strtok(NULL, delim);
		customer_data[i].company_name = malloc(sizeof(char)*strlen(ptr));
		strcpy(customer_data[i].company_name,ptr);
		ptr = strtok(NULL, delim);
		customer_data[i].amount = atoi(ptr);

		CustomerData *p = customer_data+i;
		pthread_create(&customer_threads[i], NULL, customer_execution, p);
	}
	fclose(input_file);

	/* Join Threads to Main Thread */
	for(int i = 0; i < NUM_OF_CUSTOMERS; i++)
		pthread_join(customer_threads[i], NULL);
	
vtm_active = 0;	// deactivate VTMs
	for(int i = 0; i < 10; i++) {
		pthread_cond_signal(&vtm_cond[i]);	// deactivation signal to VTMs
		pthread_join(vtm_threads[i], NULL);
	}

	/* Main Output*/
	fprintf(output_file, "[Main]: All payments are completed\n");
	fprintf(output_file, "[Main]: Kevin: %d\n", result.kevin);
	fprintf(output_file, "[Main]: Bob: %d\n", result.bob);
	fprintf(output_file, "[Main]: Stuart: %d\n", result.stuart);
	fprintf(output_file, "[Main]: Otto: %d\n", result.otto);
	fprintf(output_file, "[Main]: Dave: %d\n", result.dave);
	
	fclose(output_file);
	
	return 0;
}
