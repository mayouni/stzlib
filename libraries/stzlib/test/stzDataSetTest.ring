
load "../max/stzmax.ring"

#  stzDataSet Test File

# The stzDataSet class forms the statistical backbone of the Softanza
# Data Analytics System. Built around four conceptual-yet-practical pillars
# (Comparison, Composition, Distribution, and Relation), it offers a
# knowledgeable and guided Programmer Experience, along with a
# simple yet powerful data exploration journey for everyone—
# especially when paired with the charting capabilities provided by
# the stzChart class.


decimals(4) # Precision required in practice in data anlytics scenarios

#======================================================================#
#  PILLAR 1: COMPARISON - Descriptive Statistics                       #
#======================================================================#

# This pillar includes functions for summarizing and comparing datasets using
# measures of central tendency, dispersion, and uncertainty.

/*--- Core Descriptive Statistics
#NOTE: These functions provide basic summaries like mean (average), median (middle value),
# mode (most frequent value), and measures of spread like standard deviation and variance.

pr()

o1 = new stzDataSet([ 10, 15, 20, 25, 30, 35, 40 ])
o1 {
    ? Mean()            #--> 25 (arithmetic average)
    ? Median()          #--> 25 (middle value after sorting)
    ? @@(Mode())        #--> "10" (first value; no repeated values here)
    ? StandardDeviation() #--> 10.8012 (measure of data spread)
    ? Variance()        #--> 116.6667 (square of standard deviation)
    ? Range()           #--> 30 (max - min)
    ? Sum()             #--> 175 (total of all values)
    ? Min()             #--> 10 (smallest value)
    ? Max()             #--> 40 (largest value)
    ? Count()           #--> 7 (number of values)
    ? UniqueCount()     #--> 7 (number of distinct values)
}
pf()
# Executed in 0.0030 second(s) in Ring 1.22

/*--- Alternative Means
# Geometric mean (product-based average) and harmonic mean (reciprocal-based average)
# are useful for rates or skewed data.

pr()

o1 = new stzDataSet([ 2, 8, 32 ])
o1 {
    ? GeometricMean()   #--> 8 (nth root of product)
    ? HarmonicMean()    #--> 4.5714 (n divided by sum of reciprocals)
}

pf()
# Executed in 0.0010 second(s) in Ring 1.22

/*--- Coefficient of Variation
# CoVar measures relative variability (standard deviation / mean * 100),
# useful for comparing variability across datasets.

pr()

o1 = new stzDataSet([ 10, 15, 20, 25, 30, 35, 40 ])
? o1.CoVar() #--> 43.2049 (percent variability relative to mean)

pf()
# Executed in 0.0020 second(s) in Ring 1.22

/*--- Confidence Intervals
# Confidence intervals estimate the range where the true population mean lies,
# with a specified confidence level (e.g., 95%).

pr()

o1 = new stzDataSet([ 10, 20, 30, 40, 50 ])
o1 {
    ? @@(ConfidenceInterval(95)) #--> [16.1407, 43.8593] (95% confidence range)
    ? @@(ConfidenceInterval(90)) #--> [18.3681, 41.6319] (90% confidence range)
    ? @@(ConfidenceInterval(99)) #--> [-9.9910, 41.6138] (99% confidence range)
}

pf()
# Executed in 0.0020 second(s) in Ring 1.22

/*--- Weighted Mean Tests
# Weighted mean assigns different importance (weights) to each value.

pr()

o1 = new stzDataSet([ 10, 20, 30, 40, 50 ])
o1 {
    ? @@(WeightedMean([ 1, 2, 3, 2, 1 ])) #--> 30 (higher weights on middle values)
    ? @@(WeightedMean([ 5, 1, 1, 1, 5 ])) #--> 30 (higher weights on extremes)
    ? @@(WeightedMean([ 1, 1, 1, 1, 1 ])) #--> 30 (equal weights = regular mean)
}

pf()
# Executed in 0.0020 second(s) in Ring 1.22

/*--- Trimmed Mean Tests
# Trimmed mean removes a percentage of extreme values to reduce outlier impact.

pr()
o1 = new stzDataSet([ 1, 2, 3, 4, 5, 6, 7, 8, 9, 100 ])
o1 {
    ? @@(Mean())         	#--> 14.5 (affected by outlier 100)
    ? @@(TrimmedMean(10)) 	#--> 5.5 (trims 10% from each end)
    ? @@(TrimmedMean(20)) 	#--> 5.5 (trims 20% from each end)
    ? @@(Median())       	#--> 5.5 (for comparison, robust to outliers)
}

pf()
# Executed in 0.0020 second(s) in Ring 1.22

/*--- Percentile Rank Tests
# Percentile rank shows the percentage of values below a given value.

pr()

o1 = new stzDataSet([ 10, 20, 30, 40, 50, 60, 70, 80, 90, 100 ])
o1 {
    ? @@(PercentileRank(55)) 	#--> 50.0 (55 is between 50 and 60)
    ? @@(PercentileRank(30)) 	#--> 25.0 (30 is at 25th percentile)
    ? @@(PercentileRank(5))  	#--> 0.0 (below minimum)
    ? @@(PercentileRank(105)) 	#--> 100.0 (above maximum)
}

pf()
# Executed in 0.0020 second(s) in Ring 1.22

#======================================================================#
#  PILLAR 2: COMPOSITION - Frequency & Categorical Analysis            #
#======================================================================#

# This pillar analyzes the composition of data, focusing on frequency and
# categorical distributions.

/*--- Categorical Data Analysis Tests
# These functions describe the frequency and diversity of categorical data.

pr()

o1 = new stzDataSet([ "Red", "Blue", "Red", "Green", "Blue", "Red", "Yellow" ])
o1 {
    ? Mode()                #--> "Red" (most frequent value)
    ? @@(FreqTable())       #--> [[ " Red", 3], [ " Blue", 2], [ " Green", 1], [ " Yellow", 1]]
    ? @@(PercentFreq())     #--> [[ " Red", 42.8571], ...] (percentage of each category)
    ? @@(RelFreq())         #--> [[ " Red", 0.4286], ...] (proportion of each category)
    ? @@(UValues())         #--> [ " Red", "Blue", "Green", "Yellow " ] (unique values)
    ? Diversity()           #--> 0.5714 (diversity index, 0 to 1)
    ? Entropy()             #--> 1.8424 (information entropy, measure of uncertainty)
}

pf()
# Executed in 0.0160 second(s) in Ring 1.22

/*--- Data Type Detection
# Identifies the type of data (numeric, categorical, mixed). #TODO Add temporal

pr()

o1 = new stzDataSet([ "Red", "Blue", "Red", "Green", "Blue", "Red", "Yellow" ])
? o1.DataType()  #--> "categorical" (all values are strings)

pf()
# Executed in 0.0010 second(s) in Ring 1.22

/*--- Contingency Table Tests
# Shows frequency distribution of two categorical variables for association analysis.

pr()

o4 = new stzDataSet([ "A", "B", "A", "C", "B", "A" ])
o5 = new stzDataSet([ "X", "Y", "X", "Z", "Y", "X" ])

aTable = o4.ContingencyTable(o5)

? @@(aTable) #--> [[ " X", "Y", "Z " ], [[ " A", [3, 0, 0]], [ " B", [0, 2, 0]], [ " C", [0, 0, 1]]]]

pf()
# Executed in 0.0030 second(s) inಸ

/*--- Mode Count Tests
# Returns the frequency of the most common value(s).

pr()

o1 = new stzDataSet([ 1, 2, 2, 3, 2, 4, 2, 5 ])
o1 {
    ? @@(Mode())      #--> "2" (most frequent value)
    ? @@(ModeCount()) #--> 4 (frequency of "2")
    ? @@(FrequencyTable()) #--> [[ " 1", 1], [ " 2", 4], [ " 3", 1], [ " 4", 1], [ " 5", 1]]
}

pf()
# Executed in 0.0090 second(s) in Ring 1.22

#======================================================================#
#  PILLAR 3: DISTRIBUTION - Shape & Spread Analysis                    #
#======================================================================#

# This pillar examines the shape, spread, and patterns of data distributions.

/*--- Quartiles and Percentiles
# Quartiles divide data into four parts; percentiles give specific percentage points.

pr()

o1 = new stzDataSet([ 1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50 ])
o1 {
    ? Q1()                			#--> 12.5 (first quartile)
    ? Q2()                			#--> 25 (second quartile, median)
    ? Q3()                			#--> 37.5 (third quartile)
    ? IQR()               			#--> 25 (interquartile range, Q3 - Q1)
    ? @@(Quartiles())     			#--> [12.5, 25, 37.5] (using interpolation)
    ? @@(QuartilesXT(:Nearest)) 	#--> [10, 25, 40] (using nearest value)
    ? Percentile(90)      			#--> 45 (90th percentile)
}

pf()
# Executed in 0.0020 second(s) in Ring 1.22

/*--- Shape Measures
# Skewness measures asymmetry; kurtosis measures tailedness.

pr()

o1 = new stzDataSet([ 1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50 ])
o1 {
    ? Skewness()          #--> 0.0027 (near 0, nearly symmetric)
    ? Kurtosis()          #--> -3.9006 (negative = flatter than normal distribution)
}

pf()
# Executed in 0.0020 second(s) in Ring 1.22

/*--- Outlier Detection and Z-Scores
# Outliers are extreme values; Z-scores show how many standard deviations from mean.

pr()

o1 = new stzDataSet([ 10, 12, 13, 15, 18, 20, 22, 25, 100 ])
o1 {
    ? @@(Outliers())      #--> [100] (beyond 1.5*IQR from quartiles)
    ? IsOutlier(100)      #--> TRUE
    ? IsOutlier(15)       #--> FALSE
    ? @@(ZScores())       #--> [-0.5725, ..., 2.6258] (standardized values)
}

pf()
# Executed in 0.0020 second(s) in Ring 1.22

/*--- Sorted Data
# Returns data in ascending order for distribution analysis.

pr()

o1 = new stzDataSet([ 30, 10, 20, 50, 40 ])
? @@(o1.SortedData())    #--> [10, 20, 30, 40, 50]

pf()
# Executed in 0.0010 second(s) in Ring 1.22

/*--- Time Series and Trend Analysis
# Moving averages smooth data; Trend() identifies patterns over time.

pr()

o1 = new stzDataSet([ 1, 3, 5, 7, 9, 11 ])
? @@(o1.MovingAverage(3))
#--> [3, 5, 7, 9] (average of 3 consecutive values)

? @@(StzDataSetQ([ 1, 3, 5, 7, 9 ]).Trend())
#--> [[ " up", 5]] (upward trend)

? @@(StzDataSetQ([ 7, 4, 3, 1 ]).Trend())
#--> [[ " down", 4]] (downward trend)

? @@(StzDataSetQ([ 7, 4, 3, 1, 5, 9, 12 ]).Trend())
#--> [[ " down", 4], [ " up", 3]]

? @@(StzDataSetQ([ 7, 4, 3, 1, 1, 1, 5, 9, 12 ]).Trend())
#--> [[ " down", 4], [ " stable", 2], [ " up", 3]]

? @@(StzDataSetQ([ 1, 1, 1, 2, 3, 4 ]).Trend())
#--> [[ " stable", 3], [ " up", 3]]

pf()
# Executed in 0.0050 second(s) in Ring 1.22

/*--- Deciles Tests
# Deciles divide data into ten parts for finer distribution analysis.

pr()

o1 = new stzDataSet([ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ])
o1 {
    ? @@(Deciles()) # (10th to 90th percentiles)
	#--> [
	# 	1.9000, 2.8000, 3.7000, 4.6000, 5.5000, 6.4000,
	# 	7.3000, 8.2000, 9.1000
	# ]

    ? @@(Quartiles()) # (for comparison)
	#--> [3.25, 5.5, 7.75]
}

pf()
# Executed in 0.0020 second(s) in Ring 1.22

/*--- Box Plot Statistics Tests
# Summarizes data for box plot visualization (quartiles, whiskers, outliers).

pr()

o1 = new stzDataSet([ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 15, 20 ])

o1 {
    ? @@NL(BoxPlotStats())
	#--> [
	# 	[ "min", 1 ],
	# 	[ "q1", 3.7500 ],
	# 	[ "median", 6.5000 ],
	# 	[ "q3", 9.2500 ],
	# 	[ "max", 20 ],
	# 	[ "whisker_low", 1 ],
	# 	[ "whisker_high", 15 ],
	# 	[ "iqr", 5.5000 ]
	# ]

    ? @@(Outliers()) # (beyond 1.5*IQR)
	#--> [20]
}

pf()
# Executed in 0.0050 second(s) in Ring 1.22

/*--- Normality Test Tests
# Checks if data follows a normal distribution using skewness and kurtosis.

pr()

o1 = new stzDataSet([ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ])
o1 {
    aTest = NormalityTest()
    ? @@NL(aTest)
    #--> [
	# 	[ "test", "heuristic" ],
	# 	[ "skewness", 0 ],
	# 	[ "kurtosis", -4.0254 ],
	# 	[ "p_value", 0.0179 ],
	# 	[ "is_normal", 0 ]
	# ]
}

o1 = new stzDataSet([ 1, 1, 1, 2, 2, 3, 8, 9, 9, 9 ])
o1 {
    aTest = NormalityTest()
	#--> [
	# 	[ "test", "heuristic" ],
	# 	[ "skewness", 0.0413 ],
	# 	[ "kurtosis", -4.1210 ],
	# 	[ "p_value", 0.0162 ],
	# 	[ "is_normal", 0 ]
	# ]
}

pf()
# Executed in 0.0060 second(s) in Ring 1.22

#======================================================================#
#  PILLAR 4: RELATION - Correlation & Association Analysis             #
#======================================================================#

# This pillar explores relationships between variables.

/*--- Correlation Analysis Tests
# Measures strength and direction of linear relationships.

pr()

o1 = new stzDataSet([ 1, 2, 3, 4, 5 ])
o2 = new stzDataSet([ 2, 4, 6, 8, 10 ])

? o1.CorelWith(o2)       #--> 1 (perfect positive correlation)
? o1.CoVarwith(o2)       #--> 5 (covariance)
? o1.RankCorelWith(o2)   #--> 1 (Spearman rank correlation)

pf()
# Executed in 0.0240 second(s) in Ring 1.22

/*--- Chi-Square Test for Independence
# Tests association between two categorical variables.

pr()
aGender = [ " Male", "Female", "Male", "Female", "Male", "Female", "Male", "Female", "Male", "Female " ]
aPreference = [ " Like", "Like", "Dislike", "Dislike", "Like", "Like", "Dislike", "Like", "Dislike", "Like " ]

oGend = new stzDataSet(aGender)
oPref = new stzDataSet(aPreference)

? oGend.ChiSquareWith(oPref) 		#--> 1.6667 (chi-square statistic)
? @@NL(oGend.CompareWith(oPref)) 	#--> [ " Similar diversity levels " ]

pf()
# Executed in 0.0030 second(s) in Ring 1.22

/*--- Similarity Measures
# Quantifies how similar two datasets are.

pr()

o1 = new stzDataSet([ 1, 2, 3, 4, 5 ])
? o1.SimilarityScore(o1) #--> 1 (identical datasets)
pf()

# Executed in 0.0020 second(s) in Ring 1.22

/*--- Regression Coefficients Tests
# Fits a linear model and returns slope, intercept, and R-squared.

pr()
oX = new stzDataSet([ 1, 2, 3, 4, 5 ])
oY = new stzDataSet([ 2, 4, 6, 8, 10 ])

aRegression = oX.RegressionCoefficients(oY)
? @@NL(aRegression)
#--> [[ " slope", 2], [ " intercept", 0], [ " r_squared", 1]]

oY2 = new stzDataSet([ 1, 3, 5, 7, 11 ])
aRegression2 = oX.RegressionCoefficients(oY2)
? @@NL(aRegression2)
 #--> [[ " slope", 2.4], [ " intercept", -1.8], [ " r_squared", 0.9730]]

pf()
# Executed in 0.0050 second(s) in Ring 1.22

/*--- Partial Correlation Tests
# Measures correlation between two variables, controlling for a third.

pr()

oX = new stzDataSet([ 1, 2, 3, 4, 5 ])
oY = new stzDataSet([ 2, 3, 4, 5, 6 ])
oZ = new stzDataSet([ 1, 1, 2, 2, 3 ])

? @@(oX.CorrelationWith(oY))     	#--> 1
? @@(oX.PartialCorrelation(oY, oZ)) #--> 1

pf()
# Executed in 0.0020 second(s) in Ring 1.22

/*--- Mutual Information Tests
# Measures shared information between variables (linear and non-linear).

pr()

oA = new stzDataSet([ "Low", "Low", "High", "High", "Low", "High" ])
oB = new stzDataSet([ "No", "No", "Yes", "Yes", "No", "Yes" ])

? @@(oA.MutualInformation(oB)) #--> 1 (perfect dependence)

oC = new stzDataSet([ "X", "Y", "X", "Y", "X", "Y" ])
? @@(oA.MutualInformation(oC)) #--> 0.0817 (near independence)

pf()
# Executed in 0.0150 second(s) in Ring 1.22

#======================================================================#
#  Data Preprocessing                                                  #
#======================================================================#

# Prepares data for analysis through transformations.

/*--- Data Transformation Tests
# Normalization scales to [0,1]; standardization to mean 0, variance 1;
# robust scaling uses median and IQR.

pr()

o1 = new stzDataSet([ 100, 200, 300, 400, 500 ])
o1 {
    ? @@(Normalize())     #--> [0, 0.25, 0.5, 0.75, 1]
    ? @@(Standardize())   #--> [-1.2649, -0.6325, 0, 0.6325, 1.2649]
    ? @@(RobustScale())   #--> [-1, -0.5, 0, 0.5, 1]
}

pf()
# Executed in 0.0030 second(s) in Ring 1.22

/*--- Access to Original Data
# Retrieves the raw dataset.

pr()

o1 = new stzDataSet([ 100, 200, 300, 400, 500 ])
o1 {
    ? @@(Data())          #--> [100, 200, 300, 400, 500]
    ? @@(Values())        #--> [100, 200, 300, 400, 500] (alias for Data())
}

pf()
# Executed in almost 0 second(s) in Ring 1.22

#======================================================================#
#  Insights and Recommendations                                        #
#======================================================================#

# Generates interpretative insights and analysis suggestions.
#TODO Add Actions() - Transforms recommendations into actionable code to execute

/*--- Basic Insights
# Provides observations based on statistical properties.
#TODO Update to include all the statistical functions we have

pr()

o1 = new stzDataSet([ 10, 12, 13, 15, 18, 20, 22, 25, 100 ])
? @@NL(o1.Insights())
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

/*--- Categorical Insights
# Insights tailored for categorical data.

pr()

o1 = new stzDataSet([ "A", "B", "A", "C", "A", "D" ])
? @@NL(o1.Insights())
#--> [
#	"Moderate diversity (66.6667%) shows balanced distribution",
#	"Information entropy (1.7925) indicates balanced category distribution",
#	"'A' is most common (50%) but distribution remains balanced"
# ]

pf()
# Executed in 0.0080 second(s) in Ring 1.22

/*--- Custom Insight Rules
# Allows user-defined rules for domain-specific insights.

pr()

o1 = new stzDataSet([ 10, 20, 30, 40, 50 ])
o1 {

    AddInsightRule(
		:Finance,
		"Mean() > 20", "Mean ({Mean()}) exceeds threshold."
	)

    ? @@NL(InsightsOfDomain(:Finance)) + NL #--> [ " Mean (30) exceeds threshold. " ]


    ? @@NL(InsightsXT())
	#--> [
	# 	"The data is symmetrically distributed with mean 30 and median 30",
	# 	"High variability (CV = 52.70%) indicates diverse data points",
	# 	"Light-tailed distribution (kurtosis = -6.26) indicates fewer extreme values",
	# 	"Small sample size (n = 5) limits statistical reliability",
	# 	"Financially, Mean (30) exceeds threshold."
	# ]

	# Note how the "Financially" adverb is generated to show that the insight
	# belongs to the financial domain as specified when adding the rule.

}

pf()

# Executed in 0.07 second(s) in Ring 1.22

/*--- Weighted Rules
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
	#--> [ " High mean (30).", "High volatility (15.8114). " ]

	? @@NL( InsightsForDomain(:Finance) ) + NL
	#--> [ "High mean (30).", "High volatility (15.81)." ]

	? @@NL( InsightsXT() )
	#--> [
	# 	"Data shows negative skew (mean 15.81 < median 30)",
	# 	"High variability (CV = 141.65%) indicates diverse data points",
	# 	"Light-tailed distribution (kurtosis = -6.31) indicates fewer extreme values",
	# 	"Small sample size (n = 5) limits statistical reliability",
	# 	"Financially, High mean (22.40).",
	# 	"Financially, High volatility (17.95)."
	# ]

	#TODO // Check why the values computed for financial insights are not the same

}

pf()
# Executed in 0.12 second(s) in Ring 1.22

#======================================================================#
#  Data Quality and Validation                                         #
#======================================================================#

# Ensures data reliability through quality checks.

/*--- Data Quality Tests
# Handles missing values by excluding them from analysis.

pr()

# Listing the missing values supported by Softanza
# (recognized and cleaned automatically in stzDataSet)

? @@(MissingValues())
#--> ['', "NA", "NULL", "n/a", "#N/A " ]


o1 = new stzDataSet([ 1, "NA", 3, "NULL", 5, "#N/A" ])
? @@(o1.Data())       #--> [ 1, 3, 5 ] (excludes missing values)
? o1.Count()          #--> 3 (count of valid values)

pf()

# Executed in 0.0020 second(s) in Ring 1.22

/*--- Data Validation
# Checks for issues like no variance or outliers.

pr()

o1 = new stzDataSet([ 1, 2, 3, 4, 5, 100 ])
? @@(o1.ValidateData()) + NL
#--> [ "Data quality appears good" ]

o1 = new stzDataSet([ 5, 5, 5, 5, 5 ])
? @@(o1.ValidateData()) + NL
#--> [ "No variance in data (all values identical)" ]

o1 = new stzDataSet([ 1, 2, 3, 4, 100 ])
? @@NL(o1.Recommendations())
#--> [
# 	"Small sample size - interpret results cautiously",
# 	"Outliers detected - consider robust statistics",
# 	"High variability - segment analysis recommended"
# ]

pf()
# Executed in 0.0040 second(s) in Ring 1.22

#======================================================================#
#  Utilities and Performance                                           #
#======================================================================#

# Enhances functionality and efficiency.

/*--- Cache & Performance
# Caches computed values for faster access.

pr()

o1 = new stzDataSet([ 10, 20, 30, 40, 50 ])
o1 {
    ? @@(Cache())         #--> [] (initially empty)
    ? Mean()              #--> 30 (computes and caches)
    ? @@(Cache())         #--> [[ "mean", 30]]
    @aCache[:Mean] = 77
    ? Mean()              #--> 77 (uses modified cache)
    ClearCache()
    ? @@(Cache())         #--> [] (cache cleared)
    ? Mean()              #--> 30 (recomputed)
}

pf()
# Executed in 0.0020 second(s) in Ring 1.22

/*--- Utility & Standalone Functions
# Provides additional tools like dataset comparison.

pr()

? @@NL(CompareDatasets([ 1, 2, 3, 4, 5], [2, 4, 6, 8, 10 ]))
#--> [
#	"Mean difference: -50%",
#	"Dataset 2 shows higher variability",
#	"Strong positive correlation (1)"
# ]

pf()
# Executed in 0.0030 second(s) in Ring 1.22

#======================================================================#
#  Summary and Export                                                  #
#======================================================================#

# Summarizes and exports dataset statistics.

/*--- Summary and Export Functions
# Provides a formatted summary and structured export.
*/
pr()

o1 = new stzDataSet([ 10, 20, 30, 40, 50 ])

# Export structured data
//? @@NL(o1.Export()) + nl
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

# Complete summary (XT to include Recommendations)
# Use Summary() without XT to get the basic summary

? o1.SummaryXT()
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

╭─────────────────╮
│ Recommendations │
╰─────────────────╯
• Small sample size - interpret results cautiously
• High variability - segment analysis recommended
'

pf()
# Executed in 0.0510 second(s) in Ring 1.22

#======================================================================#
#  Edge Cases and Validation                                           #
#======================================================================#

# Tests robustness in unusual scenarios.

/*--- Empty Dataset
# Handles cases with no data.

pr()

o1 = new stzDataSet([  ])
o1 {
    ? DataType()          #--> "empty"
    ? Mean()              #--> 0 (default for empty)
    ? Median()            #--> 0
    ? @@(Mode())          #--> ""
    ? @@(Insights())      #--> [ "Dataset is empty. No analysis possible without data." ]
}

pf()
# Executed in 0.0020 second(s) in Ring 1.22

/*--- Single Value Dataset
# Tests behavior with minimal data.

pr()

o1 = new stzDataSet([ 42 ])
o1 {
    ? Mean()              #--> 42
    ? StandardDeviation() #--> 0 (no variability)

    ? @@NL(o1.Insights())
	#--> [
	# "The data is symmetrically distributed with mean 42 and median 42",
	# "The data shows low variability with a coefficient of variation of 0%, indicating consistent values",
	# "Small sample size (n = 1) limits statistical reliability"
	# ]

}

pf()
# Executed in 0.0040 second(s) in Ring 1.22

/*--- Mixed Data Types
# Handles datasets with both numeric and categorical values.

pr()

o1 = new stzDataSet([ 1, "text", 3, 4, "another" ])

o1 {
    ? DataType() #--> "mixed"

    ? @@NL(Insights())
	#--> [
	# "Mixed dataset containing both numeric and categorical data (5 unique values from 5 total)",
	# "Consider separating data types for specialized analysis. Numeric methods apply only to numeric subset"
	# ]

}

pf()
# Executed in 0.0040 second(s) in Ring 1.22

/*--- Invalid Correlation Cases
# Tests correlation with incompatible datasets.

pr()

o1 = new stzDataSet([ "A", "B", "C" ])
o2 = new stzDataSet([ 1, 2, 3, 4, 5 ])

? o1.CorrelationWith(o2) #--> 0 (different lengths)

o3 = new stzDataSet([ 1, 2, 3 ])
o4 = new stzDataSet([ "X", "Y" ])

? o3.ChiSquareWith(o4)   #--> 0 (different lengths)

pf()
# Executed in 0.0010 second(s) in Ring 1.22

#======================================================================#
#  Combined Analysis Example                                           #
#======================================================================#

# Demonstrates a comprehensive analysis using multiple pillars.
*/
pr()

// Setting up sales data for 10 months and their corresponding month numbers
oSales = new stzDataSet([ 100, 120, 140, 160, 180, 200, 220, 240, 260, 280 ])  // Sales figures from month 1 to 10
oMonth = new stzDataSet([ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ])                     // Months numbered 1 to 10

// Showing the average sales across all months
? oSales.Mean()           			#--> 190  // Average sales is 190 units

// Showing the average after removing 20% of extreme values (highs and lows)
? oSales.TrimmedMean(20)  			#--> 190  // Still 190, meaning no big outliers affect the average

// Showing how much sales vary from the average (higher number = more variation)
? oSales.StandardDeviation() + NL 	#--> 60.5530  // Sales fluctuate by about 60.55 units

// Summarizing sales spread (like a snapshot of how sales are distributed)
? @@NL( oSales.BoxPlotStats() ) + NL
#--> [
#	[ "min", 100 ],         // Lowest sales: 100 units
#	[ "q1", 145 ],          // 25% of sales are below 145 units
#	[ "median", 190 ],      // Middle value: half the sales are below 190
#	[ "q3", 235 ],          // 75% of sales are below 235 units
#	[ "max", 280 ],         // Highest sales: 280 units
#	[ "whisker_low", 100 ], // Lower typical range starts at 100
#	[ "whisker_high", 280 ],// Upper typical range ends at 280
#	[ "iqr", 90 ]           // Middle 50% of sales range from 145 to 235 (spread of 90 units)
# ]

// Showing the sales trend over months (how sales change with time)
? @@NL( oMonth.RegressionCoefficients(oSales) ) + NL
#--> [
#	[ "slope", 20 ],        // Sales grow by 20 units each month
#	[ "intercept", 80 ],    // Starting point: sales would be 80 at month 0
#	[ "r_squared", 1 ]      // Perfect fit: sales follow this trend exactly
# ]

// Checking if sales follow a normal (bell-shaped) pattern
? @@NL( oSales.NormalityTest() )
#--> [
#	[ "test", "heuristic" ],  // Method used to test the pattern
#	[ "skewness", 0 ],        // Symmetry: 0 means perfectly balanced
#	[ "kurtosis", -4.0616 ],  // Flatness: negative means flatter than a bell curve
#	[ "p_value", 0.0172 ],    // Statistical check: low value suggests not normal
#	[ "is_normal", 0 ]        // Result: 0 means sales don’t follow a normal pattern
# ]

# NARRATION OF THE ANALYSIS (#TODO Automate it!)
/*
What This Means for Your Business

Sales Overview: Your sales start at 100 units and grow steadily
to 280 over 10 months, averaging 190 units per month.

Consistency: The trimmed mean matching the average (190) shows
no extreme highs or lows skewing your results. The standard
deviation (60.55) indicates moderate month-to-month variation.

Distribution: Most sales fall between 145 and 235 units,
with the middle point at 190, giving you a clear picture
of typical performance.

Growth Trend: Sales increase by exactly 20 units each month,
starting from a baseline of 80, and this pattern is
perfectly consistent.

Pattern Check: The data doesn’t fit a normal (bell-shaped) curve,
which might matter if you’re using certain statistical tools,
but the steady growth is the key takeaway here.

This analysis shows a strong, predictable sales increase each
month with no surprises, which is great for planning!
*/

pf()
# Executed in 0.01 second(s) in Ring 1.22
