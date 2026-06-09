# Narrative
# --------
# Simple nested list with different data types
#
# Extracted from stzextercodetest.ring, block #13.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

R = new stzExterCode("r")

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

pf()
# Executed in 0.46 second(s) in Ring 1.23
