# Narrative
# --------
# Nested calculations with custom functions
#
# Extracted from stzrcodetest.ring, block #6.

load "../../../stzBase.ring"


pr()

R = new stzRCode

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

pf()
# Executed in 0.32 second(s) in Ring 1.22
