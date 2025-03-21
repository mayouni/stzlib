load "../max/stzmax.ring"

/*---

pr()

# Python code  
Py() { @('res = 2 + 3') Run() ? Result() }  #--> 5

# R code  
R() { @('res = 2 + 3') Run() ? Result() }   #--> 5

pf()
# Executed in 0.41 second(s) in Ring 1.22

/*--- Simple python code

pr()

py() {

# Pyhton code
@('
res = {
    "numbers": [1, 2, 3, 4, 5],
    "mean": sum([1, 2, 3, 4, 5]) / 5
}
')
# end of Python code

# Instructing python to run the code
Execute()

# Instructing Ring to return the result from Python
? @@( Result() )
#--> [
#	[ "numbers", [ 1, 2, 3, 4, 5 ] ],
#	[ "mean", 3 ]
# ]

} # closing brace of the py() object

pf()
# Executed in 0.10 second(s) in Ring 1.22

/*--- Data Analysis with Pandas

pr()

py() {

# Pyhton code
@('
import pandas as pd
import numpy as np

# Create sample data
res = {
    "sales_data": {
            "total_revenue": sum([a*b for a,b in zip([100, 150, 200, 120],
				 [10.5, 8.75, 12.25, 15.00])]),

            "average_price": np.mean([10.5, 8.75, 12.25, 15.00]),
            "best_seller": "C"
    }
}
') # End of Python code

# Back to Ring
Execute()

? @@NL(Result())

} # Closing brace of the py() object

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

pf()
# Executed in 2.50 second(s) in Ring 1.22 : AFTER FIRST RUN
# Executed in 0.57 second(s) in Ring 1.22 : AFTER WARMUP

/*--- Text Processing with Python and its regex engine

pr()

py() {

# Start of the Python code
@('
from collections import Counter
import re

text = """
Ring is a innovative programming language that can embed Python code.
This makes Ring more powerful and flexible for developers who need
both Ring and Python capabilities in their applications.
"""

res = {
    "text_analysis": {
        "word_count": len(text.split()),
        "char_count": len(text),
        "word_frequency": dict(Counter(re.findall(r"\w+", text.lower()))),
        "sentences": len(re.split(r"[.!?]+", text))
    }
}
') # end of the Python code

# Back to Ring

Execute()

? @@(Result())

}
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


pf()
# Executed in 0.13 second(s) in Ring 1.22

/*--- Python Machine Learning Integration in a Ring program

pr()

py() {

# Start of the python code

@('
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

res = {
    "accuracy": clf.score(X_test, y_test),
    "feature_importance": clf.feature_importances_.tolist(),
    "predictions": predictions.tolist()
}
') # end of the python code

# Bakc to Ring: run the code and get the result

Execute()
? @@(Result())

} # closing brace of the py() object

#--> [
#	[ "accuracy", 0.90 ],
#	[ "feature_importance", [ 0.03, 0.09, 0.33, 0.55 ] ],
#	[ "predictions", [ 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0 ] ]
# ]


pf()
# Executed in 7.61 second(s) in Ring 1.22 : AFTER FIRST RUN
# Executed in 1.87 second(s) in Ring 1.22 : AFTER WARMUP

/*===== ADVANCED EXAMPLE - COMPARING PERF PYTHON VS SOFTANZA
*/
pr()

py() {

	# --> START OF PYHTON CODE
    	@('

# Function to traverse the list and replace all occurrences of a target item
def traverse_and_replace(lst, target, replacement):
    count = 0
    for i in range(len(lst)):
        if isinstance(lst[i], list):
            # If the element is a sublist, recurse
            count += traverse_and_replace(lst[i], target, replacement)
        elif lst[i] == target:
            # If the element is the target, replace it
            lst[i] = replacement
            count += 1
    return count

deep_list = aDeep =  [
    	42, "apple", "♥", ["sun", 314, [-7, "moon", "♥"], "rain"], [
        99,
        "star", "♥",
        [
            0,
            "♥", "cloud",
            [
                272,
                "wind", "♥",
                [
                    "tree",
                    100,
                    [
                        "fish", "♥",
                        "♥", "bird",
                        [
                            8,
                            "sky", "♥",
                            [
                                "♥", "river",
                                162,
                                [
                                    "fire", "♥", "♥",
                                    "♥", "stone",
                                    ["lake", "♥", 77]
                                ]
                            ]
                        ],
                        "winter", "♥"
                    ]
                ]
            ],
            "♥", "summer", "♥"
        ],
        "night", "♥", "♥"
	]
]

# Step 4: Replace all "♥" with "★" and count the replacements
count = traverse_and_replace(deep_list, "♥", "★")

# Step 5: Set the result
res = {"replacements_made": count}
')
	# <-- END OF PYTHON CODE

	run()
	? result()

}

pf()
# Executed in 0.17 second(s) in Ring 1.22

/*---
*/

pr()

aDeep =  [
    	42, "apple", "♥", ["sun", 314, [-7, "moon", "♥"], "rain"], [
        99,
        "star", "♥",
        [
            0,
            "♥", "cloud",
            [
                272,
                "wind", "♥",
                [
                    "tree",
                    100,
                    [
                        "fish", "♥",
                        "♥", "bird",
                        [
                            8,
                            "sky", "♥",
                            [
                                "♥", "river",
                                162,
                                [
                                    "fire", "♥", "♥",
                                    "♥", "stone",
                                    ["lake", "♥", 77]
                                ]
                            ]
                        ],
                        "winter", "♥"
                    ]
                ]
            ],
            "♥", "summer", "♥"
        ],
        "night", "♥", "♥"
    ]
]

o1 = new stzList(aDeep)
o1.DeepReplace("♥", "★")

pf()
# Executed in 0.01 second(s) in Ring 1.22
