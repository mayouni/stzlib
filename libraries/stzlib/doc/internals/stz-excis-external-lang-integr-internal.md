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

You can explore its code [here](https://github.com/mayouni/stzlib/blob/main/libraries/stzlib/io/stzExtCodeXT.ring).

## Implementation Workflow

The execution workflow of the EXCIS system follows a clear sequence of operations:

1. **Initialization**: A language-specific executor is instantiated with appropriate runtime parameters
2. **Code Setting**: The external code to be executed is provided to the executor
3. **Preparation**: Temporary files are created, and the source code is enhanced with transformation functions
4. **Execution**: The external runtime is invoked to execute the code
5. **Data Retrieval**: The transformed data is captured from a designated output file
6. **Cleanup**: Temporary resources are removed (when configured)

![](../images/stz-excis-system.png)
This workflow is encapsulated in the `Execute()` method and its supporting private methods.

## Easy Configuration

After installing the external languages on your system (currently Python and R) and ensuring they are accessible from the system PATH (so the Ring `system()` command can call their runtimes), you can start working with the preconfigured settings available in the class attributes region.

Alternatively, you can customize the configuration in code based on your needs by directly modifying the class attributes or using dedicated methods such as:

```
def SetRuntimePath(cPath)
	@aLanguages\[@cLanguage]\[:customPath] = cPath

def SetVerbose(bVerbose)
	@bVerbose = bVerbose

def SetResultVar(cResVar)
	if NOT cResVar = ""
		@cResVar = cResVar
	ok

def SetLogFile(cFileName)
	@cLogFile = cFileName

```

## File System and I/O Management

The system utilizes several distinct file types for different purposes:

### Source File (@cSourceFile)

A temporary file named after the target language (e.g., `temp.py` for Python or `temp.R` for R) is automatically generated. This file contains the provided code along with the transformation function's code.

It serves as the actual script fed into the Python or R runtime for execution. Its content can be accessed through the `Code()` method.

### Log File (@cLogFile)

The log file captures the standard output and standard error streams from the external program execution. This file is essential for:

* Capturing console output from the target language
* Recording error messages and warnings
* Facilitating debugging of external code
* Monitoring execution progress

The log file is accessed through the `Log()` method, which retrieves the complete console output of the most recent execution. This is particularly useful for diagnosing issues when the external code fails to execute correctly or produces unexpected results.

### Result File (@cResultFile)

The result file stores the transformed data structure that needs to be passed back to Ring. Unlike the log file, which contains arbitrary text output, the result file:

* Contains only the structured data in Ring-compatible format
* Is written to explicitly by the transformation function
* Is language-dependent (specified in the language registry)
* Serves as the primary data exchange mechanism between languages

The `Result()` method parses the content of this file, evaluates it as Ring code, and returns the resulting data structure to the caller.

```ring
def Code()
    if NOT fexists(@cSourceFile)
        return ""
    ok
    return This.ReadFile(@cSourceFile)

def Log()
    if NOT fexists(@cLogFile)
        return ""
    ok
    return This.ReadFile(@cLogFile)

def Result()
    if NOT fexists(@cResultFile)
        stzraise("Result file does not exist!")
    ok
    cContent = This.ReadFile(@cResultFile)
    if cContent = NULL or cContent = ""
        return ""
    end
    try
        cCode = 'result = ' + cContent
        eval(cCode)
        return result
    catch
        ? "Eval error: " + cCatchError
        return cContent
    end
```

This separation of concerns ensures that diagnostic information is kept separate from actual data transfer, making the system more robust and easier to debug.

## Extensibility Mechanism

The system is designed for extensibility, with a language registry that maintains metadata for each supported language:

```ring
@aLanguages = [
        :python = [
            :Name = "Python",
            :Type = "interpreted",
            :Extension = ".py",
            :Runtime = "python",
            :AlternateRuntimes = ["python3", "py"],
            :ResultFile = "pyresult.txt",
            :CustomPath = "",
            :TransFunc = $cPyToRingTransFunc,
            :Cleanup = TRUE
        ],
        :r = [
            :Name = "R",
            :Type = "interpreted",
            :Extension = ".R",
            :Runtime = "Rscript",
            :AlternateRuntimes = ["R"],
            :ResultFile = "rresult.txt",
            :CustomPath = "",
            :TransFunc = $cRToRingTransFunc,
            :Cleanup = TRUE
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

## Simplified Programmer Experience

The `stzExtCodeXT` class can be used directly as follows:

```ring
# Executing Python code  
Py = new stzExtCodeXT(:Python)  

Py.SetCode("res = 2 + 3")  
Py.Run()  
? Py.Result()  
# --> 5  

# Executing R code  
R = new stzExtCodeXT(:R)  

R.SetCode("res = 2 + 3")  
R.Run()  
? R.Result()  
# --> 5  
```

However, in practice, you may prefer the more concise and elegant `Py()` and `R()` helper functions:

```ring
# Python code  
Py() { @('res = 2 + 3') Run() ? Result() }  

# R code  
R() { @('res = 2 + 3') Run() ? Result() }  
```

The `Py()` function instantiates an object of the `stzPythonCode` class, while `R()` instantiates an object of the `stzRCode` class. Both classes are specialized versions of the parent class `stzExtCodeXT`.

## Tracing the System

It is possible to check the internal operation of the computation by using several methods:
```ring
R() {

	@('res = 2 + 3')
	Run()

	? Result()		#--> 5
	? Duration() + NL	#--> 0.30s

	? @@(Trace()) + NL
	#--> [
	 	[
	 	[ "language", "r" ],
	 	[ "timestamp", "25/02/2025-09:08:58" ],
	 	[ "duration", 0.30 ],
	 	[ "log", "R script starting... Data written to file" ],
	 	[ "exitcode", "" ],
	 	[ "mode", "interpreted" ]
	 	]
	 ]

	? Code()
	#--> The listing of the internal code generate by the class
	# in the target langauge (in this case R), including the code
	# we provided ('res = 2 + 3') and the code of the transformation
	# function transform_to_ring()

}
```

## Conclusion

The Softanza External Code Integration System provides a powerful mechanism for bridging the gap between Ring and other programming languages, particularly those with rich ecosystems for data science, machine learning, and statistical computing. By automating the transformation of data structures and providing a clean, consistent interface, **EXCIS** enables Ring developers to leverage the best tools for each task across language boundaries.