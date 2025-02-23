load "../max/stzmax.ring"


/*=====================================#
#  PYTHON LANGUAGE EXAMPLES -- PART 1  #
#======================================#

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
#--> Executed in 0.10 second(s) in Ring 1.22


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

/*=====================================#
#  PTHON EXAMPLES - PART 2 (ADVANCED)  #
#======================================#
*/

/*--- Data Analysis with Pandas

pr()

oPyCode = new StzExtCodeXT("python")
oPyCode.SetCode('
import pandas as pd
import numpy as np

# Create sample data
data = {
    "sales_data": {
            "total_revenue": sum([a*b for a,b in zip([100, 150, 200, 120], [10.5, 8.75, 12.25, 15.00])]),
            "average_price": np.mean([10.5, 8.75, 12.25, 15.00]),
            "best_seller": "C"
    }
}
')
oPyCode.Execute()
? @@(oPyCode.Result())
#--> [
#	[
#		"sales_data",
#		[
#			[ "total_revenue", 6612.50 ],
#			[ "average_price", 11.62 ],
#			[ "best_seller", "C" ] ]
#		]
#	]
# ]

proff()
# Executed in 0.60 second(s) in Ring 1.22

/*--- Text Processing

pr()

oPyCode = new StzExtCodeXT("python")
oPyCode.SetCode('
from collections import Counter
import re

text = """
Ring is a innovative programming language that can embed Python code.
This makes Ring more powerful and flexible for developers who need
both Ring and Python capabilities in their applications.
"""

data = {
    "text_analysis": {
        "word_count": len(text.split()),
        "char_count": len(text),
        "word_frequency": dict(Counter(re.findall(r"\w+", text.lower()))),
        "sentences": len(re.split(r"[.!?]+", text))
    }
}
')
oPyCode.Execute()
? @@(oPyCode.Result())
#--> [
#	[
#		"text_analysis",
#		[
#			[ "word_count", 30 ],
#			[ "char_count", 195 ],
#			[
#				"word_frequency",
#				[
#					[ "ring", 3 ],
#					[ "is", 1 ],
#					[ "a", 1 ],
#					[ "innovative", 1 ],
#					[ "programming", 1 ],
#					[ "language", 1 ],
#					[ "that", 1 ],
#					[ "can", 1 ],
#					[ "embed", 1 ],
#					[ "python", 2 ],
#					[ "code", 1 ],
#					[ "this", 1 ],
#					[ "makes", 1 ],
#					[ "more", 1 ],
#					[ "powerful", 1 ],
#					[ "and", 2 ],
#					[ "flexible", 1 ],
#					[ "for", 1 ],
#					[ "developers", 1 ],
#					[ "who", 1 ],
#					[ "need", 1 ],
#					[ "both", 1 ],
#					[ "capabilities", 1 ],
#					[ "in", 1 ],
#					[ "their", 1 ],
#					[ "applications", 1 ]
#				]
#			],
#			[ "sentences", 3 ]
#		]
#	]
# ]

proff()
# Executed in 0.14 second(s) in Ring 1.22

/*--- Machine Learning Integration

pr()

oPyCode = new StzExtCodeXT("python")

oPyCode.SetCode('
from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier

# Generate synthetic data
X, y = make_classification(n_samples=100, n_features=4, random_state=42)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

# Train model
clf = RandomForestClassifier(random_state=42)
clf.fit(X_train, y_train)

# Get predictions
predictions = clf.predict(X_test)

data = {
    "accuracy": clf.score(X_test, y_test),
    "feature_importance": clf.feature_importances_.tolist(),
    "predictions": predictions.tolist(),
    "model_params": str(clf.get_params())
}
')
oPyCode.Execute()
? @@(oPyCode.Result())
#--> [
#	['accuracy', 1.0],
#	['feature_importance',
#		[ 0.05509410437235118, 0.12683805728497533, 0.32986783001366454, 0.48820000832900895 ]
#	],
#	['predictions',
#		[1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0]
#	],
#	['model_params', [
#		[ 'bootstrap', True],
#		[ 'ccp_alpha': 0.0 ],
#		[ 'class_weight', Null],
#		[ 'criterion', 'gini' ],
#		[ 'max_depth', Null ],
#		[ 'max_features', 'sqrt' ],
#		[ 'max_leaf_nodes', Null ],
#		[ 'max_samples', Null ],
#		[ 'min_impurity_decrease', 0.0 ],
#		[ 'min_samples_leaf', 1 ],
#		[ 'min_samples_split', 2 ],
#		[ 'min_weight_fraction_leaf', 0.0 ],
#		[ 'monotonic_cst', Null ],
#		[ 'n_estimators', 100 ],
#		[ 'n_jobs', Null ],
#		[ 'oob_score', False ],
#		[ 'random_state', 42 ],
# 		[ 'verbose', 0 ],
# 		[ 'warm_start', False]
#	]
# ]

proff()
# Executed in 1.68 second(s) in Ring 1.22
