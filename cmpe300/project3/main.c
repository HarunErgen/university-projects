

#include <stdio.h>
#include <stdlib.h>
#include <time.h>

const int size[3] = {100, 1000, 10000}; // input sizes

// Function prototypes
void swap(int *ptr1, int *ptr2);
void quicksort1(int *array, int low, int high);
void quicksort2(int *array, int low, int high);
void quicksort3(int *array, int size);
void quicksort4(int *array, int low, int high);
void q_sort(int *array, int size, int version);
void generate_input(int *buffer, int size, int type);
void print_input(int *arr, int size);
void copy_input(int *src, int *dest, int size);


int main() {
	srand((unsigned int)time(NULL));					// set the seed
	int **buffers = (int **)malloc(6*sizeof(int *));	// random arrays will be initialised at buffers
	for (int i = 0; i < 6; i++) {
		buffers[i] = (int *)malloc(10000*sizeof(int));
	}
	int *input = (int *)malloc(10000*sizeof(int));
	struct timespec start, end;							// needed to measure time
	double duration;

	for (int i = 0; i < 3; i++) {								// size loop
		printf("*** n=%d\n\n", size[i]);
		for (int type = 1; type < 5; type++) {					// input type loop
			printf("InpType%d\n", type);
			for (int k = 0; k < 5; k++) {						// generate 5 average case inputs
				generate_input(buffers[k], size[i], type);		// print average inputs
				printf("Input%d (average)= ", k+1);
				print_input(buffers[k], size[i]);
				printf("\n");
			}
			generate_input(buffers[5], size[i], type);			// generate worst case
			q_sort(buffers[5], size[i], 2);						// worst case is an already sorted array
			printf("Input (worst)= ");
			print_input(buffers[5], size[i]);					// print worst input
			printf("\n");

			for (int version = 1; version < 5; version++) {		// qsort version loop
				// Average Case
				duration = 0.0;
				for (int j = 0; j < 5; j++) {					// repeat 5 times for the average case
					copy_input(buffers[j], input, size[i]);
					clock_gettime(CLOCK_REALTIME, &start);
					q_sort(input, size[i], version);
					clock_gettime(CLOCK_REALTIME, &end);
					duration += (end.tv_sec-start.tv_sec) + (double)(end.tv_nsec-start.tv_nsec) / 1000000000.0;
				}						
				printf("Ver%d Average=%.9f s\n", version, duration/5.0);

				// Worst Case
				clock_gettime(CLOCK_REALTIME, &start);
				q_sort(buffers[5], size[i], version);		// use the sorted one
				clock_gettime(CLOCK_REALTIME, &end);
				duration = (end.tv_sec-start.tv_sec) + (double)(end.tv_nsec-start.tv_nsec) / 1000000000.0;
				printf("Ver%d Worst=%.9f s\n", version, duration);
			}
		}
		printf("\n\n\n");
	}

	// Free allocated spaces
	for (int i = 0; i < 6; i++) {
		free(buffers[i]);
	}
	free(input);
	free(buffers);

	return 0;
}

// Swaps two integers pointed by the pointers given
void swap(int *ptr1, int *ptr2) {
	int temp = *ptr1;
	*ptr1 = *ptr2;
	*ptr2 = temp;
}

// deterministic quicksort algorithm
// chooses the pivot as the first element of the array
void quicksort1(int *array, int low, int high) {
	if (low >= high)
		return;
	int pivot = array[low];
	int low_index = low;
	int high_index = high;
	while (low_index <= high_index) {
		while (array[low_index] < pivot)	low_index++;
		while (array[high_index] > pivot)	high_index--;
		if (low_index <= high_index) {
			swap(array+low_index, array+high_index);
			low_index++;
			high_index--;
		}
	}
	quicksort1(array, low, high_index);
	quicksort1(array, low_index, high);
}

// a randomized quicksort algorithm
// the pivot is choosen randomly
void quicksort2(int *array, int low, int high) {
	if (low >= high)
		return;
	int pivot_index = low + rand()%(high-low+1);
	int pivot = array[pivot_index];
	int low_index = low;
	int high_index = high;
	while (low_index <= high_index) {
		while (array[low_index] < pivot)	low_index++;
		while (array[high_index] > pivot)	high_index--;
		if (low_index <= high_index) {
			swap(array+low_index, array+high_index);
			low_index++;
			high_index--;
		}
	}
	quicksort2(array, low, high_index);
	quicksort2(array, low_index, high);

}

// a randomized quicksort algorithm
// permutes the array,
// then calls the deterministic quicksort algorithm 
// where the pivot is chosen as the first element of the array
void quicksort3(int *array, int size) {
	for (int i = 0; i < size-1; i++) {
		int j = i+ rand()%(size-i); // j is an integer between i and size-1
		swap(array+i,array+j);
	}
	quicksort1(array, 0, size-1);
}

// a deterministic algorithm
// the pivot is chosen according to the median of three rule
void quicksort4(int *array, int low, int high) {
	if (low >= high)
		return;
	int middle = low + (high-low)/2;
	int three[3] = {array[low], array[middle], array[high]};
	quicksort1(three, 0, 2);
	int pivot = three[1];
	int low_index = low;
	int high_index = high;
	while (low_index <= high_index) {
		while (array[low_index] < pivot)	low_index++;
		while (array[high_index] > pivot)	high_index--;
		if (low_index <= high_index) {
			swap(array+low_index, array+high_index);
			low_index++;
			high_index--;
		}
	}
	quicksort4(array, low, high_index);
	quicksort4(array, low_index, high);
}

// calls a quicksort algorithm depending to the version
void q_sort(int *array, int size, int version) {
	if 		(version == 1)	quicksort1(array, 0, size-1);
	else if (version == 2)	quicksort2(array, 0, size-1);
	else if (version == 3)	quicksort3(array, size);
	else if (version == 4)	quicksort4(array, 0, size-1);
}

// generates random numbers depending to the type given
// and fills the first "size" elements of the buffer with them
void generate_input(int *buffer, int size, int type) {
	if (type == 1) {
		for (int i = 0; i < size; i++)
			buffer[i] = rand()%(10*size) + 1;
	} else if (type == 2) {
		for (int i = 0; i < size; i++)
			buffer[i] = rand()%(3*size/4) + 1;
	} else if (type == 3) {
		for (int i = 0; i < size; i++)
			buffer[i] = rand()%(size/4) + 1;
	} else if (type == 4) {
		for (int i = 0; i < size; i++)
			buffer[i] = 1;
	}
}

// Prints an int array
void print_input(int *arr, int size) {
	for (int i = 0; i < size; i++) {
		printf("%d-", arr[i]);
	}
}

// Copies integers from src to dest
void copy_input(int *src, int *dest, int size) {
	for (int i = 0; i < size; i++) {
		dest[i] = src[i];
	}
}



