
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
[10, 20, 30, 40, 50]

╭─────────────────╮
│ Dataset Summary │
╰─────────────────╯
• Type: numeric

• Count: 5

╭──────────────────╮
│ Dataset Insights │
╰──────────────────╯
• High variability (CV = 141.6539%) suggests heterogeneous data with significant spread.

• Extreme kurtosis detected (-6.2609). Distribution has heavy tails and potential extreme values.

╭─────────────────╮
│ Recommendations │
╰─────────────────╯
• Small sample size (n=5) prone to outlier influence. Use non-parametric methods, bootstrap confidence intervals, TrimmedMean(), and interpret results cautiously.

• Non-normal distribution violates test assumptions. Use non-parametric tests, percentile-based confidence intervals, or apply Normalize()/Standardize().

• Extremely high variability (CV = 80.1488%) may indicate multiple populations. Consider subgroup analysis or use MovingAverage(5) to identify patterns.

• Sequential data contains temporal patterns. Apply TrendAnalysis() and MovingAverage(5) to smooth fluctuations and identify trends.
'

pf()
# Executed in 0.1280 second(s) in Ring 1.22

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

pr()

# Setting up sales data for 10 months and their corresponding month numbers
oSales = new stzDataSet([ 100, 120, 140, 160, 180, 200, 220, 240, 260, 280 ])  // Sales figures from month 1 to 10
oMonth = new stzDataSet([ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ])                     // Months numbered 1 to 10

# Showing the average sales across all months
? oSales.Mean()           			#--> 190  // Average sales is 190 units

" Showing the average after removing 20% of extreme values (highs and lows)
? oSales.TrimmedMean(20)  			#--> 190  // Still 190, meaning no big outliers affect the average

# Showing how much sales vary from the average (higher number = more variation)
? oSales.StandardDeviation() + NL 	#--> 60.5530  // Sales fluctuate by about 60.55 units

" Summarizing sales spread (like a snapshot of how sales are distributed)
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

# Showing the sales trend over months (how sales change with time)
? @@NL( oMonth.RegressionCoefficients(oSales) ) + NL
#--> [
#	[ "slope", 20 ],        // Sales grow by 20 units each month
#	[ "intercept", 80 ],    // Starting point: sales would be 80 at month 0
#	[ "r_squared", 1 ]      // Perfect fit: sales follow this trend exactly
# ]

# Checking if sales follow a normal (bell-shaped) pattern
? @@NL( oSales.NormalityTest() )
#--> [
#	[ "test", "heuristic" ],  // Method used to test the pattern
#	[ "skewness", 0 ],        // Symmetry: 0 means perfectly balanced
#	[ "kurtosis", -4.0616 ],  // Flatness: negative means flatter than a bell curve
#	[ "p_value", 0.0172 ],    // Statistical check: low value suggests not normal
#	[ "is_normal", 0 ]        // Result: 0 means sales don’t follow a normal pattern
# ]

pf()
# Executed in 0.01 second(s) in Ring 1.22

#=====================================#
#  TESTING THE ANALYTICS Plan SYSTEM  #
#=====================================#

pr()

aStep = [ [ "function", "ValidateData" ], [ "required", 1 ], [ "description", "Check data quality" ] ]
? HasKey(aStep, "condition")
#--> FALSE

? @@(aStep[:condition])
#--> ""

? HasKey(aStep, "required")

? @@(aStep[:required])
#--> 1

pf()
# Executed in 0.0020 second(s) in Ring 1.22


/*--- EXAMPLE 1: Basic Data Exploration

pr()

aSalesData = [
	120, 150, 89, 200, 175,
	95, 180, 210, 165, 145,
	190, 88, 220, 155, 170
]

oSales = new stzDataSet(aSalesData)

# Making a plan for understanding data

oPlan = oSales.MakePlan(:Understand) # Or PreparePlan() or GeneratePlan()

# Preview Plan without execution

? oSales.PlanSummary(:Understand)
#-->
'
╭─────────────────────────────────╮
│ Plan: Exploratory Data Analysis │
╰─────────────────────────────────╯
• Name: {eda}
• Goal: Comprehensive data exploration and understanding
• Steps (9):
  1. Check data quality
  2. Identify data type
  3. Get sample size
  4. Central tendency (conditional)
  5. Robust center (conditional)
  6. Variability (conditional)
  7. Distribution shape (conditional)
  8. Asymmetry check (conditional)
  9. Outlier detection (conditional)
'

# Full Plan execution

oResults = oSales.ExecutePlan(:EDA) # Or RunPlan() or PerformPlan()
#-->
'
╭───────────────────────────────────────────╮
│ Executing Plan: Exploratory Data Analysis │
╰───────────────────────────────────────────╯
• Name: {eda}
• Goal: Comprehensive data exploration and understanding
• Steps: 9

✅ Step 1/9: Check data quality
╰─> ValidateData: 1 values

✅ Step 2/9: Identify data type
╰─> Data type: numeric

✅ Step 3/9: Get sample size
╰─> Sample size: 15

✅ Step 4/9: Central tendency
╰─> Mean: 156.8000

✅ Step 5/9: Robust center
╰─> Median: 165

✅ Step 6/9: Variability
╰─> Std Dev: 125.5495

✅ Step 7/9: Distribution shape
╰─> Quartiles: 3 values

✅ Step 8/9: Asymmetry check
╰─> Skewness: 0.0850

✅ Step 9/9: Outlier detection
╰─> Outliers present: 0

( Plan completed in 0.0980s : 9 successful steps, 0 errors )
'

pf()
# Executed in 0.1990 second(s) in Ring 1.22

/*--- EXAMPLE 2: Quality Control Analysis

# Manufacturing process data (with some issues)

aProcessData = [98.2, 99.1, 97.8, 101.5, 98.9, 99.3, 98.7, 110.2, 99.0, 98.5, 
                99.4, 97.9, 98.8, 99.2, 98.6, 85.1, 99.1, 98.4, 99.7, 98.3]

oProcess = new stzDataSet(aProcessData)

# Quality control Plan
oQCResults = oProcess.ExecutePlan(:quality)
#-->
'
╭──────────────────────────────────────────╮
│ Executing Plan: Quality Control Analysis │
╰──────────────────────────────────────────╯
• Name: {quality}
• Goal: Statistical process control and quality assessment
• Steps: 8

✅ Step 1/8: Data integrity check
╰─> ValidateData: 1 value(s)

✅ Step 2/8: Process center
╰─> Mean: 98.7850

✅ Step 3/8: Process variation
╰─> Std Dev: 4.1642

✅ Step 4/8: Process consistency
╰─> CoefficientOfVariation: 100

✅ Step 5/8: Process anomalies
╰─> Outliers present: 1

✅ Step 6/8: Out-of-control points
╰─> Outliers: 3 value(s)

✅ Step 7/8: Process spread
╰─> Range: 25.1000

✅ Step 8/8: Process drift detection
❌ Error: Error (R21) : Using operator with values of incorrect type

( Plan completed in 0.0750s : 8 successful step(s), 1 error(s) )
'

pf()
# Executed in 3.7100 second(s) in Ring 1.22

/*--- EXAMPLE 3: Correlation Analysis Between Variables

pr()

# Temperature and ice cream sales data
aTemperature = [72, 75, 80, 85, 90, 68, 78, 82, 88, 95, 70, 77, 83, 87, 92]
aSales = [120, 145, 180, 220, 280, 95, 160, 200, 250, 320, 110, 155, 205, 240, 300]

oTemp = new stzDataSet(aTemperature)
oSalesTemp = new stzDataSet(aSales)

# Correlation Plan (automatically chooses Pearson vs Spearman)
oCorrelation = oTemp.ExecutePlan(:relation)
#-->
'
╭───────────────────────────────────────────╮
│ Executing Plan: Correlation Analysis Plan │
╰───────────────────────────────────────────╯
• Name: {correlation}
• Goal: Analyze relationships between variables
• Steps: 5

✅ Step 1/5: Verify numeric data
╰─> Data type: numeric

✅ Step 2/5: Check sample size
╰─> Sample size: 15

✅ Step 3/5: Test normality assumption
╰─> Normality p-value: [ "skewness", 0.0756 ]

✅ Step 4/5: Spearman correlation (non-normal data)
❌ Error: Error (R19) : Calling function with less number of parameters

✅ Step 5/5: Covariance analysis
❌ Error: Error (R19) : Calling function with less number of parameters

( Plan completed in 0.0740s : 3 successful step(s), 2 error(s) )
'

? ""
# Manual correlation with second dataset
? oTemp.CorrelationWith(oSalesTemp)
#--> 0.1064  #TODO Strong positive correlation expected?

pf()
# Executed in 0.0760 second(s) in Ring 1.22

/*--- EXAMPLE 4: Outlier Investigation

pr()

# Customer satisfaction scores (with some extreme values)
aSatisfaction = [8.2, 7.9, 8.5, 8.1, 7.8, 8.3, 8.0, 2.1, 8.4, 7.7, 
                 8.6, 8.2, 7.9, 9.8, 8.1, 8.3, 7.8, 8.5, 8.0, 7.9]

oSatisfaction = new stzDataSet(aSatisfaction)

# Comprehensive outlier analysis
oSatisfaction.ExecutePlan(:outliers)
#-->
'
╭────────────────────────────────────────────────╮
│ Executing Plan: Outlier Detection and Analysis │
╰────────────────────────────────────────────────╯
• Name: {outliers}
• Goal: Comprehensive outlier identification and impact assessment
• Steps: 7

✅ Step 1/7: Initial outlier detection
╰─> Outliers present: 1

✅ Step 2/7: List outlier values
╰─> Outliers: 2 value(s)

✅ Step 3/7: Standardized scores
╰─> ZScores: 20 value(s)

✅ Step 4/7: Mean with outliers
╰─> Mean: 7.9050

✅ Step 5/7: Robust mean (10% trimmed)
╰─> TrimmedMean: 8.1188

✅ Step 6/7: Outlier-resistant center
╰─> Median: 8.1000

✅ Step 7/7: Outlier-resistant scaling
╰─> RobustScale: 20 value(s)

( Plan completed in 0.0790s : 7 successful step(s), 0 error(s) )
'
pf()
# Executed in 0.0810 second(s) in Ring 1.22

/*--- EXAMPLE 5: Custom Plan Creation

pr()

# Create a specialized financial analysis Plan

aFinancialSteps = [
    [ :function = "Mean", :required = TRUE, :description = "Average return" ],
    [ :function = "StandardDeviation", :required = TRUE, :description = "Volatility measure" ],
    [ :function = "CoefficientOfVariation", :required = TRUE, :description = "Risk-return ratio" ],
    [ :function = "Skewness", :required = TRUE, :description = "Return asymmetry" ],
    [ :condition = "Skewness() > 0", :function = "Percentile", :args = [5], :description = "Downside risk (5th percentile)" ],
    [ :function = "ContainsOutliers", :required = TRUE, :description = "Extreme market events" ],
    [ :condition = "ContainsOutliers()", :function = "Outliers", :description = "Crisis periods identification" ]
]

# Stock return data
aReturns = [0.05, 0.02, -0.01, 0.08, -0.15, 0.03, 0.07, -0.02, 0.12, -0.08, 
            0.04, 0.01, -0.03, 0.09, -0.20, 0.06, 0.02, -0.01, 0.11, -0.04]

oReturns = new stzDataSet(aReturns)

# Register custom Plan
oReturns.AddPlan(
	:FinRisk,
	"Financial Risk Analysis",
	"Comprehensive financial risk assessment", 
    aFinancialSteps
)

# Execute custom Plan
oReturns.ExecutePlan(:FinRisk)
#-->
'
╭─────────────────────────────────────────╮
│ Executing Plan: Financial Risk Analysis │
╰─────────────────────────────────────────╯
• Name: {finrisk}
• Goal: Comprehensive financial risk assessment
• Steps: 6

✅ Step 1/6: Average return
╰─> Mean: 0.0080

✅ Step 2/6: Volatility measure
╰─> Std Dev: 0.0815

✅ Step 3/6: Risk-return ratio
╰─> CoefficientOfVariation: 100

✅ Step 4/6: Return asymmetry
╰─> Skewness: -0.0976

✅ Step 5/6: Extreme market events
╰─> Outliers present: 1

✅ Step 6/6: Crisis periods identification
╰─> Outliers: 1 value(s)

( Plan completed in 0.0730s : 6 successful step(s), 0 error(s) )
'

pf()
# Executed in 0.0740 second(s) in Ring 1.22

/*--- EXAMPLE 6: Trend Analysis for Time Series

pr()

# Monthly website visitors
aVisitors = [1200, 1350, 1180, 1420, 1580, 1750, 1650, 1820, 1920, 1780, 2100, 2350]
oVisitors = new stzDataSet(aVisitors)

# Trend analysis Plan
oVisitors.ExecutePlan(:trends)
'
╭────────────────────────────────────────────╮
│ Executing Plan: Time Series Trend Analysis │
╰────────────────────────────────────────────╯
• Name: {trends}
• Goal: Analyze temporal patterns and trends
• Steps: 6

✅ Step 1/6: Check sufficient data points
╰─> Sample size: 12

✅ Step 2/6: Overall trend direction
❌ Error: Error (R21) : Using operator with values of incorrect type

✅ Step 3/6: Smooth short-term fluctuations
╰─> MovingAverage: 8 value(s)

✅ Step 4/6: Long-term trend smoothing
╰─> MovingAverage: 3 value(s)

✅ Step 5/6: Trend stability assessment
╰─> Std Dev: 354.8239

✅ Step 6/6: Trend magnitude
╰─> Range: 1170

( Plan completed in 0.0690s : 6 successful step(s), 1 error(s) )
'

pf()
# Executed in 0.0700 second(s) in Ring 1.22

/*--- EXAMPLE 7: Comparative Analysis Plan

pr()

# Before/After performance data
aBefore = [78, 82, 75, 80, 77, 83, 79, 81, 76, 84]
aAfter = [85, 88, 84, 87, 89, 91, 86, 90, 87, 93]

oBefore = new stzDataSet(aBefore)
oAfter = new stzDataSet(aAfter)

# Run EDA on both datasets
oBefore.ExecutePlan(:EDA)
#-->
'
╭───────────────────────────────────────────╮
│ Executing Plan: Exploratory Data Analysis │
╰───────────────────────────────────────────╯
• Data: [ 78, 82, 75, 80, 77, 83, 79, 81, 76, 84 ]
• Name: {eda}
• Goal: Comprehensive data exploration and understanding
• Steps: 9

✅ Step 1/9: Check data quality
╰─> ValidateData: 1 value(s)

✅ Step 2/9: Identify data type
╰─> Data type: numeric

✅ Step 3/9: Get sample size
╰─> Sample size: 10

✅ Step 4/9: Central tendency
╰─> Mean: 79.5000

✅ Step 5/9: Robust center
╰─> Median: 79.5000

✅ Step 6/9: Variability
╰─> Std Dev: 80.6658

✅ Step 7/9: Distribution shape
╰─> Quartiles: 3 value(s)

✅ Step 8/9: Asymmetry check
╰─> Skewness: 0.1188

✅ Step 9/9: Outlier detection
╰─> Outliers present: 0

( Plan completed in 0.1060s : 9 successful step(s), 0 error(s) )
'

? ""
oAfter.ExecutePlan(:EDA)
#-->
'
╭───────────────────────────────────────────╮
│ Executing Plan: Exploratory Data Analysis │
╰───────────────────────────────────────────╯
• Data: [ 85, 88, 84, 87, 89, 91, 86, 90, 87, 93 ]
• Name: {eda}
• Goal: Comprehensive data exploration and understanding
• Steps: 9

✅ Step 1/9: Check data quality
╰─> ValidateData: 1 value(s)

✅ Step 2/9: Identify data type
╰─> Data type: numeric

✅ Step 3/9: Get sample size
╰─> Sample size: 10

✅ Step 4/9: Central tendency
╰─> Mean: 88

✅ Step 5/9: Robust center
╰─> Median: 87.5000

✅ Step 6/9: Variability
╰─> Std Dev: 89.8637

✅ Step 7/9: Distribution shape
╰─> Quartiles: 3 value(s)

✅ Step 8/9: Asymmetry check
╰─> Skewness: 0.1188

✅ Step 9/9: Outlier detection
╰─> Outliers present: 0

( Plan completed in 0.1050s : 9 successful step(s), 0 error(s) )
'

? ""
# Compare key metrics
? Boxround("Performance Comparison")
? "Before - Mean: " + @@(oBefore.Mean()) + ", Std: " + @@(oBefore.StandardDeviation())
? "After  - Mean: " + @@(oAfter.Mean()) + ", Std: " + @@(oAfter.StandardDeviation())
nImprovement = ((oAfter.Mean() - oBefore.Mean()) / oBefore.Mean()) * 100
? "Improvement: " + @@(nImprovement) + "%"
#-->
'
Before - Mean: 80.6658, Std: 3.2675
After  - Mean: 89.8637, Std: 3.4113
Improvement: 11.4025%
'

pf()
# Executed in 0.2360 second(s) in Ring 1.22

/*--- EXAMPLE 8: Smart Plan Selection

pr()

# Function to automatically suggest best Plan based on data characteristics

# Test with different datasets
oNormalData = new stzDataSet([98, 99, 100, 101, 99, 98, 100, 99, 101, 98])
oSkewedData = new stzDataSet([10, 11, 12, 11, 10, 45, 12, 11, 10, 11, 9, 12])
oHighVarData = new stzDataSet([50, 150, 75, 200, 25, 175, 100, 225, 60, 180])

? "Normal data → " + oNormalData.SuggestPlan()     # "NORMALITY"
? "Skewed data → " + oSkewedData.SuggestPlan()     # "OUTLIERS"  
? "High variance → " + oHighVarData.SuggestPlan()  # "QC"
? ""
# You can run any plan easily using its name

oNormalData.RunPlan(:NORMALITY) # Or ExecutePlan()
#-->
'
╭───────────────────────────────────────────╮
│ Executing Plan: Normality Assessment Plan │
╰───────────────────────────────────────────╯
• Data: [ 98, 99, 100, 101, 99, 98, 100, 99, 101, 98 ]
• Name: {normality}
• Goal: Determine if data follows normal distribution
• Steps: 5

✅ Step 1/5: Check sample size adequacy
╰─> Sample size: 10

✅ Step 2/5: Formal normality test
╰─> Normality p-value: [ "skewness", 0.0342 ]

✅ Step 3/5: Check asymmetry
╰─> Skewness: 0.1186

✅ Step 4/5: Check tail behavior
╰─> Kurtosis: -4.1624

✅ Step 5/5: Visual normality indicators
╰─> BoxPlotStats: 8 value(s)

( Plan completed in 0.0580s : 5 successful step(s), 0 error(s) )
'

pf()
# Executed in 0.0600 second(s) in Ring 1.22

/*--- EXAMPLE 9: Plan Chaining

pr()

# Comprehensive data analysis pipeline
pProductionData = new stzDataSet([
	95.2, 96.1, 94.8, 97.3, 95.9, 96.5, 95.1, 98.2, 96.0, 95.7,
    96.8, 94.9, 95.6, 96.3, 95.4, 99.1, 96.2, 95.8, 96.7, 95.3
])

pProductionData.ChainPlans([ "EDA", "QUALITY", "OUTLIERS", "NORMALITY" ])
#-->
'
╭───────────────────────────────────────────╮
│ Executing Plan: Exploratory Data Analysis │
╰───────────────────────────────────────────╯
• Data: [ 95.2000, 96.1000, 94.8000, 97.3000, 95.9000, 96.5000, 95.1000, 98.2000, 96, 95.7000, 96.8000, 94.9000, 95.6000, 96.3000, 95.4000, 99.1000, 96.2000, 95.8000, 96.7000, 95.3000 ]
• Name: {eda}
• Goal: Comprehensive data exploration and understanding
• Steps: 9

✅ Step 1/9: Check data quality
╰─> ValidateData: 1 value(s)

✅ Step 2/9: Identify data type
╰─> Data type: numeric

✅ Step 3/9: Get sample size
╰─> Sample size: 20

✅ Step 4/9: Central tendency
╰─> Mean: 96.1450

✅ Step 5/9: Robust center
╰─> Median: 95.9500

✅ Step 6/9: Variability
╰─> Std Dev: 97.5325

✅ Step 7/9: Distribution shape
╰─> Quartiles: 3 value(s)

✅ Step 8/9: Asymmetry check
╰─> Skewness: 0.0542

✅ Step 9/9: Outlier detection
╰─> Outliers present: 1

( Plan completed in 0.1050s : 9 successful step(s), 0 error(s) )

╭──────────────────────────────────────────╮
│ Executing Plan: Quality Control Analysis │
╰──────────────────────────────────────────╯
• Name: {quality}
• Goal: Statistical process control and quality assessment
• Steps: 8

✅ Step 1/8: Data integrity check
╰─> ValidateData: 1 value(s)

✅ Step 2/8: Process center
╰─> Mean: 97.5325

✅ Step 3/8: Process variation
╰─> Std Dev: 1.7917

✅ Step 4/8: Process consistency
╰─> CoefficientOfVariation: 1.8370

✅ Step 5/8: Process anomalies
╰─> Outliers present: 1

✅ Step 6/8: Out-of-control points
╰─> Outliers: 1 value(s)

✅ Step 7/8: Process spread
╰─> Range: 4.3000

✅ Step 8/8: Process drift detection
❌ Error: Error (R21) : Using operator with values of incorrect type

( Plan completed in 0.0730s : 8 successful step(s), 1 error(s) )

╭────────────────────────────────────────────────╮
│ Executing Plan: Outlier Detection and Analysis │
╰────────────────────────────────────────────────╯
• Name: {outliers}
• Goal: Comprehensive outlier identification and impact assessment
• Steps: 7

✅ Step 1/7: Initial outlier detection
╰─> Outliers present: 1

✅ Step 2/7: List outlier values
╰─> Outliers: 1 value(s)

✅ Step 3/7: Standardized scores
╰─> ZScores: 20 value(s)

✅ Step 4/7: Mean with outliers
╰─> Mean: 1.7917

✅ Step 5/7: Robust mean (10% trimmed)
╰─> TrimmedMean: 95.9937

✅ Step 6/7: Outlier-resistant center
╰─> Median: 95.9500

✅ Step 7/7: Outlier-resistant scaling
╰─> RobustScale: 20 value(s)

( Plan completed in 0.0770s : 7 successful step(s), 0 error(s) )

╭───────────────────────────────────────────╮
│ Executing Plan: Normality Assessment Plan │
╰───────────────────────────────────────────╯
• Name: {normality}
• Goal: Determine if data follows normal distribution
• Steps: 6

✅ Step 1/6: Check sample size adequacy
╰─> Sample size: 20

✅ Step 2/6: Formal normality test
╰─> Normality p-value: [ "skewness", 0.0542 ]

✅ Step 3/6: Check asymmetry
╰─> Skewness: 0.0542

✅ Step 4/6: Check tail behavior
╰─> Kurtosis: -3.4740

✅ Step 5/6: Visual normality indicators
╰─> BoxPlotStats: 8 value(s)

✅ Step 6/6: Outlier impact on normality
╰─> Outliers: 1 value(s)

( Plan completed in 0.0610s : 6 successful step(s), 0 error(s) )
'

pf()
# Executed in 0.3180 second(s) in Ring 1.22

/*--- EXAMPLE 10: Conditional Plan Execution

pr()

# Test dataset with various characteristics
oMixedData = new stzDataSet([
	100, 98, 102, 99, 101, 97, 103, 95, 105, 99, 
	98, 101, 96, 104, 100, 180, 99, 102, 98, 101,
	97, 103, 100, 99, 102, 98, 101, 97, 104, 100
])

oMixedData.AdaptiveAnalysis()
#-->
'
~> Start with basic exploration...
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

╭───────────────────────────────────────────╮
│ Executing Plan: Exploratory Data Analysis │
╰───────────────────────────────────────────╯
• Data: [ 100, 98, 102, 99, 101, 97, 103, 95, 105, 99, 98, 101, 96, 104, 100, 180, 99, 102, 98, 101, 97, 103, 100, 99, 102, 98, 101, 97, 104, 100 ]
• Name: {eda}
• Goal: Comprehensive data exploration and understanding
• Steps: 9

✅ Step 1/9: Check data quality
╰─> ValidateData: 1 value(s)

✅ Step 2/9: Identify data type
╰─> Data type: numeric

✅ Step 3/9: Get sample size
╰─> Sample size: 30

✅ Step 4/9: Central tendency
╰─> Mean: 102.6333

✅ Step 5/9: Robust center
╰─> Median: 100

✅ Step 6/9: Variability
╰─> Std Dev: 90.5341

✅ Step 7/9: Distribution shape
╰─> Quartiles: 3 value(s)

✅ Step 8/9: Asymmetry check
╰─> Skewness: 0.0373

✅ Step 9/9: Outlier detection
╰─> Outliers present: 1

( Plan completed in 0.1030s : 9 successful step(s), 0 error(s) )

~> Outliers found, performing detailed outlier analysis...
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

╭────────────────────────────────────────────────╮
│ Executing Plan: Outlier Detection and Analysis │
╰────────────────────────────────────────────────╯
• Name: {outliers}
• Goal: Comprehensive outlier identification and impact assessment
• Steps: 7

✅ Step 1/7: Initial outlier detection
╰─> Outliers present: 1

✅ Step 2/7: List outlier values
╰─> Outliers: 1 value(s)

✅ Step 3/7: Standardized scores
╰─> ZScores: 30 value(s)

✅ Step 4/7: Mean with outliers
╰─> Mean: 0.0373

✅ Step 5/7: Robust mean (10% trimmed)
╰─> TrimmedMean: 100.0833

✅ Step 6/7: Outlier-resistant center
╰─> Median: 100

✅ Step 7/7: Outlier-resistant scaling
╰─> RobustScale: 30 value(s)

( Plan completed in 0.0750s : 7 successful step(s), 0 error(s) )

~> Sufficient sample size, testing normality assumptions...
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

╭───────────────────────────────────────────╮
│ Executing Plan: Normality Assessment Plan │
╰───────────────────────────────────────────╯
• Name: {normality}
• Goal: Determine if data follows normal distribution
• Steps: 6

✅ Step 1/6: Check sample size adequacy
╰─> Sample size: 30

✅ Step 2/6: Formal normality test
╰─> Normality p-value: [ "skewness", 0.0375 ]

✅ Step 3/6: Check asymmetry
╰─> Skewness: 0.1462

✅ Step 4/6: Check tail behavior
╰─> Kurtosis: -2.4901

✅ Step 5/6: Visual normality indicators
╰─> BoxPlotStats: 8 value(s)

✅ Step 6/6: Outlier impact on normality
╰─> Outliers: 1 value(s)

( Plan completed in 0.0610s : 6 successful step(s), 0 error(s) )
'

pf()
# Executed in 0.2430 second(s) in Ring 1.22



