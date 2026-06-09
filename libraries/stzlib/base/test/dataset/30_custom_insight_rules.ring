# Narrative
# --------
# Custom Insight Rules
#
# Extracted from stzdatasettest.ring, block #30.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

# Allows user-defined rules for domain-specific insights.

pr()

o1 = new stzDataSet([ 10, 20, 30, 40, 50 ])
o1 {

    AddInsightRule(
		:Finance,
		"Mean() > 20", "Mean ({Mean()}) exceeds threshold."
	)

    ? @@NL(InsightsOfDomain(:Finance)) + NL
    #--> [
    # 	"High financial volatility (CV = 52.7046%). Risk assessment required.",
    # 	"Mean (30) exceeds threshold."
    # ]

    ? @@NL(InsightsXT())
    #--> [
    # 	"High variability (CV = 52.7046%) suggests heterogeneous data with significant spread.",
    # 	"Extreme kurtosis detected (-6.6400). Distribution has heavy tails and potential extreme values.",
    # 	"High financial volatility (CV = 52.7046%). Risk assessment required.",
    # 	"Mean (30) exceeds threshold.",
    # 	"High variability in health metrics (CV = 52.7046%). Patient stratification needed.",
    # 	"Below-average performance (median = 30). Curriculum review needed.",
    # 	"High performance variability (CV = 52.7046%). Differentiated instruction required.",
    # 	"Wide quality range (Range/Mean = 1.3333). Process capability study needed."
    # ]

}

pf()

# Executed in 0.07 second(s) in Ring 1.22
