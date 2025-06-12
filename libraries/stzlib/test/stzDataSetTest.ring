load "../max/stzmax.ring"
decimals(4)

#==========================================#
#  1. BASIC STATISTICS & DESCRIPTIVE       #
#==========================================#


/*--- Core descriptive statistics
*/
pr()

oStats = new stzDataSet([10, 15, 20, 25, 30, 35, 40])
oStats {
    ? Mean()
	#--> 25

    ? Median()
	#--> 25

    ? @@(Mode())
	 #--> "10" (first value)

    ? StandardDeviation()
	#--> 10.8012

    ? Variance()
	#--> ~116.67
    ? Range()                  #--> 30
    ? Sum()                      #--> 175
    ? Min()                      #--> 10
    ? Max()                      #--> 40
    ? Count()                  #--> 7
    ? UniqueCount()      #--> 7

}

pf()

/*--- Alternative means

oStats = new stzDataSet([2, 8, 32])
oStats {
    ? "GeometricMean: " + GeometricMean()  #--> 8
    ? "HarmonicMean: " + HarmonicMean()    #--> ~4.57
}

/*--- Coefficient of variation

oStats = new stzDataSet([10, 15, 20, 25, 30, 35, 40])
? "CoefficientOfVariation: " + oStats.CoefficientOfVariation()

pf()

#==========================================#
#  2. DISTRIBUTION ANALYSIS                #
#==========================================#

pr()
/*--- Distribution Analysis Tests ==="

# Quartiles and percentiles
oStats = new stzDataSet([1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50])
oStats {
    ? "Q1: " + Q1()                       #--> ~10
    ? "Q2: " + Q2()                       #--> 25
    ? "Q3: " + Q3()                       #--> ~40
    ? "IQR: " + IQR()                     #--> ~30
    ? @@("Quartiles: ", Quartiles())
    ? @@("Quartiles (Nearest): ", QuartilesXT(:Nearest))
    ? "Percentile(90): " + Percentile(90) #--> ~45
}

# Shape measures
oStats {
    ? "Skewness: " + Skewness()           #--> ~0 (symmetric)
    ? "Kurtosis: " + Kurtosis()           #--> negative
}

# Outlier detection and z-scores
oStats = new stzDataSet([10, 12, 13, 15, 18, 20, 22, 25, 100])
oStats {
    ? @@("Outliers: ", Outliers())
    ? "IsOutlier(100): " + IsOutlier(100)
    ? "IsOutlier(15): " + IsOutlier(15)
    ? @@("ZScores: ", ZScores())
}

# Sorted data
oStats = new stzDataSet([30, 10, 20, 50, 40])
? @@("SortedData: ", oStats.SortedData())

pf()

#==========================================#
#  3. CATEGORICAL DATA & FREQUENCY         #
#==========================================#

pr()
/*--- Categorical Data Analysis Tests ==="

oStats = new stzDataSet(["Red", "Blue", "Red", "Green", "Blue", "Red", "Yellow"])
oStats {
    ? "Mode: " + Mode()                   #--> "Red"
    ? @@("FrequencyTable: ", FrequencyTable())
    ? @@("PercentageFrequency: ", PercentageFrequency())
    ? @@("RelativeFrequency: ", RelativeFrequency()) # Or RelFreq()
    ? @@("UniqueValues: ", UniqueValues()) # Or UValues()
    ? "Diversity: " + Diversity()
    ? "EntropyIndex: " + EntropyIndex()
}

# Data type detection
oStats {
    ? "DataType: " + DataType()           #--> "categorical"
}

pf()

#==========================================#
#  4. DATA TRANSFORMATION                  #
#==========================================#

pr()
/*--- Data Transformation Tests ==="

oStats = new stzDataSet([100, 200, 300, 400, 500])
oStats {
    ? @@("Normalize: ", Normalize())      # Min-max normalization
    ? @@("Standardize: ", Standardize())  # Z-score standardization
    ? @@("RobustScale: ", RobustScale())  # Median and IQR based
}

# Access to original data
oStats {
    ? @@("Data: ", Data())               # Original data
    ? @@("Values: ", Values())           # Same as Data()
}

pf()

#==========================================#
#  5. CORRELATION & RELATIONSHIPS          #
#==========================================#

pr()
/*--- Correlation Analysis Tests ==="

# Correlation measures
oStats1 = new stzDataSet([1, 2, 3, 4, 5])
oStats2 = new stzDataSet([2, 4, 6, 8, 10])

? "CorrelationWith: " + oStats1.CorrelationWith(oStats2)
? "CovarianceWith: " + oStats1.CovarianceWith(oStats2)
? "RankCorrelationWith: " + oStats1.RankCorrelationWith(oStats2)

# Chi-square test for independence
aGender = ["Male", "Female", "Male", "Female", "Male", "Female", "Male", "Female", "Male", "Female"]
aPreference = ["Like", "Like", "Dislike", "Dislike", "Like", "Like", "Dislike", "Like", "Dislike", "Like"]

oGender = new stzDataSet(aGender)
oPreference = new stzDataSet(aPreference)
? "ChiSquareWith: " + oGender.ChiSquareWith(oPreference)

# Dataset comparison
? @@NL("CompareWith: ", oStats1.CompareWith(oStats2))

# Similarity measures
oStats3 = new stzDataSet([1, 2, 3, 4, 5])
? "SimilarityScore: " + oStats1.SimilarityScore(oStats3)

pf()

#==========================================#
#  6. INSIGHT GENERATION                   #
#==========================================#

pr()
/*--- Insight Generation Tests ==="

# Basic insights
oStats = new stzDataSet([10, 12, 13, 15, 18, 20, 22, 25, 100])
? @@NL("Insight: ", oStats.Insight())
? @@NL("Insights: ", oStats.Insights()) # Alternative method

# Categorical insights
oStats = new stzDataSet(["A", "B", "A", "C", "A", "D"])
? @@NL("Categorical Insights: ", oStats.Insight())

# Custom insight rules
oStats = new stzDataSet([10, 20, 30, 40, 50])
oStats {
    AddInsightRule(:Finance, "Mean() > 20", "Mean ({Mean()}) exceeds threshold.")
    ? @@NL("InsightsOfDomain: ", InsightsOfDomain(:Finance))
    ? @@NL("InsightsXT: ", InsightsXT()) # All insights without domain filter
}

# Weighted rules
oStats {
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

oStats = new stzDataSet([1, "NA", 3, "NULL", 5, "#N/A"])
? @@("Data after cleaning: ", oStats.Data())
? "Count after cleaning: " + oStats.Count()

# Data validation
oStats = new stzDataSet([1, 2, 3, 4, 5, 100])
? @@("ValidateData: ", oStats.ValidateData()) # Or Validate()

# No variance case
oStats = new stzDataSet([5, 5, 5, 5, 5])
? @@("No variance validation: ", oStats.ValidateData())

# Analysis recommendations
oStats = new stzDataSet([1, 2, 3, 4, 100])
? @@NL("RecommendAnalysis: ", oStats.RecommendAnalysis())
? @@NL("Recommendations: ", oStats.Recommendations()) # Alternative method

pf()

#==========================================#
#  8. CONFIDENCE INTERVALS & STATISTICAL   #
#==========================================#

pr()
/*--- Statistical Inference Tests ==="

oStats = new stzDataSet([10, 20, 30, 40, 50])
oStats {
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
oStats = new stzDataSet([1, 3, 5, 7, 9, 11])
? @@("MovingAverage(3): ", oStats.MovingAverage(3))

# Trend analysis patterns
patterns = [
    [[1, 3, 5, 7, 9], "Upward"],
    [[7, 4, 3, 1], "Downward"],
    [[7, 4, 3, 1, 5, 9, 12], "Mixed"],
    [[7, 4, 3, 1, 1, 1, 5, 9, 12], "Complex"],
    [[1, 1, 1, 2, 3, 4], "Stable-Up"]
]

for aPattern in patterns
    oStats = new stzDataSet(aPattern[1])
    ? aPattern[2] + " TrendAnalysis: " + @@(oStats.TrendAnalysis())
end

pf()

#==========================================#
#  10. CACHE & PERFORMANCE                 #
#==========================================#

pr()
/*--- Cache Management Tests ==="

oStats = new stzDataSet([10, 20, 30, 40, 50])
oStats {
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

oStats = new stzDataSet([10, 20, 30, 40, 50])

# Export structured data
? @@NL("Export: ", oStats.Export())

# Complete summary
? oStats.Summary()

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
oStats = new stzDataSet([])
oStats {
    ? "Empty DataType: " + DataType()
    ? "Empty Mean: " + Mean()
    ? "Empty Median: " + Median()
    ? @@("Empty Mode: ", Mode())
    ? @@("Empty Insights: ", Insights())
}

# Single value dataset
oStats = new stzDataSet([42])
oStats {
    ? "Single Mean: " + Mean()
    ? "Single StdDev: " + StandardDeviation()
    ? @@NL("Single Insights: ", oStats.Insight())
}

# Mixed data types
oStats = new stzDataSet([1, "text", 3, 4, "another"])
oStats {
    ? "Mixed DataType: " + DataType()
    ? @@NL("Mixed Insights: ", Insight())
}

# Invalid correlation cases
oStats1 = new stzDataSet(["A", "B", "C"])
oStats2 = new stzDataSet([1, 2, 3, 4, 5]) # Different lengths
? "Invalid correlation: " + oStats1.CorrelationWith(oStats2)

oStats3 = new stzDataSet([1, 2, 3])
oStats4 = new stzDataSet(["X", "Y"]) # Different lengths
? "Invalid chi-square: " + oStats3.ChiSquareWith(oStats4)

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
