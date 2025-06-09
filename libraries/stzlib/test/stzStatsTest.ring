load "../max/stzmax.ring"

#-------------------------------------------------#
#  COMPREHENSIVE TEST FILE FOR stzStats CLASS     #
#-------------------------------------------------#

/*
This test file validates:
- Pillar 1: Comparison (Descriptive Statistics)
- Pillar 2: Composition (Frequency & Categorical Analysis)
- Pillar 3: Distribution (Shape & Spread Analysis)
- Pillar 4: Relation (Correlation & Association Analysis)
- Data Transformation & Normalization
- Insight Generation with Custom Rules
- Quality Assurance & Utility Methods
- Edge Cases (Missing Values, Empty Data, Single Value)
*/

# Because we are dealing with statistics, let's work on that precesion
decimals(4)

/*-- Basic Numeric Data Analysis (Comparison Pillar)

pr()
oStats = new stzStats([10, 15, 20, 25, 30, 35, 40])
oStats {
    ? Mean()           # Expected: 25
    ? Median()         # Expected: 25
    ? StandardDeviation() # Expected: 10.8012
    ? Range()          # Expected: 30
    ? Sum()            # Expected: 175
    ? GeometricMean()  # Expected: 23.0823	Got: 22.7458
    ? HarmonicMean()   # Expected: 21.3052	Got: 20.3742
    ? CoefficientOfVariation() # Expected: 43.2048	Got: 100
}

pf()
# Executed in 0.0020 second(s) in Ring 1.22

/*--- Quartile and Percentile Analysis (Distribution Pillar)

pr()

oStats = new stzStats([1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50])
oStats {
    ? Q1()             # Expected: 10	Got: 8.75
    ? Q2()             # Expected: 25
    ? Q3()             # Expected: 40	Got: 36.25
    ? IQR()            # Expected: 30	Got: 27.5
    ? Percentile(90)   # Expected: 45	Got: 44.5
    ? Skewness()       # Expected: 0 (approx, symmetric) Got 0.0027
    ? Kurtosis()       # Expected: -1.2 (approx, platykurtic) Got: -3.8819
}

pf()
# Executed in 0.0020 second(s) in Ring 1.22

/*--- Outlier Detection and Z-Scores (Distribution Pillar)

pr()

oStats = new stzStats([10, 12, 13, 15, 18, 20, 22, 25, 100])

oStats {
    ? @@(FindOutliers()) # Expected: [100]
    ? IsOutlier(100)   # Expected: TRUE
    ? IsOutlier(15)    # Expected: FALSE

    ? @@(ZScores())
	# Expected: [-0.6633, -0.5926, -0.5572, -0.4865, -0.3805, -0.3098, -0.2391, -0.1331, 3.3623] (approx)
	# Got: [ -0.5725, -0.5015, -0.4659, -0.3949, -0.2882, -0.2172, -0.1461, -0.0395, 2.6258 ]
}

pf()
# Executed in 0.0020 second(s) in Ring 1.22

/*--- Categorical Data Frequency Analysis (Composition Pillar)

pr()

oStats = new stzStats(["Red", "Blue", "Red", "Green", "Blue", "Red", "Yellow"])
oStats {
    ? Mode()           # Expected: "Red"
    ? @@(FrequencyTable()) # Expected: [["Red", 3], ["Blue", 2], ["Green", 1], ["Yellow", 1]]
    ? @@(PercentageFrequency()) # Expected: [["Red", 42.8571], ["Blue", 28.5714], ["Green", 14.2857], ["Yellow", 14.2857]]
    ? Diversity()      # Expected: 0.5714
    ? EntropyIndex()   # Expected: 1.8424
}

pf()
# Executed in 0.0150 second(s) in Ring 1.22

/*--- Data Normalization and Standardization (Transformation)

pr()

oStats = new stzStats([100, 200, 300, 400, 500])
oStats {
    ? @@(Normalize())  # Expected: [0, 0.25, 0.5, 0.75, 1]
    ? @@(Standardize()) # Expected: [-1.2649, -0.6325, 0, 0.6325, 1.2649] (approx)

    ? @@(RobustScale())
	# Expected: [-1, -0.5, 0, 0.5, 1]
	# Got: [ -0.8000, -0.4000, 0, 0.4000, 0.8000 ]

}

pf()
# Executed in 0.0020 second(s) in Ring 1.22

/*--- Correlation and Covariance (Relation Pillar)

pr()

oStats1 = new stzStats([1, 2, 3, 4, 5])
oStats2 = new stzStats([2, 4, 6, 8, 10])

? oStats1.CorrelationWith(oStats2)  # Expected: 1 (perfect positive correlation)
? oStats1.CovarianceWith(oStats2)   # Expected: 5
? oStats1.RankCorrelationWith(oStats2) # Expected: 1

pf()
# Executed in 0.0230 second(s) in Ring 1.22

/*--- 7: Insight Generation for Numeric Data

pr()

oStats = new stzStats([10, 12, 13, 15, 18, 20, 22, 25, 100])
? @@NL(oStats.Insight())
#--> [
#	"Data shows positive skew (mean 26.1111 > median 18)",
#	"High variability (CV = 100%) indicates diverse data points",
#	"Light-tailed distribution (kurtosis = -3.3227) indicates fewer extreme values",
#	"Contains 1 outlier(s) (11.1111% of data)",
#	"High outlier proportion may distort mean-based statistics",
#	"Small sample size (n = 9) limits statistical reliability"
# ]

pf()
# Executed in 0.0030 second(s) in Ring 1.22

/*--- Insight Generation for Categorical Data

pr()

oStats = new stzStats(["A", "B", "A", "C", "A", "D"])
? @@NL(oStats.Insight())
#--> [
#	"Moderate diversity (66.6700%) shows balanced distribution",
#	"Information entropy (1.7925) indicates balanced category distribution",
#	"'A' is most common (50%) but distribution remains balanced"
# ]

pf()
# Executed in 0.0110 second(s) in Ring 1.22

/*--- Mixed Data Type Handling

pr()

oStats = new stzStats([1, "text", 3, 4, "another"])
? oStats.DataType()  #--> "mixed"
? @@NL(oStats.Insight())
#--> [
#	"Mixed dataset containing both numeric and categorical data (5 unique values from 5 total)",
#	"Consider separating data types for specialized analysis. Numeric methods apply only to numeric subset"
# ]

pf()
# Executed in 0.0020 second(s) in Ring 1.22

/*--- Empty Dataset Handling

pr()

oStats = new stzStats([])
? oStats.DataType()  # Expected: "empty"
? oStats.Mean()      # Expected: 0
? oStats.Median()    # Expected: 0
? oStats.Mode()      # Expected: NULL
? oStats.Insight()
#--> "Dataset is empty. No analysis possible without data."
pf()
# Executed in 0.0010 second(s) in Ring 1.22

/*--- Single Value Dataset

pr()
oStats = new stzStats([42])
? oStats.Mean()      # Expected: 42
? oStats.Median()    # Expected: 42
? oStats.StandardDeviation() # Expected: 0
? @@NL(oStats.Insight())
#--> [
#	"The data is symmetrically distributed with mean 42 and median 42.",
#	"The data shows low variability with a coefficient of variation of 0%, indicating consistent values.",
#	"Small sample size (n = 1) limits statistical reliability"
# ]

pf()
# Executed in 0.0030 second(s) in Ring 1.22

/*--- 12: Missing Values Handling

pr()

oStats = new stzStats([1, "NA", 3, "NULL", 5, "#N/A"])
? @@(oStats.Data())  # Expected: [1, 3, 5]
? oStats.Count()     # Expected: 3
? oStats.Mean()      # Expected: 3

pf()
# Executed in 0.0010 second(s) in Ring 1.22

/*--- Data Validation

pr()

oStats = new stzStats([1, 2, 3, 4, 5, 100])
? @@(oStats.ValidateData())
# Expected: ["High proportion of outliers detected"]
# Got: [ "Data quality appears good" ]

pf()
# Executed in 0.0020 second(s) in Ring 1.22

/*--- Recommendation for Analysis

pr()

oStats = new stzStats([1, 2, 3, 4, 5, 100])
? @@NL(oStats.RecommendAnalysis())

# Expected: [
#	"Data is skewed - consider using median instead of mean",
#	"Outliers detected - consider robust statistics",
#	"High variability - segment analysis recommended"
# ]

# Got: [
#	"Small sample size - interpret results cautiously",
#	"Outliers detected - consider robust statistics",
#	"High variability - segment analysis recommended"
# ]

pf()
# Executed in 0.0030 second(s) in Ring 1.22

/*--- Custom Insight Rules

pr()

oStats = new stzStats([10, 20, 30, 40, 50])
oStats {

	AddInsightRule(
		:Finance,
		"Mean() > 20",
		"Mean (" + Mean() + ") exceeds threshold (20) for financial analysis"
	)

	? Mean() #--> 30

	? @@NL( DomainInsights(:Finance) )
	#--> [ "Mean (30) exceeds threshold (20) for financial analysis" ]

}

pf()
# Executed in 0.0060 second(s) in Ring 1.22

/*--- Time Series Analysis (Moving Average)

pr()

oStats = new stzStats([1, 3, 5, 7, 9, 11])
? @@(oStats.MovingAverage(3))  # Expected: [3, 5, 7, 9]

pf()
# Executed in 0.0010 second(s) in Ring 1.22

/*--- Dataset Comparison

pr()

oStats1 = new stzStats([1, 2, 3, 4, 5])
oStats2 = new stzStats([2, 4, 6, 8, 10])

? @@NL(oStats1.CompareWith(oStats2))
# Expected: [
#	"Mean difference: -50%",
#	"Similar variability patterns",
#	"Strong positive correlation (1)"
# ]

# Got: [
#	"Mean difference: -50%",
#	"Dataset 2 shows higher variability",
#	"Strong positive correlation (1)"
# ]

pf()
# Executed in 0.0020 second(s) in Ring 1.22

/*--- Similarity Score

pr()

oStats1 = new stzStats([1, 2, 3, 4, 5])
oStats2 = new stzStats([1, 2, 3, 4, 5])

? oStats1.SimilarityScore(oStats2)  # Expected: 1 (identical datasets)

pf()
# Executed in 0.0020 second(s) in Ring 1.22

/*--- 19: Summary Generation

pr()
oStats = new stzStats([10, 20, 30, 40, 50])
? oStats.Summary()  # Expected: Detailed summary including type, count, mean, median, etc., and insights
#-->
# === Dataset Summary ===
# Type: numeric
# Count: 5
# Mean: 30
# Median: 30
# Standard Deviation: 15.8114
# Range: 40 (10 to 50)
# Quartiles: Q1=12.5000, Q2=30, Q3=37.5000

# === Insights ===
# • Data shows negative skew (mean 15.8114 < median 30)
# • High variability (CV = 100%) indicates diverse data points
# • Light-tailed distribution (kurtosis = -6.6961) indicates fewer extreme values
# • Small sample size (n = 5) limits statistical reliability

pf()
# Executed in 0.0030 second(s) in Ring 1.22

/*--- Export Functionality

pr()

oStats = new stzStats([10, 20, 30, 40, 50])
? @@NL(oStats.Export())  # Expected: Structured hash list with statistical results
#--> [
#	[ "data_type", "numeric" ],
#	[ "count", 5 ],
#	[ "unique_count", 5 ],
#	[ "mean", 30 ],
#	[ "median", 30 ],
#	[ "mode", "10" ],
#	[ "standard_deviation", 15.8114 ],
#	[ "variance", 501.6435 ],
#	[ "range", 40 ],
#	[ "min", 10 ],
#	[ "max", 50 ],
#	[ "quartiles", [ 12.5000, 30, 37.5000 ] ],
#	[ "skewness", 0.3602 ],
#	[ "kurtosis", -6.6974 ],
#	[ "outliers", [ ] ]
# ]

pf()

/*--- Precision Control

pr()
oStats = new stzStats([1.23456, 2.34567, 3.45678])
oStats {
	SetPrecision(2)
	? Mean()  # Expected: 2.35 (rounded to 2 decimals)
}

pf()
# Executed in 0.0010 second(s) in Ring 1.22

/*--- Confidence Interval

pr()

oStats = new stzStats([10, 20, 30, 40, 50])
? @@(oStats.ConfidenceInterval(95))
# Expected: [17.6076, 42.3924] (approx with t=1.96)
# Got : [ 16.1407, 43.8593 ]

pf()
# Executed in 0.0010 second(s) in Ring 1.22

/*--- Trend Analysis

pr()

oStats = new stzStats([1, 3, 5, 7, 9])
? oStats.TrendAnalysis()
# Expected: "increasing"
# Should give:
# [ [ "inccreasing", 5 ] ]
# Increasing over the 5 items of the dataset

oStats = new stzStats([ 7, 4, 3, 1 ])
? oStats.TrendAnalysis() # Gives "decreasing"
# Should give:
#--> [ "decreasing", 4 ]
# Decreasing over the 4 items of the dataset

oStats = new stzStats([ 7, 4, 3, 1, 5, 9, 12 ])
? oStats.TrendAnalysis()
#--> "increasing"
#ERROR Should give:
# [ [ "decreasing, 3 ] , [ :inflecting, 1 ], [ "increasing", 3 ] ]
# Decreasing over 3 items, inflecting at 1 item (the 4th), and the increasing over the 3 remaining items.")


pf()
# Executed in 0.0010 second(s) in Ring 1.22

#---------------------------------------------
# Example: Chi-Square Test for Independence
#---------------------------------------------
*/
pr()

# Scenario: Testing if gender (Male/Female) is independent
# of product preference (Like/Dislike)

# Sample data
aGender = ["Male", "Female", "Male", "Female", "Male", "Female", "Male", "Female", "Male", "Female"]
aPreference = ["Like", "Like", "Dislike", "Dislike", "Like", "Like", "Dislike", "Like", "Dislike", "Like"]

# Create stzStats objects
oStats1 = new stzStats(aGender)
oStats2 = new stzStats(aPreference)

# Perform chi-square test

# Chi-Square Statistic
? oStats1.ChiSquareWith(oStats2)
# Expected: 0.4762 (see calculation below)
# Got: 1.6667

	# Expected contingency table:
	#           Like | Dislike
	# Male    |  3   |   2
	# Female  |  4   |   1
	# 
	# Row totals: Male = 5, Female = 5
	# Col totals: Like = 7, Dislike = 3
	# Grand total: 10
	# 
	# Expected frequencies:
	# Male-Like: (5*7)/10 = 3.5
	# Male-Dislike: (5*3)/10 = 1.5
	# Female-Like: (5*7)/10 = 3.5
	# Female-Dislike: (5*3)/10 = 1.5
	# 
	# Chi-Square = [(3-3.5)^2/3.5 + (2-1.5)^2/1.5 + (4-3.5)^2/3.5 + (1-1.5)^2/1.5]
	#            = [0.0714 + 0.1667 + 0.0714 + 0.1667] = 0.4762 (rounded to 0.4762)
	
# Invalid case: Numeric data
oStats3 = new stzStats([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])

# Chi-Square with Numeric Data (Invalid)
? oStats1.ChiSquareWith(oStats3)
#--> 0

# Invalid case: Different lengths
oStats4 = new stzStats(["Like", "Dislike"])
? oStats1.ChiSquareWith(oStats4)
#--> 0

pf()
# Executed in 0.0030 second(s) in Ring 1.22
