# Narrative
# --------
# Statistical calculations
#
# Extracted from stzextercodetest.ring, block #15.

load "../../../stzBase.ring"


pr()

R = new stzExterCode(:R)

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

pf()
# Executed in 0.45 second(s) in Ring 1.23
