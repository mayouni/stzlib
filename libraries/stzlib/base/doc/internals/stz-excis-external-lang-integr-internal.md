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

## System Configuration

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

> NOTE: Of course, any new langauge you add should be installed on your system along with all the packages required by your code. The runtime of the language must be accessible from the system PATH.

## Transformation Functions

At the heart of EXCIS are the transformation functions that convert data structures between Ring and target languages. These functions are automatically embedded with the user code during execution. Here we show the example of the Pyhton transformation function.

### Python Transformation Function

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

You can see the other functions code in the Softanza code base [here](https://github.com/mayouni/stzlib/blob/main/libraries/stzlib/io/stzExtCodeTransFuncs.ring).

### Type Mapping Table

Here's a comprehensive mapping table showing how each supported language's data types are transformed to Ring types:

| Language    | Source Type                   | Ring Type              | Notes                                            |
|-------------|-------------------------------|------------------------|--------------------------------------------------|
| **Python**  | `int`                         | Number                 |                                                  |
|             | `float`                       | Number                 | Scientific notation converts to string           |
|             | `str`                         | String                 |                                                  |
|             | `bool` (`True`)               | `TRUE`                 |                                                  |
|             | `bool` (`False`)              | `FALSE`                |                                                  |
|             | `None`                        | `NULL`                 |                                                  |
|             | `list`                        | List                   |                                                  |
|             | `dict`                        | List of key-value pairs| Each pair as `[key, value]`                      |
|             | Custom objects                | String                 | Via `str()` conversion                           |
| **R**       | `numeric`                     | Number                 | Scientific notation converts to string           |
|             | `character`                   | String                 |                                                  |
|             | `logical` (`TRUE`)            | `TRUE`                 |                                                  |
|             | `logical` (`FALSE`)           | `FALSE`                |                                                  |
|             | `NULL`                        | `NULL`                 |                                                  |
|             | `NA`                          | `NULL`                 |                                                  |
|             | `list`                        | List                   |                                                  |
|             | `data.frame`                  | List of key-value pairs| Column names as keys                             |
|             | `vector` (named)              | List of key-value pairs|                                                  |
|             | `vector` (unnamed)            | List                   |                                                  |
|             | `factor`                      | String                 | Should be converted with `as.character()`        |
| **Julia**   | `Int`                         | Number                 |                                                  |
|             | `Float64`                     | Number                 | Scientific notation converts to string           |
|             | `String`                      | String                 |                                                  |
|             | `Bool` (`true`)               | `TRUE`                 |                                                  |
|             | `Bool` (`false`)              | `FALSE`                |                                                  |
|             | `Nothing`                     | `NULL`                 |                                                  |
|             | `Dict`                        | List of key-value pairs| Each pair as `[key, value]`                      |
|             | `Array`                       | List                   |                                                  |
|             | `Tuple`                       | List                   |                                                  |
|             | Custom structs                | String                 | Via `string()` conversion                        |
| **C**       | `int64_t`                     | Number                 |                                                  |
|             | `double`                      | Number                 | Scientific notation converts to string           |
|             | `char*`                       | String                 |                                                  |
|             | `bool` (`true`)               | `TRUE`                 |                                                  |
|             | `bool` (`false`)              | `FALSE`                |                                                  |
|             | `NULL`                        | `NULL`                 |                                                  |
|             | `Value` (`TYPE_ARRAY`)        | List                   | Custom implementation                            |
|             | `Value` (`TYPE_STRUCT`)       | List of key-value pairs| Custom implementation                            |
| **Prolog**  | `atom`                        | String                 |                                                  |
|             | `string`                      | String                 |                                                  |
|             | `number` (integer)            | Number                 |                                                  |
|             | `number` (float)              | Number                 | Scientific notation converts to string           |
|             | `true`                        | `TRUE`                 |                                                  |
|             | `false`                       | `FALSE`                |                                                  |
|             | `list`                        | List                   |                                                  |
|             | `Key-Value` ('-' operator)    | List `[Key, Value]`    | May be inconsistent                              |
|             | Compound terms                | List                   | Arguments become list elements                   |


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

### Julia Guidelines

- **Supported Data Types**:  
  - Basic: `Int`, `Float64`, `String`, `Bool`, `Nothing`  
  - Collections: `Dict`, `Array`, `Tuple`  
  - String representations of dictionaries (parsed if possible)  

- **Unsupported/Potential Issues**: 
  - Complex objects (custom structs/types)  
  - Special numeric types (`BigInt`, `Complex`)  
  - Circular references  
  - Symbols  
  - Functions or closures  
  - Dates/times (convert to strings)
  - Higher-dimensional arrays (flatten or convert to nested arrays)

- **Best Practices**:  
  - Convert specialized types to basic types
  - Convert `Date`, `DateTime` to string format with `string()`
  - Flatten or nest multidimensional arrays as needed
  - Use dictionaries with string keys for structured data
  - Convert symbols to strings with `string()`
  - Avoid returning functions or custom struct instances
  - Use `Dict`, `Array`, `String`, `Number` for data transfer

### C Guidelines

- **Supported Data Types**:  
  - Basic: `int64_t`, `double`, `char*`, `bool`, `NULL`  
  - Collections: Custom struct using `Value` and `KeyValue` types
  - Arrays using the `Value` array structure  

- **Unsupported/Potential Issues**: 
  - Arbitrary C structs (must convert to Value type)
  - Function pointers
  - Void pointers without type information
  - Raw pointers to memory blocks  
  - Circular references
  - Thread-specific data
  - File handles or I/O streams

- **Best Practices**:  
  - Use the provided functions to create Value objects:
    - `create_int_value()` for integers
    - `create_float_value()` for floating point
    - `create_string_value()` for strings
    - `create_bool_value()` for booleans
    - `create_array_value()` for arrays
    - `create_struct_value()` for key-value structures
  - Remember to free dynamically allocated Value objects
  - Convert custom structs to Value objects with struct_val type
  - Convert raw C arrays to Value arrays
  - Properly null-terminate all strings
  - Set the global `res` variable to the Value object to be returned
    
### SWI-Prolog Guidelines

- **Supported Data Types**:  
  - Basic: `atom`, `string`, `number`, `true/false`  
  - Collections: `list`, `compound terms`
  - Key-value pairs using direct list notation [Key, Value] (most reliable)
  - Key-value pairs using the `-` operator (Key-Value) (may be inconsistent)

- **Unsupported/Potential Issues**: 
  - Variables (unbound variables)
  - Modules
  - Streams
  - Database references
  - Large/infinite terms
  - Cyclic terms
  - Meta-predicates
  - DCG rules
  - Double backslashes (\\) in strings

- **Best Practices**:  
  - Define the result using a `res/1` predicate
  - Use lists for sequential data
  - Prefer list notation [Key, Value] over Key-Value pairs for more reliable results
  - If using Key-Value pairs with the `-` operator, validate results carefully
  - Use single backslash (\) instead of double backslash (\\) in strings
  - Represent complex structures as nested lists or compound terms
  - Convert dates/times to string format
  - Use atomic values (atoms, strings, numbers) for basic data
  - Use true/false atoms for boolean values
  - Ensure all variables are bound in the final result
  - Avoid circular references in data structures

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

Most of the information returned in the trace are expressive, except `"exitcode"` whcih may seem unclear to you...

In fact, the `@nExitCode` in the `StzExtCodeXT` class captures the exit status of external Python or R script executions. It's stored in the execution trace record (`:exitcode` key in `@aCallTrace`) to track whether scripts ran successfully (exit code 0) or failed (non-zero).

This information is valuable for debugging, error reporting, and potentially implementing conditional behavior based on execution success or failure, though the current implementation primarily uses it for record-keeping purposes.

## Troubleshooting: Handling Errors and Missing Output

If you encounter an error or no output at all, check the contents of the `log.txt` file using the `Log()` method. This file contains all the debugging information you need.

For example, the log might reveal that your R script depends on a missing library, such as `ggplot`. In that case, simply install the package and try again:

```
R script starting...
Error in ggplot(df, aes(x = x, y = y, color = category)) : 
  could not find function "ggplot"
Execution halted
```

Normally, this information will be displayed automatically in the Ring console when an operation fails. However, it's good to keep this in mind in case you need to investigate further.

**IMPORTANT: Cleanup Behavior**

If you've set the `@aLanguages` attribute with `:Cleanup = TRUE`, the `Log()` method won't return anything—because all temporary files, including logs and output files, are deleted.

So here is of  best practice to adopt for safety and peac of mind:

* Keep `:Cleanup = FALSE` while developing and debugging your code.
* Once everything works as expected or when deploying to production, switch to `:Cleanup = TRUE` to maintain a clean environment.

## Conclusion

The Softanza External Code Integration System provides a powerful mechanism for bridging the gap between Ring and other programming languages, particularly those with rich ecosystems for data science, machine learning, and statistical computing. By automating the transformation of data structures and providing a clean, consistent interface, **EXCIS** enables Ring developers to leverage the best tools for each task across language boundaries.