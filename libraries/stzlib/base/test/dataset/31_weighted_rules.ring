# Narrative
# --------
# Weighted Rules
#
# Extracted from stzdatasettest.ring, block #31.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

# Prioritizes insights based on user-assigned weights.

pr()

o1 = new stzDataSet([ 10, 20, 30, 40, 50 ])
o1 {
    AddWeightedRule(
		:Finance,
		"Mean() > 20", "High mean ({Mean()}).",
		2
	)

    AddWeightedRule(:Finance,
		"StandardDeviation() > 10",
		"High volatility ({StandardDeviation()}).",
		1
	)

    ? @@NL(PrioritizedInsights(:Finance))
	#--> [
	# 	[ "High mean (30).", 2 ],
	# 	[
	# 		"High financial volatility (CV = 52.7046%). Risk assessment required.",
	# 		1
	# 	],
	# 	[ "High volatility (15.8114).", 1 ]
	# ]

	? @@NL( InsightsForDomain(:Finance) ) + NL
	#--> [
	# 	"High financial volatility (CV = 52.7046%). Risk assessment required.",
	# 	"High mean (30).",
	# 	"High volatility (15.8114)."
	# ]

	? @@NL( InsightsXT() )
	#--> [
	# "High variability (CV = 52.7046%) suggests heterogeneous data with significant spread.",
	# "Extreme kurtosis detected (-6.6400). Distribution has heavy tails and potential extreme values.",
	# "High financial volatility (CV = 52.7046%). Risk assessment required.",
	# "High mean (30).",
	# "High volatility (15.8114).",
	# "High variability in health metrics (CV = 52.7046%). Patient stratification needed.",
	# "Below-average performance (median = 30). Curriculum review needed.",
	# "High performance variability (CV = 52.7046%). Differentiated instruction required.",
	# "Wide quality range (Range/Mean = 1.3333). Process capability study needed."
	# ]

}

pf()
# Executed in 0.12 second(s) in Ring 1.22

#======================================================================#
#  Data Quality and Validation                                         #
#======================================================================#

# Ensures data reliability through quality checks.
