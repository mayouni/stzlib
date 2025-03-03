
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>

#define MAX_DEPTH 100
#define BUFFER_SIZE 8192

typedef enum {
    TYPE_NULL,
    TYPE_INT,
    TYPE_FLOAT,
    TYPE_STRING,
    TYPE_BOOL,
    TYPE_ARRAY,
    TYPE_STRUCT
} DataType;

typedef struct Value {
    DataType type;
    union {
        int64_t int_val;
        double float_val;
        char* string_val;
        bool bool_val;
        struct {
            struct KeyValue* pairs;
            size_t size;
        } struct_val;
        struct {
            struct Value* items;
            size_t size;
        } array_val;
    } data;
} Value;

typedef struct KeyValue {
    char* key;
    Value value;
} KeyValue;

// Forward declarations
char* value_to_ring_string(Value* value, int depth);
void free_value(Value* value);

// Write string to file
void write_to_file(const char* filename, const char* content) {
    FILE* file = fopen(filename, "w");
    if (file != NULL) {
        fprintf(file, "%s", content);
        fclose(file);
    } else {
        fprintf(stderr, "Error: Could not open file %s\n", filename);
    }
}

// Convert array to Ring string
char* array_to_ring_string(Value* items, size_t size, int depth) {
    if (depth > MAX_DEPTH) return strdup("TOO_DEEP");
    
    // Allocate buffer with generous size
    char* result = (char*)malloc(BUFFER_SIZE);
    if (!result) return NULL;
    
    strcpy(result, "[");
    size_t pos = 1;
    
    for (size_t i = 0; i < size; i++) {
        char* item_str = value_to_ring_string(&items[i], depth + 1);
        if (item_str) {
            // Check if we need to resize buffer
            size_t needed = pos + strlen(item_str) + 3; // +3 for ", " and possibly "]"
            if (needed >= BUFFER_SIZE) {
                char* new_buf = (char*)realloc(result, needed + BUFFER_SIZE);
                if (!new_buf) {
                    free(item_str);
                    free(result);
                    return NULL;
                }
                result = new_buf;
            }
            
            strcpy(result + pos, item_str);
            pos += strlen(item_str);
            
            if (i < size - 1) {
                strcpy(result + pos, ", ");
                pos += 2;
            }
            
            free(item_str);
        }
    }
    
    strcpy(result + pos, "]");
    return result;
}

// Convert struct to Ring string
char* struct_to_ring_string(KeyValue* pairs, size_t size, int depth) {
    if (depth > MAX_DEPTH) return strdup("TOO_DEEP");
    
    char* result = (char*)malloc(BUFFER_SIZE);
    if (!result) return NULL;
    
    strcpy(result, "[");
    size_t pos = 1;
    
    for (size_t i = 0; i < size; i++) {
        char* value_str = value_to_ring_string(&pairs[i].value, depth + 1);
        if (value_str) {
            // Check if we need to resize buffer
            size_t needed = pos + strlen(value_str) + strlen(pairs[i].key) + 10;
            if (needed >= BUFFER_SIZE) {
                char* new_buf = (char*)realloc(result, needed + BUFFER_SIZE);
                if (!new_buf) {
                    free(value_str);
                    free(result);
                    return NULL;
                }
                result = new_buf;
            }
            
            sprintf(result + pos, "['%s', %s]", pairs[i].key, value_str);
            pos += strlen(result + pos);
            
            if (i < size - 1) {
                strcpy(result + pos, ", ");
                pos += 2;
            }
            
            free(value_str);
        }
    }
    
    strcpy(result + pos, "]");
    return result;
}

// Convert any value to Ring string
char* value_to_ring_string(Value* value, int depth) {
    if (!value) return strdup("NULL");
    
    char buffer[128];
    char* result = NULL;
    
    switch (value->type) {
        case TYPE_NULL:
            return strdup("NULL");
            
        case TYPE_INT:
            sprintf(buffer, "%lld", (long long)value->data.int_val);
            return strdup(buffer);
            
        case TYPE_FLOAT:
            sprintf(buffer, "%.15g", value->data.float_val);
            return strdup(buffer);
            
        case TYPE_STRING:
            sprintf(buffer, "'%s'", value->data.string_val ? value->data.string_val : "");
            return strdup(buffer);
            
        case TYPE_BOOL:
            return strdup(value->data.bool_val ? "TRUE" : "FALSE");
            
        case TYPE_ARRAY:
            return array_to_ring_string(value->data.array_val.items, 
                                        value->data.array_val.size, depth);
            
        case TYPE_STRUCT:
            return struct_to_ring_string(value->data.struct_val.pairs, 
                                         value->data.struct_val.size, depth);
            
        default:
            return strdup("'UNKNOWN_TYPE'");
    }
}

// Free allocated memory in a Value
void free_value(Value* value) {
    if (!value) return;
    
    switch (value->type) {
        case TYPE_STRING:
            if (value->data.string_val) free(value->data.string_val);
            break;
            
        case TYPE_ARRAY:
            for (size_t i = 0; i < value->data.array_val.size; i++) {
                free_value(&value->data.array_val.items[i]);
            }
            if (value->data.array_val.items) free(value->data.array_val.items);
            break;
            
        case TYPE_STRUCT:
            for (size_t i = 0; i < value->data.struct_val.size; i++) {
                if (value->data.struct_val.pairs[i].key) 
                    free(value->data.struct_val.pairs[i].key);
                free_value(&value->data.struct_val.pairs[i].value);
            }
            if (value->data.struct_val.pairs) free(value->data.struct_val.pairs);
            break;
            
        default:
            break;
    }
}

// Main transformation function
void transform_to_ring(void* res, const char* filename) {
    if (!res) {
        write_to_file(filename, "NULL");
        return;
    }
    
    // Assume res is a pointer to a Value structure
    Value* value = (Value*)res;
    char* result = value_to_ring_string(value, 0);
    
    if (result) {
        write_to_file(filename, result);
        free(result);
    } else {
        write_to_file(filename, "NULL");
    }
}

// Example of creating values
Value* create_int_value(int64_t val) {
    Value* value = (Value*)malloc(sizeof(Value));
    if (value) {
        value->type = TYPE_INT;
        value->data.int_val = val;
    }
    return value;
}

Value* create_float_value(double val) {
    Value* value = (Value*)malloc(sizeof(Value));
    if (value) {
        value->type = TYPE_FLOAT;
        value->data.float_val = val;
    }
    return value;
}

Value* create_string_value(const char* val) {
    Value* value = (Value*)malloc(sizeof(Value));
    if (value) {
        value->type = TYPE_STRING;
        value->data.string_val = strdup(val);
    }
    return value;
}

Value* create_bool_value(bool val) {
    Value* value = (Value*)malloc(sizeof(Value));
    if (value) {
        value->type = TYPE_BOOL;
        value->data.bool_val = val;
    }
    return value;
}

Value* create_array_value(size_t size) {
    Value* value = (Value*)malloc(sizeof(Value));
    if (value) {
        value->type = TYPE_ARRAY;
        value->data.array_val.size = size;
        value->data.array_val.items = (Value*)calloc(size, sizeof(Value));
    }
    return value;
}

Value* create_struct_value(size_t size) {
    Value* value = (Value*)malloc(sizeof(Value));
    if (value) {
        value->type = TYPE_STRUCT;
        value->data.struct_val.size = size;
        value->data.struct_val.pairs = (KeyValue*)calloc(size, sizeof(KeyValue));
    }
    return value;
}


			int main() {
			    printf("C program starting...\n");
			    
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <stdint.h>

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

// Performance benchmark
Value* res = create_struct_value(3);
if (res) {
    // 1. Fibonacci sequence benchmark
    clock_t start = clock();
    int n = 450;  // Calculate the 450th Fibonacci number (matching Ring)
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
    int array_size = 1000000;  // Match Ring 1,000,000 array size
    int* array = (int*)malloc(array_size * sizeof(int));
    
    // Fill with random numbers
    srand(42);  // Fixed seed for reproducibility (same as Ring)
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
    int matrix_size = 250;  // Match Ring 250 matrix size
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
    printf("Failed to create result structure\n");
    res = NULL;
}

			    transform_to_ring(res, "temp\\cresult_ocj819ay.txt");
			    printf("Data written to file.\n");
			    return 0;
			}
			