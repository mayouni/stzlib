#  TARGET LANGAUGES DATA TRANSFORMATION FUNCTIONS  #

#~> Embedded automatically within the external code you provide.
#~> They transform the result of the external computation in
#   format that is processable by Ring

#----------------------------------#
#  Python Transformation Function  #
#----------------------------------#

$cPyToRingTransFunc = '
def transform_to_ring(data):
    def _transform(obj):
        if isinstance(obj, dict):
            items = []
            for key, value in obj.items():
                items.append(f"['+char(39)+'{key}'+char(39)+', {_transform(value)}]")
            return "[" + ", ".join(items) + "]"
        elif isinstance(obj, list):
            return "[" + ", ".join(_transform(item) for item in obj) + "]"
        elif isinstance(obj, str):
            # Check if the string looks like a Python dictionary
            if obj.startswith("{") and obj.endswith("}"):
                try:
                    # Try to convert the string back to a dictionary using eval
                    # This is safe here because we know the source is from get_params()
                    dict_obj = eval(obj)
                    if isinstance(dict_obj, dict):
                        # If successful, transform the dictionary
                        return _transform(dict_obj)
                except:
                    # If eval fails, just treat it as a normal string
                    pass
            return f"'+char(39)+'{obj}'+char(39)+'"
        elif isinstance(obj, (int, float)):
            # Convert to string first to check for scientific notation
            str_val = str(obj)
            if "e" in str_val.lower():  # Check for scientific notation
                return f"'+char(39)+'{str_val}'+char(39)+'"
            return str_val
        elif obj is None:
            return "NULL"
        elif isinstance(obj, bool):
            return str(obj).upper()  # Convert True/False to TRUE/FALSE
        else:
            return f"'+char(39)+'{str(obj)}'+char(39)+'"
    return _transform(data)
'

#-----------------------------#
#  R Transformation Function  #
#-----------------------------#

$cRToRingTransFunc = '
transform_to_ring <- function(data) {
  transform <- function(obj, depth = 0) {
    # Prevent excessive recursion
    if (depth > 100) {
      return("TOO_DEEP")
    }
    
    # Handle NULL and NA values explicitly
    if (is.null(obj)) {
      return("NULL")
    }
    
    # Handle lists or data frames
    if (is.list(obj) || is.data.frame(obj)) {
      items <- lapply(seq_along(obj), function(i) {
        key <- names(obj)[i]
        value <- transform(obj[[i]], depth + 1)
        if (!is.null(key)) {
          sprintf("['+char(39)+'%s'+char(39)+', %s]", key, value)
        } else {
          value
        }
      })
      return(paste0("[", paste(items, collapse=", "), "]"))
    }
    
    # Handle vectors or arrays
    if (is.vector(obj) || is.array(obj)) {
      if (length(obj) > 1) {
        items <- sapply(obj, function(x) {
          if (is.na(x)) return("NULL") # Changed from "NA" to "NULL"
          transform(x, depth + 1)
        })
        return(paste0("[", paste(items, collapse=", "), "]"))
      } else {
        if (is.na(obj)) return("NULL") # Changed from "NA" to "NULL"
      }
    }
    
    # Handle character strings
    if (is.character(obj)) {
      return(sprintf("'+char(39)+'%s'+char(39)+'", obj))
    }
    
    # Handle numeric values
    if (is.numeric(obj)) {
      # Check for scientific notation
      str_val <- as.character(obj)
      if (grepl("e", str_val, ignore.case = TRUE)) {
        return(sprintf("'+char(39)+'%s'+char(39)+'", str_val))
      }
      return(str_val)
    }
    
    # Handle logical values
    if (is.logical(obj)) {
      return(ifelse(obj, "TRUE", "FALSE"))
    }
    
    # Default case
    return(sprintf("'+char(39)+'%s'+char(39)+'", as.character(obj)))
  }
  
  transform(data, depth = 0)
}
'

#---------------------------------#
#  Julia Transformation Function  #
#---------------------------------#

$cJuliaToRingTransFunc = '
function transform_to_ring(data)
    function _transform(obj, depth=0)
        # Prevent excessive recursion
        if depth > 100
            return "TOO_DEEP"
        end
        
        # Handle nothing/missing values
        if obj === nothing
            return "NULL"
        end
        
        # Handle dictionaries
        if isa(obj, Dict)
            items = String[]
            for (key, value) in obj
                push!(items, "[\'+char(39)+'$(key)\'+char(39)+', $(_transform(value, depth + 1))]")
            end
            return "[" * join(items, ", ") * "]"
        end
        
        # Handle arrays
        if isa(obj, AbstractArray)
            return "[" * join([_transform(item, depth + 1) for item in obj], ", ") * "]"
        end
        
        # Handle strings
        if isa(obj, AbstractString)
            return "\'+char(39)+'$(obj)\'+char(39)+'"
        end
        
        # Handle numeric values
        if isa(obj, Number)
            str_val = string(obj)
            # Check for scientific notation
            if occursin(r"e|E", str_val)
                return "\'+char(39)+'$(str_val)\'+char(39)+'"
            end
            return str_val
        end
        
        # Handle boolean values
        if isa(obj, Bool)
            return obj ? "TRUE" : "FALSE"
        end
        
        # Default case: convert to string
        return "\'+char(39)+'$(string(obj))\'+char(39)+'"
    end
    
    return _transform(data)
end
'

#-----------------------------#
#  C Transformation Function  #
#-----------------------------#

$cCToRingTransFunc = '
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
            
            sprintf(result + pos, "['+char(39)+'%s'+char(39)+', %s]", pairs[i].key, value_str);
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
            sprintf(buffer, "'+char(39)+'%s'+char(39)+'", value->data.string_val ? value->data.string_val : "");
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
            return strdup("'+char(39)+'UNKNOWN_TYPE'+char(39)+'");
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
'

#--------------------------------------#
#  SWI-Prolog Transformation Function  #
#--------------------------------------#

$cPrologToRingTransFunc = '
:- use_module(library(http/json)).

% Main function to transform Prolog term to Ring format and save to file
transform_to_ring(Term, Filename) :-
    transform(Term, ResultStr),
    open(Filename, write, Stream),
    write(Stream, ResultStr),
    close(Stream).

% Entry point for transformation, starts with depth 0
transform(Term, Result) :-
    transform_internal(Term, Result, 0).

% Transform an atom or string
transform_internal(Term, Result, _) :-
    (atom(Term) ; string(Term)),
    !,
    format(atom(Result), "\' + char(39) + '~w\' + char(39) + '", [Term]).

% Transform a number, handling scientific notation
transform_internal(Term, Result, _) :-
    number(Term),
    !,
    format(atom(StrVal), "~w", [Term]),
    (   sub_atom(StrVal, _, _, _, e)
    ->  format(atom(Result), "\' + char(39) + '~w\' + char(39) + '", [Term])
    ;   Result = StrVal
    ).

% Transform boolean values
transform_internal(true, "TRUE", _) :- !.
transform_internal(false, "FALSE", _) :- !.

% Transform a list
transform_internal(List, Result, Depth) :-
    is_list(List),
    !,
    transform_list(List, Result, Depth).

% Transform a compound term (e.g., key-value pairs)
transform_internal(Term, Result, Depth) :-
    compound(Term),
    !,
    Term =.. [Functor|Args],
    transform_compound(Functor, Args, Result, Depth).

% Default case for variables or other terms
transform_internal(_, "NULL", _).

% Transform an empty list
transform_list([], "[]", _).

% Transform a non-empty list with depth check
transform_list(List, Result, Depth) :-
    Depth < 100,
    !,
    findall(Str, (member(Elem, List), transform_internal(Elem, Str, Depth + 1)), StrList),
    atomic_list_concat(StrList, ", ", ElementsStr),
    format(atom(Result), "[~w]", [ElementsStr]).

% Handle excessive depth
transform_list(_, "TOO_DEEP", Depth) :-
    Depth >= 100.

% Handle key-value pairs (e.g., input_list-[1,2,3,4,5])
transform_compound(-, [Key, Value], Result, Depth) :-
    (atom(Key) ; string(Key)),
    !,
    transform_internal(Value, ValueResult, Depth),
    format(atom(Result), "[\' + char(39) + '~w\' + char(39) + ', ~w]", [Key, ValueResult]).

% Default handling for other compound terms
transform_compound(_, Args, Result, Depth) :-
    transform_list(Args, Result, Depth).
'

#--------------------------------------#
#  NodeJS Transformation Function      #
#--------------------------------------#

$cNodeJSToRingTransFunc = '
const fs = require("fs");

function transform_to_ring(data) {
    return _transform(data, 0);
}

function _transform(obj, depth = 0) {
    // Prevent excessive recursion
    if (depth > 100) {
        return "TOO_DEEP";
    }
    
    // Handle null and undefined
    if (obj === null || obj === undefined) {
        return "NULL";
    }
    
    // Handle objects (including arrays)
    if (typeof obj === "object") {
        if (Array.isArray(obj)) {
            // Transform array
            const items = obj.map(item => _transform(item, depth + 1));
            return "[" + items.join(", ") + "]";
        } else {
            // Transform object as key-value pairs
            const items = [];
            for (const key in obj) {
                if (Object.prototype.hasOwnProperty.call(obj, key)) {
                    items.push(`['+char(39)+'${key}'+char(39)+', ${_transform(obj[key], depth + 1)}]`);
                }
            }
            return "[" + items.join(", ") + "]";
        }
    }
    
    // Handle strings
    if (typeof obj === "string") {
        return `'+char(39)+'${obj}'+char(39)+'`;
    }
    
    // Handle numbers
    if (typeof obj === "number") {
        // Convert to string to check for scientific notation
        const strVal = String(obj);
        if (strVal.includes("e") || strVal.includes("E")) {
            return `'+char(39)+'${strVal}'+char(39)+'`;
        }
        return strVal;
    }
    
    // Handle booleans
    if (typeof obj === "boolean") {
        return obj ? "TRUE" : "FALSE";
    }
    
    // Default case
    return `'+char(39)+'${String(obj)}'+char(39)+'`;
}

// Function to write results to file
function writeResultToFile(data, filename) {
    const result = transform_to_ring(data);
    fs.writeFileSync(filename, result);
    console.log(`Result written to ${filename}`);
}

module.exports = {
    transform_to_ring,
    writeResultToFile
};
'
