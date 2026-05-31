# Narrative
# --------
# Data analysis with NA handling
#
# Extracted from stzextercodetest.ring, block #14.

load "../../../stzBase.ring"


pr()

R = new stzExterCode("r")

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

pf()
# Executed in 0.46 second(s) in Ring 1.23
