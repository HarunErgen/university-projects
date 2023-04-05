#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <time.h>

const int sizes[10] = {1, 5, 10, 25, 50, 75, 100, 150, 200, 250};

void func(int *arr, int n, int arr2[5]);
void print_array(int *array, int size);
void call_func_abw(int n);

int main(int argc, char *argv[]) {
	srand((unsigned int)time(NULL)); 	// set seed
	for (int i = 0; i < 10; i++) {
		call_func_abw(sizes[i]);		// test the algorithm with different sizes
	}
	return 0;
}

void call_func_abw(int n) {
	int arr[n];
	int arr2[5];
	struct timespec start, end;
	double duration = 0.0;

	// AVERAGE CASE
	for (int i = 0; i < 3; i++) {		// run the algorithm 3 times for the average case
		for (int j = 0; j < n; j++) { 	// initialise arr with random numbers
			arr[j] = rand()%3;
		}
		clock_gettime(CLOCK_REALTIME, &start);
		func(arr, n, arr2);
		clock_gettime(CLOCK_REALTIME, &end);
		duration += (end.tv_sec - start.tv_sec) + (double)(end.tv_nsec - start.tv_nsec) / 1000000000.0;
	}
	printf("Case: average | Size: %d | Elapsed Time: %f s\n", n, duration/3.0);	// Print average execution time
 
	// BEST CASE
	for (int j = 0; j < n; j++) { 	// initialise the array for the best case
		arr[j] = 0;
	}
	clock_gettime(CLOCK_REALTIME, &start);
	func(arr, n, arr2);
	clock_gettime(CLOCK_REALTIME, &end);
	duration = (end.tv_sec - start.tv_sec) + (double)(end.tv_nsec - start.tv_nsec) / 1000000000.0;
	printf("Case: best | Size: %d | Elapsed Time: %f s\n", n, duration);
 
	// WORST CASE
	for (int j = 0; j < n; j++) {	// initialise the array for the worst case
		arr[j] = 2;
	}
	clock_gettime(CLOCK_REALTIME, &start);
	func(arr, n, arr2);
	clock_gettime(CLOCK_REALTIME, &end);
	duration = (end.tv_sec - start.tv_sec) + (double)(end.tv_nsec - start.tv_nsec) / 1000000000.0;
	printf("Case: worst | Size: %d | Elapsed Time: %f s\n", n, duration);
}

// Algorithm
void func(int *arr, int n, int arr2[5]) {
	int i, t1, x1, t2, p2, x2, t3, p3, x3;
	double p1;

	for (i = 0; i < 5; i++) {
		arr2[i] = 0;
	}

	for (i = 0; i < n; i++) {
		if (arr[i] == 0) {
			for (t1 = i; t1 < n; t1++) {
				p1 = sqrt((double)t1);
				x1 = n+1;
				while (x1 >= 1) {
					x1 = x1/2;
					arr2[i%5] = arr2[i%5] + 1;
				}
			}
		}
		else if (arr[i] == 1) {
			for (t2 = n; t2 > 0; t2--) {
				for (p2 = 1; p2 < n+1; p2++) {
					x2 = n+1;
					while (x2 > 0) {
						x2 = x2/2;
						arr2[i%5] = arr2[i%5] + 1;
					}
				}
			}
		}
		else if (arr[i] == 2) {
			for (t3 = 1; t3 < n+1; t3++) {
				x3 = t3+1;
				for (p3 = 0; p3 < t3*t3; p3++) {
					arr2[i%5] = arr2[i%5] + 1;
				}
			}
		}
	}
}

