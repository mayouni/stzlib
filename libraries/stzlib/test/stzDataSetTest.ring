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
*/
pr()

o1 = new stzDataSet([1, 2, 3, 4, 5])
? o1.SimilarityScore(o1)
#--> 1

pf()
# Executed in 0.0020 second(s) in Ring 1.22

#==========================================#
#  6. INSIGHT GENERATION                   #
#==========================================#


/*--- Insight Generation Tests ==="

# Basic insights
o1 = new stzDataSet([10, 12, 13, 15, 18, 20, 22, 25, 100])
? @@NL("Insight: ", o1.Insight())
? @@NL("Insights: ", o1.Insights()) # Alternative method

# Categorical insights
o1 = new stzDataSet(["A", "B", "A", "C", "A", "D"])
? @@NL("Categorical Insights: ", o1.Insight())

# Custom insight rules
o1 = new stzDataSet([10, 20, 30, 40, 50])
o1 {
    AddInsightRule(:Finance, "Mean() > 20", "Mean ({Mean()}) exceeds threshold.")
    ? @@NL("InsightsOfDomain: ", InsightsOfDomain(:Finance))
    ? @@NL("InsightsXT: ", InsightsXT()) # All insights without domain filter
}

# Weighted rules
o1 {
    AddWeightedRule(:Finance, "Mean() > 20", "High mean ({Mean()}).", 2)
    AddWeightedRule(:Finance, "StandardDeviation() > 10", "High volatility ({StandardDeviation()}).", 1)
    ? @@NL("PrioritizedInsights: ", PrioritizedInsights(:Finance))
}

pf()

#==========================================#
#  7. DATA QUALITY & VALIDATION            #
#==========================================#

pr()
/*--- Data Quality Tests ==="

# Missing values
? @@("MissingValues: ", MissingValues()) # System-defined missing patterns

o1 = new stzDataSet([1, "NA", 3, "NULL", 5, "#N/A"])
? @@("Data after cleaning: ", o1.Data())
? "Count after cleaning: " + o1.Count()

# Data validation
o1 = new stzDataSet([1, 2, 3, 4, 5, 100])
? @@("ValidateData: ", o1.ValidateData()) # Or Validate()

# No variance case
o1 = new stzDataSet([5, 5, 5, 5, 5])
? @@("No variance validation: ", o1.ValidateData())

# Analysis recommendations
o1 = new stzDataSet([1, 2, 3, 4, 100])
? @@NL("RecommendAnalysis: ", o1.RecommendAnalysis())
? @@NL("Recommendations: ", o1.Recommendations()) # Alternative method

pf()

#==========================================#
#  8. CONFIDENCE INTERVALS & STATISTICAL   #
#==========================================#

pr()
/*--- Statistical Inference Tests ==="

o1 = new stzDataSet([10, 20, 30, 40, 50])
o1 {
    ? @@("ConfidenceInterval(95): ", ConfidenceInterval(95))
    ? @@("ConfidenceInterval(90): ", ConfidenceInterval(90))
    ? @@("ConfidenceInterval(99): ", ConfidenceInterval(99))
}

pf()

#==========================================#
#  9. TIME SERIES & TREND ANALYSIS         #
#==========================================#

pr()
/*--- Time Series & Trend Tests ==="

# Moving averages
o1 = new stzDataSet([1, 3, 5, 7, 9, 11])
? @@("MovingAverage(3): ", o1.MovingAverage(3))

# Trend analysis patterns
patterns = [
    [[1, 3, 5, 7, 9], "Upward"],
    [[7, 4, 3, 1], "Downward"],
    [[7, 4, 3, 1, 5, 9, 12], "Mixed"],
    [[7, 4, 3, 1, 1, 1, 5, 9, 12], "Complex"],
    [[1, 1, 1, 2, 3, 4], "Stable-Up"]
]

for aPattern in patterns
    o1 = new stzDataSet(aPattern[1])
    ? aPattern[2] + " TrendAnalysis: " + @@(o1.TrendAnalysis())
end

pf()

#==========================================#
#  10. CACHE & PERFORMANCE                 #
#==========================================#

pr()
/*--- Cache Management Tests ==="

o1 = new stzDataSet([10, 20, 30, 40, 50])
o1 {
    ? @@("Initial Cache: ", Cache())
    ? "Mean: " + Mean()  # Populates cache
    ? @@("Cache after Mean: ", Cache())
    
    # Manually modify cache for testing
    @aCache[:Mean] = 77
    ? "Modified cached mean: " + Mean()
    
    ClearCache()
    ? @@("Cache after clear: ", Cache())
    ? "Recalculated mean: " + Mean()
}

pf()

#==========================================#
#  11. EXPORT & SUMMARY FUNCTIONS          #
#==========================================#

pr()
/*--- Export & Summary Tests ==="

o1 = new stzDataSet([10, 20, 30, 40, 50])

# Export structured data
? @@NL("Export: ", o1.Export())

# Complete summary
? o1.Summary()

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
