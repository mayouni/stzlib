# Narrative
# --------
# Data analysis with NA handling
#
# Extracted from stzrcodetest.ring, block #4.

load "../../../stzBase.ring"


pr()

R() {
# Start of R script
@('
measurements <- c(23.5, NA, 22.1, 24.3, NA, 21.8)
res <- list(
    measurements = measurements,
    analysis = list(
        complete_cases = sum(!is.na(measurements)),
        mean_without_na = mean(measurements, na.rm = TRUE),
        na_positions = which(is.na(measurements))
    )
)
') # End of R script

# Back to Ring
Run()
? @@( Result() )

} # Closing brace of the R() object

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
# Executed in 0.32 second(s) in Ring 1.22
