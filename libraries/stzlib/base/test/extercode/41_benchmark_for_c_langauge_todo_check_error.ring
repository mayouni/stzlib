# Narrative
# --------
# #  BENCHMARK FOR C LANGAUGE  # TODO Check error
#
# Extracted from stzextercodetest.ring, block #41.

load "../../stzBase.ring"

#----------------------------#

pr()

cCCode = '
// Need to include time.h for clock functions
#include <time.h>

// Function to calculate fibonacci numbers iteratively
// Using uint64_t for larger fibonacci numbers
uint64_t fib(int n) {
    if (n <= 1) return n;
    
    uint64_t a = 0, b = 1, temp;
    for (int i = 2; i <= n; i++) {
        temp = a + b;
        a = b;
        b = temp;
    }
    return b;
}

// Function to sort an array using quicksort
void quicksort(int arr[], int low, int high) {
    if (low < high) {
        // Partition the array
        int pivot = arr[high];
        int i = low - 1;
        
        for (int j = low; j <= high - 1; j++) {
            if (arr[j] < pivot) {
                i++;
                int temp = arr[i];
                arr[i] = arr[j];
                arr[j] = temp;
            }
        }
        
        int temp = arr[i + 1];
        arr[i + 1] = arr[high];
        arr[high] = temp;
        
        int partition = i + 1;
        
        // Recursively sort the sub-arrays
        quicksort(arr, low, partition - 1);
        quicksort(arr, partition + 1, high);
    }
}

// Performance benchmark - this code runs inside main()
Value* res = create_struct_value(3);
if (res) {
    // 1. Fibonacci sequence benchmark
    clock_t start = clock();
    int n = 45;  // Reduced from 450 to avoid overflow
    uint64_t result = fib(n);
    clock_t end = clock();
    double fib_time = ((double)(end - start)) / CLOCKS_PER_SEC * 1000;
    
    // Store fibonacci result
    if (res->data.struct_val.pairs) {
        res->data.struct_val.pairs[0].key = strdup("fibonacci");
        Value* fib_struct = create_struct_value(3);
        
        fib_struct->data.struct_val.pairs[0].key = strdup("n");
        fib_struct->data.struct_val.pairs[0].value.type = TYPE_INT;
        fib_struct->data.struct_val.pairs[0].value.data.int_val = n;
        
        fib_struct->data.struct_val.pairs[1].key = strdup("result");
        fib_struct->data.struct_val.pairs[1].value.type = TYPE_INT;
        fib_struct->data.struct_val.pairs[1].value.data.int_val = result;
        
        fib_struct->data.struct_val.pairs[2].key = strdup("time_ms");
        fib_struct->data.struct_val.pairs[2].value.type = TYPE_FLOAT;
        fib_struct->data.struct_val.pairs[2].value.data.float_val = fib_time;
        
        res->data.struct_val.pairs[0].value.type = TYPE_STRUCT;
        res->data.struct_val.pairs[0].value.data.struct_val = fib_struct->data.struct_val;
        free(fib_struct);
    }
    
    // 2. Sorting benchmark
    start = clock();
    int array_size = 100000;  // Reduced from 1,000,000 for faster execution
    int* array = (int*)malloc(array_size * sizeof(int));
    
    // Fill with random numbers
    srand(42);  // Fixed seed for reproducibility
    for (int i = 0; i < array_size; i++) {
        array[i] = rand() % 10000;  // Random numbers between 0-9999
    }
    
    // Sort the array
    quicksort(array, 0, array_size - 1);
    end = clock();
    double sort_time = ((double)(end - start)) / CLOCKS_PER_SEC * 1000;
    free(array);
    
    // Store sorting result
    if (res->data.struct_val.pairs) {
        res->data.struct_val.pairs[1].key = strdup("sorting");
        Value* sort_struct = create_struct_value(2);
        
        sort_struct->data.struct_val.pairs[0].key = strdup("array_size");
        sort_struct->data.struct_val.pairs[0].value.type = TYPE_INT;
        sort_struct->data.struct_val.pairs[0].value.data.int_val = array_size;
        
        sort_struct->data.struct_val.pairs[1].key = strdup("time_ms");
        sort_struct->data.struct_val.pairs[1].value.type = TYPE_FLOAT;
        sort_struct->data.struct_val.pairs[1].value.data.float_val = sort_time;
        
        res->data.struct_val.pairs[1].value.type = TYPE_STRUCT;
        res->data.struct_val.pairs[1].value.data.struct_val = sort_struct->data.struct_val;
        free(sort_struct);
    }
    
    // 3. Matrix multiplication benchmark
    start = clock();
    int matrix_size = 100;  // Reduced from 250 for faster execution
    int** matrix1 = (int**)malloc(matrix_size * sizeof(int*));
    int** matrix2 = (int**)malloc(matrix_size * sizeof(int*));
    int** result_matrix = (int**)malloc(matrix_size * sizeof(int*));
    
    for(int i = 0; i < matrix_size; i++) {
        matrix1[i] = (int*)malloc(matrix_size * sizeof(int));
        matrix2[i] = (int*)malloc(matrix_size * sizeof(int));
        result_matrix[i] = (int*)malloc(matrix_size * sizeof(int));
        
        for(int j = 0; j < matrix_size; j++) {
            matrix1[i][j] = rand() % 100;  // Random numbers between 0-99
            matrix2[i][j] = rand() % 100;
            result_matrix[i][j] = 0;
        }
    }
    
    // Matrix multiplication
    for(int i = 0; i < matrix_size; i++) {
        for(int j = 0; j < matrix_size; j++) {
            for(int k = 0; k < matrix_size; k++) {
                result_matrix[i][j] += matrix1[i][k] * matrix2[k][j];
            }
        }
    }
    
    end = clock();
    double matrix_time = ((double)(end - start)) / CLOCKS_PER_SEC * 1000;
    
    // Free memory
    for(int i = 0; i < matrix_size; i++) {
        free(matrix1[i]);
        free(matrix2[i]);
        free(result_matrix[i]);
    }
    free(matrix1);
    free(matrix2);
    free(result_matrix);
    
    // Store matrix multiplication result
    if (res->data.struct_val.pairs) {
        res->data.struct_val.pairs[2].key = strdup("matrix");
        Value* matrix_struct = create_struct_value(2);
        
        matrix_struct->data.struct_val.pairs[0].key = strdup("matrix_size");
        matrix_struct->data.struct_val.pairs[0].value.type = TYPE_INT;
        matrix_struct->data.struct_val.pairs[0].value.data.int_val = matrix_size;
        
        matrix_struct->data.struct_val.pairs[1].key = strdup("time_ms");
        matrix_struct->data.struct_val.pairs[1].value.type = TYPE_FLOAT;
        matrix_struct->data.struct_val.pairs[1].value.data.float_val = matrix_time;
        
        res->data.struct_val.pairs[2].value.type = TYPE_STRUCT;
        res->data.struct_val.pairs[2].value.data.struct_val = matrix_struct->data.struct_val;
        free(matrix_struct);
    }
} else {
    printf("Failed to create result structure\\n");
    res = NULL;
}
'

? "Creating C executor..."
C = new stzExterCode("c")

? "Setting C code..."
C.SetCode(cCCode) 

? "Executing C code..."
C.Execute()

? "Getting results..."
? @@( C.Result() )

? "Done!"
#--> [
#	[
#	[
#		"fibonacci",
#		[ [ "n", 450 ], [ "result", -8044227546631567360.00 ], [ "time_ms", 0 ] ]
#	],
#	[
#		"sorting",
#		[ [ "array_size", 1000000 ], [ "time_ms", 197 ] ]
#	],
#	[
#		"matrix",
#		[ [ "matrix_size", 250 ], [ "time_ms", 61 ] ]
#	]
# ]

pf()
# Executed in 0.61 second(s) in Ring 1.22
