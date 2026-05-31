# Narrative
# --------
# Time series data with aggregation
#
# Extracted from stzextercodetest.ring, block #17.

load "../../../stzBase.ring"


pr()

R = new stzExterCode(:R)

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

pf()
# Executed in 0.49 second(s) in Ring 1.23
