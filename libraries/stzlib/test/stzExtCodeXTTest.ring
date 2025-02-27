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
res = {
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

? @@NL( oPyCode.Result() )
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
res = {
    "integer": 42,
    "decimal": 3.14159,
    "negative": -17,
    "calculation": 2 ** 8
}
')

oPyCode.Run()
? @@(oPyCode.Result())
#--> [
#	[ "integer", 42 ],
#	[ "decimal", 3.14 ],
#	[ "negative", -17 ],
#	[ "calculation", 256 ]
# ]

proff()
#--> Executed in 0.12 second(s) in Ring 1.22


/*--- String variations with proper escaping

pr()

oPyCode = new StzExtCodeXT("python")
oPyCode.setCode('
res = {
    "simple": "Hello World",
    "multiline": "First line\\nSecond line\\nThird line",
    "spaces": "   padded   ",
    "mixed_text": "Numbers: 123, Symbols: @#$%"
}
')

oPyCode.Exec()

? @@(oPyCode.Result())
#--> [
#	[ "simple", "Hello World" ],
#	[ "multiline", "First line
# Second line
# Third line" ],
#	[ "spaces", "   padded   " ],
#	[ "mixed_text", "Numbers: 123, Symbols: @#$%" ]
# ]

proff()
# Executed in 0.12 second(s) in Ring 1.22

/*--- Nested lists and mixed types

pr()

oPyCode = new StzExtCodeXT("python")

oPyCode.SetCode('
res = {
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
? @@(oPyCode.Result())
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
res = {
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
? @@NL(oPyCode.Result())
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

/*======================================#
#  PYTHON EXAMPLES - PART 2 (ADVANCED)  #
#=======================================#

/*--- Data Analysis with Pandas

pr()

oPyCode = new StzExtCodeXT("python")
oPyCode.SetCode('
import pandas as pd
import numpy as np

# Create sample data
res = {
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
# Executed in 0.55 second(s) in Ring 1.22

/*--- Text Processing

pr()

oPyCode = new StzExtCodeXT("python")
oPyCode.SetCode('
from collections import Counter
import re

text = """
Ring is an innovative programming language that can embed Python code.
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

res = {
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
# Executed in 1.75 second(s) in Ring 1.22

/*=======================#
#  R LANGAUAGE EXAMPLES  #
#========================#

/*--- Basic Numeric Data

pr()

R = new StzExtCodeXT("r")

R.SetCode('
res <- list(
    numbers = c(1, 2, 3, 4, 5),
    mean = mean(c(1, 2, 3, 4, 5))
)
')

R.Execute()
? @@(R.Result())
#--> [
#    [ "numbers", [1, 2, 3, 4, 5] ],
#    [ "mean", 3 ]
# ]

proff()
# Executed in 0.31 second(s) in Ring 1.22

/*--- Simple nested list with different data types

pr()

R = new StzExtCodeXT("r")

R.SetCode('
numbers <- c(12, 15, 18, 22, 25)
res <- list(
    basic_stats = list(
        numbers = numbers,
        mean = mean(numbers),
        median = median(numbers),
        has_outliers = FALSE
    ),
    metadata = list(
        description = "Sample dataset",
        date_created = format(Sys.Date(), "%Y-%m-%d")
    )
)
')

R.Execute()
? @@( R.Result() )
#--> [
#	[
#		"basic_stats",
#		[
#			[ "numbers", [ 12, 15, 18, 22, 25 ] ],
#			[ "mean", 18.40 ],
#			[ "median", 18 ],
#			[ "has_outliers", 0 ]
#		]
#	],
#	[
#		"metadata",
#		[ [ "description", "Sample dataset" ], [ "date_created", "2025-02-24" ] ]
#	]
# ]

proff()
# Executed in 0.32 second(s) in Ring 1.22

/*--- Data analysis with NA handling

pr()

R = new StzExtCodeXT("r")

R.SetCode('

	measurements <- c(23.5, NA, 22.1, 24.3, NA, 21.8)

	res <- list(

	    measurements = measurements,

	    analysis = list(
	        complete_cases = sum(!is.na(measurements)),
	        mean_without_na = mean(measurements, na.rm = TRUE),
	        na_positions = which(is.na(measurements))
	    )

	)
')

R.Execute()
? @@( R.Result() )
#--> [
#	[ "measurements", [ 23.50, "", 22.10, 24.30, "", 21.80 ] ],
#	[
#		"analysis",
#		[
#			[ "complete_cases", 4 ],
#			[ "mean_without_na", 22.93 ],
#			[ "na_positions", [ 2, 5 ] ]
#		]
#	]
# ]

proff()
# Executed in 0.31 second(s) in Ring 1.22

/*--- Statistical calculations

pr()

R = new stzExtCodeXT(:R)

R.SetCode('

	temperatures <- c(18.2, 19.5, 22.1, 23.4, 25.8, 26.9, 27.5, 28.1, 26.8, 25.2)

	res <- list(

	    raw_data = temperatures,

	    statistics = list(
	        mean = mean(temperatures),
	        sd = sd(temperatures),
	        quartiles = quantile(temperatures, probs = c(0.25, 0.5, 0.75)),
	        range = range(temperatures)
	    ),

	    analysis = list(
	        above_25 = sum(temperatures > 25),
	        percent_above_25 = mean(temperatures > 25) * 100
	    )
	)
')

R.Execute()
? @@ ( R.Result() )
#--> [
#	[ "raw_data", [ 18.20, 19.50, 22.10, 23.40, 25.80, 26.90, 27.50, 28.10, 26.80, 25.20 ] ],
#	[
#		"statistics",
#		[
#			[ "mean", 24.35 ],
#			[ "sd", 3.44 ],
#			[ "quartiles", [ 22.43, 25.50, 26.88 ] ],
#			[ "range", [ 18.20, 28.10 ] ]
#		]
#	],
#	[
#		"analysis",
#		[ [ "above_25", 6 ], [ "percent_above_25", 60 ] ]
#	]
# ]

proff()
# Executed in 0.32 second(s) in Ring 1.22

/*--- Nested calculations with custom functions

pr()

R = new stzExtCodeXT(:R)

R.SetCode('

	group_a <- c(15, 18, 21, 24, 27)
	group_b <- c(22, 25, 28, 31, 34)

	calculate_metrics <- function(values) {
	    list(
	        mean = mean(values),
	        variance = var(values),
	        coefficient_variation = sd(values) / mean(values) * 100
	    )
	}
	
	res <- list(

	    groups = list(
	        group_a = group_a,
	        group_b = group_b
	    ),

	    metrics = list(
	        group_a_metrics = calculate_metrics(group_a),
	        group_b_metrics = calculate_metrics(group_b)
	    ),

	    comparison = list(
	        mean_difference = mean(group_b) - mean(group_a),
	        ratio = mean(group_b) / mean(group_a)
	    )

	)
')

R.Execute()
? @@( R.Result() )
#-- [
#	[
#		"groups",
#		[
#			[ "group_a", [ 15, 18, 21, 24, 27 ] ],
#			[ "group_b", [ 22, 25, 28, 31, 34 ] ]
#		]
#	],
#	[
#		"metrics",
#		[
#			[
#				"group_a_metrics",
#				[ [ "mean", 21 ], [ "variance", 22.50 ], [ "coefficient_variation", 22.59 ] ]
#			],
#			[
#				"group_b_metrics",
#				[ [ "mean", 28 ], [ "variance", 22.50 ], [ "coefficient_variation", 16.94 ] ]
#			]
#		]
#	],
#	[
#		"comparison",
#		[ [ "mean_difference", 7 ], [ "ratio", 1.33 ] ]
#	]
# ]

proff()
# Executed in 0.31 second(s) in Ring 1.22

/*--- Time series data with aggregation

pr()

R = new stzExtCodeXT(:R)

R.SetCode('

	dates <- as.Date("2024-01-01") + 0:29  # 30 days of data
	values <- rnorm(30, mean = 100, sd = 15)

	res <- list(

	    time_series = list(
	        dates = format(dates, "%Y-%m-%d"),
	        values = values
	    ),

	    weekly_stats = list(
	        week_means = tapply(values, ceiling(seq_along(values)/7), mean),
	        week_sds = tapply(values, ceiling(seq_along(values)/7), sd)
	    ),

	    trends = list(
	        overall_trend = coef(lm(values ~ seq_along(values))),
	        volatility = sd(diff(values))
	    )

	)
')

R.Execute()
? @@( R.Result() )
#--> [
#	[
#		"time_series",
#		[
#			[ "dates", [ "2024-01-01", "2024-01-02", "2024-01-03", "2024-01-04", "2024-01-05", "2024-01-06", "2024-01-07", "2024-01-08", "2024-01-09", "2024-01-10", "2024-01-11", "2024-01-12", "2024-01-13", "2024-01-14", "2024-01-15", "2024-01-16", "2024-01-17", "2024-01-18", "2024-01-19", "2024-01-20", "2024-01-21", "2024-01-22", "2024-01-23", "2024-01-24", "2024-01-25", "2024-01-26", "2024-01-27", "2024-01-28", "2024-01-29", "2024-01-30" ] ],
#			[ "values", [ 116.31, 98.84, 105.34, 84.91, 95.95, 107.65, 88.83, 118.05, 81.38, 126.66, 116.20, 115.88, 108.89, 91.34, 84.57, 87.03, 95.34, 98.85, 102.06, 91.35, 89.68, 108.28, 72.91, 89.75, 78.61, 109.23, 103.20, 77.80, 87.77, 92.12 ] ]
#		]
#	],
#	[
#		"weekly_stats",
#		[
#			[ "week_means", [ 99.69, 108.34, 92.70, 91.40, 89.95 ] ],
#			[ "week_sds", [ 10.97, 16.15, 6.34, 15.47, 3.08 ] ]
#		]
#	],
#	[
#		"trends",
#		[
#			[ "overall_trend", [ 106.51, -0.58 ] ],
#			[ "volatility", 18.97 ]
#		]
#	]
# ]

proff()
# Executed in 0.32 second(s) in Ring 1.22

/*=== Graphic DataViz - Complex scatter plot with density

pr()

R = new stzExtCodeXT(:R)

R.SetCode('

	# Load required libraries with error handling
	library("ggplot2")
	library("plotly")
	library("viridis")
	
	# Generate data
	set.seed(123)
	n_points <- 200
	x <- rnorm(n_points, mean = 0, sd = 1.5)
	y <- x^2 + rnorm(n_points, mean = 0, sd = 2)
	categories <- factor(sample(c("A", "B", "C"), n_points, replace = TRUE))
	sizes <- runif(n_points, 1, 5)
	
	# Create data frame
	df <- data.frame(
	    x = x,
	    y = y,
	    category = categories,
	    size = sizes
	)
	
	# Create and save the plot first
	p <- ggplot(df, aes(x = x, y = y, color = category)) +
	    geom_point(aes(size = size), alpha = 0.6) +
	    geom_smooth(method = "loess", se = TRUE) +
	    stat_density_2d(aes(fill = after_stat(level)), geom = "polygon", alpha = 0.1) +
	    labs(
	        title = "Complex 2D Visualization",
	        subtitle = "Scatter plot with density contours and trend lines",
	        x = "X Variable",
	        y = "Y Variable",
	        color = "Category",
	        size = "Size"
	    ) +
	    theme_minimal() +
	    theme(
	        plot.title = element_text(size = 16, face = "bold"),
	        plot.subtitle = element_text(size = 12),
	        legend.position = "right"
	    )
	
	# Add color scales
	if (requireNamespace("viridis", quietly = TRUE)) {
	    p <- p + scale_color_viridis_d() + scale_fill_viridis_c()
	} else {
	    p <- p + scale_color_brewer(palette = "Set1") + scale_fill_distiller(palette = "Blues")
	}
	
	# Save the plot
	ggsave("output.png", p, width = 10, height = 8, dpi = 300)
	
	# Create separate data structure for Ring
	res <- list(
	    plot_info = list(
	        filename = "output.png",
	        dimensions = list(
	            width = 10,
	            height = 8,
	            dpi = 300
	        ),
	        data_points = n_points
	    ),
	    statistics = list(
	        x = list(
	            mean = mean(x),
	            sd = sd(x),
	            range = range(x)
	        ),
	        y = list(
	            mean = mean(y),
	            sd = sd(y),
	            range = range(y)
	        ),
	        correlation = cor(x, y)
	    ),
	    categories = list(
	        levels = levels(categories),
	        counts = as.list(table(categories))
	    )
	)
')

R.Execute()

if fexists("output.png")
	system("start output.png")
ok


proff()
# Executed in 2.92 second(s) in Ring 1.22

/*==========================#
#  JULIA LANGUAGE EXAMPLES  #
#===========================#

pr()

J = new stzExtCodeXT(:julia)
J { @('
    # Your Julia code here
    using Statistics
    
    # Example data
    data = [1, 2, 3, 4, 5]
    
    # Calculate statistics
    res = Dict(
        "mean" => mean(data),
        "median" => median(data),
        "std" => std(data),
        "min" => minimum(data),
        "max" => maximum(data)
    )
')
    Run()
    ? @@( Result() )

}
#--> [
#	[ "median", 3 ],
#	[ "max", 5 ],
#	[ "min", 1 ],
#	[ "mean", 3 ],
#	[ "std", 1.58 ]
# ]

proff()
# Executed in 1.35 second(s) in Ring 1.22

/*======================#
#  C LANGUAGE EXAMPLES  #
#=======================#

/*--- Basic example

pr()

xc = new StzExtCodeXT("c")
xc.SetCode('
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Create an array using the Value system
Value* res = create_array_value(5);
if (res) {
    for (int i = 0; i < 5; i++) {
        res->data.array_val.items[i].type = TYPE_INT;
        res->data.array_val.items[i].data.int_val = i + 1;
    }
    printf("Array created with values 1,2,3,4,5\n");
} else {
    printf("Failed to create array\n");
    res = NULL;
}
') # End of C code

xc.Execute()
? @@( xc.Result() )
#--> [1, 2, 3, 4, 5]

proff()
# Executed in 0.34 second(s) in Ring 1.22

/*--- Creating structs with key pairs

pr()

xc = new StzExtCodeXT("c")
xc.SetCode('
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Create a struct using the Value system
Value* res = create_struct_value(3);
if (res) {
    // First key-value pair: name -> "John"
    res->data.struct_val.pairs[0].key = strdup("name");
    res->data.struct_val.pairs[0].value.type = TYPE_STRING;
    res->data.struct_val.pairs[0].value.data.string_val = strdup("John");
    
    // Second key-value pair: age -> 30
    res->data.struct_val.pairs[1].key = strdup("age");
    res->data.struct_val.pairs[1].value.type = TYPE_INT;
    res->data.struct_val.pairs[1].value.data.int_val = 30;
    
    // Third key-value pair: isActive -> true
    res->data.struct_val.pairs[2].key = strdup("isActive");
    res->data.struct_val.pairs[2].value.type = TYPE_BOOL;
    res->data.struct_val.pairs[2].value.data.bool_val = true;
    
    printf("Struct created with 3 key-value pairs\n");
} else {
    printf("Failed to create struct\n");
    res = NULL;
}
')

xc.Execute()
? @@( xc.Result() )
#--> # [ [ "name", "John" ], [ "age", 30 ], [ "isActive", 1 ] ]

proff()

# Executed in 1.21 second(s) in Ring 1.22

/*---  Nested Array of Mixed Types

pr()

xc = new StzExtCodeXT("c")
xc.SetCode('
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
')

xc.Execute()
? @@( xc.Result() )
#--> [ 42, "hello", 3.14, [ TRUE, 99 ] ]

proff()
# Executed in 0.34 second(s) in Ring 1.22

/*--- Complex Nested Structure with Arrays and Structs

pr()

xc = new StzExtCodeXT("c")
xc.SetCode('
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Create a person record with nested data
Value* res = create_struct_value(3);
if (res) {
    // Person basic info
    res->data.struct_val.pairs[0].key = strdup("person");
    res->data.struct_val.pairs[0].value.type = TYPE_STRUCT;
    res->data.struct_val.pairs[0].value.data.struct_val.size = 2;
    res->data.struct_val.pairs[0].value.data.struct_val.pairs = (KeyValue*)calloc(2, sizeof(KeyValue));
    
    // Add name
    res->data.struct_val.pairs[0].value.data.struct_val.pairs[0].key = strdup("name");
    res->data.struct_val.pairs[0].value.data.struct_val.pairs[0].value.type = TYPE_STRING;
    res->data.struct_val.pairs[0].value.data.struct_val.pairs[0].value.data.string_val = strdup("Alice");
    
    // Add age
    res->data.struct_val.pairs[0].value.data.struct_val.pairs[1].key = strdup("age");
    res->data.struct_val.pairs[0].value.data.struct_val.pairs[1].value.type = TYPE_INT;
    res->data.struct_val.pairs[0].value.data.struct_val.pairs[1].value.data.int_val = 28;
    
    // Skills array
    res->data.struct_val.pairs[1].key = strdup("skills");
    res->data.struct_val.pairs[1].value.type = TYPE_ARRAY;
    res->data.struct_val.pairs[1].value.data.array_val.size = 3;
    res->data.struct_val.pairs[1].value.data.array_val.items = (Value*)calloc(3, sizeof(Value));
    
    // Add skills
    res->data.struct_val.pairs[1].value.data.array_val.items[0].type = TYPE_STRING;
    res->data.struct_val.pairs[1].value.data.array_val.items[0].data.string_val = strdup("programming");
    
    res->data.struct_val.pairs[1].value.data.array_val.items[1].type = TYPE_STRING;
    res->data.struct_val.pairs[1].value.data.array_val.items[1].data.string_val = strdup("design");
    
    res->data.struct_val.pairs[1].value.data.array_val.items[2].type = TYPE_STRING;
    res->data.struct_val.pairs[1].value.data.array_val.items[2].data.string_val = strdup("management");
    
    // Metadata with mixed types
    res->data.struct_val.pairs[2].key = strdup("metadata");
    res->data.struct_val.pairs[2].value.type = TYPE_STRUCT;
    res->data.struct_val.pairs[2].value.data.struct_val.size = 3;
    res->data.struct_val.pairs[2].value.data.struct_val.pairs = (KeyValue*)calloc(3, sizeof(KeyValue));
    
    // Add metadata fields
    res->data.struct_val.pairs[2].value.data.struct_val.pairs[0].key = strdup("active");
    res->data.struct_val.pairs[2].value.data.struct_val.pairs[0].value.type = TYPE_BOOL;
    res->data.struct_val.pairs[2].value.data.struct_val.pairs[0].value.data.bool_val = true;
    
    res->data.struct_val.pairs[2].value.data.struct_val.pairs[1].key = strdup("score");
    res->data.struct_val.pairs[2].value.data.struct_val.pairs[1].value.type = TYPE_FLOAT;
    res->data.struct_val.pairs[2].value.data.struct_val.pairs[1].value.data.float_val = 95.5;
    
    res->data.struct_val.pairs[2].value.data.struct_val.pairs[2].key = strdup("id");
    res->data.struct_val.pairs[2].value.data.struct_val.pairs[2].value.type = TYPE_STRING;
    res->data.struct_val.pairs[2].value.data.struct_val.pairs[2].value.data.string_val = strdup("USR-123");
    
    printf("Complex nested structure created\n");
} else {
    printf("Failed to create structure\n");
    res = NULL;
}
')
xc.Execute()
? @@( xc.Result() )
#--> [
#	[
#		"person",
#		[ [ "name", "Alice" ], [ "age", 28 ] ]
#	],
#	[ "skills", [ "programming", "design", "management" ] ],
#	[
#		"metadata",
#		[ [ "active", 1 ], [ "score", 95.50 ], [ "id", "USR-123" ] ]
#	]
# ]

proff()
# Executed in 0.35 second(s) in Ring 1.22

/*===================================#
#  EXAMPLES FOR THE PROLOG LANGUAGE  #
#====================================#

/*--- Simple program that creates a list of factorials
*/
oProlog = new stzExtCodeXT(:Prolog)

oProlog.SetCode('
% Compute factorial
factorial(0, 1).
factorial(N, F) :-
    N > 0,
    N1 is N - 1,
    factorial(N1, F1),
    F is N * F1.

% Create a list with factorials from 1 to 10
get_factorials(Result) :-
    findall(
        N-Fact,
        (between(1, 10, N), factorial(N, Fact)),
        Result
    ).

% Define the main result - this will be transformed
res(Result) :- get_factorials(Result).
')

oProlog.Run()
? @@( oProlog.Result() )
proff()

/*=============================================#
#  A BIT OF FUN: THE GRAND PERFORMANCE BATTLE  #
#==============================================#

/*------------------------------#
#  BENCHMARK FOR RING LANGAUGE  #
#-------------------------------#

pr()

    results = []
    
    # 1. Fibonacci benchmark
    #------------------------

    n = 450
    startTime = clock()
    result = ringFib(n)
    endTime = clock()
    fibTime = (endTime - startTime) / clockspersecond() * 1000
    
    add(results, ["fibonacci", [
        ["n", n],
        ["result", result],
        ["time_ms", fibTime]
    ]])
    

    # 2. Sorting benchmark
    #----------------------

    startTime = clock()
    arraySize = 1000_000
    array = list(arraySize)
    
    # Fill with random numbers (using same seed as C)

    random(42)  // Set seed
    for i = 1 to arraySize
        array[i] = random(9999)
    next
    
    # Sort the array

    ringQuickSort(array, 1, arraySize)
    endTime = clock()
    sortTime = (endTime - startTime) / clockspersecond() * 1000
    
    add(results, ["sorting", [
        ["array_size", arraySize],
        ["time_ms", sortTime]
    ]])
    

    # 3. Matrix multiplication benchmark
    #------------------------------------

    startTime = clock()
    matrixSize = 250
    
    # Initialize matrices

    matrix1 = list(matrixSize)
    matrix2 = list(matrixSize)
    resultMatrix = list(matrixSize)
    
    for i = 1 to matrixSize
        matrix1[i] = list(matrixSize)
        matrix2[i] = list(matrixSize)
        resultMatrix[i] = list(matrixSize)
        
        for j = 1 to matrixSize
            matrix1[i][j] = random(99)
            matrix2[i][j] = random(99)
            resultMatrix[i][j] = 0
        next
    next
    
    # Matrix multiplication

    for i = 1 to matrixSize
        for j = 1 to matrixSize
            for k = 1 to matrixSize
                resultMatrix[i][j] += matrix1[i][k] * matrix2[k][j]
            next
        next
    next
    
    endTime = clock()
    matrixTime = (endTime - startTime) / clockspersecond() * 1000
    
    add(results, ["matrix", [
        ["matrix_size", matrixSize],
        ["time_ms", matrixTime]
    ]])
    
? @@( results )
#--> [
#	[
#		"fibonacci",
#		[ [ "n", 450 ], [ "result", 4953967011875060426190016040962563748574111464292417351569305200915826269230622714208530202624.00 ], [ "time_ms", 1 ] ]
#	],
#	[
#		"sorting",
#		[ [ "array_size", 1000000 ], [ "time_ms", 29923 ] ]
#	],
#	[
#		"matrix",
#		[ [ "matrix_size", 250 ], [ "time_ms", 7805 ] ]
#	]
# ]

proff()
# Executed in 37.83 second(s) in Ring 1.22

# Ring fibonacci implementation

func ringFib n
    if n <= 1 return n ok
    
    a = 0 b = 1
    for i = 2 to n
        temp = a + b
        a = b
        b = temp
    next
    return b

# Ring quicksort implementation

func ringQuickSort arr, low, high
    if low < high
        // Partition the array
        pivot = arr[high]
        i = low - 1
        
        for j = low to high - 1
            if arr[j] < pivot
                i++
                temp = arr[i]
                arr[i] = arr[j]
                arr[j] = temp
            ok
        next
        
        temp = arr[i + 1]
        arr[i + 1] = arr[high]
        arr[high] = temp
        
        partition = i + 1
        
        // Recursively sort the sub-arrays
        ringQuickSort(arr, low, partition - 1)
        ringQuickSort(arr, partition + 1, high)

   ok

/*---------------------------#
#  BENCHMARK FOR C LANGAUGE  #
#----------------------------#

pr()

cCCode = '
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <stdint.h>

// Function to calculate fibonacci numbers iteratively
// Using uint64_t for larger fibonacci numbers
uint64_t fib(int n) {
    if (n <= 1) return n;
    
    uint64_t a = 0, b = 1, temp;
    for (int i = 2; i <= n; i++) {
        temp = a + b;
        a = b;
        b = temp;
    }
    return b;
}

// Function to sort an array using quicksort
void quicksort(int arr[], int low, int high) {
    if (low < high) {
        // Partition the array
        int pivot = arr[high];
        int i = low - 1;
        
        for (int j = low; j <= high - 1; j++) {
            if (arr[j] < pivot) {
                i++;
                int temp = arr[i];
                arr[i] = arr[j];
                arr[j] = temp;
            }
        }
        
        int temp = arr[i + 1];
        arr[i + 1] = arr[high];
        arr[high] = temp;
        
        int partition = i + 1;
        
        // Recursively sort the sub-arrays
        quicksort(arr, low, partition - 1);
        quicksort(arr, partition + 1, high);
    }
}

// Performance benchmark
Value* res = create_struct_value(3);
if (res) {
    // 1. Fibonacci sequence benchmark
    clock_t start = clock();
    int n = 450;  // Calculate the 450th Fibonacci number (matching Ring)
    uint64_t result = fib(n);
    clock_t end = clock();
    double fib_time = ((double)(end - start)) / CLOCKS_PER_SEC * 1000;
    
    // Store fibonacci result
    if (res->data.struct_val.pairs) {
        res->data.struct_val.pairs[0].key = strdup("fibonacci");
        Value* fib_struct = create_struct_value(3);
        
        fib_struct->data.struct_val.pairs[0].key = strdup("n");
        fib_struct->data.struct_val.pairs[0].value.type = TYPE_INT;
        fib_struct->data.struct_val.pairs[0].value.data.int_val = n;
        
        fib_struct->data.struct_val.pairs[1].key = strdup("result");
        fib_struct->data.struct_val.pairs[1].value.type = TYPE_INT;
        fib_struct->data.struct_val.pairs[1].value.data.int_val = result;
        
        fib_struct->data.struct_val.pairs[2].key = strdup("time_ms");
        fib_struct->data.struct_val.pairs[2].value.type = TYPE_FLOAT;
        fib_struct->data.struct_val.pairs[2].value.data.float_val = fib_time;
        
        res->data.struct_val.pairs[0].value.type = TYPE_STRUCT;
        res->data.struct_val.pairs[0].value.data.struct_val = fib_struct->data.struct_val;
        free(fib_struct);
    }
    
    // 2. Sorting benchmark
    start = clock();
    int array_size = 1000000;  // Match Ring 1,000,000 array size
    int* array = (int*)malloc(array_size * sizeof(int));
    
    // Fill with random numbers
    srand(42);  // Fixed seed for reproducibility (same as Ring)
    for (int i = 0; i < array_size; i++) {
        array[i] = rand() % 10000;  // Random numbers between 0-9999
    }
    
    // Sort the array
    quicksort(array, 0, array_size - 1);
    end = clock();
    double sort_time = ((double)(end - start)) / CLOCKS_PER_SEC * 1000;
    free(array);
    
    // Store sorting result
    if (res->data.struct_val.pairs) {
        res->data.struct_val.pairs[1].key = strdup("sorting");
        Value* sort_struct = create_struct_value(2);
        
        sort_struct->data.struct_val.pairs[0].key = strdup("array_size");
        sort_struct->data.struct_val.pairs[0].value.type = TYPE_INT;
        sort_struct->data.struct_val.pairs[0].value.data.int_val = array_size;
        
        sort_struct->data.struct_val.pairs[1].key = strdup("time_ms");
        sort_struct->data.struct_val.pairs[1].value.type = TYPE_FLOAT;
        sort_struct->data.struct_val.pairs[1].value.data.float_val = sort_time;
        
        res->data.struct_val.pairs[1].value.type = TYPE_STRUCT;
        res->data.struct_val.pairs[1].value.data.struct_val = sort_struct->data.struct_val;
        free(sort_struct);
    }
    
    // 3. Matrix multiplication benchmark
    start = clock();
    int matrix_size = 250;  // Match Ring 250 matrix size
    int** matrix1 = (int**)malloc(matrix_size * sizeof(int*));
    int** matrix2 = (int**)malloc(matrix_size * sizeof(int*));
    int** result_matrix = (int**)malloc(matrix_size * sizeof(int*));
    
    for(int i = 0; i < matrix_size; i++) {
        matrix1[i] = (int*)malloc(matrix_size * sizeof(int));
        matrix2[i] = (int*)malloc(matrix_size * sizeof(int));
        result_matrix[i] = (int*)malloc(matrix_size * sizeof(int));
        
        for(int j = 0; j < matrix_size; j++) {
            matrix1[i][j] = rand() % 100;  // Random numbers between 0-99
            matrix2[i][j] = rand() % 100;
            result_matrix[i][j] = 0;
        }
    }
    
    // Matrix multiplication
    for(int i = 0; i < matrix_size; i++) {
        for(int j = 0; j < matrix_size; j++) {
            for(int k = 0; k < matrix_size; k++) {
                result_matrix[i][j] += matrix1[i][k] * matrix2[k][j];
            }
        }
    }
    
    end = clock();
    double matrix_time = ((double)(end - start)) / CLOCKS_PER_SEC * 1000;
    
    // Free memory
    for(int i = 0; i < matrix_size; i++) {
        free(matrix1[i]);
        free(matrix2[i]);
        free(result_matrix[i]);
    }
    free(matrix1);
    free(matrix2);
    free(result_matrix);
    
    // Store matrix multiplication result
    if (res->data.struct_val.pairs) {
        res->data.struct_val.pairs[2].key = strdup("matrix");
        Value* matrix_struct = create_struct_value(2);
        
        matrix_struct->data.struct_val.pairs[0].key = strdup("matrix_size");
        matrix_struct->data.struct_val.pairs[0].value.type = TYPE_INT;
        matrix_struct->data.struct_val.pairs[0].value.data.int_val = matrix_size;
        
        matrix_struct->data.struct_val.pairs[1].key = strdup("time_ms");
        matrix_struct->data.struct_val.pairs[1].value.type = TYPE_FLOAT;
        matrix_struct->data.struct_val.pairs[1].value.data.float_val = matrix_time;
        
        res->data.struct_val.pairs[2].value.type = TYPE_STRUCT;
        res->data.struct_val.pairs[2].value.data.struct_val = matrix_struct->data.struct_val;
        free(matrix_struct);
    }
} else {
    printf("Failed to create result structure\n");
    res = NULL;
}
'

C = new StzExtCodeXT("c")
C.SetCode(cCCode) 

// Execute the C code and get results
C.Execute()
? @@( C.Result() )
#--> [
#	[
#	[
#		"fibonacci",
#		[ [ "n", 450 ], [ "result", -8044227546631567360.00 ], [ "time_ms", 0 ] ]
#	],
#	[
#		"sorting",
#		[ [ "array_size", 1000000 ], [ "time_ms", 197 ] ]
#	],
#	[
#		"matrix",
#		[ [ "matrix_size", 250 ], [ "time_ms", 61 ] ]
#	]
# ]

proff()
# Executed in 0.61 second(s) in Ring 1.22

/*--------------------------------#
#  BENCHMARK FOR PYTHON LANGAUGE  #
#---------------------------------#

pr()

cPythonCode = '
import time
import random

# 1. Fibonacci benchmark
def fib(n):
    if n <= 1:
        return n
    
    a, b = 0, 1
    for i in range(2, n + 1):
        a, b = b, a + b
    return b

# 2. Quicksort implementation
def quicksort(arr, low, high):
    if low < high:
        # Partition the array
        pivot = arr[high]
        i = low - 1
        
        for j in range(low, high):
            if arr[j] < pivot:
                i += 1
                arr[i], arr[j] = arr[j], arr[i]
        
        arr[i + 1], arr[high] = arr[high], arr[i + 1]
        
        partition = i + 1
        
        # Recursively sort the sub-arrays
        quicksort(arr, low, partition - 1)
        quicksort(arr, partition + 1, high)

# Performance benchmark
results = []

# 1. Fibonacci sequence benchmark
n = 450
start_time = time.time()
result = fib(n)
end_time = time.time()
fib_time = (end_time - start_time) * 1000  # Convert to milliseconds

results.append(["fibonacci", [
    ["n", n],
    ["result", result],
    ["time_ms", fib_time]
]])

# 2. Sorting benchmark
start_time = time.time()
array_size = 1000000  # One million elements
array = []

# Fill with random numbers
random.seed(42)  # Fixed seed for reproducibility
for i in range(array_size):
    array.append(random.randint(0, 9999))

# Sort the array
quicksort(array, 0, array_size - 1)
end_time = time.time()
sort_time = (end_time - start_time) * 1000  # Convert to milliseconds

results.append(["sorting", [
    ["array_size", array_size],
    ["time_ms", sort_time]
]])

# 3. Matrix multiplication benchmark
start_time = time.time()
matrix_size = 250

# Initialize matrices
matrix1 = []
matrix2 = []
result_matrix = []

for i in range(matrix_size):
    matrix1.append([0] * matrix_size)
    matrix2.append([0] * matrix_size)
    result_matrix.append([0] * matrix_size)
    
    for j in range(matrix_size):
        matrix1[i][j] = random.randint(0, 99)
        matrix2[i][j] = random.randint(0, 99)

# Matrix multiplication
for i in range(matrix_size):
    for j in range(matrix_size):
        for k in range(matrix_size):
            result_matrix[i][j] += matrix1[i][k] * matrix2[k][j]

end_time = time.time()
matrix_time = (end_time - start_time) * 1000  # Convert to milliseconds

results.append(["matrix", [
    ["matrix_size", matrix_size],
    ["time_ms", matrix_time]
]])

# Return results
res = results'

py = new stzExtCodeXT(:Python)
py.setCode(cPythonCode)

py.Run()
? @@( py.Result() )
#--> [
#	[
#		"fibonacci",
#		[ [ "n", 450 ], [ "result", 4953967011875066910547013330669507468549271950815257134688446476787412478855327157343790039040.00 ], [ "time_ms", 0 ] ]
#	],
#	[
#		"sorting",
#		[ [ "array_size", 1000000 ], [ "time_ms", 3896.04 ] ]
#	],
#	[
#		"matrix",
#		[ [ "matrix_size", 250 ], [ "time_ms", 2512.93 ] ]
#	]
# ]

proff()
# Executed in 8.51 second(s) in Ring 1.22

/*---------------------------#
#  BENCHMARK FOR R LANGAUGE  #
#----------------------------#

cRCode = '
# 1. Fibonacci function
fib <- function(n) {
  if (n <= 1) return(n)
  
  a <- 0
  b <- 1
  for (i in 2:n) {
    temp <- a + b
    a <- b
    b <- temp
  }
  return(b)
}

# 2. Quicksort implementation
quicksort <- function(arr, low, high) {
  if (low < high) {
    # Partition the array
    pivot <- arr[high]
    i <- low - 1
    
    for (j in low:(high-1)) {
      if (arr[j] < pivot) {
        i <- i + 1
        temp <- arr[i]
        arr[i] <- arr[j]
        arr[j] <- temp
      }
    }
    
    temp <- arr[i + 1]
    arr[i + 1] <- arr[high]
    arr[high] <- temp
    
    partition <- i + 1
    
    # Recursively sort the sub-arrays
    arr <- quicksort(arr, low, partition - 1)
    arr <- quicksort(arr, partition + 1, high)
  }
  return(arr)
}

# Performance benchmark
results <- list()

# 1. Fibonacci sequence benchmark
n <- 450
start_time <- proc.time()
result <- fib(n)
end_time <- proc.time()
fib_time <- (end_time - start_time)[3] * 1000  # Convert to milliseconds

results$fibonacci <- list(
  n = n,
  result = result,
  time_ms = fib_time
)

# 2. Sorting benchmark
start_time <- proc.time()
array_size <- 1000000  # One million elements
array <- numeric(array_size)

# Fill with random numbers
set.seed(42)  # Fixed seed for reproducibility
for (i in 1:array_size) {
  array[i] <- floor(runif(1, 0, 10000))
}

# Note: For large arrays, we will use R built-in sort for performance
# but measure the time regardless
array <- sort(array)
end_time <- proc.time()
sort_time <- (end_time - start_time)[3] * 1000  # Convert to milliseconds

results$sorting <- list(
  array_size = array_size,
  time_ms = sort_time
)

# 3. Matrix multiplication benchmark
start_time <- proc.time()
matrix_size <- 250

# Initialize matrices
set.seed(42)
matrix1 <- matrix(floor(runif(matrix_size * matrix_size, 0, 100)), nrow = matrix_size)
matrix2 <- matrix(floor(runif(matrix_size * matrix_size, 0, 100)), nrow = matrix_size)

# Matrix multiplication (using R built-in operator)
result_matrix <- matrix1 %*% matrix2

end_time <- proc.time()
matrix_time <- (end_time - start_time)[3] * 1000  # Convert to milliseconds

results$matrix <- list(
  matrix_size = matrix_size,
  time_ms = matrix_time
)

# Return results in the expected format for StzExtCodeXT
res <- list(
  list("fibonacci", list(
    list("n", n),
    list("result", result),
    list("time_ms", fib_time)
  )),
  list("sorting", list(
    list("array_size", array_size),
    list("time_ms", sort_time)
  )),
  list("matrix", list(
    list("matrix_size", matrix_size),
    list("time_ms", matrix_time)
  ))
)'

R = new stzExtCodeXT(:R)
R.SetCode(cRCode)
R.Run()
? @@( R.Result() )
#--> [
#	[ 'fibonacci', [['n', 450], ['result', 4.95396701187506e+93], ['time_ms', 20]]],
# 	['sorting', [['array_size', 1e+06], ['time_ms', 690]]],
#	['matrix', [['matrix_size', 250], ['time_ms', 10]]]
# ]

proff()
# Executed in 4.53 second(s) in Ring 1.22

/*-------------------------------#
#  BENCHMARK FOR JULIA LANGAUGE  #
#--------------------------------#

pr()

cJuliaCode = '
# 1. Fibonacci function
function fib(n)
    if n <= 1
        return n
    end
    
    a, b = 0, 1
    for i in 2:n
        a, b = b, a + b
    end
    return b
end

# 2. Quicksort implementation
function quicksort!(arr, low, high)
    if low < high
        # Partition the array
        pivot = arr[high]
        i = low - 1
        
        for j in low:(high-1)
            if arr[j] < pivot
                i += 1
                arr[i], arr[j] = arr[j], arr[i]
            end
        end
        
        arr[i+1], arr[high] = arr[high], arr[i+1]
        
        partition = i + 1
        
        # Recursively sort the sub-arrays
        quicksort!(arr, low, partition - 1)
        quicksort!(arr, partition + 1, high)
    end
    return arr
end

# Performance benchmark
using Random
using LinearAlgebra

results = []

# 1. Fibonacci sequence benchmark
n = 450
start_time = time()
result = fib(n)
end_time = time()
fib_time = (end_time - start_time) * 1000  # Convert to milliseconds

push!(results, ["fibonacci", [
    ["n", n],
    ["result", result],
    ["time_ms", fib_time]
]])

# 2. Sorting benchmark
start_time = time()
array_size = 1000000  # One million elements
array = zeros(Int, array_size)

# Fill with random numbers
Random.seed!(42)  # Fixed seed for reproducibility
for i in 1:array_size
    array[i] = rand(0:9999)
end

# Sort the array (using Julia built-in sort! for performance on large arrays)
sort!(array)
end_time = time()
sort_time = (end_time - start_time) * 1000  # Convert to milliseconds

push!(results, ["sorting", [
    ["array_size", array_size],
    ["time_ms", sort_time]
]])

# 3. Matrix multiplication benchmark
start_time = time()
matrix_size = 250

# Initialize matrices
Random.seed!(42)
matrix1 = rand(0:99, matrix_size, matrix_size)
matrix2 = rand(0:99, matrix_size, matrix_size)

# Matrix multiplication (using Julia built-in multiplication)
result_matrix = matrix1 * matrix2

end_time = time()
matrix_time = (end_time - start_time) * 1000  # Convert to milliseconds

push!(results, ["matrix", [
    ["matrix_size", matrix_size],
    ["time_ms", matrix_time]
]])

# Return results
res = Dict(
    "fibonacci" => Dict(
        "n" => n,
        "result" => result,
        "time_ms" => fib_time
    ),
    "sorting" => Dict(
        "array_size" => array_size,
        "time_ms" => sort_time
    ),
    "matrix" => Dict(
        "matrix_size" => matrix_size,
        "time_ms" => matrix_time
    )
)'

J = new stzExtCodeXT(:Julia)
J.SetCode(cJuliaCode)
J.Run()
? @@( J.Result() )
#--> [
#	[
#		"fibonacci",
#		[ [ "n", 450 ], [ "time_ms", 11.00 ], [ "result", -8044227546631567360.00 ] ]
#	],
#	[
#		"matrix",
#		[ [ "time_ms", 255.00 ], [ "matrix_size", 250 ] ]
#	],
#	[
#		"sorting",
#		[ [ "time_ms", 944.00 ], [ "array_size", 1000000 ] ]
#	]
# ]

proff()
# Executed in 4.18 second(s) in Ring 1.22 : AFTER FIRST STARTUP
# Executed in 2.04 second(s) in Ring 1.22 : AFTER WARM-UP

