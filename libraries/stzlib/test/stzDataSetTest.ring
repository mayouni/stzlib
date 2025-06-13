load "../max/stzmax.ring"
decimals(4)

#==========================================#
#  1. BASIC STATISTICS & DESCRIPTIVE       #
#==========================================#


/*--- Core descriptive statistics

pr()

o1 = new stzDataSet([10, 15, 20, 25, 30, 35, 40])
o1 {
    ? Mean()
	#--> 25

    ? Median()
	#--> 25

    ? @@(Mode())
	 #--> "10" (first value)

    ? StandardDeviation()
	#--> 10.8012

    ? Variance()
	#--> 116.6667

    ? Range()
	#--> 30

    ? Sum()
	#--> 175

    ? Min()
	#--> 10

    ? Max()
	#--> 40

    ? Count()
	#--> 7

    ? UniqueCount()
	#--> 7

}

pf()
# Executed in 0.0030 second(s) in Ring 1.22

/*--- Alternative means

pr()

o1 = new stzDataSet([2, 8, 32])
o1 {

    ? GeometricMean()
	#--> 8

    ? HarmonicMean()
	#--> 4.5714

}

pf()
# Executed in 0.0010 second(s) in Ring 1.22

/*--- Coefficient of variation

pr()

o1 = new stzDataSet([10, 15, 20, 25, 30, 35, 40])
? o1.CoVar() # Or CoefficientOfVariation
#--> 43.2049

pf()

#==========================================#
#  2. DISTRIBUTION ANALYSIS                #
#==========================================#


/*--- Quartiles and percentiles

pr()

o1 = new stzDataSet([1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50])
o1 {
    ? Q1()
	#--> 12.5

    ? Q2()
	#--> 25

    ? Q3()
	#--> 37.5

    ? IQR() + NL #--> ? ~30
	#--> 25

    ? @@( Quartiles() ) + NL # Or QuartilesXT(:Interpolation)
	#--> [ 12.5, 25, 37.5 ]

    ? @@(QuartilesXT(:Nearest)) + NL
	#--> [ 10, 25, 40 ]

    ? Percentile(90)
	#--> 45
}

pf()
# Executed in 0.0020 second(s) in Ring 1.22

/*--- Shape measures

pr()

o1 = new stzDataSet([1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50])
o1 {
    ? Skewness() # ~> very low skewness because - nearly perfectly symmetric
	#--> 0.0027

    ? Kurtosis()
	#--> -3.9006	~> platykurtic distribution (flatter than normal)

}

pf()
# Executed in 0.0020 second(s) in Ring 1.22

/*--- Outlier detection and z-scores

pr()

o1 = new stzDataSet([10, 12, 13, 15, 18, 20, 22, 25, 100])
o1 {
    ? @@( Outliers() )
	#--> [ 100 ]

    ? IsOutlier(100)
	#--> TRUE

    ? IsOutlier(15)
	#--> FALSE

    ? @@(ZScores())
	#--> [ -0.5725, -0.5015, -0.4659, -0.3949, -0.2882, -0.2172, -0.1461, -0.0395, 2.6258 ]
}

pf()
# Executed in 0.0020 second(s) in Ring 1.22

/*--- Sorted data

pr()

o1 = new stzDataSet([30, 10, 20, 50, 40])
? @@(o1.SortedData())
#--> [ 10, 20, 30, 40, 50 ]

pf()
# Executed in 0.0010 second(s) in Ring 1.22

#==========================================#
#  3. CATEGORICAL DATA & FREQUENCY         #
#==========================================#


/*--- Categorical Data Analysis Tests ==="

pr()

o1 = new stzDataSet(["Red", "Blue", "Red", "Green", "Blue", "Red", "Yellow"])
o1 {
    ? Mode()
	#--> "Red"

    ? @@(FreqTable()) + NL # Or FrequencyTable()
	#--> [ [ "Red", 3 ], [ "Blue", 2 ], [ "Green", 1 ], [ "Yellow", 1 ] ]

    ? @@(PercentFreq()) + NL # Or PercentageFrequency()
	#--> [ [ "Red", 42.8571 ], [ "Blue", 28.5714 ], [ "Green", 14.2857 ], [ "Yellow", 14.2857 ] ]

    ? @@(RelFreq()) + NL # OrRelativeFrequency()
	#--> [ [ "Red", 0.4286 ], [ "Blue", 0.2857 ], [ "Green", 0.1429 ], [ "Yellow", 0.1429 ] ]

    ? @@(UValues()) + NL # Or UniqueValues()
	#--> [ "Red", "Blue", "Green", "Yellow" ]

    ? Diversity() # Or DiversityIndex()
	#--> 0.5714

    ? Entropy() # Or EntropyIndex
	#--> 1.8424

}

pf()
# Executed in 0.0160 second(s) in Ring 1.22

/*--- Data type detection

pr()

o1 = new stzDataSet(["Red", "Blue", "Red", "Green", "Blue", "Red", "Yellow"])
? o1.DataType()
#--> "categorical"

pf()
# Executed in 0.0010 second(s) in Ring 1.22

#==========================================#
#  4. DATA TRANSFORMATION                  #
#==========================================#


/*--- Data Transformation Tests ==="

pr()

o1 = new stzDataSet([100, 200, 300, 400, 500])
o1 {
	# Min-max normalization
    ? @@(Normalize())
	#--> [ 0, 0.2500, 0.5000, 0.7500, 1 ]

	# Z-score standardization
    ? @@(Standardize())
	#--> [ -1.2649, -0.6325, 0, 0.6325, 1.2649 ]

	# Robust Scale (Median and IQR based)
    ? @@(RobustScale())
	#--> [ -1, -0.5000, 0, 0.5000, 1 ]
}

pf()
# Executed in 0.0020 second(s) in Ring 1.22

/*--- Access to original data

pr()

o1 = new stzDataSet([100, 200, 300, 400, 500])
o1 {
    ? @@(Data())	# Original data
	#--> [ 100, 200, 300, 400, 500 ]

    ? @@(Values())	# Same as Data()
	#--> [ 100, 200, 300, 400, 500 ]
}

pf()
# Executed in 0.0010 second(s) in Ring 1.22

#==========================================#
#  5. CORRELATION & RELATIONSHIPS          #
#==========================================#


/*--- Correlation Analysis Tests ==="

pr()

# Correlation measures
o1 = new stzDataSet([1, 2, 3, 4, 5])
o2 = new stzDataSet([2, 4, 6, 8, 10])

? o1.Corelwith(o2) # Or CorrelationWith()
#--> 1

? o1.CoVarwith(o2) # Or CovarianceWith()
#--> 5

? o1.RankCorelWith(o2) # Or RankCorrelationWith()
#--> 1

pf()
# Executed in 0.0240 second(s) in Ring 1.22

/*--- Chi-square test for independence

pr()

aGender = [
	"Male", "Female", "Male", "Female", "Male",
	"Female", "Male", "Female", "Male", "Female"
]

aPreference = [
	"Like", "Like", "Dislike", "Dislike", "Like",
	"Like", "Dislike", "Like", "Dislike", "Like"
]

oGend = new stzDataSet(aGender)
oPref = new stzDataSet(aPreference)

? oGend.ChiSquareWith(oPref)
#--> 1.6667

# Dataset comparison
? @@NL(oGend.CompareWith(oPref))
#--> [ "Similar diversity levels" ]

pf()
# Executed in 0.0030 second(s) in Ring 1.22

/*--- Similarity measures

pr()

o1 = new stzDataSet([1, 2, 3, 4, 5])
? o1.SimilarityScore(o1)
#--> 1

pf()
# Executed in 0.0020 second(s) in Ring 1.22

#==========================================#
#  6. INSIGHT GENERATION                   #
#==========================================#

/*--- Basic insights

pr()

o1 = new stzDataSet([10, 12, 13, 15, 18, 20, 22, 25, 100])
? @@NL( o1.Insights() )
#--> [
#	"Data shows positive skew (mean 26.1111 > median 18)",
#	"High variability (CV = 107.7703%) indicates diverse data points",
#	"Light-tailed distribution (kurtosis = -3.3076) indicates fewer extreme values",
#	"Contains 1 outlier(s) (11.1111% of data)",
#	"High outlier proportion may distort mean-based statistics",
#	"Small sample size (n = 9) limits statistical reliability"
# ]

pf()
# Executed in 0.0040 second(s) in Ring 1.22

/*--- Categorical insights

pr()

o1 = new stzDataSet(["A", "B", "A", "C", "A", "D"])
? @@NL( o1.Insights() )
#--> [
#	"Moderate diversity (66.6667%) shows balanced distribution",
#	"Information entropy (1.7925) indicates balanced category distribution",
#	"'A' is most common (50%) but distribution remains balanced"
# ]

pf()
# Executed in 0.0080 second(s) in Ring 1.22

/*--- Custom insight rules

pr()

o1 = new stzDataSet([10, 20, 30, 40, 50])
o1 {
    AddInsightRule(:Finance, "Mean() > 20", "Mean ({Mean()}) exceeds threshold.")
    ? @@NL(InsightsOfDomain(:Finance)) + NL
	#--> [ "Mean (30) exceeds threshold." ]

	 # All insights including domain insights at the end

    ? @@NL(InsightsXT())
	#--> [
	# 	"The data is symmetrically distributed with mean 30 and median 30.",
	# 	"High variability (CV = 52.70%) indicates diverse data points",
	# 	"Light-tailed distribution (kurtosis = -6.26) indicates fewer extreme values",
	# 	"Small sample size (n = 5) limits statistical reliability",
	# 	"Financially, Mean (30) exceeds threshold."
	# ]
}

pf()
# Executed in 0.07 second(s) in Ring 1.22

/*--- Weighted rules

pr()

o1 = new stzDataSet([ 10, 20, 30, 40, 50 ])

o1 {
    AddWeightedRule(:Finance, "Mean() > 20", "High mean ({Mean()}).", 2)
    AddWeightedRule(:Finance, "StandardDeviation() > 10", "High volatility ({StandardDeviation()}).", 1)
    ? @@NL(PrioritizedInsights(:Finance))
}

pf()

# Executed in 0.05 second(s) in Ring 1.22

#==========================================#
#  7. DATA QUALITY & VALIDATION            #
#==========================================#


/*--- Data Quality Tests ==="

pr()

# Missing values
? @@(MissingValues()) # System-defined missing patterns
#--> [ '', "NA", "NULL", "n/a", "#N/A" ]

o1 = new stzDataSet([1, "NA", 3, "NULL", 5, "#N/A"])
? @@(o1.Data())
#--> [ 1, 3, 5 ]

? o1.Count()
#--> 3

pf()
# Executed in 0.0010 second(s) in Ring 1.22

/*--- Data validation

pr()

o1 = new stzDataSet([1, 2, 3, 4, 5, 100])
? @@(o1.ValidateData()) + NL # Or Validate()
#--> [ "Data quality appears good" ]

# No variance case
o1 = new stzDataSet([5, 5, 5, 5, 5])
? @@(o1.ValidateData()) + NL
#--> [ "No variance in data (all values identical)" ]

# Analysis recommendations
o1 = new stzDataSet([1, 2, 3, 4, 100])
? @@NL(o1.Recommendations())
#--> [
#	"Small sample size - interpret results cautiously",
#	"Outliers detected - consider robust statistics",
#	"High variability - segment analysis recommended"
# ]

pf()
# Executed in 0.0050 second(s) in Ring 1.22

#==========================================#
#  8. CONFIDENCE INTERVALS & STATISTICAL   #
#==========================================#


/*--- Statistical Inference Tests

pr()

o1 = new stzDataSet([10, 20, 30, 40, 50])
o1 {

    ? @@(ConfidenceInterval(95)) # Or ConfInt()
	#--> [ 16.1407, 43.8593 ]

    ? @@(ConfidenceInterval(90))
	#--> [ 18.3681, 41.6319 ]

    ? @@(ConfidenceInterval(99))
	#--> [ -9.9910, 41.6138 ]

}

pf()
# Executed in 0.0020 second(s) in Ring 1.22

#==========================================#
#  9. TIME SERIES & TREND ANALYSIS         #
#==========================================#

/*--- Moving averages

pr()

o1 = new stzDataSet([1, 3, 5, 7, 9, 11])
? @@(o1.MovingAverage(3))
#--> [ 3, 5, 7, 9 ]

pf()

/*--- Trend analysis patterns

pr()

? @@(StzDataSetQ([1, 3, 5, 7, 9]).Trend())
#--> [ [ "up", 5 ] ]

? @@(StzDataSetQ([7, 4, 3, 1]).Trend())
#--> [ [ "down", 4 ] ]

? @@(StzDataSetQ([7, 4, 3, 1, 5, 9, 12]).Trend())
#--> [ [ "down", 4 ], [ "up", 3 ] ]

? @@(StzDataSetQ([7, 4, 3, 1, 1, 1, 5, 9, 12]).Trend())
#--> [ [ "down", 4 ], [ "stable", 2 ], [ "up", 3 ] ]

? @@(StzDataSetQ([1, 1, 1, 2, 3, 4]).Trend())
#--> [ [ "stable", 3 ], [ "up", 3 ] ]

pf()
# Executed in 0.0050 second(s) in Ring 1.22

#==========================================#
#  10. CACHE & PERFORMANCE                 #
#==========================================#

pr()

o1 = new stzDataSet([10, 20, 30, 40, 50])
o1 {
	# Initial Cache
    ? @@(Cache())
	#--> [ ]

	# Populates cache
    ? Mean()
	#--> 30

    # Cache after Mean
    ? @@(Cache())
	#--> [ [ "mean", 30 ] ]

    # Manually modify cache for testing
    @aCache[:Mean] = 77
    # Modified cached mean
	? Mean()
    #--> 77

    ClearCache()
    # Cache after clear:
	? @@(Cache())
	#--> [ ]

    # Recalculated mean:
	? Mean()
	#--> 30
}

pf()
# Executed in 0.0010 second(s) in Ring 1.22

#==========================================#
#  11. EXPORT & SUMMARY FUNCTIONS          #
#==========================================#
*

/*--- Export & Summary Tests ==="
*/
o1 = new stzDataSet([10, 20, 30, 40, 50])

# Export structured data
? @@NL(o1.Export()) + nl
#--> [
#	[ "data_type", "numeric" ],
#	[ "count", 5 ],
#	[ "unique_count", 5 ],
#	[ "mean", 30 ],
#	[ "median", 30 ],
#	[ "mode", "10" ],
#	[ "standard_deviation", 15.8114 ],
#	[ "variance", 250 ],
#	[ "range", 40 ],
#	[ "min", 10 ],
#	[ "max", 50 ],
#	[ "quartiles", [ 20, 30, 40 ] ],
#	[ "skewness", 0 ],
#	[ "kurtosis", -6.2609 ],
#	[ "outliers", [ ] ]
# ]

# Complete summary
? o1.Summary()
#-->
'
╭─────────────────╮
│ Dataset Content │
╰─────────────────╯
[ 10, 20, 30, 40, 50 ]

╭─────────────────╮
│ Dataset Summary │
╰─────────────────╯
• Type: numeric
• Count: 5
• Mean: 30
• Median: 30
• Standard Deviation: 15.8114
• Range: 40 (10 to 50)
• Quartiles: Q1=20, Q2=30, Q3=40

╭──────────────────╮
│ Dataset Insights │
╰──────────────────╯
• The data is symmetrically distributed with mean 30 and median 30.
• The data shows low variability with a coefficient of variation of 6.3246%, indicating consistent values.
• Light-tailed distribution (kurtosis = -6.6400) indicates fewer extreme values
• Small sample size (n = 5) limits statistical reliability


Executed in 3.3790 second(s) in Ring 1.22
'
#TODO Add Recommendations
pf()

#==========================================#
#  12. UTILITY & STANDALONE FUNCTIONS      #
#==========================================#

pr()
/*--- Utility Functions Tests ==="

# Standalone comparison function
? @@NL("CompareDatasets: ", CompareDatasets([1, 2, 3, 4, 5], [2, 4, 6, 8, 10]))

pf()

#==========================================#
#  13. EDGE CASES & ERROR HANDLING         #
#==========================================#

pr()
/*--- Edge Cases Tests ==="

# Empty dataset
o1 = new stzDataSet([])
o1 {
    ? "Empty DataType: " + DataType()
    ? "Empty Mean: " + Mean()
    ? "Empty Median: " + Median()
    ? @@("Empty Mode: ", Mode())
    ? @@("Empty Insights: ", Insights())
}

# Single value dataset
o1 = new stzDataSet([42])
o1 {
    ? "Single Mean: " + Mean()
    ? "Single StdDev: " + StandardDeviation()
    ? @@NL("Single Insights: ", o1.Insight())
}

# Mixed data types
o1 = new stzDataSet([1, "text", 3, 4, "another"])
o1 {
    ? "Mixed DataType: " + DataType()
    ? @@NL("Mixed Insights: ", Insight())
}

# Invalid correlation cases
o1 = new stzDataSet(["A", "B", "C"])
o2 = new stzDataSet([1, 2, 3, 4, 5]) # Different lengths
? "Invalid correlation: " + o1.CorrelationWith(o2)

o3 = new stzDataSet([1, 2, 3])
o14 = new stzDataSet(["X", "Y"]) # Different lengths
? "Invalid chi-square: " + o3.ChiSquareWith(o14)

pf()

/*--- All stzDataSet Methods Tested ==="

/*
METHODS COVERED:
Core Statistics: Mean, Median, Mode, StandardDeviation, Variance, Range, Sum, Min, Max, Count, UniqueCount
Alternative Means: GeometricMean, HarmonicMean
Distribution: Q1, Q2, Q3, IQR, Quartiles, QuartilesXT, Percentile, Skewness, Kurtosis
Outliers: Outliers, IsOutlier, ZScores
Categorical: FrequencyTable, PercentageFrequency, RelativeFrequency, UniqueValues, Diversity, EntropyIndex
Transformation: Normalize, Standardize, RobustScale
Correlation: CorrelationWith, CovarianceWith, RankCorrelationWith, ChiSquareWith
Comparison: CompareWith, SimilarityScore
Insights: Insight, Insights, InsightsXT, InsightsOfDomain, AddInsightRule, AddWeightedRule, PrioritizedInsights
Quality: ValidateData, RecommendAnalysis, Recommendations
Statistics: ConfidenceInterval
Time Series: MovingAverage, TrendAnalysis
Utility: Cache, ClearCache, Export, Summary, DataType, Data, Values, SortedData
Standalone: CompareDatasets, MissingValues
*/
