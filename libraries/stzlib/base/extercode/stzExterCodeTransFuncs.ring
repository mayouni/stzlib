#  TARGET LANGAUGES DATA TRANSFORMATION FUNCTIONS  #

#~> Embedded automatically within the external code you provide.
#~> They transform the result of the external computation in
#   format that is processable by Ring

#--------------------------------------#
#  SWI-Prolog Transformation Function  #
#--------------------------------------#

$cPrologToRingTransFunc = '
:- use_module(library(http/json)).

% Main function to transform Prolog _Term_ to Ring format and save to file
transform_to_ring(_Term_, Filename) :-
    transform(_Term_, ResultStr),
    open(Filename, write, Stream),
    write(Stream, ResultStr),
    close(Stream).

% Transform an atom or string
transform(_Term_, _result_) :-
    (atom(_Term_) ; string(_Term_)),
    !,
    format(atom(_result_), "\' + StzChar(39) + '~w\' + StzChar(39) + '", [_Term_]).

% Transform a number, handling scientific notation
transform(_Term_, _result_) :-
    number(_Term_),
    !,
    format(atom(StrVal), "~w", [_Term_]),
    (   sub_atom(StrVal, _, _, _, e) 
    ->  format(atom(_result_), "\' + StzChar(39) + '~w\' + StzChar(39) + '", [_Term_])
    ;   _result_ = StrVal
    ).

% Transform boolean true value
transform(true, "TRUE") :- !.

% Transform boolean false value
transform(false, "FALSE") :- !.

% Transform a list
transform(List, _result_) :-
    is_list(List),
    !,
    transform_list(List, _result_).

% Transform a compound _Term_
transform(_Term_, _result_) :-
    compound(_Term_),
    !,
    _Term_ =.. [Functor|Args],
    transform_compound(Functor, Args, _result_).

% Default case for variables or other terms
transform(_, "NULL").

% Transform a list into a flat string
transform_list(List, _result_) :-
    transform_list_items(List, _items_),
    format(atom(_result_), "[~w]", [_items_]).

% Transform list _items_ into a comma-separated string
transform_list_items([], "").
transform_list_items([H], _result_) :-
    transform(H, HResult),
    format(atom(_result_), "~w", [HResult]).
transform_list_items([H|T], _result_) :-
    transform(H, HResult),
    transform_list_items(T, TResult),
    (   TResult = "" -> format(atom(_result_), "~w", [HResult])
    ;   format(atom(_result_), "~w, ~w", [HResult, TResult])
    ).

% Handle key-value pairs (_Term_ = Key-Value), including numeric keys
transform_compound(-, [Key, Value], _result_) :-
    transform(Key, KeyResult),
    transform(Value, ValueResult),
    format(atom(_result_), "[~w, ~w]", [KeyResult, ValueResult]).

% Default handling for other compound terms
transform_compound(_, Args, _result_) :-
    transform_list(Args, _result_).
'

#----------------------------------#
#  Python Transformation Function  #
#----------------------------------#

$cPyToRingTransFunc = '
def transform_to_ring(data):
    def _transform(obj):
        if isinstance(obj, dict):
            _items_ = []
            for key, value in obj.items():
                _items_.append(f"['+StzChar(39)+'{key}'+StzChar(39)+', {_transform(value)}]")
            return "[" + ", ".join(_items_) + "]"
        elif isinstance(obj, list):
            return "[" + ", ".join(_transform(item) for item in obj) + "]"
        elif isinstance(obj, str):
            # Check if the string looks like a Python dictionary
            if obj.startswith("{") and obj.endswith("}"):
                try:
                    # Try to convert the string back to a dictionary using eval
                    # This is safe here because we know the source is from get_params()
                    _dict_obj_ = eval(obj)
                    if isinstance(_dict_obj_, dict):
                        # If successful, transform the dictionary
                        return _transform(_dict_obj_)
                except:
                    # If eval fails, just treat it as a normal string
                    pass
            return f"'+StzChar(39)+'{obj}'+StzChar(39)+'"
        elif isinstance(obj, (int, float)):
            # Convert to string first to check for scientific notation
            _str_val_ = str(obj)
            if "e" in _str_val_.lower():  # Check for scientific notation
                return f"'+StzChar(39)+'{str_val}'+StzChar(39)+'"
            return _str_val_
        elif obj is None:
            return "NULL"
        elif isinstance(obj, bool):
            return str(obj).upper()  # Convert True/False to TRUE/FALSE
        else:
            return f"'+StzChar(39)+'{str(obj)}'+StzChar(39)+'"
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
      _items_ <- lapply(seq_along(obj), function(i) {
        key <- names(obj)[i]
        value <- transform(obj[[i]], depth + 1)
        if (!is.null(key)) {
          sprintf("['+StzChar(39)+'%s'+StzChar(39)+', %s]", key, value)
        } else {
          value
        }
      })
      return(paste0("[", paste(_items_, collapse=", "), "]"))
    }
    
    # Handle vectors or arrays
    if (is.vector(obj) || is.array(obj)) {
      if (length(obj) > 1) {
        _items_ <- sapply(obj, function(x) {
          if (is.na(x)) return("NULL") # Changed from "NA" to "NULL"
          transform(x, depth + 1)
        })
        return(paste0("[", paste(_items_, collapse=", "), "]"))
      } else {
        if (is.na(obj)) return("NULL") # Changed from "NA" to "NULL"
      }
    }
    
    # Handle character strings
    if (is.character(obj)) {
      return(sprintf("'+StzChar(39)+'%s'+StzChar(39)+'", obj))
    }
    
    # Handle numeric values
    if (is.numeric(obj)) {
      # Check for scientific notation
      _str_val_ <- as.character(obj)
      if (grepl("e", _str_val_, ignore.case = TRUE)) {
        return(sprintf("'+StzChar(39)+'%s'+StzChar(39)+'", _str_val_))
      }
      return(_str_val_)
    }
    
    # Handle logical values
    if (is.logical(obj)) {
      return(ifelse(obj, "TRUE", "FALSE"))
    }
    
    # Default case
    return(sprintf("'+StzChar(39)+'%s'+StzChar(39)+'", as.character(obj)))
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
            _items_ = String[]
            for (key, value) in obj
                push!(_items_, "[\'+StzChar(39)+'$(key)\'+StzChar(39)+', $(_transform(value, depth + 1))]")
            end
            return "[" * join(_items_, ", ") * "]"
        end
        
        # Handle arrays
        if isa(obj, AbstractArray)
            return "[" * join([_transform(item, depth + 1) for item in obj], ", ") * "]"
        end
        
        # Handle strings
        if isa(obj, AbstractString)
            return "\'+StzChar(39)+'$(obj)\'+StzChar(39)+'"
        end
        
        # Handle numeric values
        if isa(obj, Number)
            _str_val_ = string(obj)
            # Check for scientific notation
            if occursin(r"e|E", _str_val_)
                return "\'+StzChar(39)+'$(str_val)\'+StzChar(39)+'"
            end
            return _str_val_
        end
        
        # Handle boolean values
        if isa(obj, Bool)
            return obj ? "TRUE" : "FALSE"
        end
        
        # Default case: convert to string
        return "\'+StzChar(39)+'$(string(obj))\'+StzChar(39)+'"
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
            struct Value* _items_;
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
char* array_to_ring_string(Value* _items_, size_t size, int depth) {
    if (depth > MAX_DEPTH) return strdup("TOO_DEEP");
    
    // Allocate buffer with generous size
    char* _result_ = (char*)malloc(BUFFER_SIZE);
    if (!_result_) return NULL;
    
    strcpy(_result_, "[");
    size_t pos = 1;
    
    for (size_t i = 0; i < size; i++) {
        char* item_str = value_to_ring_string(&_items_[i], depth + 1);
        if (item_str) {
            // Check if we need to resize buffer
            size_t needed = pos + strlen(item_str) + 3; // +3 for ", " and possibly "]"
            if (needed >= BUFFER_SIZE) {
                char* new_buf = (char*)realloc(_result_, needed + BUFFER_SIZE);
                if (!new_buf) {
                    free(item_str);
                    free(_result_);
                    return NULL;
                }
                _result_ = new_buf;
            }
            
            strcpy(_result_ + pos, item_str);
            pos += strlen(item_str);
            
            if (i < size - 1) {
                strcpy(_result_ + pos, ", ");
                pos += 2;
            }
            
            free(item_str);
        }
    }
    
    strcpy(_result_ + pos, "]");
    return _result_;
}

// Convert struct to Ring string
char* struct_to_ring_string(KeyValue* pairs, size_t size, int depth) {
    if (depth > MAX_DEPTH) return strdup("TOO_DEEP");
    
    char* _result_ = (char*)malloc(BUFFER_SIZE);
    if (!_result_) return NULL;
    
    strcpy(_result_, "[");
    size_t pos = 1;
    
    for (size_t i = 0; i < size; i++) {
        char* value_str = value_to_ring_string(&pairs[i].value, depth + 1);
        if (value_str) {
            // Check if we need to resize buffer
            size_t needed = pos + strlen(value_str) + strlen(pairs[i].key) + 10;
            if (needed >= BUFFER_SIZE) {
                char* new_buf = (char*)realloc(_result_, needed + BUFFER_SIZE);
                if (!new_buf) {
                    free(value_str);
                    free(_result_);
                    return NULL;
                }
                _result_ = new_buf;
            }
            
            sprintf(_result_ + pos, "['+StzChar(39)+'%s'+StzChar(39)+', %s]", pairs[i].key, value_str);
            pos += strlen(_result_ + pos);
            
            if (i < size - 1) {
                strcpy(_result_ + pos, ", ");
                pos += 2;
            }
            
            free(value_str);
        }
    }
    
    strcpy(_result_ + pos, "]");
    return _result_;
}

// Convert any value to Ring string
char* value_to_ring_string(Value* value, int depth) {
    if (!value) return strdup("NULL");
    
    char buffer[128];
    char* _result_ = NULL;
    
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
            sprintf(buffer, "'+StzChar(39)+'%s'+StzChar(39)+'", value->data.string_val ? value->data.string_val : "");
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
            return strdup("'+StzChar(39)+'UNKNOWN_TYPE'+StzChar(39)+'");
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
    char* _result_ = value_to_ring_string(value, 0);
    
    if (_result_) {
        write_to_file(filename, _result_);
        free(_result_);
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

#-------------------------------------#
#  JavaScript Transformation Function #
#-------------------------------------#

$cJSToRingTransFunc = '
function transform_to_ring(data) {
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
            // Handle arrays
            if (Array.isArray(obj)) {
                const _items_ = obj.map(item => _transform(item, depth + 1));
                return "[" + _items_.join(", ") + "]";
            }
            
            // Handle plain objects (dictionaries)
            const _items_ = [];
            for (const [key, value] of Object.entries(obj)) {
                _items_.push("[' + StzChar(39) + '" + key + "' + StzChar(39) + ', " + _transform(value, depth + 1) + "]");
            }
            return "[" + _items_.join(", ") + "]";
        }
        
        // Handle strings
        if (typeof obj === "string") {
            return "' + StzChar(39) + '" + obj + "' + StzChar(39) + '";
        }
        
        // Handle numbers
        if (typeof obj === "number") {
            const _str_val_ = obj.toString();
            // Check for scientific notation
            if (_str_val_.includes("e") || _str_val_.includes("E")) {
                return "' + StzChar(39) + '" + _str_val_ + "' + StzChar(39) + '";
            }
            return _str_val_;
        }
        
        // Handle booleans
        if (typeof obj === "boolean") {
            return obj ? "TRUE" : "FALSE";
        }
        
        // Default case
        return "' + StzChar(39) + '" + String(obj) + "' + StzChar(39) + '";
    }
    
    return _transform(data);
}
'
