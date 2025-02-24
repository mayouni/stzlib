# EXCIS: Softanza's External Code Integration System – Architecture and Implementation

## Introduction

The Softanza External Code Integration System (EXCIS) provides a seamless bridge between Ring applications and external programming languages, enabling developers to leverage the vast ecosystems of languages like Python and R directly from Ring code. This article explores the architectural design, implementation workflow, extensibility mechanisms, and transformation functions that power this integration system.

## System Architecture

EXCIS follows a modular, language-agnostic architecture that enables consistent interaction patterns regardless of the target language. The system is designed around these core principles:

1. **Uniform Abstraction**: A consistent interface for executing code in any supported language
2. **Language Isolation**: Clean separation between Ring and external language environments
3. **Data Marshalling**: Automatic transformation of data structures between Ring and target languages
4. **Execution Tracing**: Comprehensive logging of execution details for debugging and monitoring
5. **Resource Management**: Automatic cleanup of temporary files and resources

The `StzExtCodeXT` class serves as the central component, orchestrating the entire execution workflow from code preparation to data retrieval.

You can explore its code here:
[](https://github.com/mayouni/stzlib/blob/main/libraries/stzlib/io/stzExtCodeXT.ring)

## Implementation Workflow

The execution workflow follows a clear sequence of operations:

1. **Initialization**: A language-specific executor is instantiated with appropriate runtime parameters
2. **Code Setting**: The external code to be executed is provided to the executor
3. **Preparation**: Temporary files are created, and the source code is enhanced with transformation functions
4. **Execution**: The external runtime is invoked to execute the code
5. **Data Retrieval**: The transformed data is captured from a designated output file
6. **Cleanup**: Temporary resources are removed (when configured)

This workflow is encapsulated in the `Execute()` method and its supporting private methods.

```
┌────────────────┐     ┌────────────────┐     ┌────────────────┐     ┌────────────────┐
│ Initialization │────>│ Code Setting   │────>│ Preparation    │────>│ Execution      │
└────────────────┘     └────────────────┘     └────────────────┘     └────────────────┘
                                                                             │
┌────────────────┐     ┌────────────────┐                                    │
│ Cleanup        │<────│ Data Retrieval │<───────────────────────────────────┘
└────────────────┘     └────────────────┘
```

## Extensibility Mechanism

The system is designed for extensibility, with a language registry that maintains metadata for each supported language:

```ring
@aLanguages = [
    :python = [
        :name = "Python",
        :type = "interpreted",
        :extension = ".py",
        :runtime = "python",
        :alternateRuntimes = ["python3", "py"],
        :datafile = "pydata.txt",
        :customPath = "",
        :transformFunction = $cPyToRingDataTransFunc,
        :cleanup = TRUE
    ],
    :r = [
        :name = "R",
        :type = "interpreted",
        :extension = ".R",
        :runtime = "Rscript",
        :alternateRuntimes = ["R"],
        :datafile = "rdata.txt",
        :customPath = "",
        :transformFunction = $cRToRingDataTransFunc,
        :cleanup = TRUE
    ]
]
```

Adding support for a new language involves:

1. Extending the language registry with appropriate metadata
2. Implementing a language-specific transformation function
3. Adding any specialized preparation logic if needed

The system's design allows for both interpreted and compiled languages, though the current implementation focuses on interpreted languages.

## Transformation Functions

At the heart of EXCIS are the transformation functions that convert data structures between Ring and target languages. These functions are automatically embedded with the user code during execution.

### Python Transformation

The Python transformation function converts Python data structures to Ring format:

```python
def transform_to_ring(data):
    def _transform(obj):
        if isinstance(obj, dict):
            items = []
            for key, value in obj.items():
                items.append(f"['{key}', {_transform(value)}]")
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
            return f"'{obj}'"
        elif isinstance(obj, (int, float)):
            return str(obj)
        elif obj is None:
            return "NULL"
        elif isinstance(obj, bool):
            return str(obj).upper()  # Convert True/False to TRUE/FALSE
        else:
            return f"'{str(obj)}'"
    return _transform(data)
```

### R Transformation

The R transformation function converts R data structures to Ring format:

```r
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
          sprintf("['%s', %s]", key, value)
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
      return(sprintf("'%s'", obj))
    }
    
    # Handle numeric values
    if (is.numeric(obj)) {
      return(as.character(obj))
    }
    
    # Handle logical values
    if (is.logical(obj)) {
      return(ifelse(obj, "TRUE", "FALSE"))
    }
    
    # Default case
    return(sprintf("'%s'", as.character(obj)))
  }
  
  transform(data, depth = 0)
}
```

## Language-Specific Guidelines

### Python Guidelines

The transformation engine converts Python data structures to Ring format with these limitations:

1. **Supported data types**:
- Basic types: `int`, `float`, `str`, `bool`, `None`
- Collections: `dict`, `list`
- String representations of dictionaries (will be parsed if possible)

2. **Unsupported or potentially problematic types**:
- Complex objects (classes, custom types)
- Numpy arrays (use `.tolist()` method)
- Pandas DataFrames (convert to `dict` or `list` first)
- Circular references
- Special numeric types (Decimal, complex numbers)
- Dates/times (convert to strings)

3. **Best practices**:
- Convert specialized types to basic types before output
- Flatten numpy arrays with `.tolist()`
- Convert all dates/times to string format
- Use `dict/list/string/number` for any data to be transferred to Ring
- Avoid storing function objects or class instances in the output data

### R Guidelines

The transformation engine converts R data structures to Ring format with these limitations:

1. **Supported data types**:
- Basic types: `numeric`, `character`, `logical`, `NULL`, `NA`
- Collections: `list`, `data.frame`, `vector, array`

2. **Unsupported or potentially problematic types**:
- Complex R objects (`S3/S4/R6` classes)
- Environments
- Functions
- Factors (convert to `character` first)
- Circular references
- Dates/POSIXt objects (convert to `character` first)

3. **Best practices**:
- Convert factors to character vectors with `as.character()`
- Convert dates/times to character with `format()` or `as.character()`
- Convert specialized objects to lists where possible
- Simplify complex data structures before output
- Ensure vectors have appropriate names for dictionary-like behavior
- Use `as.list()` for complex objects when appropriate

Here’s a clearer and more polished version of your text:

## Simplified Programmer Experience

The `stzExtCodeXT` class can be used directly as follows:

```ring
# Executing Python code  
Py = new stzExtCodeXT(:Python)  

Py.SetCode("2 + 3")  
Py.Run()  
? Py.Output()  
# --> 5  

# Executing R code  
R = new stzExtCodeXT(:R)  

R.SetCode("2 + 3")  
R.Run()  
? R.Output()  
# --> 5  
```

However, in practice, you may prefer the more concise and elegant `Py()` and `R()` helper functions:

```ring
# Python code  
Py() { @('2 + 3') Run() ? Output }  

# R code  
R() { @('2 + 3') Run() ? Output }  
```

The `Py()` function instantiates an object of the `stzPythonCode` class, while `R()` instantiates an object of the `stzRCode` class. Both classes are specialized versions of the parent class `stzExtCodeXT`.

> **Note:** The `XT` suffix in `stzExtCodeXT` indicates that this is an extended version of a more basic class called `stzExtCode`. This class allows writing Ring code that mimics the syntax of external languages (such as Python or others) while remaining purely Ring code.

## Conclusion

The Softanza External Code Integration System provides a powerful mechanism for bridging the gap between Ring and other programming languages, particularly those with rich ecosystems for data science, machine learning, and statistical computing. By automating the transformation of data structures and providing a clean, consistent interface, **EXCIS** enables Ring developers to leverage the best tools for each task across language boundaries.

Future enhancements could include support for additional languages, more sophisticated data transformation capabilities, and integration with asynchronous execution models for long-running computations.