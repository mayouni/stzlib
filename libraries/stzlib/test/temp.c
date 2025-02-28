
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

// Create the main array
Value* res = create_array_value(4);
if (res) {
    // First element: integer
    res->data.array_val.items[0].type = TYPE_INT;
    res->data.array_val.items[0].data.int_val = 42;
    
    // Second element: string
    res->data.array_val.items[1].type = TYPE_STRING;
    res->data.array_val.items[1].data.string_val = strdup("hello");
    
    // Third element: float
    res->data.array_val.items[2].type = TYPE_FLOAT;
    res->data.array_val.items[2].data.float_val = 3.14159;
    
    // Fourth element: nested array
    res->data.array_val.items[3].type = TYPE_ARRAY;
    res->data.array_val.items[3].data.array_val.size = 2;
    res->data.array_val.items[3].data.array_val.items = (Value*)calloc(2, sizeof(Value));
    
    // Add values to nested array
    res->data.array_val.items[3].data.array_val.items[0].type = TYPE_BOOL;
    res->data.array_val.items[3].data.array_val.items[0].data.bool_val = true;
    
    res->data.array_val.items[3].data.array_val.items[1].type = TYPE_INT;
    res->data.array_val.items[3].data.array_val.items[1].data.int_val = 99;
    
    printf("Mixed type array created\n");
} else {
    printf("Failed to create array\n");
    res = NULL;
}

    transform_to_ring(res, "cresult.txt");
    printf("Data written to file.\n");
    return 0;
}
