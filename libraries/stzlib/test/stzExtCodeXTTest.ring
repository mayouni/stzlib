load "../max/stzmax.ring"


/*===========================#
#  PYTHON LANGUAGE EXAMPLES  #
#============================#

/*--- Basic example

pr()

# Create instance for Python

oPyCode = new StzExtCodeXT("python")

# Python code that generates some data

oPyCode.SetCode('
data = {
    "numbers": [1, 2, 3, 4, 5],
    "mean": sum([1, 2, 3, 4, 5]) / 5
}
') # End of Python code

# Execute the python code (inside Python)

oPyCode.Execute()

# The output will be printed inta a text file
# Check the data file name:

? @@( oPyCode.FileName() )
#--> "pydata.txt"

# Read and display the file content

? @@( read(oPyCode.FileName()) )
#--> "[['numbers', [1, 2, 3, 4, 5]], ['mean', 3.0]]"
# As you see, the data has been traformed internally to cope
# with Ring list data formatting

# Check Python execution time in seconds

? oPyCode.LastCallDuration() + NL
#--> 0.09 seconds

# Retrieve and display the data (in it's Ring natif form)

? @@NL( oPyCode.FileData() )
#--> [
#	[ "numbers", [ 1, 2, 3, 4, 5 ] ],
#	[ "mean", 3 ]
# ]

proff()
# Executed in 0.10 second(s) in Ring 1.22



/*--- Different number types

pr()

oPyCode = new StzExtCodeXT("python")

oPyCode.SetCode('
data = {
    "integer": 42,
    "decimal": 3.14159,
    "negative": -17,
    "calculation": 2 ** 8
}
')

oPyCode.Execute()
? @@(oPyCode.FileData())
#--> [
#	[ "integer", 42 ],
#	[ "decimal", 3.14 ],
#	[ "negative", -17 ],
#	[ "calculation", 256 ]
# ]

proff()
#--> Executed in 0.11 second(s) in Ring 1.22


/*--- String variations with proper escaping

pr()

oPyCode = new StzExtCodeXT("python")
oPyCode.setCode('
data = {
    "simple": "Hello World",
    "multiline": "First line\\nSecond line\\nThird line",
    "spaces": "   padded   ",
    "mixed_text": "Numbers: 123, Symbols: @#$%"
}
')

#TODO: Adapt transform_to_ring() to manage escaping of \\n and other chars

oPyCode.Execute()

? @@(oPyCode.FileData())
#--> [
#	[ "simple", "Hello World" ],
#	[ "multiline", "First line\nSecond line\nThird line" ],
#	[ "spaces", "   padded   " ],
#	[ "mixed_text", "Numbers: 123, Symbols: @#$%" ]
# ]

proff()
# Executed in 0.11 second(s) in Ring 1.22

/*--- Nested lists and mixed types

pr()

oPyCode = new StzExtCodeXT("python")

oPyCode.SetCode('
data = {
    "simple_list": [1, 2, 3, 4, 5],
    "mixed_list": [1, "two", 3.14, True, None],
    "nested_list": [
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9]
    ],
    "complex_nested": [
        {"name": "John", "age": 30},
        {"name": "Alice", "age": 25},
        {"name": "Bob", "age": 35}
    ]
}
')

oPyCode.Execute()
? @@(oPyCode.FileData())
#--> [
#	[ "simple_list", [ 1, 2, 3, 4, 5 ] ],
#	[ "mixed_list", [ 1, "two", 3.14, 1, "None" ] ],
#	[
#		"nested_list",
#		[ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ]
#	],
#	[
#		"complex_nested",
#		[
#			[ [ "name", "John" ], [ "age", 30 ] ],
#			[ [ "name", "Alice" ], [ "age", 25 ] ],
#			[ [ "name", "Bob" ], [ "age", 35 ] ]
#		]
#	]
# ]

proff()
# Executed in 0.12 second(s) in Ring 1.22

/*--- Complex nested structure

pr()

oPyCode = new StzExtCodeXT("python")

oPyCode.SetCode('
data = {
    "company": {
        "name": "TechCorp",
        "departments": {
            "IT": {
                "employees": [
                    {"name": "John", "skills": ["Python", "Ring", "SQL"]},
                    {"name": "Alice", "skills": ["Java", "C++", "Ruby"]}
                ],
                "projects": ["WebApp", "Mobile"]
            },
            "HR": {
                "employees": [
                    {"name": "Bob", "role": "Manager"},
                    {"name": "Carol", "role": "Recruiter"}
                ],
                "current_openings": 3
            }
        },
        "stats": {
            "founded": 2020,
            "locations": ["NY", "SF", "London"],
            "revenue": 1234567.89
        }
    }
}
')

oPyCode.Execute()
? @@NL(oPyCode.FileData())
#--> [
#	[
#		"company",
#		[
#			[ "name", "TechCorp" ],
#			[
#				"departments",
#				[
#					[
#						"IT",
#						[
#							[
#								"employees",
#								[
#									[
#										[ "name", "John" ],
#										[ "skills", [ "Python", "Ring", "SQL" ] ]
#									],
#									[
#										[ "name", "Alice" ],
#										[ "skills", [ "Java", "C++", "Ruby" ] ]
#									]
#								]
#							],
#							[ "projects", [ "WebApp", "Mobile" ] ]
#						]
#					],
#					[
#						"HR",
#						[
#							[
#								"employees",
#								[
#									[ [ "name", "Bob" ], [ "role", "Manager" ] ],
#									[ [ "name", "Carol" ], [ "role", "Recruiter" ] ]
#								]
#							],
#							[ "current_openings", 3 ]
#						]
#					]
#				]
#			],
#			[
#				"stats",
#				[
#					[ "founded", 2020 ],
#					[ "locations", [ "NY", "SF", "London" ] ],
#					[ "revenue", 1234567.89 ]
#				]
#			]
#		]
#	]
# ]

proff()
# Executed in 0.12 second(s) in Ring 1.22

/*==========================#
#  JULIA LANGUAGE EXAMPLES  #
#===========================#
*/
pr()

oExtCode = new StzExtCodeXT("julia")

oExtCode.SetCode('
data = Dict("key1" => [1, 2, 3], "key2" => "value")
')

# Executing the julia code (by firing Julia)

oExtCode.Execute()
? "Julia duration in seconds: " + oExtCode.Duration()
#--> Duration in seconds: 0.10

# Get transformed data from the exchange file

? @@( oExtCode.FileData() )
#--> [["key1", [1, 2, 3]], ["key2", "value"]]

proff()
# Executed in 0.12 second(s) in Ring 1.22

/*========================#
#  C++ LANGUAGE EXAMPLES  #
#=========================#


# Test file to verify the refactored functionality:

pr()

    ? "Testing C++ compilation and execution"
    
    
    # Create instance for C++
    oCppCode = new StzExtCodeXT("cpp")
    
    # Test 1: Simple Hello World
    ? NL + "Test 1: Hello World Program"
    cCode = '
    #include <iostream>
    int main() {
        std::cout << "Hello from C++!" << std::endl;
        return 0;
    }'
    
    oCppCode.SetCode(cCode)
    oCppCode.Execute()
    ? "Execution duration: " + oCppCode.LastCallDuration() + " seconds"
    
    # Test 2: File Output
    ? NL + "Test 2: File Output Program"
    cCode = '
    #include <iostream>
    #include <fstream>
    
    int main() {
        std::ofstream outFile("cppdata.txt");
        outFile << "[[\'+char(34)+'numbers\'+char(34)+', [1, 2, 3, 4, 5]]]";
        outFile.close();
        std::cout << "Data written to file" << std::endl;
        return 0;
    }'
    
    oCppCode.SetCode(cCode)
    oCppCode.Execute()
    ? "File content: " + read(oCppCode.FileName())
    
    # Test 3: Error handling
    ? NL + "Test 3: Compilation Error Handling"
    cCode = '
    #include <iostream>
    int main() {
        std::cout << "This has a syntax error << std::endl;
        return 0;
    }'
    
    oCppCode.SetCode(cCode)
    try
        oCppCode.Execute()
    catch
        ? "Caught expected error: " + cCatchError
    done
    
proff()

/*----

cBatCode = '
"C:\msys64\ucrt64\bin\g++.exe" %1 -o %2 2>&1
echo Compilation completed with status: %ERRORLEVEL%
'

# Create instance for C++
oCppCode = new StzExtCodeXT("cpp")

# Set absolutely minimal test code
cCode = '
#include <iostream>
int main() {
    return 0;
}
'

# Set the code in our object
oCppCode.SetCode(cCode)

# First write the source file
write("temp.cpp", cCode)

# Write the batch file - now more silent
cBatchContent = '@echo off
"C:\msys64\ucrt64\bin\g++.exe" %1 -o %2 2>&1
echo %ERRORLEVEL%'
write("compile.bat", cBatchContent)

# Show the content of temp.cpp to verify
? "C++ Source content:"
? read("temp.cpp")

# Try compilation using SystemSilent() instead of system()
? "Attempting compilation:"
cOutput = System("compile.bat temp.cpp temp.exe")
? "Compilation returned: " + cOutput

# Check the result
? "Executable exists: " + @@(fexists("temp.exe"))

if fexists("temp.exe")
    ? "Running the executable:"
    ? SystemSilent("temp.exe")
ok

/*---

cCppCode = '
#include <iostream>
#include <fstream>
#include <string>

int main() {
    // Create test data
    std::ofstream outFile("cppdata.txt");
    if (!outFile.is_open()) {
        std::cerr << "Failed to open file" << std::endl;
        return 1;
    }

    outFile << "[ [\'+char(34)+'test\'char(34)+', \'+char(34)+'value\'+char(34)+'] ]";
    outFile.close();
    
    std::cout << "File written successfully" << std::endl;
    return 0;
}'

# Create instance for C++
oCppCode = new StzExtCodeXT("cpp")

# Set the C++ code
oCppCode.SetCode(cCppCode) # Content from test-cpp artifact

# Write compile.bat
write("compile.bat", cBatCode) # Content from compile-cpp artifact

# Try compilation using the batch file
? "Attempting compilation via batch file:"
? system("compile.bat temp.cpp temp.exe")

# Check if executable was created
? "Checking for temp.exe:"
if fexists("temp.exe")
    ? "Executable created successfully"
    ? "Running the program:"
    ? system("temp.exe")
    
    # Check if data file was created
    if fexists("cppdata.txt")
        ? "Data file content:"
        ? read("cppdata.txt")
    ok
else
    ? "Compilation failed"
ok
