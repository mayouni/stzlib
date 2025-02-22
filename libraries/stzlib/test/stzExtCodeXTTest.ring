load "../max/stzmax.ring"



/*--- Basic example

pr()

# Create instance for Python

oPyCode = new StzExtCodeXT("python")

# Python code that generates some data

oPyCode.setCode('
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
    "special_chars": "alpha,beta,gamma,delta",
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
#	[ "special_chars", "alpha,beta,gamma,delta" ],
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
# Executed in 0.01 second(s) in Ring 1.22

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
# Executed in 0.10 second(s) in Ring 1.22
