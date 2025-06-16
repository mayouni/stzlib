
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

#=========================================#
#  TESTING THE ANALYTICS WORKFLOW SYSTEM  #
#=========================================#

/*--- EXAMPLE 1: Basic Data Exploration
*/
pr()

# Sample sales data
aSalesData = [120, 150, 89, 200, 175, 95, 180, 210, 165, 145, 190, 88, 220, 155, 170]

oSales = new stzDataSet(aSalesData)

# Simple workflow generation
oWorkflow = oSales.GenerateWorkflow(:Understand)
? oWorkflow[:name]          # "Exploratory Data Analysis"
? oWorkflow[:total_steps]   # 9 (filtered based on data type)

# Preview workflow without execution
? oSales.WorkflowSummary(:Understand) + NL
# Output:
# 📋 Workflow: Exploratory Data Analysis
# 🎯 Goal: Comprehensive data exploration and understanding
# ⏱️  Estimated time: 1.4 seconds
# 📊 Steps (9):
# 
#   1. Check data quality
#   2. Identify data type
#   3. Get sample size
#   4. Central tendency
#   5. Robust center
#   6. Variability
#   7. Distribution shape
#   8. Asymmetry check
#   9. Outlier detection

# Full workflow execution
//oResults = oSales.ExecuteWorkflow("EDA", TRUE)
# Output:
# 🔄 Executing Workflow: Exploratory Data Analysis
# 📋 Description: Comprehensive data exploration and understanding
# 📊 Steps: 9
# 
# Step 1/9: Check data quality
#    ✅ ValidateData: completed
# Step 2/9: Identify data type  
#    ✅ Data type: numeric
# Step 3/9: Get sample size
#    ✅ Sample size: 15
# Step 4/9: Central tendency
#    ✅ Mean: 153.13
# Step 5/9: Robust center
#    ✅ Median: 155.00
# Step 6/9: Variability
#    ✅ Std Dev: 38.42
# Step 7/9: Distribution shape
#    ✅ Quartiles: 4 values
# Step 8/9: Asymmetry check
#    ✅ Skewness: -0.23
# Step 9/9: Outlier detection
#    ✅ Outliers present: FALSE
# 
# 🎯 Workflow completed: 9 successful steps, 0 errors

pf()

/*--- EXAMPLE 2: Quality Control Analysis
# ==================================

# Manufacturing process data (with some issues)
aProcessData = [98.2, 99.1, 97.8, 101.5, 98.9, 99.3, 98.7, 110.2, 99.0, 98.5, 
                99.4, 97.9, 98.8, 99.2, 98.6, 85.1, 99.1, 98.4, 99.7, 98.3]

oProcess = new stzDataSet(aProcessData)

# Quality control workflow
oQCResults = oProcess.ExecuteWorkflow("quality control", TRUE)
# This will automatically:
# 1. Validate data integrity
# 2. Calculate process center (mean)  
# 3. Measure process variation (std dev)
# 4. Assess consistency (CV)
# 5. Detect anomalies (outliers)
# 6. List out-of-control points
# 7. Check process drift

# Access specific results
for aResult in oQCResults[:results]
    if aResult[:function] = "CoefficientOfVariation"
        if aResult[:result] > 5
            ? "⚠️  High process variability detected: " + aResult[:result] + "%"
        ok
    ok
    
    if aResult[:function] = "ContainsOutliers" and aResult[:result] = TRUE
        ? "🚨 Quality control alert: Outliers detected in process"
    ok
next


/*--- EXAMPLE 3: Correlation Analysis Between Variables
# ================================================

# Temperature and ice cream sales data
aTemperature = [72, 75, 80, 85, 90, 68, 78, 82, 88, 95, 70, 77, 83, 87, 92]
aSales = [120, 145, 180, 220, 280, 95, 160, 200, 250, 320, 110, 155, 205, 240, 300]

oTemp = new stzDataSet(aTemperature)
oSalesTemp = new stzDataSet(aSales)

# Correlation workflow (automatically chooses Pearson vs Spearman)
oCorrelation = oTemp.ExecuteWorkflow("find relationships", FALSE)

# Manual correlation with second dataset
nCorr = oTemp.CorrelationWith(oSalesTemp)
? "Temperature-Sales Correlation: " + @@(nCorr)  # Strong positive correlation expected


/*--- EXAMPLE 4: Outlier Investigation
# ================================

# Customer satisfaction scores (with some extreme values)
aSatisfaction = [8.2, 7.9, 8.5, 8.1, 7.8, 8.3, 8.0, 2.1, 8.4, 7.7, 
                 8.6, 8.2, 7.9, 9.8, 8.1, 8.3, 7.8, 8.5, 8.0, 7.9]

oSatisfaction = new stzDataSet(aSatisfaction)

# Comprehensive outlier analysis
oOutlierResults = oSatisfaction.ExecuteWorkflow("detect outliers", TRUE)

# Extract actionable insights
for aResult in oOutlierResults[:results]
    if aResult[:function] = "Outliers"
        ? "🎯 Outlier values requiring investigation: " + This._FormatList(aResult[:result])
    ok
    
    if aResult[:function] = "TrimmedMean"
        ? "📊 Robust average (outliers removed): " + @@(aResult[:result])
    ok
next


/*--- EXAMPLE 5: Custom Workflow Creation
# ===================================

# Create a specialized financial analysis workflow
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

# Register custom workflow
cCustomKey = oReturns.CreateCustomWorkflow("Financial Risk Analysis", 
                                          "Comprehensive financial risk assessment", 
                                          aFinancialSteps)

# Execute custom workflow
oFinancialResults = oReturns.ExecuteWorkflow(cCustomKey, TRUE)


/*--- EXAMPLE 6: Trend Analysis for Time Series
# =========================================

# Monthly website visitors
aVisitors = [1200, 1350, 1180, 1420, 1580, 1750, 1650, 1820, 1920, 1780, 2100, 2350]

oVisitors = new stzDataSet(aVisitors)

# Trend analysis workflow
oTrendResults = oVisitors.ExecuteWorkflow("analyze trends", TRUE)

# Extract trend insights
for aResult in oTrendResults[:results]
    if aResult[:function] = "TrendAnalysis"
        ? "📈 Overall trend direction: " + aResult[:result]
    ok
    
    if aResult[:function] = "MovingAverage"
        ? "📊 Smoothed trend line available for visualization"
    ok
next


/*--- EXAMPLE 7: Comparative Analysis Workflow
# =======================================

# Before/After performance data
aBefore = [78, 82, 75, 80, 77, 83, 79, 81, 76, 84]
aAfter = [85, 88, 84, 87, 89, 91, 86, 90, 87, 93]

oBefore = new stzDataSet(aBefore)
oAfter = new stzDataSet(aAfter)

# Run EDA on both datasets
oBeforeAnalysis = oBefore.ExecuteWorkflow("EDA", FALSE)
oAfterAnalysis = oAfter.ExecuteWorkflow("EDA", FALSE)

# Compare key metrics
? "=== Performance Comparison ==="
? "Before - Mean: " + @@(oBefore.Mean()) + ", Std: " + @@(oBefore.StandardDeviation())
? "After  - Mean: " + @@(oAfter.Mean()) + ", Std: " + @@(oAfter.StandardDeviation())

nImprovement = ((oAfter.Mean() - oBefore.Mean()) / oBefore.Mean()) * 100
? "Improvement: " + @@(nImprovement) + "%"


/*--- EXAMPLE 8: Smart Workflow Selection
# ===================================

# Function to automatically suggest best workflow based on data characteristics
func SuggestWorkflow(paData)
    oData = new stzDataSet(paData)
    
    cDataType = oData.DataType()
    nCount = oData.Count()
    bHasOutliers = oData.ContainsOutliers()
    
    if nCount < 10
        return "EDA"  # Basic exploration for small samples
    ok
    
    if bHasOutliers
        return "OUTLIERS"  # Focus on outlier analysis
    ok
    
    if cDataType = "numeric" and nCount >= 20
        nCV = oData.CoefficientOfVariation()
        if nCV > 30
            return "QC"  # Quality control for high variability
        else
            return "NORMALITY"  # Test distribution assumptions
        ok
    ok
    
    return "EDA"  # Default fallback

# Test with different datasets
aNormalData = [98, 99, 100, 101, 99, 98, 100, 99, 101, 98]
aSkewedData = [10, 11, 12, 11, 10, 45, 12, 11, 10, 11, 9, 12]
aHighVarData = [50, 150, 75, 200, 25, 175, 100, 225, 60, 180]

? "Normal data → " + SuggestWorkflow(aNormalData)     # "NORMALITY"
? "Skewed data → " + SuggestWorkflow(aSkewedData)     # "OUTLIERS"  
? "High variance → " + SuggestWorkflow(aHighVarData)  # "QC"


/*--- EXAMPLE 9: Workflow Chaining (COMPLETED)
# ============================

# Execute multiple workflows in sequence
func ChainWorkflows(paData, paWorkflowNames)
    oData = new stzDataSet(paData)
    aAllResults = []
    
    for cWorkflow in paWorkflowNames
        ? "🔗 Executing: " + cWorkflow
        oResult = oData.ExecuteWorkflow(cWorkflow, FALSE)
        aAllResults + oResult
    next
    
    return aAllResults

/*--- EXAMPLE usage - comprehensive data analysis pipeline
aProductionData = [95.2, 96.1, 94.8, 97.3, 95.9, 96.5, 95.1, 98.2, 96.0, 95.7,
                   96.8, 94.9, 95.6, 96.3, 95.4, 99.1, 96.2, 95.8, 96.7, 95.3]

aWorkflowChain = ["EDA", "QC", "OUTLIERS", "NORMALITY"]
aChainedResults = ChainWorkflows(aProductionData, aWorkflowChain)

? "📊 Pipeline completed: " + len(aChainedResults) + " workflows executed"


/*--- EXAMPLE 10: Conditional Workflow Execution
# ==========================================

# Smart workflow that adapts based on intermediate results
func AdaptiveAnalysis(paData)
    oData = new stzDataSet(paData)
    
    # Start with basic exploration
    oEDA = oData.ExecuteWorkflow("EDA", FALSE)
    
    # Extract key findings
    nMean = oData.Mean()
    nStdDev = oData.StandardDeviation()
    nCV = oData.CoefficientOfVariation()
    
    # Conditional branching based on initial results
    if nCV > 25
        ? "⚠️  High variability detected, running quality control analysis..."
        oQC = oData.ExecuteWorkflow("QC", TRUE)
    ok
    
    if oData.ContainsOutliers()
        ? "🔍 Outliers found, performing detailed outlier analysis..."
        oOutliers = oData.ExecuteWorkflow("OUTLIERS", TRUE)
    ok
    
    if oData.Count() >= 30
        ? "📈 Sufficient sample size, testing normality assumptions..."
        oNormality = oData.ExecuteWorkflow("NORMALITY", TRUE)
    ok
    
    return TRUE

# Test dataset with various characteristics
aMixedData = [100, 98, 102, 99, 101, 97, 103, 95, 105, 99, 
              98, 101, 96, 104, 100, 180, 99, 102, 98, 101,
              97, 103, 100, 99, 102, 98, 101, 97, 104, 100]

AdaptiveAnalysis(aMixedData)


/*--- EXAMPLE 11: Batch Processing Multiple Datasets
# ==============================================

# Process multiple related datasets with consistent workflows
func BatchAnalysis(paDatasets, cWorkflowType)
    aBatchResults = []
    nDatasetNum = 1
    
    for aDataset in paDatasets
        ? "📋 Processing Dataset " + nDatasetNum + "..."
        
        oData = new stzDataSet(aDataset)
        oResult = oData.ExecuteWorkflow(cWorkflowType, FALSE)
        
        # Store results with dataset identifier
        oResult[:dataset_id] = nDatasetNum
        aBatchResults + oResult
        
        nDatasetNum++
    next
    
    return aBatchResults

/*--- EXAMPLE: Analyze multiple product lines
aProductA = [85, 87, 86, 88, 85, 89, 87, 86, 88, 87]
aProductB = [92, 94, 91, 95, 93, 90, 94, 92, 96, 93]
aProductC = [78, 80, 77, 82, 79, 76, 81, 78, 83, 80]

aAllProducts = [aProductA, aProductB, aProductC]
aBatchResults = BatchAnalysis(aAllProducts, "EDA")

? "📊 Batch analysis completed for " + len(aAllProducts) + " product lines"


/*--- EXAMPLE 12: Workflow Performance Monitoring
# ===========================================

# Monitor and log workflow execution times and success rates
class stzWorkflowMonitor
    aExecutionLog = []
    
    func LogExecution(cWorkflowName, nStartTime, nEndTime, bSuccess, cError)
        aLogEntry = [
            :workflow = cWorkflowName,
            :start_time = nStartTime,
            :end_time = nEndTime,
            :duration = nEndTime - nStartTime,
            :success = bSuccess,
            :error = cError,
            :timestamp = Date()
        ]
        
        This.aExecutionLog + aLogEntry
        
    func GetPerformanceStats(cWorkflowName)
        aFilteredLogs = []
        for aEntry in This.aExecutionLog
            if aEntry[:workflow] = cWorkflowName
                aFilteredLogs + aEntry
            ok
        next
        
        if len(aFilteredLogs) = 0
            return "No execution data for " + cWorkflowName
        ok
        
        nTotal = len(aFilteredLogs)
        nSuccessful = 0
        nTotalDuration = 0
        
        for aEntry in aFilteredLogs
            if aEntry[:success]
                nSuccessful++
            ok
            nTotalDuration += aEntry[:duration]
        next
        
        nSuccessRate = (nSuccessful / nTotal) * 100
        nAvgDuration = nTotalDuration / nTotal
        
        return [
            :total_executions = nTotal,
            :success_rate = nSuccessRate,
            :average_duration = nAvgDuration
        ]

# Usage example
oMonitor = new stzWorkflowMonitor()

func MonitoredWorkflow(paData, cWorkflowType)
    nStart = clock()
    
    try
        oData = new stzDataSet(paData)
        oResult = oData.ExecuteWorkflow(cWorkflowType, FALSE)
        nEnd = clock()
        oMonitor.LogExecution(cWorkflowType, nStart, nEnd, TRUE, "")
        return oResult
    catch cError
        nEnd = clock()
        oMonitor.LogExecution(cWorkflowType, nStart, nEnd, FALSE, cError)
        ? "❌ Workflow failed: " + cError
        return NULL
    done

# Test monitoring
aTestData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
MonitoredWorkflow(aTestData, "EDA")
MonitoredWorkflow(aTestData, "OUTLIERS")

? oMonitor.GetPerformanceStats("EDA")


/*--- EXAMPLE 13: Dynamic Workflow Generation
# =======================================

# Generate workflows based on data characteristics and user goals
func GenerateDynamicWorkflow(paData, cUserGoal, cDataContext)
    oData = new stzDataSet(paData)
    aCustomSteps = []
    
    # Base steps for all workflows
    aCustomSteps + [ :function = "ValidateData", :required = TRUE, :description = "Data integrity check" ]
    aCustomSteps + [ :function = "Count", :required = TRUE, :description = "Sample size" ]
    
    # Goal-specific steps
    switch cUserGoal
    case "process_improvement"
        aCustomSteps + [ :function = "Mean", :required = TRUE, :description = "Process center" ]
        aCustomSteps + [ :function = "StandardDeviation", :required = TRUE, :description = "Process variation" ]
        aCustomSteps + [ :function = "CoefficientOfVariation", :required = TRUE, :description = "Relative variation" ]
        aCustomSteps + [ :condition = "CoefficientOfVariation() > 15", :function = "ControlCharts", :description = "Process control analysis" ]
        
    case "financial_analysis"
        aCustomSteps + [ :function = "Mean", :required = TRUE, :description = "Expected return" ]
        aCustomSteps + [ :function = "StandardDeviation", :required = TRUE, :description = "Volatility" ]
        aCustomSteps + [ :function = "Skewness", :required = TRUE, :description = "Return distribution shape" ]
        aCustomSteps + [ :function = "Percentile", :args = [5], :required = TRUE, :description = "Value at Risk (5%)" ]
        
    case "quality_assessment"
        aCustomSteps + [ :function = "Median", :required = TRUE, :description = "Robust center" ]
        aCustomSteps + [ :function = "IQR", :required = TRUE, :description = "Middle 50% spread" ]
        aCustomSteps + [ :function = "ContainsOutliers", :required = TRUE, :description = "Quality issues detection" ]
        aCustomSteps + [ :condition = "ContainsOutliers()", :function = "Outliers", :description = "Problem identification" ]
    off
    
    # Context-specific additions
    if cDataContext = "manufacturing"
        aCustomSteps + [ :function = "ProcessCapability", :description = "Cp/Cpk calculation" ]
    elseif cDataContext = "sales"
        aCustomSteps + [ :function = "TrendAnalysis", :description = "Sales trend identification" ]
    elseif cDataContext = "survey"
        aCustomSteps + [ :function = "ConfidenceInterval", :description = "Population estimate" ]
    ok
    
    return aCustomSteps

/*--- EXAMPLE usage
aSalesPerformance = [120, 135, 118, 142, 156, 128, 149, 133, 157, 141]

aDynamicSteps = GenerateDynamicWorkflow(aSalesPerformance, "process_improvement", "sales")
oSales = new stzDataSet(aSalesPerformance)
cDynamicKey = oSales.CreateCustomWorkflow("Dynamic Sales Analysis", 
                                         "AI-generated workflow for sales performance", 
                                         aDynamicSteps)

oSales.ExecuteWorkflow(cDynamicKey, TRUE)


/*--- EXAMPLE 14: Workflow Results Comparison
# =======================================

# Compare results across different workflows or datasets
func CompareWorkflowResults(paResults1, paResults2, cComparisonName)
    ? "🔍 " + cComparisonName + " Comparison"
    ? "=" * (len(cComparisonName) + 12)
    
    # Find common functions between results
    aFunctions1 = []
    aFunctions2 = []
    
    for aResult in paResults1[:results]
        aFunctions1 + aResult[:function]
    next
    
    for aResult in paResults2[:results]
        aFunctions2 + aResult[:function]
    next
    
    # Compare common metrics
    for cFunction in aFunctions1
        if find(aFunctions2, cFunction) > 0
            # Find values for this function in both results
            nValue1 = NULL
            nValue2 = NULL
            
            for aResult in paResults1[:results]
                if aResult[:function] = cFunction
                    nValue1 = aResult[:result]
                ok
            next
            
            for aResult in paResults2[:results]
                if aResult[:function] = cFunction
                    nValue2 = aResult[:result]
                ok
            next
            
            if nValue1 != NULL and nValue2 != NULL
                nDifference = nValue2 - nValue1
                nPercentChange = (nDifference / nValue1) * 100
                
                ? cFunction + ":"
                ? "  Dataset 1: " + @@(nValue1)
                ? "  Dataset 2: " + @@(nValue2)
                ? "  Change: " + @@(nDifference) + " (" + @@(nPercentChange) + "%)"
                ? ""
            ok
        ok
    next

/*--- EXAMPLE comparison
aBeforeTraining = [72, 74, 71, 75, 73, 70, 76, 72, 74, 73]
aAfterTraining = [78, 80, 77, 81, 79, 76, 82, 78, 80, 79]

oBefore = new stzDataSet(aBeforeTraining)
oAfter = new stzDataSet(aAfterTraining)

oResultsBefore = oBefore.ExecuteWorkflow("EDA", FALSE)
oResultsAfter = oAfter.ExecuteWorkflow("EDA", FALSE)

CompareWorkflowResults(oResultsBefore, oResultsAfter, "Training Impact Analysis")


/*--- EXAMPLE 15: Workflow Documentation Generator
# ============================================

# Automatically generate documentation for executed workflows
func GenerateWorkflowReport(poResults, cTitle)
    cReport = "# " + cTitle + " - Statistical Analysis Report" + nl + nl
    cReport += "**Generated:** " + Date() + " " + Time() + nl
    cReport += "**Workflow:** " + poResults[:name] + nl
    cReport += "**Description:** " + poResults[:description] + nl + nl
    
    cReport += "## Executive Summary" + nl
    cReport += "This analysis processed " + @@(len(poResults[:results])) + " statistical measures "
    cReport += "with " + @@(poResults[:successful_steps]) + " successful calculations." + nl + nl
    
    cReport += "## Detailed Results" + nl + nl
    
    for aResult in poResults[:results]
        cReport += "### " + aResult[:function] + nl
        cReport += "**Value:** " + @@(aResult[:result]) + nl
        
        if aResult[:description] != NULL
            cReport += "**Interpretation:** " + aResult[:description] + nl
        ok
        
        cReport += "**Status:** " + (aResult[:success] ? "✅ Success" : "❌ Failed") + nl + nl
    next
    
    cReport += "## Recommendations" + nl
    cReport += GenerateRecommendations(poResults) + nl
    
    return cReport

func GenerateRecommendations(poResults)
    cRecommendations = ""
    
    # Look for specific patterns in results
    for aResult in poResults[:results]
        switch aResult[:function]
        case "CoefficientOfVariation"
            if aResult[:result] > 30
                cRecommendations += "- **High Variability Alert:** Consider process standardization (CV: " + @@(aResult[:result]) + "%)" + nl
            ok
            
        case "ContainsOutliers"
            if aResult[:result] = TRUE
                cRecommendations += "- **Data Quality:** Investigate outlying values for data entry errors or special causes" + nl
            ok
            
        case "Skewness"
            if abs(aResult[:result]) > 1
                cRecommendations += "- **Distribution Shape:** Data is highly skewed, consider robust statistical methods" + nl
            ok
        off
    next
    
    if cRecommendations = ""
        cRecommendations = "- Data appears to be within normal parameters for standard analysis"
    ok
    
    return cRecommendations

/*--- EXAMPLE usage
aQualityData = [98.1, 99.2, 97.8, 98.9, 99.1, 98.3, 99.0, 97.9, 98.7, 99.3,
                98.5, 99.1, 98.2, 98.8, 99.2, 98.4, 99.0, 98.6, 99.1, 98.9]

oQuality = new stzDataSet(aQualityData)
oQualityResults = oQuality.ExecuteWorkflow("QC", FALSE)

cReport = GenerateWorkflowReport(oQualityResults, "Monthly Quality Control Analysis")
? cReport

# Save report to file (if file system available)
# write("quality_report.md", cReport)
