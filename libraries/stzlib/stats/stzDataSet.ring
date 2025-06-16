#==========================================================================#
#  stzDataSet Cass - Statistics Layer of the Softanza Analytics Framework  #
#     Four Pillars: Comparison | Composition | Distribution | Relation     #
#==========================================================================#

# Global configuration for missing values
$aSTAT_MISSING_VALUES = [ "", "NA", "NULL", "n/a", "#N/A" ]

# Thresholds and Constants
$nSmallSampleSizeThreshold = 30
$nSkewnessThreshold = 0.5
$nKurtosisThreshold = 3
$nDiversityThreshold = 0.3
$nEntropyThreshold = 1.5
$nMeanDifferenceThreshold = 0.05
$nVarThreshold = 30
$nCorrelationThreshold = 0.7
$nOutlierThreshold = 0.1
$nNormalityThreshold = 0.05
$nMovingAverageWindow = 5

# Insight Templates
$aEmptyInsightTemplates = [
    [ :condition = "Count() = 0", :template = "Dataset is empty - No analysis possible without data." ]
]

$aMixedInsightTemplates = [ 
    [
        :condition = "DataType() = 'mixed'",
        :template = "Mixed dataset containing both numeric and categorical data. Consider separating data types for specialized analysis."
    ]
]

$aNumericInsightTemplates = [
    # Central Tendency Analysis
    [
        :condition = "abs(Mean() - Median()) / max(abs(Mean()), abs(Median()), 1) < $nMeanDifferenceThreshold",
        :template = "Data shows symmetric distribution (mean {Mean()} ≈ median {Median()}), suggesting normal-like behavior."
    ],
    [
        :condition = "Mean() > Median() and abs(Skewness()) > $nSkewnessThreshold",
        :template = "Right-skewed distribution detected (mean {Mean()} > median {Median()}, skewness {Skewness()}). Consider median-based analysis."
    ],
    [
        :condition = "Mean() < Median() and abs(Skewness()) > $nSkewnessThreshold",
        :template = "Left-skewed distribution detected (mean {Mean()} < median {Median()}, skewness {Skewness()}). Outliers may be affecting the mean."
    ],
    
    # Variability Analysis
    [
        :condition = "CoefficientOfVariation() < 15",
        :template = "Low variability (CV = {CoefficientOfVariation()}%) indicates consistent, homogeneous data."
    ],
    [
        :condition = "CoefficientOfVariation() > $nVarThreshold",
        :template = "High variability (CV = {CoefficientOfVariation()}%) suggests heterogeneous data with significant spread."
    ],
    [
        :condition = "IQR() > 0 and (Q3() - Q1()) / Range() > 0.5",
        :template = "Data concentrated in middle 50% (IQR = {IQR()}, Range = {Range()}). Potential outliers at extremes."
    ],
    
    # Distribution Shape Analysis
    [
        :condition = "abs(Kurtosis()) > $nKurtosisThreshold",
        :template = "Extreme kurtosis detected ({Kurtosis()}). Distribution has heavy tails and potential extreme values."
    ],
    [
        :condition = "ContainsOutliers() and len(Outliers()) / Count() > $nOutlierThreshold",
        :template = "Significant outliers detected ({len(Outliers())} outliers, {len(Outliers()) / Count() * 100}% of data). Consider robust statistics."
    ],
    
    # Sample Size Considerations
    [
        :condition = "Count() >= $nSmallSampleSizeThreshold and StandardDeviation() / sqrt(Count()) < Mean() * 0.1",
        :template = "Large sample with stable mean estimate (n={Count()}, SEM={StandardDeviation() / sqrt(Count())}). High confidence in central tendency."
    ],
    
    # Normality Assessment
    [
        :condition = "abs(Skewness()) < 0.5 and abs(Kurtosis()) < 1",
        :template = "Near-normal distribution characteristics (skewness {Skewness()}, kurtosis {Kurtosis()}). Parametric methods appropriate."
    ]
]

$aCategoricalInsightTemplates = [
    [
        :condition = "DataType() = 'categorical' and Diversity() < $nDiversityThreshold",
        :template = "Low diversity ({Diversity() * 100}%) indicates dominant categories - {UniqueCount()} unique values from {Count()} observations."
    ],
    [
        :condition = "DataType() = 'categorical' and Diversity() > 0.8",
        :template = "High diversity ({Diversity() * 100}%) suggests evenly distributed categories or many unique values."
    ],
    [
        :condition = "DataType() = 'categorical' and EntropyIndex() > $nEntropyThreshold",
        :template = "High information content (entropy = {EntropyIndex()}) indicates balanced categorical distribution."
    ],
    [
        :condition = "DataType() = 'categorical' and ModeCount() / Count() > 0.5",
        :template = "Single category dominates ({ModeCount() / Count() * 100}% are '{Mode()[1]}') - consider binary classification."
    ]
]

# Simplified Recommendation Templates
$aRecommendations = [
    # Sample Size Recommendations
    [
        :condition = "Count() < $nSmallSampleSizeThreshold",
        :recommendation = "Small sample size (n={Count()}) prone to outlier influence. Use non-parametric methods, bootstrap confidence intervals, TrimmedMean(), and interpret results cautiously."
    ],
    
    # Skewness Handling
    [
        :condition = "abs(Skewness()) > $nSkewnessThreshold and DataType() = 'numeric'",
        :recommendation = "Skewed data (skewness = {Skewness()}) makes mean unreliable. Use Median(), IQR(), and Quartiles() for robust central tendency analysis."
    ],
    
    # Outlier Management
    [
        :condition = "ContainsOutliers() and len(Outliers()) / Count() > 0.05",
        :recommendation = "Multiple outliers detected ({len(Outliers())} values) can distort statistics. Apply TrimmedMean(10) and RobustScale(), or investigate data quality."
    ],
    
    # Normality Violations
    [
        :condition = "DataType() = 'numeric' and (abs(Skewness()) > 1 or abs(Kurtosis()) > 3)",
        :recommendation = "Non-normal distribution violates test assumptions. Use non-parametric tests, percentile-based confidence intervals, or apply Normalize()/Standardize()."
    ],
    
    # High Variability
    [
        :condition = "CoefficientOfVariation() > 50 and DataType() = 'numeric'",
        :recommendation = "Extremely high variability (CV = {CoefficientOfVariation()}%) may indicate multiple populations. Consider subgroup analysis or use MovingAverage({$nMovingAverageWindow}) to identify patterns."
    ],
    
    # Categorical Data Insights
    [
        :condition = "DataType() = 'categorical' and UniqueCount() / Count() > 0.9",
        :recommendation = "Too many unique categories ({UniqueCount()}/{Count()}) creates sparse data problems. Group categories with frequency < 5% into 'Other' category."
    ],
    
    # Trend Analysis
    [
        :condition = "DataType() = 'numeric' and Count() >= 5",
        :recommendation = "Sequential data contains temporal patterns. Apply TrendAnalysis() and MovingAverage({$nMovingAverageWindow}) to smooth fluctuations and identify trends."
    ]
]

# Domain-Specific Rules
$aDomainInsightRules = [

    :Finance = [
        [
            :condition = "CoefficientOfVariation() > 25",
            :template = "High financial volatility (CV = {CoefficientOfVariation()}%). Risk assessment required."
        ],
        [
            :condition = "abs(Skewness()) > 1",
            :template = "Asymmetric returns distribution (skewness = {Skewness()}). Consider VaR and tail risk measures."
        ],
        [
            :condition = "ContainsOutliers()",
            :template = "Extreme market events detected ({len(Outliers())} outliers). Stress testing recommended."
        ]
    ],

    :Healthcare = [
        [
            :condition = "CoefficientOfVariation() > 30",
            :template = "High variability in health metrics (CV = {CoefficientOfVariation()}%). Patient stratification needed."
        ],
        [
            :condition = "ContainsOutliers()",
            :template = "Outlier patients identified ({len(Outliers())} cases). Clinical review recommended."
        ],
        [
            :condition = "abs(Skewness()) > 1",
            :template = "Non-normal health distribution (skewness = {Skewness()}). Use percentile-based reference ranges."
        ]
    ],

    :Education = [
        [
            :condition = "Median() < 60",
            :template = "Below-average performance (median = {Median()}). Curriculum review needed."
        ],
        [
            :condition = "CoefficientOfVariation() > 40",
            :template = "High performance variability (CV = {CoefficientOfVariation()}%). Differentiated instruction required."
        ],
        [
            :condition = "abs(Skewness()) > 0.5",
            :template = "Skewed score distribution (skewness = {Skewness()}). Assessment difficulty may be inappropriate."
        ]
    ],

    :Quality = [
        [
            :condition = "CoefficientOfVariation() < 5",
            :template = "Excellent process control (CV = {CoefficientOfVariation()}%). Maintain current standards."
        ],
        [
            :condition = "ContainsOutliers()",
            :template = "Quality deviations detected ({len(Outliers())} outliers). Process investigation required."
        ],
        [
            :condition = "Range() / Mean() > 0.2",
            :template = "Wide quality range (Range/Mean = {Range() / Mean()}). Process capability study needed."
        ]
    ]
]

# Summary Templates
$aSummaryTemplate = [
    :format = "text",
    :sections = [
        [
            :title = "Dataset Content",
            :content = "{Content()}"
        ],
        [
            :title = "Dataset Summary",
            :content = [
                "Type: {DataType()}",
                "Count: {Count()}"
            ]
        ],
        [
            :condition = "DataType() = 'numeric'",
            :content = [
                "Mean: {Mean()}",
                "Median: {Median()}",
                "Standard Deviation: {StandardDeviation()}",
                "Range: {Range()} ({Min()} to {Max()})",
                "Quartiles: Q1={Quartiles()[1]}, Q2={Quartiles()[2]}, Q3={Quartiles()[3]}",
                "Outliers: {len(Outliers())} detected"
            ]
        ],
        [
            :condition = "DataType() = 'categorical'",
            :content = [
                "Unique Values: {UniqueCount()}",
                "Diversity: {Diversity() * 100}%",
                "Most Common: {Mode()}"
            ]
        ],
        [
            :title = "Dataset Insights",
            :content = "{Insights()}"
        ]
    ]
]

$aSummaryXTTemplate = [
    :format = "text",
    :sections = [
        :inherit = "$aSummaryTemplate",
        [
            :title = "Recommendations",
            :content = "{Recommendations()}"
        ]
    ]
]

# Class Capabilities Catalog
$aStatFunctions = [
    # === DESCRIPTIVE STATISTICS (PILLAR 1: COMPARISON) ===
    [
        :function = "Mean",
        :params = [],
        :condition = "DataType() = 'numeric'",
        :output = "number",
        :description = "Calculates the arithmetic mean of the dataset."
    ],
    [
        :function = "Median",
        :params = [],
        :condition = "DataType() = 'numeric'",
        :output = "number",
        :description = "Calculates the median of the dataset."
    ],
    [
        :function = "Mode",
        :params = [],
        :condition = "TRUE",
        :output = "list",
        :description = "Finds the most frequent value(s) in the dataset."
    ],
    [
        :function = "StandardDeviation",
        :params = [],
        :condition = "DataType() = 'numeric'",
        :output = "number",
        :description = "Computes the standard deviation for numeric data."
    ],
    [
        :function = "Variance",
        :params = [],
        :condition = "DataType() = 'numeric'",
        :output = "number",
        :description = "Computes the variance for numeric data."
    ],
    [
        :function = "Range",
        :params = [],
        :condition = "DataType() = 'numeric'",
        :output = "number",
        :description = "Returns the difference between maximum and minimum values."
    ],
    [
        :function = "Min",
        :params = [],
        :condition = "DataType() = 'numeric'",
        :output = "number",
        :description = "Returns the minimum value in the dataset."
    ],
    [
        :function = "Max",
        :params = [],
        :condition = "DataType() = 'numeric'",
        :output = "number",
        :description = "Returns the maximum value in the dataset."
    ],
    [
        :function = "Sum",
        :params = [],
        :condition = "DataType() = 'numeric'",
        :output = "number",
        :description = "Sums all numeric values in the dataset."
    ],
    [
        :function = "Count",
        :params = [],
        :condition = "TRUE",
        :output = "number",
        :description = "Returns the number of data points in the dataset."
    ],
    [
        :function = "GeometricMean",
        :params = [],
        :condition = "DataType() = 'numeric' and AllPositive()",
        :output = "number",
        :description = "Calculates the geometric mean for positive numeric data."
    ],
    [
        :function = "HarmonicMean",
        :params = [],
        :condition = "DataType() = 'numeric' and NoZeros()",
        :output = "number",
        :description = "Calculates the harmonic mean for non-zero numeric data."
    ],
    [
        :function = "CoefficientOfVariation",
        :params = [],
        :condition = "DataType() = 'numeric' and Mean() != 0",
        :output = "number",
        :description = "Computes the coefficient of variation as a percentage."
    ],
    [
        :function = "CompareWith",
        :params = ["oOtherStats"],
        :condition = "DataType() = 'numeric' and oOtherStats.DataType() = 'numeric'",
        :output = "list",
        :description = "Compares datasets including mean, variability, and correlation."
    ],
    [
        :function = "SimilarityScore",
        :params = ["oOtherStats"],
        :condition = "DataType() = oOtherStats.DataType()",
        :output = "number",
        :description = "Computes similarity score (0-1) between datasets."
    ],
    [
        :function = "ConfidenceInterval",
        :params = ["nConfidence"],
        :condition = "DataType() = 'numeric' and nConfidence > 0 and nConfidence < 100",
        :output = "list",
        :description = "Calculates confidence interval for the mean."
    ],
    [
        :function = "WeightedMean",
        :params = ["aWeights"],
        :condition = "DataType() = 'numeric' and len(aWeights) = Count()",
        :output = "number",
        :description = "Computes weighted mean with given weights."
    ],
    [
        :function = "TrimmedMean",
        :params = ["nTrimPercent"],
        :condition = "DataType() = 'numeric' and nTrimPercent >= 0 and nTrimPercent < 50",
        :output = "number",
        :description = "Calculates mean after trimming extreme values."
    ],
    [
        :function = "PercentileRank",
        :params = ["nValue"],
        :condition = "DataType() = 'numeric'",
        :output = "number",
        :description = "Computes the percentile rank of a specific value."
    ],

    # === FREQUENCY & CATEGORICAL ANALYSIS (PILLAR 2: COMPOSITION) ===
    [
        :function = "FrequencyTable",
        :params = [],
        :condition = "TRUE",
        :output = "list",
        :description = "Generates frequency table for the dataset."
    ],
    [
        :function = "RelativeFrequency",
        :params = [],
        :condition = "TRUE",
        :output = "list",
        :description = "Computes relative frequencies for all values."
    ],
    [
        :function = "PercentageFrequency",
        :params = [],
        :condition = "TRUE",
        :output = "list",
        :description = "Computes percentage frequencies for all values."
    ],
    [
        :function = "UniqueCount",
        :params = [],
        :condition = "TRUE",
        :output = "number",
        :description = "Counts the number of unique values in the dataset."
    ],
    [
        :function = "UniqueValues",
        :params = [],
        :condition = "TRUE",
        :output = "list",
        :description = "Returns a list of unique values in the dataset."
    ],
    [
        :function = "Diversity",
        :params = [],
        :condition = "TRUE",
        :output = "number",
        :description = "Calculates diversity index (unique values / total values)."
    ],
    [
        :function = "EntropyIndex",
        :params = [],
        :condition = "DataType() = 'categorical'",
        :output = "number",
        :description = "Computes Shannon entropy for categorical data."
    ],
    [
        :function = "ContingencyTable",
        :params = ["oOtherDataSet"],
        :condition = "TRUE",
        :output = "list",
        :description = "Creates contingency table with another dataset."
    ],
    [
        :function = "ModeCount",
        :params = [],
        :condition = "TRUE",
        :output = "number",
        :description = "Returns the frequency of the mode value(s)."
    ],

    # === SHAPE & SPREAD ANALYSIS (PILLAR 3: DISTRIBUTION) ===
    [
        :function = "Percentile",
        :params = ["nPercent"],
        :condition = "DataType() = 'numeric' and nPercent >= 0 and nPercent <= 100",
        :output = "number",
        :description = "Computes percentile using interpolation method."
    ],
    [
        :function = "PercentileXT",
        :params = ["nPercent", "cMethod"],
        :condition = "DataType() = 'numeric' and nPercent >= 0 and nPercent <= 100",
        :output = "number",
        :description = "Computes percentile with specified method (interpolation/nearest)."
    ],
    [
        :function = "Q1",
        :params = [],
        :condition = "DataType() = 'numeric'",
        :output = "number",
        :description = "Returns the first quartile (25th percentile)."
    ],
    [
        :function = "Q2",
        :params = [],
        :condition = "DataType() = 'numeric'",
        :output = "number",
        :description = "Returns the second quartile (50th percentile, median)."
    ],
    [
        :function = "Q3",
        :params = [],
        :condition = "DataType() = 'numeric'",
        :output = "number",
        :description = "Returns the third quartile (75th percentile)."
    ],
    [
        :function = "IQR",
        :params = [],
        :condition = "DataType() = 'numeric'",
        :output = "number",
        :description = "Computes the interquartile range (Q3 - Q1)."
    ],
    [
        :function = "Quartiles",
        :params = [],
        :condition = "DataType() = 'numeric'",
        :output = "list",
        :description = "Returns a list of all quartiles."
    ],
    [
        :function = "Skewness",
        :params = [],
        :condition = "DataType() = 'numeric'",
        :output = "number",
        :description = "Computes the skewness of numeric data."
    ],
    [
        :function = "Kurtosis",
        :params = [],
        :condition = "DataType() = 'numeric'",
        :output = "number",
        :description = "Computes the excess kurtosis of numeric data."
    ],
    [
        :function = "ContainsOutliers",
        :params = [],
        :condition = "DataType() = 'numeric'",
        :output = "bool",
        :description = "Checks for the presence of outliers in the dataset."
    ],
    [
        :function = "Outliers",
        :params = [],
        :condition = "DataType() = 'numeric'",
        :output = "list",
        :description = "Returns a list of outlier values."
    ],
    [
        :function = "IsOutlier",
        :params = ["nValue"],
        :condition = "DataType() = 'numeric'",
        :output = "bool",
        :description = "Checks if a specific value is an outlier."
    ],
    [
        :function = "ZScores",
        :params = [],
        :condition = "DataType() = 'numeric'",
        :output = "list",
        :description = "Computes z-scores for all numeric data points."
    ],
    [
        :function = "MovingAverage",
        :params = ["nWindow"],
        :condition = "DataType() = 'numeric' and nWindow > 0 and nWindow <= Count()",
        :output = "list",
        :description = "Calculates moving average over specified window size."
    ],
    [
        :function = "TrendAnalysis",
        :params = [],
        :condition = "DataType() = 'numeric' and Count() >= 3",
        :output = "string",
        :description = "Detects trends (up, down, stable) in numeric data."
    ],
    [
        :function = "Deciles",
        :params = [],
        :condition = "DataType() = 'numeric'",
        :output = "list",
        :description = "Returns deciles of numeric data (10th, 20th, ..., 90th percentiles)."
    ],
    [
        :function = "BoxPlotStats",
        :params = [],
        :condition = "DataType() = 'numeric'",
        :output = "list",
        :description = "Prepares statistical values for box plot visualization."
    ],
    [
        :function = "NormalityTest",
        :params = [],
        :condition = "DataType() = 'numeric' and Count() >= 8",
        :output = "list",
        :description = "Performs heuristic normality test using skewness and kurtosis."
    ],

    # === CORRELATION & ASSOCIATION ANALYSIS (PILLAR 4: RELATION) ===
    [
        :function = "CorrelationWith",
        :params = ["oOtherStats"],
        :condition = "DataType() = 'numeric' and oOtherStats.DataType() = 'numeric' and Count() = oOtherStats.Count()",
        :output = "number",
        :description = "Computes Pearson correlation coefficient with another dataset."
    ],
    [
        :function = "CovarianceWith",
        :params = ["oOtherStats"],
        :condition = "DataType() = 'numeric' and oOtherStats.DataType() = 'numeric' and Count() = oOtherStats.Count()",
        :output = "number",
        :description = "Computes covariance between datasets."
    ],
    [
        :function = "RankCorrelationWith",
        :params = ["oOtherStats"],
        :condition = "DataType() = 'numeric' and oOtherStats.DataType() = 'numeric' and Count() = oOtherStats.Count()",
        :output = "number",
        :description = "Computes Spearman's rank correlation coefficient."
    ],
    [
        :function = "ChiSquareWith",
        :params = ["oOtherStats"],
        :condition = "DataType() = 'categorical' and oOtherStats.DataType() = 'categorical'",
        :output = "list",
        :description = "Performs chi-square test for categorical data association."
    ],
    [
        :function = "RegressionCoefficients",
        :params = ["oOtherDataSet"],
        :condition = "DataType() = 'numeric' and oOtherDataSet.DataType() = 'numeric' and Count() = oOtherDataSet.Count()",
        :output = "list",
        :description = "Computes linear regression coefficients (slope, intercept)."
    ],
    [
        :function = "PartialCorrelation",
        :params = ["oDataSetY", "oDataSetZ"],
        :condition = "DataType() = 'numeric' and oDataSetY.DataType() = 'numeric' and oDataSetZ.DataType() = 'numeric' and Count() = oDataSetY.Count() and Count() = oDataSetZ.Count()",
        :output = "number",
        :description = "Computes partial correlation controlling for a third dataset."
    ],
    [
        :function = "MutualInformation",
        :params = ["oOtherDataSet"],
        :condition = "DataType() = 'categorical' and oOtherDataSet.DataType() = 'categorical'",
        :output = "number",
        :description = "Computes mutual information for categorical data."
    ],

    # === DATA PROCESSING ===
    [
        :function = "Normalize",
        :params = [],
        :condition = "DataType() = 'numeric'",
        :output = "list",
        :description = "Applies min-max normalization to scale data to 0-1 range."
    ],
    [
        :function = "Standardize",
        :params = [],
        :condition = "DataType() = 'numeric'",
        :output = "list",
        :description = "Applies z-score standardization (mean=0, std=1)."
    ],
    [
        :function = "RobustScale",
        :params = [],
        :condition = "DataType() = 'numeric'",
        :output = "list",
        :description = "Scales data using median and IQR for outlier resistance."
    ],

    # === DATA QUALITY ===
    [
        :function = "ValidateData",
        :params = [],
        :condition = "TRUE",
        :output = "list",
        :description = "Checks data integrity (empty, nulls, outliers, variance)."
    ],

    # === DYNAMIC INSIGHT GENERATION ===
    [
        :function = "GenerateInsight",
        :params = [],
        :condition = "TRUE",
        :output = "string",
        :description = "Generates insights based on data type and templates."
    ],
    [
        :function = "InsightsXT",
        :params = [],
        :condition = "TRUE",
        :output = "list",
        :description = "Generates insights including domain-specific rules."
    ],
    [
        :function = "InsightsOfDomain",
        :params = ["cDomain"],
        :condition = "TRUE",
        :output = "list",
        :description = "Generates insights for a specific domain."
    ],
    [
        :function = "AddInsightRule",
        :params = ["cDomain", "cCondition", "cInsight"],
        :condition = "TRUE",
        :output = "void",
        :description = "Adds a domain-specific insight rule."
    ],
    [
        :function = "AddWeightedRule",
        :params = ["cDomain", "cCondition", "cInsight", "nWeight"],
        :condition = "nWeight > 0",
        :output = "void",
        :description = "Adds a weighted domain-specific insight rule."
    ],
    [
        :function = "PrioritizedInsights",
        :params = ["cDomain"],
        :condition = "TRUE",
        :output = "list",
        :description = "Returns domain insights sorted by weight."
    ],

    # === DYNAMIC RECOMMENDATION SYSTEM ===
    [
        :function = "RecommendAnalysis",
        :params = [],
        :condition = "TRUE",
        :output = "list",
        :description = "Generates analysis recommendations based on data conditions."
    ],

    # === DYNAMIC REPORTING SYSTEM ===
    [
        :function = "Summary",
        :params = [],
        :condition = "TRUE",
        :output = "string",
        :description = "Generates standard summary report of the dataset."
    ],
    [
        :function = "SummaryXT",
        :params = [],
        :condition = "TRUE",
        :output = "string",
        :description = "Generates extended summary with recommendations."
    ],
    [
        :function = "Export",
        :params = [],
        :condition = "TRUE",
        :output = "list",
        :description = "Exports statistical results as structured data."
    ]
]

# Plan Templates - Define common analysis patterns
$aPlanTemplates = [
    
    # EXPLORATORY DATA ANALYSIS
    :EDA = [
		:name = "eda",
        :title = "Exploratory Data Analysis",
        :description = "Comprehensive data exploration and understanding",
        :steps = [
            [ :function = "ValidateData", :required = TRUE, :description = "Check data quality" ],
            [ :function = "DataType", :required = TRUE, :description = "Identify data type" ],
            [ :function = "Count", :required = TRUE, :description = "Get sample size" ],
            [ :condition = "DataType() = 'numeric'", :function = "Mean", :description = "Central tendency" ],
            [ :condition = "DataType() = 'numeric'", :function = "Median", :description = "Robust center" ],
            [ :condition = "DataType() = 'numeric'", :function = "StandardDeviation", :description = "Variability" ],
            [ :condition = "DataType() = 'numeric'", :function = "Quartiles", :description = "Distribution shape" ],
            [ :condition = "DataType() = 'numeric'", :function = "Skewness", :description = "Asymmetry check" ],
            [ :condition = "DataType() = 'numeric'", :function = "ContainsOutliers", :description = "Outlier detection" ],
            [ :condition = "DataType() = 'categorical'", :function = "FrequencyTable", :description = "Category distribution" ],
            [ :condition = "DataType() = 'categorical'", :function = "Diversity", :description = "Category balance" ]
        ]
    ],
    
    # NORMALITY ASSESSMENT
    :NORMALITY = [
		:name = "normality",
        :title = "Normality Assessment Plan",
        :description = "Determine if data follows normal distribution",
        :steps = [
            [ :function = "Count", :required = TRUE, :description = "Check sample size adequacy" ],
            [ :condition = "Count() >= 8", :function = "NormalityTest", :description = "Formal normality test" ],
            [ :function = "Skewness", :required = TRUE, :description = "Check asymmetry" ],
            [ :function = "Kurtosis", :required = TRUE, :description = "Check tail behavior" ],
            [ :function = "BoxPlotStats", :required = TRUE, :description = "Visual normality indicators" ],
            [ :condition = "ContainsOutliers()", :function = "Outliers", :description = "Outlier impact on normality" ]
        ]
    ],
    
    # CORRELATION ANALYSIS
    :CORRELATION = [
		:name = "correlation",
        :title = "Correlation Analysis Plan",
        :description = "Analyze relationships between variables",
        :steps = [
            [ :function = "DataType", :required = TRUE, :description = "Verify numeric data" ],
            [ :function = "Count", :required = TRUE, :description = "Check sample size" ],
            [ :function = "NormalityTest", :description = "Test normality assumption" ],
            [ :condition = "abs(Skewness()) < 0.5 and abs(Kurtosis()) < 1", :function = "CorrelationWith", :description = "Pearson correlation (normal data)" ],
            [ :condition = "abs(Skewness()) >= 0.5 or abs(Kurtosis()) >= 1", :function = "RankCorrelationWith", :description = "Spearman correlation (non-normal data)" ],
            [ :function = "CovarianceWith", :description = "Covariance analysis" ],
            [ :condition = "abs(CorrelationWith(oOther)) > 0.3", :function = "RegressionCoefficients", :description = "Linear relationship modeling" ]
        ]
    ],
    
    # OUTLIER ANALYSIS
    :OUTLIERS = [
		:name = "outliers",
        :title = "Outlier Detection and Analysis",
        :description = "Comprehensive outlier identification and impact assessment",
        :steps = [
            [ :function = "ContainsOutliers", :required = TRUE, :description = "Initial outlier detection" ],
            [ :condition = "ContainsOutliers()", :function = "Outliers", :description = "List outlier values" ],
            [ :condition = "ContainsOutliers()", :function = "ZScores", :description = "Standardized scores" ],
            [ :function = "Mean", :required = TRUE, :description = "Mean with outliers" ],
            [ :condition = "ContainsOutliers()", :function = "TrimmedMean", :args = [10], :description = "Robust mean (10% trimmed)" ],
            [ :function = "Median", :required = TRUE, :description = "Outlier-resistant center" ],
            [ :condition = "ContainsOutliers()", :function = "RobustScale", :description = "Outlier-resistant scaling" ]
        ]
    ],
    
    # TREND ANALYSIS  
    :TRENDS = [
		:name = "trends",
        :title = "Time Series Trend Analysis",
        :description = "Analyze temporal patterns and trends",
        :steps = [
            [ :function = "Count", :required = TRUE, :description = "Check sufficient data points" ],
            [ :condition = "Count() >= 3", :function = "TrendAnalysis", :description = "Overall trend direction" ],
            [ :condition = "Count() >= 5", :function = "MovingAverage", :args = [5], :description = "Smooth short-term fluctuations" ],
            [ :condition = "Count() >= 10", :function = "MovingAverage", :args = [10], :description = "Long-term trend smoothing" ],
            [ :function = "StandardDeviation", :description = "Trend stability assessment" ],
            [ :function = "Range", :description = "Trend magnitude" ]
        ]
    ],
    
    # QUALITY CONTROL
    :QUALITY = [
		:name = "quality",
        :title = "Quality Control Analysis",
        :description = "Statistical process control and quality assessment",
        :steps = [
            [ :function = "ValidateData", :required = TRUE, :description = "Data integrity check" ],
            [ :function = "Mean", :required = TRUE, :description = "Process center" ],
            [ :function = "StandardDeviation", :required = TRUE, :description = "Process variation" ],
            [ :function = "CoefficientOfVariation", :required = TRUE, :description = "Process consistency" ],
            [ :function = "ContainsOutliers", :required = TRUE, :description = "Process anomalies" ],
            [ :condition = "ContainsOutliers()", :function = "Outliers", :description = "Out-of-control points" ],
            [ :function = "Range", :description = "Process spread" ],
            [ :condition = "Count() >= 5", :function = "TrendAnalysis", :description = "Process drift detection" ]
        ]
    ]

]

# Goal-based Plan mapping
$aPlanGoals = [
    :understand = :EDA,
    :explore = :EDA,
    :summarize = :EDA,
    
    :normality = :NORMALITY,
    :normal_distribution = :NORMALITY,
    :test_assumptions = :NORMALITY,
    
    :relationship = :CORRELATION,
    :correlation = :CORRELATION,
    :relation = :CORRELATION,
    :association = :CORRELATION,
    
    :outliers = :OUTLIERS,
    :anomalies = :OUTLIERS,
    :unusual_values = :OUTLIERS,
    
    :trend = :TRENDS,
	:trends = :TRENDS,
    :time_series = :TRENDS,
    :temporal_analysis = :TRENDS,
    
    :quality_control = :QUALITY,
    :process_control = :QUALITY,
    :QUALITY_analysis = :QUALITY,
    :quality_assessment = :QUALITY
]

# Helper Functions
func MissingValues()
    return $aSTAT_MISSING_VALUES

func @MissingValues()
    return $aSTAT_MISSING_VALUES

func DataSetTemplates()
    aResult = $aEmptyInsightTemplates
    
    nLen = len($aNumericInsightTemplates)
    for i = 1 to nLen
        aResult + $aNumericInsightTemplates[i]
    next
    
    nLen = len($aCategoricalInsightTemplates)
    for i = 1 to nLen
        aResult + $aCategoricalInsightTemplates[i]
    next
    
    nLen = len($aMixedInsightTemplates)
    for i = 1 to nLen
        aResult + $aMixedInsightTemplates[i]
    next
    
    return aResult

func DataSetTemplatesXT(cType)
    if CheckParams() and NOT isString(cType)
        SteRaise("Incorrect param type! cType must be a string.")
    ok
    
    switch cType
    on "empty"
        return $aEmptyInsightTemplates
    on "numeric"
        return $aNumericInsightTemplates
    on "categorical"
        return $aCategoricalInsightTemplates
    on "mixed"
        return $aMixedInsightTemplates
    other
        return []
    off

# Convenience functions
func GeneratePlanFor(paData, cGoal)
    oStats = new stzDataSet(paData)
    return oStats.GeneratePlan(cGoal)

func ExecutePlanFor(paData, cGoal)
    oStats = new stzDataSet(paData)
    return oStats.ExecutePlan(cGoal, TRUE)

func PlanSummaryFor(paData, cGoal)
    oStats = new stzDataSet(paData)
    return oStats.PlanSummary(cGoal)

# Factory function
func StzDataSetQ(paData)
	return new stzDataSet(paData)
    
func CompareDatasets(paData1, paData2)
	oStats1 = new stzDataSet(paData1)
	oStats2 = new stzDataSet(paData2)
	return oStats1.CompareWith(oStats2)

#-------------#
#  THE CLASS  #
#-------------#

class stzDataSet

    @anData = []
    @cDataType = "numeric"  # numeric, categorical, mixed, empty
    @bSorted = FALSE
    @anSortedData = []
    @aCache = []  # Standard Ring hash list as [ [:key, value], ... ]

	@bChain = FALSE
	@bFirstChain = FALSE

    @nMinSampleSize = 3  # Minimum for advanced statistics

    def init(paData)
        if CheckParams()
            if NOT isList(paData)
                StzRaise("stzDataSet requires a list of data")
            ok
        ok

        @anData = This._CleanData(paData)
        This._DetectDataType()
        This._InitializeCache()

    def _CleanData(paData)
        # Remove missing values and prepare data
        aCleanData = []
        nLen = len(paData)

        for i = 1 to nLen
            if NOT This._IsMissing(paData[i])
                aCleanData + paData[i]
            ok
        next
        
        return aCleanData

    def _IsMissing(item)
        if isNull(item)
            return TRUE
        ok
        
        cStr = "" + item
        return ring_find($aSTAT_MISSING_VALUES, cStr) > 0

    def _DetectDataType()
        if len(@anData) = 0
            @cDataType = "empty"
            return
        ok

        nNumeric = 0
        nCategorical = 0
        nLen = len(@anData)

        for i = 1 to nLen
            if IsNumber(@anData[i])
                nNumeric++
            else
                nCategorical++
            ok
        next

        if nNumeric = nLen
            @cDataType = "numeric"
        but nCategorical = nLen
            @cDataType = "categorical"
        else
            @cDataType = "mixed"
        ok


    def _SortIfNeeded()
        if @cDataType = "numeric" and NOT @bSorted
            @anSortedData = sort(@anData)
            @bSorted = TRUE
        ok

    #=================================================#
    #  PILLAR 1: COMPARISON - Descriptive Statistics  #
    #=================================================#

    def Mean()
        if @cDataType != "numeric" or len(@anData) = 0
            return 0
        ok
        
        cKey = "mean"
        nCached = This._GetCached(cKey)

        if NOT IsNull(nCached)
            return nCached
        ok
        
        nSum = 0
        nLen = len(@anData)
        
        for i = 1 to nLen
            nSum += @anData[i]
        next
        
        nMean = nSum / nLen
        This._SetCache(cKey, nMean)
        return nMean

		def Average()
			return This.Mean()

		def Avrg()
			return This.Mean()


    def Median()
        if @cDataType != "numeric" or len(@anData) = 0
            return 0
        ok
        
        cKey = "median"
        nCached = This._GetCached(cKey)

        if NOT IsNull(nCached)
            return nCached
        ok
        
        This._SortIfNeeded()
        nLen = len(@anSortedData)
        
        nMedian = 0
        if nLen % 2 = 1
            nMedian = @anSortedData[ceil(nLen/2)]
        else
            nMid1 = @anSortedData[nLen/2] 
            nMid2 = @anSortedData[nLen/2 + 1]
            nMedian = (nMid1 + nMid2) / 2
        ok
        
        This._SetCache(cKey, nMedian)
        return nMedian


	def Mode()
	    if len(@anData) = 0
	        return NULL
	    ok
	
	    cKey = "mode"
	    cached = This._GetCached(cKey)
	
	    if NOT isNull(cached)
	        return cached
	    ok
	
	    nLen = len(@anData)
	    aFreqHash = []
	
	    for i = 1 to nLen
	        cItemKey = "" + @anData[i]
	        bFound = FALSE
	        
	        # Search for existing key in frequency list
	        for j = 1 to len(aFreqHash)
	            if aFreqHash[j][1] = cItemKey
	                aFreqHash[j][2]++
	                bFound = TRUE
	                exit
	            ok
	        next
	        
	        # Add new key if not found
	        if NOT bFound
	            aFreqHash + [cItemKey, 1]
	        ok
	    next
	
	    nMaxFreq = 0
	    cModeKey = ""
	    nFreqLen = len(aFreqHash)
	
	    for i = 1 to nFreqLen
	        if aFreqHash[i][2] > nMaxFreq
	            nMaxFreq = aFreqHash[i][2]
	            cModeKey = aFreqHash[i][1]
	        ok
	    next
	
	    This._SetCache(cKey, cModeKey)
	    return cModeKey


    def StandardDeviation()
        if @cDataType != "numeric" or len(@anData) <= 1
            return 0
        ok
        
        cKey = "stddev"
        nCached = This._GetCached(cKey)

        if NOT IsNull(nCached)
            return nCached
        ok
        
        nMean = This.Mean()
        nSumSquares = 0
        nLen = len(@anData)
        
        for i = 1 to nLen
            nDiff = @anData[i] - nMean
            nSumSquares += (nDiff * nDiff)
        next
        
        nVariance = nSumSquares / (nLen - 1)
        nStdDev = sqrt(nVariance)
        This._SetCache(cKey, nStdDev)
        return nStdDev

		def StdDev()
			return This.StandardDeviation()


	def Variance()
	    if @cDataType != "numeric" or len(@anData) <= 1
	        return 0
	    ok
	    
	    cKey = "variance"
	    nCached = This._GetCached(cKey)

	    if NOT isNull(nCached)
	        return nCached
	    ok
	    
	    nMean = This.Mean()

	    nSumSquares = 0
	    nLen = len(@anData)
	    
	    for i = 1 to nLen
	        nDiff = @anData[i] - nMean
	        nSumSquares += (nDiff * nDiff)
	    next
	    
	    nVariance = nSumSquares / (nLen - 1)
	    This._SetCache(cKey, nVariance)
	    return nVariance

		def Var()
			return This.Variance()

		def V()
			return This.Variance()


    def Range()
        if @cDataType != "numeric" or len(@anData) = 0
            return 0
        ok
        return This.Max() - This.Min()


    def Min()
        if @cDataType != "numeric" or len(@anData) = 0
            return NULL
        ok
        return @min(@anData)


    def Max()
        if @cDataType != "numeric" or len(@anData) = 0
            return NULL
        ok
        return @max(@anData)


    def Sum()
        if @cDataType != "numeric"
            return 0
        ok

		nLen = len(@anData)
        nSum = 0

        for i = 1 to nLen
            nSum += @anData[i]
        next
        
        return nSum


    def Count()
        return len(@anData)


    def GeometricMean()
        if @cDataType != "numeric" or len(@anData) = 0
            return 0
        ok

		nLen = len(@anData)

        # Check for non-positive values
        for i = 1 to nLen
            if @anData[i] <= 0
                return 0  # Geometric mean undefined for non-positive values
            ok
        next
        
        nProduct = 1      
        for i = 1 to nLen
            nProduct *= @anData[i]
        next
        
        return pow(nProduct, 1/nLen)

		#< @FunctionAlternativeForms

		def GeoMean()
			return This.GeometricMean()

		def GMean()
			return This.GeometricMean()

		def GeometricAverage()
			return This.GeometricMean()

		def GeoAverage()
			return This.GeometricMean()

		def GAverage()
			return This.GeometricMean()

		def GeoAvrg()
			return This.GeometricMean()

		def GAvrg()
			return This.GeometricMean()

		#>


    def HarmonicMean()
        if @cDataType != "numeric" or len(@anData) = 0
            return 0
        ok
        
        nSum = 0
        nLen = len(@anData)
        
        for i = 1 to nLen
            if @anData[i] = 0
                return 0  # Harmonic mean undefined for zero values
            ok
            nSum += (1 / @anData[i])
        next
        
        return nLen / nSum

		#< @FunctionAlternativeForms

		def HarMean()
			return This.HarmonicMean()

		def HMean()
			return This.HarmonicMean()

		def HarmonicAverage()
			return This.HarmonicMean()

		def HarAverage()
			return This.HarmonicMean()

		def HAverage()
			return This.HarmonicMean()

		def HarAvrg()
			return This.HarmonicMean()

		def HAvrg()
			return This.HarmonicMean()

		#>


    def CoefficientOfVariation()
        if @cDataType != "numeric" or This.Mean() = 0
            return 0
        ok
        
        return This.StandardDeviation() / abs(This.Mean()) * 100

		def CoVar()
			return This.CoefficientOfVariation()

		def CoVariance()
			return This.CoefficientOfVariation()

		def CV()
			return This.CoefficientOfVariation()


	#---

    def CompareWith(oOtherStats)
        # Comprehensive comparison with another dataset
        if oOtherStats.Count() = 0 or This.Count() = 0
            return "Cannot compare with empty dataset"
        ok
        
        aComparison = []
        
        if @cDataType = "numeric" and oOtherStats.DataType() = "numeric"
            # Numeric comparison
            nMean1 = This.Mean()
            nMean2 = oOtherStats.Mean()
            nMeanDiff = ((nMean1 - nMean2) / nMean2) * 100
            
            aComparison + ("Mean difference: " + nMeanDiff + "%")
            
            nStd1 = This.StandardDeviation()
            nStd2 = oOtherStats.StandardDeviation()
            
            if nStd1 > nStd2 * 1.5
                aComparison + "Dataset 1 shows higher variability"
            but nStd2 > nStd1 * 1.5
                aComparison + "Dataset 2 shows higher variability"
            else
                aComparison + "Similar variability patterns"
            ok
            
            # Correlation if same size
            if This.Count() = oOtherStats.Count()
                nCorr = This.CorrelationWith(oOtherStats)
                if abs(nCorr) > 0.7
                    cDirection = iff(nCorr > 0, "positive", "negative")
                    aComparison + ( "Strong " + cDirection + " correlation (" + nCorr + ")" )
                ok
            ok
        else
            # Categorical or mixed comparison
            nDiv1 = This.Diversity()
            nDiv2 = oOtherStats.Diversity()
            
            if abs(nDiv1 - nDiv2) > 0.2
                cHigher = iff(nDiv1 > nDiv2, "Dataset 1", "Dataset 2")
                aComparison + ( cHigher + " shows higher diversity" )
            else
                aComparison + "Similar diversity levels"
            ok
        ok
        
        return aComparison

		def CompareTo(oOtherStats)
			return This.CompareWith(oOtherStats)

		def Compare(oOtherStats)
			if isList(oOtherStats) and StzListQ(oOtherStats).IsWithOrToNamedParam()
				oOtherStats = oOtherStats[2]
			ok

			return This.CompareWith(oOtherStats)


    def SimilarityScore(oOtherStats)
        # Calculate similarity score between datasets (0-1 scale)
        if oOtherStats.Count() = 0 or This.Count() = 0
            return 0
        ok
        
        if @cDataType != oOtherStats.DataType()
            return 0  # Different data types
        ok
        
        if @cDataType = "numeric"
            # Numeric similarity based on statistical properties
            nMeanSim = 1 - abs(This.Mean() - oOtherStats.Mean()) / (abs(This.Mean()) + abs(oOtherStats.Mean()) + 1)
            nStdSim = 1 - abs(This.StandardDeviation() - oOtherStats.StandardDeviation()) / (This.StandardDeviation() + oOtherStats.StandardDeviation() + 1)
            
            return (nMeanSim + nStdSim) / 2

        else
            # Categorical similarity based on overlap
            aUnique1 = This.UniqueValues()
            aUnique2 = oOtherStats.UniqueValues()
            
            nIntersection = 0
			nLen = len(aUnique1)

            for i = 1 to nLen
                if ring_find(aUnique2, aUnique1[i]) > 0
                    nIntersection++
                ok
            next
            
            nUnion = len(aUnique1) + len(aUnique2) - nIntersection
            return nIntersection / nUnion
        ok

		def SimilarityScoreWith(oOtherStats)
			return This.SimilarityScore(oOtherStats)

		def SimScore(oOtherStats)
			return This.SimilarityScore(oOtherStats)

		def SimScoreWith(oOtherStats)
			return SimilarityScore(oOtherStats)

	#---

    def ConfidenceInterval(nConfidence)
        if nConfidence = 0
            nConfidence = 95
        ok

        # Calculate confidence interval for the mean
        if @cDataType != "numeric" or len(@anData) < 2
            return [0, 0]
        ok
        
        nMean = This.Mean()
        nStdDev = This.StandardDeviation()
        nLen = len(@anData)
        
        # Using t-distribution approximation
        nAlpha = (100 - nConfidence) / 100
        nTValue = 1.96  # Approximation for 95% confidence
        
        if nConfidence = 90
            nTValue = 1.645

        but nConfidence = 99
            nTValue = 2.576
        ok
        
        nMarginError = nTValue * (nStdDev / sqrt(nLen))
        
        return [nMean - nMarginError, nMean + nMarginError]

		def ConfInt()
			return This.ConfidentialInterval()


	#---

	def WeightedMean(aWeights)
	    if @cDataType != "numeric" or len(@anData) = 0
	        return 0
	    ok
	    
	    if NOT isList(aWeights) or len(aWeights) != len(@anData)
	        StzRaise("Weights must be a list with same length as data")
	    ok
	    
	    cKey = "weightedmean_" + This._HashList(aWeights)
	    nCached = This._GetCached(cKey)
	    
	    if NOT IsNull(nCached)
	        return nCached
	    ok
	    
	    nWeightedSum = 0
	    nWeightSum = 0
	    nLen = len(@anData)
	    
	    for i = 1 to nLen
	        nWeightedSum += @anData[i] * aWeights[i]
	        nWeightSum += aWeights[i]
	    next
	    
	    if nWeightSum = 0
	        return 0
	    ok
	    
	    nResult = nWeightedSum / nWeightSum
	    This._SetCache(cKey, nResult)
	    return nResult

		def WMean(aWeights)
			return This.WMean(aWeights)


	def TrimmedMean(nTrimPercent)
	    if @cDataType != "numeric" or len(@anData) = 0
	        return 0
	    ok
	    
	    if nTrimPercent < 0 or nTrimPercent >= 50
	        StzRaise("Trim percentage must be between 0 and 50")
	    ok
	    
	    cKey = "trimmedmean_" + nTrimPercent
	    nCached = This._GetCached(cKey)
	    
	    if NOT IsNull(nCached)
	        return nCached
	    ok
	    
	    This._SortIfNeeded()
	    nLen = len(@anSortedData)
	    nTrimCount = floor((nLen * nTrimPercent) / 100)
	    
	    if nTrimCount * 2 >= nLen
	        return This.Median()
	    ok
	    
	    nSum = 0
	    nStart = nTrimCount + 1
	    nEnd = nLen - nTrimCount
	    
	    for i = nStart to nEnd
	        nSum += @anSortedData[i]
	    next
	    
	    nResult = nSum / (nEnd - nStart + 1)
	    This._SetCache(cKey, nResult)
	    return nResult
	
		def TMean(nTrimPercent)
			return This.TrimmedMean(nTrimPercent)


	def PercentileRank(nValue)
	    if @cDataType != "numeric" or len(@anData) = 0
	        return 0
	    ok
	    
	    This._SortIfNeeded()
	    nLen = len(@anSortedData)
	    nBelow = 0
	    nEqual = 0
	    
	    for i = 1 to nLen
	        if @anSortedData[i] < nValue
	            nBelow++
	        but @anSortedData[i] = nValue
	            nEqual++
	        ok
	    next
	    
	    return ((nBelow + (nEqual / 2)) / nLen) * 100

		def PRank(nValue)
			return This.PercentileRank(nValue)


    #============================================================#
    #  PILLAR 2: COMPOSITION - Frequency & Categorical Analysis  #
    #============================================================#

	def FrequencyTable()
	    cKey = "freq_table"
	    cached = This._GetCached(cKey)

	    if NOT isNull(cached)
	        return cached
	    ok
	
	    aFreqHash = []
	    nLen = len(@anData)
	
	    for i = 1 to nLen
	        cItemKey = "" + @anData[i]
	
	        if isNumber(aFreqHash[cItemKey])
	            aFreqHash[cItemKey]++
	        else
	            aFreqHash[cItemKey] = 1
	        ok
	    next
	
	    # Convert hash to array of pairs
	    aFreqTable = []
	    for cKey in keys(aFreqHash)
	        aFreqTable + [cKey, aFreqHash[cKey]]
	    next
	
	    This._SetCache(cKey, aFreqTable)
	    return aFreqTable
	
		def FreqTable()
			return This.FrequencyTable()


	def RelativeFrequency()
	    aFreqTable = This.FrequencyTable()
	
	    nTotal = This.Count()
	    aRelFreq = []
	
	    nLen = len(aFreqTable)
	
	    for i = 1 to nLen
	        nRelativeFreq = aFreqTable[i][2] / nTotal
	        aRelFreq + [aFreqTable[i][1], nRelativeFreq]
	    next
	    
	    return aRelFreq
	
		def RelFreq()
		    return This.RelativeFrequency()
	

    def PercentageFrequency()

        aRelFreq = This.RelativeFrequency()
        aPercFreq = []

        nLen = len(aRelFreq)

        for i = 1 to nLen
            nPercentage = aRelFreq[i][2] * 100
            aPercFreq + [aRelFreq[i][1], nPercentage]
        next
        
        return aPercFreq

		def PercentFreq()
			return This.PercentageFrequency()


    def UniqueCount()
        return len(This.UniqueValues())

		def UCount()
			return len(This.UniqueValues())


    def UniqueValues()
        cKey = "unique_values"
        cached = This._GetCached(cKey)

        if NOT isNull(cached)
            return cached
        ok

		nLen = len(@anData)
        aUnique = []

        for i = 1 to nLen
            if ring_find(aUnique, @anData[i]) = 0
                aUnique + @anData[i]
            ok
        next
        
        This._SetCache(cKey, aUnique)
        return aUnique


		def UVals()
			return This.UniqueValues()

		def UValues()
			return This.UniqueValues()


    def Diversity()
        # Unique values / Total values
        nTotal = This.Count()
        if nTotal = 0
            return 0
        ok
        return This.UniqueCount() / nTotal

		def DiversityIndex()
			return This.Diversity()


    def EntropyIndex()
        # Shannon entropy for diversity measurement
        if len(@anData) = 0
            return 0
        ok
        
        aFreqTable = This.FrequencyTable()
        nTotal = This.Count()
        nEntropy = 0
        
		nLen = len(aFreqTable)

        for i = 1 to nLen
            nProbability = aFreqTable[i][2] / nTotal
            if nProbability > 0
                nEntropy -= nProbability * log(nProbability) / log(2)
            ok
        next
        
        return nEntropy

		def Entropy()
			return This.EntropyIndex()


	#---

	def ContingencyTable(oOtherDataSet)
	    if NOT isObject(oOtherDataSet)
	        StzRaise("ContingencyTable requires another stzDataSet object")
	    ok
	    
	    aData1 = @anData
	    aData2 = oOtherDataSet.Data()
	    
	    if len(aData1) != len(aData2)
	        StzRaise("Both datasets must have same length")
	    ok
	    
	    aUniqueX = This.UniqueValues()
	    aUniqueY = oOtherDataSet.UniqueValues()
	    aTable = []
	    
	    # Initialize table
		nLenX = len(aUniqueX)
		nLenY = len(aUniqueY)

	    for i = 1 to nLenX
	        aRow = []
	        for j = 1 to nLenY
	            aRow + 0
	        next
	        aTable + [aUniqueX[i], aRow]
	    next
	    
	    # Count occurrences
	    nLen = len(aData1)
	    for k = 1 to nLen
	        nXIndex = ring_find(aUniqueX, aData1[k])
	        nYIndex = ring_find(aUniqueY, aData2[k])
	        if nXIndex > 0 and nYIndex > 0
	            aTable[nXIndex][2][nYIndex]++
	        ok
	    next
	    
	    return [aUniqueY, aTable]
	
		def ContingTable()
			return This.ContingencyTable()


	def ModeCount()
	    if len(@anData) = 0
	        return 0
	    ok
	    
	    cKey = "modecount"
	    nCached = This._GetCached(cKey)
	    
	    if NOT IsNull(nCached)
	        return nCached
	    ok
	    
	    aFreqTable = This.FrequencyTable()
	    if len(aFreqTable) = 0
	        return 0
	    ok
	    
	    nMaxFreq = 0
	    nLen = len(aFreqTable)
	    
	    for i = 1 to nLen
	        if aFreqTable[i][2] > nMaxFreq
	            nMaxFreq = aFreqTable[i][2]
	        ok
	    next
	    
	    This._SetCache(cKey, nMaxFreq)
	    return nMaxFreq


    #====================================================#
    #  PILLAR 3: DISTRIBUTION - Shape & Spread Analysis  #
    #====================================================#

	#NOTE

	# Linear interpolation : Standard in most statistical
	# software (R, Python, Excel). More accurate for continuous
	# distributions and provides smoother results.

	# Nearest-rank: Simpler, always returns actual data values.
	# Preferred in some educational contexts and when you need
	# exact data points.


	def Percentile(nPercent)
		return This.PercentileXT(nPercent, "interpolation")


	def PercentileXT(nPercent, cMethod) # interpolation or nearest
	    if @cDataType != "numeric" or len(@anData) = 0
	        return 0
	    ok
	    
	    # Default to interpolation method
	    if cMethod = NULL
	        cMethod = "interpolation"
	    ok
	    
	    This._SortIfNeeded()
	    nLen = len(@anSortedData)
	    
	    if cMethod = "nearest" or cMethod = "nearestrank"
	        nRank = ceil((nLen * nPercent) / 100)
	        
	        if nRank < 1
	            nRank = 1
	        but nRank > nLen
	            nRank = nLen
	        ok
	        
	        return @anSortedData[nRank]

	    else
	        # Linear interpolation method (default)
	        nPosition = ((nLen - 1) * nPercent) / 100 + 1
	        
	        if nPosition <= 1
	            return @anSortedData[1]
	        but nPosition >= nLen
	            return @anSortedData[nLen]
	        ok
	        
	        # Linear interpolation
	        nLower = floor(nPosition)
	        nUpper = nLower + 1
	        nFraction = nPosition - nLower
	        
	        if nUpper > nLen
	            return @anSortedData[nLower]
	        ok
	        
	        nLowerVal = @anSortedData[nLower]
	        nUpperVal = @anSortedData[nUpper]
	        return nLowerVal + (nFraction * (nUpperVal - nLowerVal))
	    ok


	def Q1()
		return This.Percentile(25)

		def Q1XT(cMethod)
		    return This.PercentileXT(25, cMethod)
	
	def Q2()
		return This.Median()

		def Q2XT(cMethod)
		    # Median is typically the same regardless of method
		    return This.Median()
	
	def Q3()
		return This.Percentile(75)

		def Q3XT(cMethod)
		    return This.PercentileXT(75, cMethod)
	
	def IQR()
		return This.Q3() - This.Q1()

		def IQRXT(cMethod)
		    return This.Q3XT(cMethod) - This.Q1XT(cMethod)
	

	def Quartiles()
		return [This.Q1(), This.Q2(), This.Q3()]

	def QuartilesXT(cMethod)
	    return [This.Q1XT(cMethod), This.Q2XT(cMethod), This.Q3XT(cMethod)]


	#---

    def Skew()
        if @cDataType != "numeric" or len(@anData) < @nMinSampleSize
            return 0
        ok
        
        cKey = "skewness"
        nCached = This._GetCached(cKey)

        if NOT isNull(nCached)
            return nCached
        ok
        
        nMean = This.Mean()
        nStdDev = This.StandardDeviation()
        
        if nStdDev = 0
            return 0
        ok
        
        nLen = len(@anData)
        nSum = 0
        
        for i = 1 to nLen
            nStandardized = (@anData[i] - nMean) / nStdDev
            nSum += (nStandardized * nStandardized * nStandardized)
        next
        
        nSkew = nSum / ((nLen - 1) * (nLen - 2))
        This._SetCache(cKey, nSkew)
        return nSkew

		def Skewness()
			return Skew()


    def Kurtosis()
        if @cDataType != "numeric" or len(@anData) < 4
            return 0
        ok
        
        cKey = "kurtosis"
        nCached = This._GetCached(cKey)

        if NOT isNull(nCached)
            return nCached
        ok
        
        nMean = This.Mean()
        nStdDev = This.StandardDeviation()
        
        if nStdDev = 0
            return 0
        ok
        
        nLen = len(@anData)
        nSum = 0
        
        for i = 1 to nLen
            nStandardized = (@anData[i] - nMean) / nStdDev
            nSum += (nStandardized * nStandardized * nStandardized * nStandardized)
        next
        
        nKurt = (nSum / nLen) * (nLen * (nLen + 1)) / ((nLen - 1) * (nLen - 2) * (nLen - 3))
        nAdjustment = (3 * (nLen - 1) * (nLen - 1)) / ((nLen - 2) * (nLen - 3))
        
        nResult = nKurt - nAdjustment
        This._SetCache(cKey, nResult)
        return nResult

		def Kurtos()
			return Kurtosis()


	def ContainsOutliers()
		return len(This.Outliers()) > 0

    def Outliers()
        if @cDataType != "numeric"
            return []
        ok
        
        cKey = "outliers"
        cached = This._GetCached(cKey)

        if NOT IsNull(cached)
            return cached
        ok
        
        nQ1 = This.Q1()
        nQ3 = This.Q3()
        nIQR = This.IQR()
        
        nLowerBound = nQ1 - (1.5 * nIQR)
        nUpperBound = nQ3 + (1.5 * nIQR)
        
        aOutliers = []
        nLen = len(@anData)
        for i = 1 to nLen
            if @anData[i] < nLowerBound or @anData[i] > nUpperBound
                aOutliers + @anData[i]
            ok
        next
        
        This._SetCache(cKey, aOutliers)
        return aOutliers

    def IsOutlier(nValue)
        aOutliers = This.Outliers()
        return ring_find(aOutliers, nValue) > 0


    def ZScores()
        if @cDataType != "numeric"
            return []
        ok
        
        nMean = This.Mean()
        nStdDev = This.StandardDeviation()
        
        if nStdDev = 0
            return @anData  # No variation
        ok
        
        aZScores = []
		nLen = len(@anData)
        for i = 1 to nLen
            nZScore = (@anData[i] - nMean) / nStdDev
            aZScores + nZScore
        next
        
        return aZScores


    def MovingAverage(nWindow)
        if nWindow = 0
            nWindow = 3
        ok
        # Calculate moving average with specified window
        if @cDataType != "numeric" or nWindow <= 0
            return @anData
        ok
        
        if len(@anData) < nWindow
            return @anData
        ok
        
        aMovingAvg = []
        nLen = len(@anData)
        
        for i = 1 to (nLen - nWindow + 1)
            nSum = 0
            for j = i to (i + nWindow - 1)
                nSum += @anData[j]
            next
            aMovingAvg + (nSum / nWindow)
        next
        
        return aMovingAvg

		def MovAvrg()
			return This.MovingAverage()

		def MovingMean()
			return This.MovingAverage()

		def MovMean()
			return This.MovingAverage()


	#--- TREND ANALYSIS SECTION (PART OF PILLAR 3 - DITRIBUTION)

	def TrendAnalysis()
	    # Granular trend analysis detecting segments and inflection points
	    if @cDataType != "numeric" or len(@anData) < 2
	        return [ ["insufficient_data", len(@anData)] ]
	    ok
	    
	    nLenData = len(@anData)
	    
	    # For simple cases (2-3 points), use basic trend
	    if nLenData <= 3
	        return This._SimpleSeriesTrend()
	    ok
	    
	    # Calculate consecutive differences
	    aDifferences = []
	    for i = 2 to nLenData
	        aDifferences + (@anData[i] - @anData[i-1])
	    next
	    
	    # Classify each difference
	    aTrends = []
	    nTolerance = This._CalculateTolerance()
		nLenDiff = len(aDifferences)
	    for i = 1 to nLenDiff
	        aTrends + This._ClassifyDifference(aDifferences[i], nTolerance)
	    next
	    
	    # Build segments - walker visits data positions without overlap
	    aTrendSegments = []
	    cCurrentTrend = aTrends[1]
	    nSegmentStart = 1  # Start at first data position
	    nLenTrends = len(aTrends)

	    for i = 2 to nLenTrends
	        if aTrends[i] != cCurrentTrend
	            # Trend change detected at difference i
	            # Previous segment covers from nSegmentStart to position i
	            nSegmentLength = i - nSegmentStart + 1
	            aTrendSegments + [cCurrentTrend, nSegmentLength]
	            cCurrentTrend = aTrends[i]
	            nSegmentStart = i + 1  # Next segment starts AFTER transition point
	        ok
	    next
	    
	    # Add final segment
	    nFinalLength = nLenData - nSegmentStart + 1
	    aTrendSegments + [cCurrentTrend, nFinalLength]
	    
	    return aTrendSegments

		def Trend()
			return This.TrendAnalysis()


	def _SimpleSeriesTrend()
	    nLen = len(@anData)
	    if nLen = 2
	        nDiff = @anData[2] - @anData[1]
	        nTolerance = This._CalculateTolerance()
	        cTrend = This._ClassifyDifference(nDiff, nTolerance)
	        return [[cTrend, 2]]
	    ok
	    
	    # For 3 points, check if consistent trend
	    nDiff1 = @anData[2] - @anData[1]
	    nDiff2 = @anData[3] - @anData[2]
	    nTolerance = This._CalculateTolerance()
	    
	    cTrend1 = This._ClassifyDifference(nDiff1, nTolerance)
	    cTrend2 = This._ClassifyDifference(nDiff2, nTolerance)
	    
	    if cTrend1 = cTrend2
	        return [[cTrend1, 3]]
	    else
	        return [[cTrend1, 2], [cTrend2, 2]]
	    ok
	
	def _CalculateTolerance()
	    # Calculate tolerance based on data scale and variability
	    nRange = This.Range()
	    nStdDev = This.StandardDeviation()
	    
	    # Use smaller of 1% of range or 10% of standard deviation
	    nRangeTolerance = nRange * 0.01
	    nStdTolerance = nStdDev * 0.1
	    
	    nTolerance = iff(nRangeTolerance < nStdTolerance and nRangeTolerance > 0, 
	                    nRangeTolerance, nStdTolerance)
	    
	    # Ensure minimum tolerance to avoid over-sensitivity
	    if nTolerance < 0.001
	        nTolerance = 0.001
	    ok
	    
	    return nTolerance
	
	def _ClassifyDifference(nDiff, nTolerance)
	    if abs(nDiff) <= nTolerance
	        return "stable"
	    but nDiff > 0
	        return "up"
	    else
	        return "down"
	    ok


	#---

	def Deciles()
	    if @cDataType != "numeric" or len(@anData) = 0
	        return []
	    ok
	    
	    cKey = "deciles"
	    aCached = This._GetCached(cKey)
	    
	    if NOT IsNull(aCached)
	        return aCached
	    ok
	    
	    aDeciles = []
	    for i = 10 to 90 step 10
	        aDeciles + This.Percentile(i)
	    next
	    
	    This._SetCache(cKey, aDeciles)
	    return aDeciles
	

	def BoxPlotStats() # Prepare data series for stzBoxPlot

	    if @cDataType != "numeric" or len(@anData) = 0
	        return []
	    ok
	    
	    cKey = "boxplotstats"
	    aCached = This._GetCached(cKey)
	    
	    if NOT IsNull(aCached)
	        return aCached
	    ok
	    
	    nQ1 = This.Q1()
	    nQ2 = This.Q2()
	    nQ3 = This.Q3()
	    nIQR = This.IQR()
	    
	    nLowerFence = nQ1 - (1.5 * nIQR)
	    nUpperFence = nQ3 + (1.5 * nIQR)
	    
	    This._SortIfNeeded()
	    nWhiskerLow = @anSortedData[1]
	    nWhiskerHigh = @anSortedData[len(@anSortedData)]
	    
	    # Find actual whisker values within fences
	    nLen = len(@anSortedData)
	    for i = 1 to nLen
	        if @anSortedData[i] >= nLowerFence
	            nWhiskerLow = @anSortedData[i]
	            exit
	        ok
	    next
	    
	    for i = nLen to 1 step -1
	        if @anSortedData[i] <= nUpperFence
	            nWhiskerHigh = @anSortedData[i]
	            exit
	        ok
	    next
	    
	    aResult = [
	        [:min, This.Min()],
	        [:q1, nQ1],
	        [:median, nQ2],
	        [:q3, nQ3],
	        [:max, This.Max()],
	        [:whisker_low, nWhiskerLow],
	        [:whisker_high, nWhiskerHigh],
	        [:iqr, nIQR]
	    ]
	    
	    This._SetCache(cKey, aResult)
	    return aResult
	
		def BoxPlotData()
			return This.BoxPlot()


	def NormalityTest()
	    # Simplified normality test based on skewness and kurtosis
	    if @cDataType != "numeric" or len(@anData) < 4
	        return [["test", "insufficient_data"], ["p_value", 0], ["is_normal", 0]]
	    ok
	    
	    cKey = "normalitytest"
	    aCached = This._GetCached(cKey)
	    
	    if NOT IsNull(aCached)
	        return aCached
	    ok
	    
	    nSkew = This.Skewness()
	    nKurt = This.Kurtosis()  # Already excess kurtosis (normal = 0)
	    
	    # Normal distribution: skewness ≈ 0, excess kurtosis ≈ 0
	    # Use stricter thresholds since your data shows high deviations
	    bIsNormal = (abs(nSkew) < 1) and (abs(nKurt) < 1)
	    
	    # Calculate p-value based on combined deviation
	    nSkewDev = abs(nSkew)
	    nKurtDev = abs(nKurt) 
	    nCombinedDev = sqrt(nSkewDev * nSkewDev + nKurtDev * nKurtDev)
	    
	    # Exponential decay for p-value
	    nPValue = exp(-nCombinedDev)
	    
	    if nPValue > 1
	        nPValue = 1
	    ok
	    
	    nIsNormalFlag = 0
	    if bIsNormal
	        nIsNormalFlag = 1
	    ok
	    
	    aResult = [
	        ["test", "heuristic"],
	        ["skewness", nSkew],
	        ["kurtosis", nKurt],
	        ["p_value", nPValue],
	        ["is_normal", nIsNormalFlag]
	    ]
	    
	    This._SetCache(cKey, aResult)
	    return aResult

		def Normality()
			return This.NormalityTest()


    #===========================================================#
    #  PILLAR 4: RELATION - Correlation & Association Analysis  #
    #===========================================================#

    def CorrelationWith(oOtherStats)
        if @cDataType != "numeric" or oOtherStats.DataType() != "numeric"
            return 0
        ok
        
        aOtherData = oOtherStats.Data()
        if len(@anData) != len(aOtherData) or len(@anData) < 2
            return 0
        ok
        
        nMean1 = This.Mean()
        nMean2 = oOtherStats.Mean()
        nLen = len(@anData)
        nSumProduct = 0
        nSumSq1 = 0
        nSumSq2 = 0
        
        for i = 1 to nLen
            nDiff1 = @anData[i] - nMean1
            nDiff2 = aOtherData[i] - nMean2
            nSumProduct += nDiff1 * nDiff2
            nSumSq1 += nDiff1 * nDiff1
            nSumSq2 += nDiff2 * nDiff2
        next
        
        if nSumSq1 = 0 or nSumSq2 = 0
            return 0
        ok
        
        return nSumProduct / sqrt(nSumSq1 * nSumSq2)

		def CorelWith(oOtherStats)
			return This.CorrelationWith(oOtherStats)

		def Corel(oOtherStats)
			return This.CorrelationWith(oOtherStats)

		def Cor(oOtherStats)
			return This.CorrelationWith(oOtherStats)


    def CovarianceWith(oOtherStats)
        if @cDataType != "numeric" or oOtherStats.DataType() != "numeric"
            return 0
        ok
        
        aOtherData = oOtherStats.Data()
        if len(@anData) != len(aOtherData) or len(@anData) < 2
            return 0
        ok
        
        nMean1 = This.Mean()
        nMean2 = oOtherStats.Mean()
        nLen = len(@anData)
        nSum = 0
        
        for i = 1 to nLen
            nSum += (@anData[i] - nMean1) * (aOtherData[i] - nMean2)
        next
        
        return nSum / (nLen - 1)

		def CovarWith(oOtherStats)
			return This.CovarianceWith(oOtherStats)

		def CVWith(oOtherStats)
			return This.CovarianceWith(oOtherStats)

    def RankCorrelationWith(oOtherStats)
        # Spearman's rank correlation coefficient
        if @cDataType != "numeric" or oOtherStats.DataType() != "numeric"
            return 0
        ok
        
        aOtherData = oOtherStats.Data()
        if len(@anData) != len(aOtherData) or len(@anData) < 2
            return 0
        ok
        
        # Create rankings
        aRanks1 = This._GetRanks(@anData)
        aRanks2 = This._GetRanks(aOtherData)
        
        # Calculate correlation of ranks
        oRank1 = new stzDataSet(aRanks1)
        oRank2 = new stzDataSet(aRanks2)
        
        return oRank1.CorrelationWith(oRank2)

		def RankCorelWith(oOtherStats)
			return This.RankCorrelationWith(oOtherStats)

		def NonParametricCorrelation()
			return This.RankCorrelationWith(oOtherStats)


    def _GetRanks(aData)
        aIndexed = []
        nLen = len(aData)
        
        # Create value-index pairs
        for i = 1 to nLen
            aIndexed + [aData[i], i]
        next
        
        # Sort by value

        aIndexed = @SortOn(1, aIndexed)
        
        # Assign ranks
        aRanks = []
        for i = 1 to nLen
            aRanks + 0  # Initialize
        next
        
        for i = 1 to nLen
            nOriginalIndex = aIndexed[i][2]
            aRanks[nOriginalIndex] = i
        next
        
        return aRanks

	def ChiSquareWith(oOtherStats)
	    # Chi-square test for independence (categorical data)
	    if @cDataType != "categorical" or oOtherStats.DataType() != "categorical"
	        return 0
	    ok
	    
	    aOtherData = oOtherStats.Data()
	    if len(@anData) != len(aOtherData) or len(@anData) < 2
	        return 0
	    ok
	    
	    # Create cache key using stringified list
	    cKey = "chi_square_" + @@(oOtherStats.Data())
	    nCached = This._GetCached(cKey)

	    if NOT isNull(nCached)
	        return nCached
	    ok
	    
	    # Get unique categories for both datasets
	    aUnique1 = This.UniqueValues()
	    aUnique2 = oOtherStats.UniqueValues()
	    
	    if len(aUnique1) = 0 or len(aUnique2) = 0
	        return 0
	    ok
	    
	    # Initialize contingency table
	    nRows = len(aUnique1)
	    nCols = len(aUnique2)
	    aContingency = []
	    for i = 1 to nRows
	        aRow = []
	        for j = 1 to nCols
	            aRow + 0
	        next
	        aContingency + aRow
	    next
	    
	    # Populate contingency table with observed frequencies
	    nLen = len(@anData)
	    for i = 1 to nLen
	        nRow = ring_find(aUnique1, @anData[i])
	        nCol = ring_find(aUnique2, aOtherData[i])
	        if nRow > 0 and nCol > 0
	            aContingency[nRow][nCol]++
	        ok
	    next
	    
	    # Calculate row and column totals
	    aRowTotals = []
	    aColTotals = []
	    nGrandTotal = 0
	    
	    for i = 1 to nRows
	        nRowTotal = 0
	        for j = 1 to nCols
	            nRowTotal += aContingency[i][j]
	        next
	        aRowTotals + nRowTotal
	        nGrandTotal += nRowTotal
	    next
	    
	    for j = 1 to nCols
	        nColTotal = 0
	        for i = 1 to nRows
	            nColTotal += aContingency[i][j]
	        next
	        aColTotals + nColTotal
	    next
	    
	    # Check for zero totals
	    if nGrandTotal = 0
	        return 0
	    ok
	    
	    # Calculate chi-square statistic
	    nChiSquare = 0
	    for i = 1 to nRows
	        for j = 1 to nCols
	            nObserved = aContingency[i][j]
	            nExpected = (aRowTotals[i] * aColTotals[j]) / nGrandTotal
	            if nExpected > 0
	                nChiSquare += ((nObserved - nExpected) * (nObserved - nExpected)) / nExpected
	            ok
	        next
	    next
	    
	    nResult = nChiSquare
	    This._SetCache(cKey, nResult)
	    return nResult

		def CategoricalAssociationWith(oOtherStats)
			return This.ChiSquareWith(oOtherStats)

	#---

	def RegressionCoefficients(oOtherDataSet)
	    if @cDataType != "numeric" or oOtherDataSet.DataType() != "numeric"
	        return [[:slope, 0], [:intercept, 0], [:r_squared, 0]]
	    ok
	    
	    aOtherData = oOtherDataSet.Data()
	    if len(@anData) != len(aOtherData) or len(@anData) < 2
	        return [[:slope, 0], [:intercept, 0], [:r_squared, 0]]
	    ok
	    
	    nMeanX = This.Mean()
	    nMeanY = oOtherDataSet.Mean()
	    nLen = len(@anData)
	    nSumXY = 0
	    nSumXX = 0
	    
	    for i = 1 to nLen
	        nDiffX = @anData[i] - nMeanX
	        nDiffY = aOtherData[i] - nMeanY
	        nSumXY += nDiffX * nDiffY
	        nSumXX += nDiffX * nDiffX
	    next
	    
	    if nSumXX = 0
	        return [[:slope, 0], [:intercept, nMeanY], [:r_squared, 0]]
	    ok
	    
	    nSlope = nSumXY / nSumXX
	    nIntercept = nMeanY - (nSlope * nMeanX)
	    nCorr = This.CorrelationWith(oOtherDataSet)
	    nRSquared = nCorr * nCorr
	    
	    return [[:slope, nSlope], [:intercept, nIntercept], [:r_squared, nRSquared]]
	
		def RCoefficients(oOtherDataSet)
			return This.RegressionCoefficients(oOtherDataSet)


	def PartialCorrelation(oDataSetY, oDataSetZ)
	    # Partial correlation between X and Y controlling for Z
	    if @cDataType != "numeric" or oDataSetY.DataType() != "numeric" or oDataSetZ.DataType() != "numeric"
	        return 0
	    ok
	    
	    nRxy = This.CorrelationWith(oDataSetY)
	    nRxz = This.CorrelationWith(oDataSetZ)
	    nRyz = oDataSetY.CorrelationWith(oDataSetZ)
	    
	    nDenom = sqrt((1 - nRxz * nRxz) * (1 - nRyz * nRyz))
	    
	    if nDenom = 0
	        return 0
	    ok
	    
	    return (nRxy - nRxz * nRyz) / nDenom
	
		def PCorrelation(oDataSetY, oDataSetZ)
			return This.PartialCorrelation(oDataSetY, oDataSetZ)

		def PartCorrelation(oDataSetY, oDataSetZ)
			return This.PartialCorrelation(oDataSetY, oDataSetZ)

		def PartCorel(oDataSetY, oDataSetZ)
			return This.PartialCorrelation(oDataSetY, oDataSetZ)


	def MutualInformation(oOtherDataSet)
	    # Simplified mutual information for categorical data
	    aData1 = @anData
	    aData2 = oOtherDataSet.Data()
	    
	    if len(aData1) != len(aData2) or len(aData1) = 0
	        return 0
	    ok
	    
	    # Create joint frequency table
	    aJointFreq = []
	    nTotal = len(aData1)
	    
	    for i = 1 to nTotal
	        cPair = "" + aData1[i] + "_" + aData2[i]
	        nIndex = This._FindInFreqList(aJointFreq, cPair)
	        if nIndex = 0
	            aJointFreq + [cPair, 1]
	        else
	            aJointFreq[nIndex][2]++
	        ok
	    next
	    
	    # Calculate marginal frequencies
	    aFreq1 = This.FrequencyTable()
	    aFreq2 = oOtherDataSet.FrequencyTable()
	    
	    # Calculate mutual information
	    nMI = 0
	    nJointLen = len(aJointFreq)
	    
	    for i = 1 to nJointLen
	        nJointProb = aJointFreq[i][2] / nTotal
	        
	        # Extract individual values from pair
	        aPair = split(aJointFreq[i][1], "_")
	        cVal1 = aPair[1]
	        cVal2 = aPair[2]
	        
	        nMarg1 = This._GetFreqValue(aFreq1, cVal1) / nTotal
	        nMarg2 = This._GetFreqValue(aFreq2, cVal2) / nTotal
	        
	        if nJointProb > 0 and nMarg1 > 0 and nMarg2 > 0
	            nMI += nJointProb * log(nJointProb / (nMarg1 * nMarg2)) / log(2)
	        ok
	    next
	    
	    return nMI
	
		def MutualInfo(oOtherDataSet)
			return This.MutualInformation(oOtherDataSet)


	# Helper methods for new functionality
	
	def _HashList(aList)
	    cHash = ""
	    nLen = len(aList)
	    for i = 1 to nLen
	        cHash += "" + aList[i] + "_"
	    next
	    return cHash
	
	def _FindInFreqList(aFreqList, cValue)
	    nLen = len(aFreqList)
	    for i = 1 to nLen
	        if aFreqList[i][1] = cValue
	            return i
	        ok
	    next
	    return 0
	
	def _GetFreqValue(aFreqTable, cValue)
	    nLen = len(aFreqTable)
	    for i = 1 to nLen
	        if aFreqTable[i][1] = cValue
	            return aFreqTable[i][2]
	        ok
	    next
	    return 0
	

    #=====================#
    #  DATA PROCESSING    #
    #=====================#

    def Normalize()
        # Min-Max normalization (0-1 scale)
        if @cDataType != "numeric"
            return @anData
        ok
        
        nMin = This.Min()
        nMax = This.Max()
        nRange = nMax - nMin
        
        if nRange = 0
            return @anData  # All values are the same
        ok
        
        aNormalized = []
		nLen = len(@anData)

        for i = 1 to nLen
            nNormalized = (@anData[i] - nMin) / nRange
            aNormalized + nNormalized
        next
        
        return aNormalized


    def Standardize()
        # Z-score standardization
        if @cDataType != "numeric"
            return @anData
        ok
        
        nMean = This.Mean()
        nStdDev = This.StandardDeviation()
        
        if nStdDev = 0
            return @anData  # No variation
        ok
        
        aStandardized = []
		nLen = len(@anData)

        for i = 1 to nLen
            nStandardized = (@anData[i] - nMean) / nStdDev
            aStandardized + nStandardized
        next
        
        return aStandardized
 
		def Standardise()
			return This.Standardize()


    def RobustScale()
        # Scale using median and IQR (robust to outliers)
        if @cDataType != "numeric"
            return @anData
        ok
        
        nMedian = This.Median()
        nIQR = This.IQR()
        
        if nIQR = 0
            return @anData
        ok
        
        aScaled = []
		nLen = len(@anData)

        for i = 1 to nLen
            nScaled = (@anData[i] - nMedian) / nIQR
            aScaled + nScaled
        next
        
        return aScaled


		def RScale()
			return This.RobustScale()

    #=============================#
    #  DATA QUALITY AND GUIDANCE  #
    #=============================#

    def ValidateData()
        # Validate data integrity and quality
        acIssues = []

        if len(@anData) = 0
            acIssues + "Dataset is empty"
            return acIssues
        ok
        
        if @cDataType = "numeric"
            # Check for infinite or NaN values
			nLen = len(@anData)
            for i = 1 to nLen
                if isNull(@anData[i])
                    aIssues + "Contains null values"
                    exit
                ok
            next

            # Check for extreme outliers
            aOutliers = This.Outliers()
            if len(aOutliers) > (This.Count() * 0.2)
                acIssues + "High proportion of outliers detected"
            ok
            
            # Check for variance
            if This.StandardDeviation() = 0
                acIssues + "No variance in data (all values identical)"
            ok
        ok
        
        if len(acIssues) = 0
            acIssues + "Data quality appears good"
        ok
        
        return acIssues

		def Validate()
			return This.ValidateData()

		def Issues()
			return This.ValidateData()


    #=============================#
    #  INSIGHT GENERATION SYSTEM  #
    #=============================#

    def _GenerateInsights()
        aTemplates = DataSetTemplates()
        nLen = len(aTemplates)
        acInsights = []
        
        for i = 1 to nLen
            if This._EvaluateCondition(aTemplates[i][:condition])
                acInsights + This._InterpolateTemplate(aTemplates[i][:template])
            ok
        next
        
        return acInsights

    def _GenerateInsightXT(cType)
        aTemplates = DataSetTemplatesXT(cType)
        nLen = len(aTemplates)
        acInsights = []
        
        for i = 1 to nLen
            if This._EvaluateCondition(aTemplates[i][:condition])
                acInsights + This._InterpolateTemplate(aTemplates[i][:template])
            ok
        next
        
        return acInsights

    def Insights()
        return This._GenerateInsights()

        def StatInsights()
            return This._GenerateInsights()

        def StatsInsights()
            return This._GenerateInsights()

        def NativeInsights()
            return This._GenerateInsights()

    def InsightsXT()
        acResults = This.Insights()
        
        nLen = len($aDomainInsightRules)
        
        for i = 1 to nLen
            cDomain = $aDomainInsightRules[i][1]
            aDomain = $aDomainInsightRules[i][2]
            nLenDomain = len(aDomain)
            
            for j = 1 to nLenDomain
                if This._EvaluateCondition(aDomain[j][:condition])
                    acResults + This._InterpolateTemplate(aDomain[j][:template])
                ok
            next
        next
        
        return acResults

    def InsightsOfDomain(cDomain)
        acResults = []
        
        if HasKey($aDomainInsightRules, cDomain)
            nLen = len($aDomainInsightRules[cDomain])
            
            for i = 1 to nLen
                if This._EvaluateCondition($aDomainInsightRules[cDomain][i][:condition])
                    acResults + This._InterpolateTemplate($aDomainInsightRules[cDomain][i][:template])
                ok
            next
        ok
        
        return acResults


    #===============================#
    #  RECOMMENDATIONS SYSTEM       #
    #===============================#

    def RecommendAnalysis()
        nLen = len($aRecommendations)
        aResults = []
        
        for i = 1 to nLen
            aTemplate = $aRecommendations[i]
            
            if This._EvaluateCondition(aTemplate[:condition])
                cRecommendation = This._InterpolateTemplate(aTemplate[:recommendation])
                
                aResults + [ :recommendation = cRecommendation ]
            ok
        next
        
        return aResults

        def Recommendations()
            return This.RecommendAnalysis()

        def Advises()
            return This.RecommendAnalysis()


    #============================#
    #  DYNAMIC REPORTING SYSTEM  #
    #============================#

    def Summary()
        return This._GenerateReport($aSummaryTemplate)

        def Report()
            return This.Summary()

    def SummaryXT()
        return This._GenerateReport($aSummaryXTTemplate)

        def ReportXT()
            return This.SummaryXT()

    def _GenerateReport(aTemplate)
        cFormat = aTemplate[:format]
        aSections = aTemplate[:sections]

        cReport = ""
        
        for aSection in aSections
            # Check for inheritance (first element is :inherit)
            if len(aSection) >= 2 and aSection[1] = :inherit

                # Handle inheritance
                cInheritedTemplate = aSection[2]
                eval("aInheritedSections = " + cInheritedTemplate + "[:sections]")
           
                for aInheritedSection in aInheritedSections
                    cReport += This._ProcessSection(aInheritedSection, cFormat)
                next

            else
                cReport += This._ProcessSection(aSection, cFormat)
            ok
        next
        
        return @trim(cReport)


	def _ProcessSection(aSection, cFormat)
	    cSectionContent = ""
	    
	    cKey = aSection[1][1]
	    if cKey = :condition
	        if NOT This._EvaluateCondition(aSection[2][2])
	            return ""
	        ok
	    ok
	    if cKey = :title
	        cTitle = aSection[1][2]
	        if cFormat = "text"
	            cSectionContent += (NL + BoxifyRound(cTitle) + NL)
	        ok
	    ok
	    
	    vContent = aSection[2][2]
	    if isString(vContent)
	        cSectionContent += This._InterpolateContent(vContent) + NL
	
	    but isList(vContent)
	        if cFormat = "text"
				nLen = len(vContent)
				for i = 1 to nlen
					cItem = vContent[i]
	                cSectionContent += "• " + @trim(This._InterpolateContent(cItem)) + NL
					if i < nLen
						cSectionContent += NL
					ok
	            next
	        ok
	    ok
	    
	    return cSectionContent


    #===============================#
    #  CORE INTERPOLATION METHODS   #
    #===============================#

    def _EvaluateCondition(cCondition)
        if cCondition = @trim("")
            StzRaise("Can't evaluate the condition! cCondition must not be be an empty string.")
        ok
        
        try
            cCode = 'bResult = (' + cCondition + ')'
            eval(cCode)
            return bResult
        catch
            return FALSE
        done

    def _InterpolateTemplate(cTemplate)
        return This._InterpolateContent(cTemplate)


	def _InterpolateContent(cContent)
	    if NOT isString(cContent)
	        return cContent
	    ok
	    
	    oTempStr = new stzString(cContent)
	    
	    # Handle special cases first
	    if oTempStr.Contains("{Insights()}")
	        acInsights = This.Insights()
	        cInsightText = ""
	        nLen = len(acInsights)
	
	        for i = 1 to nLen
	            cInsightText += "• " + acInsights[i]
	            if i < nLen
	                cInsightText += NL + NL  # Added extra NL
	            ok
	        next
	        oTempStr.Replace("{Insights()}", cInsightText)
	    ok
	    
	    if oTempStr.Contains("{Recommendations()}")
	        aRecommendations = This.Recommendations()
	        cRecommendText = ""
	        for aRecommend in aRecommendations
	            cRecommendText += "• " + aRecommend[:recommendation] + NL + NL  # Added extra NL
	        next
	        oTempStr.Replace("{Recommendations()}", cRecommendText)
	    ok
	  
	    # Find all remaining method calls and replace them one by one
	    nMaxIterations = 50
	    nIterations = 0
	    
	    while oTempStr.Contains("{") and oTempStr.Contains("}") and nIterations < nMaxIterations
	        nIterations++
	        
	        nStart = oTempStr.FindFirst("{")
	        nEnd = oTempStr.FindNext("}", nStart)
	        
	        if nEnd = 0
	            break
	        ok
	        
	        # Extract method name without braces
	        cMethod = oTempStr.Section(nStart + 1, nEnd - 1)
	        cCode = 'value = ' + cMethod
			eval(cCode)
	        cValue = This._FormatValue(value)
	        oTempStr.ReplaceSection(nStart, nEnd, cValue)

	    end
	    
	    return oTempStr.Content()
	

    def _FormatValue(value)
        if isNumber(value)
            if value = floor(value)
                return "" + value
            else
                return @@(value)
            ok

        but isString(value)
            return value

        but isList(value)
            cResult = "["
            for i = 1 to len(value)
                cResult += This._FormatValue(value[i])
                if i < len(value)
                    cResult += ", "
                ok
            next
            cResult += "]"
            return cResult
        else
            return "" + value
        ok


    #===============================#
    #  RULE MANAGEMENT METHODS      #
    #===============================#

    def AddInsightRule(cDomain, cCondition, cInsight)
        if NOT HasKey($aDomainInsightRules, cDomain)
            $aDomainInsightRules[cDomain] = []
        ok
        $aDomainInsightRules[cDomain] + [:condition = cCondition, :template = cInsight]

    def AddRule(cDomain, cCondition, cInsight)
        This.AddInsightRule(cDomain, cCondition, cInsight)

    def AddWeightedRule(cDomain, cCondition, cInsight, nWeight)
        if nWeight = NULL nWeight = 1 ok
        if NOT HasKey($aDomainInsightRules, cDomain)
            $aDomainInsightRules[cDomain] = []
        ok
        $aDomainInsightRules[cDomain] + [:condition = cCondition, :template = cInsight, :weight = nWeight]

    def PrioritizedInsights(cDomain)
        aResults = []
        
        if HasKey($aDomainInsightRules, cDomain)
            aRules = $aDomainInsightRules[cDomain]
            
            for aRule in aRules
                if This._EvaluateCondition(aRule[:condition])
                    cInsight = This._InterpolateTemplate(aRule[:template])
                    nWeight = 1
                    
                    if HasKey(aRule, :weight)
                        nWeight = aRule[:weight]
                    ok
                    
                    aResults + [cInsight, nWeight]
                ok
            next
            
            # Sort by weight descending
            aResults = SortOnXT(2, aResults, :Descending)
        ok
        
        return aResults

    #======================================#
    #  Plan (Workflow) GENERATION SYSTEM   #
    #======================================#
    
	# Generating the plan

    def MakePlan(cNameOrGoalOrTemplate)
        /*
        Generate a statistical Plan based on user goal or template name
        @param cGoalOrTemplate: Either a goal description or template name
        @return: Plan object with steps and execution plan
        */

        cTemplate = This._ResolvePlanTemplate(cNameOrGoalOrTemplate)

        if cTemplate = NULL
            StzRaise("Unknown Plan name, goal or template: " + cNameOrGoalOrTemplate)
        ok

		n = ring_find(This._PlanNames(), cTemplate)

		if n = 0
			StzRaise("Inexistant Plan template name!")
		ok

        aTemplate = $aPlanTemplates[n][2]
        aExecutableSteps = This._FilterPlanSteps(aTemplate[:steps])

        return [
            :template = cTemplate,
			:name = aTemplate[:name],
            :title = aTemplate[:title],
            :description = aTemplate[:description],
            :steps = aExecutableSteps,
            :total_steps = len(aExecutableSteps),
        ]
    
		def GeneratePlan(cNameOrGoalOrTemplate)
			return This.MakePlan(cNameOrGoalOrTemplate)

		def PreparePlan(cNameOrGoalOrTemplate)
			return This.MakePlan(cNameOrGoalOrTemplate)


	def ExecutePlans(acPlans)
		if CheckParams()
			if NOT ( isList(acPlans) and IsListOfStrings(acPlans) )
				StzRaise("Incorrect param type! acPlans must be a list of strings.")
			ok
		ok
		@bChain = TRUE
		nLen = len(acPlans)
		for i = 1 to nLen
			if i = 1
				@bFirstChain = TRUE
			else
				@bFirstChain = FALSE
			ok

			This.ExecutePlan(acPlans[i])
			? ""
		next

		def RunPlans(acPlans)
			This.ExecutePlans(acPlans)

		def PerformPlans(acPlans)
			This.ExecutePlans(acPlans)

		def ChainPlans(acPlans)
			This.ExecutePlans(acPlans)


	def ExecutePlan(cNameOrGoalOrTemplate)
		This.ExecutePlanXT(cNameOrGoalOrTemplate, TRUE)

		def RunPlan(cNameOrGoalOrTemplate)
			This.ExecutePlan(cNameOrGoalOrTemplate)

		def PerformPlan(cNameOrGoalOrTemplate)
			This.ExecutePlan(cNameOrGoalOrTemplate)


    def ExecutePlanXT(cNameOrGoalOrTemplate, bVerbose)
        /*
        Execute a complete Plan and return results
        @param cNameOrGoalOrTemplate: Plan to execute
        @param bVerbose: Include step-by-step details
        @return: Plan execution results
        */

		nTime = clock()

        if bVerbose = NULL bVerbose = TRUE ok
        
        aPlan = This.GeneratePlan(cNameOrGoalOrTemplate)
        aResults = []
        aErrors = []
        
        if bVerbose
            ? BoxRound("Executing Plan: " + aPlan[:title])

		if @bChain = FALSE or
			(@bChain = TRUE and @bFirstChain)

				? "• Data: " + @@(This.Content())
			ok

			? "• Name: {" + aPlan[:name] + "}"
            ? "• Goal: " + aPlan[:description]
            ? "• Steps: " + aPlan[:total_steps] + NL
        ok
        
        nStepNum = 1
        for aStep in aPlan[:steps]
            if bVerbose
                ? "✅ Step " + nStepNum + "/" + aPlan[:total_steps] + ": " + aStep[:description]
            ok
            
            try
                vResult = This._ExecutePlanStep(aStep)
                aResults + [
                    :step = nStepNum,
                    :function = aStep[:function],
                    :description = aStep[:description],
                    :result = vResult,
                    :status = "success"
                ]
                
                if bVerbose
                    ? "╰─> " + This._FormatStepResult(aStep[:function], vResult) + NL
                ok
                
            catch
                aErrors + [
                    :step = nStepNum,
                    :function = aStep[:function],
                    :error = cCatchError
                ]
                
                if bVerbose
                    ? "❌ Error: " + cCatchError + NL
                ok
            done
            
            nStepNum++
        next
        
        if bVerbose
			nTime = (clock() - nTime) / clockspersecond()

            ? "( Plan completed in " + nTime + "s : " + len(aResults) + " successful step(s), " + len(aErrors) + " error(s) )"
        ok
        
        return [
            :Plan = aPlan,
            :results = aResults,
            :errors = aErrors,
            :success_rate = (len(aResults) / aPlan[:total_steps]) * 100
        ]
    
		def RunPlanXT(cNameOrGoalOrTemplate, bVerbose)
			This.ExecutePlan(cNameOrGoalOrTemplate, bVerbose)

		def PerformPlanXT(cNameOrGoalOrTemplate, bVerbose)
			This.ExecutePlan(cNameOrGoalOrTemplate, bVerbose)


    def PlanSummary(cNameOrGoalOrTemplate)
        /*
        Get a preview of Plan steps without execution
        @param cNameOrGoalOrTemplate: Plan to preview
        @return: Formatted Plan summary
        */

        aPlan = This.GeneratePlan(cNameOrGoalOrTemplate)
        cSummary = BoxifyRound("Plan: " + oPlan[:title]) + NL

		if @bChain = FALSE or
			(@bChain = TRUE and @bFirstChain)

			cSummary += "• Data: " + @@(This.Content()) + NL
		ok

		cSummary += "• Name: {" + aPlan[:name] + "}" + NL
        cSummary += "• Goal: " + aPlan[:description] + NL
        cSummary += "• Steps (" + aPlan[:total_steps] + "):" + NL
        
        nStep = 1
        for aStep in aPlan[:steps]
            cSummary += "  " + nStep + ". " + aStep[:description]
            if HasKey(aStep, :condition)
                cSummary += " (conditional)"
            ok
            if HasKey(aStep, :args)
                cSummary += " [params: " + This._FormatArgs(aStep[:args]) + "]"
            ok
            cSummary += NL
            nStep++
        next
        
        return cSummary
    
    
    def AddPlan(cName, cTitle, cDescription, aSteps)
        /*
        Create a custom Plan template
        @param cTitle: Plan title
        @param cDescription: Plan description  
        @param aSteps: Array of step definitions
        */
 
		
        cKey = "custom_" + lower(cName)
        $aPlanTemplates[cName] = [
			:name = cName,
            :title = cTitle,
            :description = cDescription,
            :steps = aSteps
        ]
        

	def SuggestPlan()
	    
	    cDataType = This.DataType()
	    nCount = This.Count()
	    bHasOutliers = This.ContainsOutliers()
	    
	    if nCount < 10
	        return :EDA  # Basic exploration for small samples
	    ok
	    
	    if bHasOutliers
	        return :OUTLIERS  # Focus on outlier analysis
	    ok
	    
	    if cDataType = "numeric" and nCount >= 20
	        nCV = oData.CoefficientOfVariation()
	        if nCV > 30
	            return :QUALITY  # Quality control for high variability
	        else
	            return :NORMALITY  # Test distribution assumptions
	        ok
	    ok
	    
	    return :EDA  # Default fallback
	

    #===============================#
    #  Plan HELPER METHODS      #
    #===============================#
    
	def _PlanNames()
		nLen = len($aPlanTemplates)
		acResult = []

		for i = 1 to nLen
			acResult + $aPlanTemplates[i][1]
		next

		return acResult

	def _PlanTemplates()
		nLen = len($aPlanTemplates)
		acResult = []

		for i = 1 to nLen
			acResult + $aPlanTemplates[i][2]
		next

		return acResult

	def _PlanGoals()
		nLen = len($aPlanGoals)
		acResult = []

		for i = 1 to nLen
			acResult + $aPlanGoals[i][1]
		next

		return acResult

    def _ResolvePlanTemplate(cInput)
        cInput = Lower(@trim(cInput))

		# Check if it's a Plan name
		if ring_find(_PlanNames(), cInput)
			return cInput
		ok

        # Check if it's a direct template key
		if ring_find(_PlanTemplates(), cInput)
			return cInput
		ok
        
        # Check goal mappings
		if ring_find(_PlanGoals(), cInput)
			return $aPlanGoals[cInput]
		ok
        
        return NULL
    
    def _FilterPlanSteps(aSteps)

        aFiltered = []
        
        for aStep in aSteps

            bInclude = TRUE
        
            # Check if step has condition
            if HasKey(aStep, :condition)
                bInclude = This._EvaluateCondition(aStep[:condition])
            ok
            
            # Check if required step
            if HasKey(aStep, :required) and aStep[:required] = TRUE
                bInclude = TRUE
            ok
            
            if bInclude
                aFiltered + aStep
            ok
        next

        return aFiltered
    
    def _ExecutePlanStep(aStep)
        cFunction = aStep[:function]
        aArgs = []
        
        if HasKey(aStep, :args)
            aArgs = aStep[:args]
        ok
        
        # Build execution code
        cCode = "result = " + cFunction + "("
        if len(aArgs) > 0
            for i = 1 to len(aArgs)
                cCode += aArgs[i]
                if i < len(aArgs)
                    cCode += ", "
                ok
            next
        ok
        cCode += ")"
        
        eval(cCode)
        return result
    
    def _FormatStepResult(cFunction, vResult)
        switch cFunction
        on "DataType"
            return "Data type: " + vResult

        on "Count"
            return "Sample size: " + vResult

        on "Mean"
            return "Mean: " + @@(vResult)

        on "Median" 
            return "Median: " + @@(vResult)

        on "StandardDeviation"
            return "Std Dev: " + @@(vResult)

        on "ContainsOutliers"
            return "Outliers present: " + vResult

        on "NormalityTest"
            return "Normality p-value: " + @@(vResult[2])

        on "TrendAnalysis"
            return "Trend: " + vResult

        other

            if isNumber(vResult)
                return cFunction + ": " + @@(vResult)

            but isString(vResult)
                return cFunction + ": " + vResult

            but isList(vResult)
                return cFunction + ": " + len(vResult) + " value(s)"

            else
                return cFunction + ": completed"
            ok

        off
    
    def _FormatArgs(aArgs)
        cResult = ""
        for i = 1 to len(aArgs)
            cResult += aArgs[i]
            if i < len(aArgs)
                cResult += ", "
            ok
        next
        return cResult


	#=======================#
	#  SIMPLE CACHE SYSTEM  #
	#=======================#

	def _InitializeCache()
	    @aCache = []
	
	def _GetCached(cKey)
	    return @aCache[cKey]

	def _CacheKeys()
		nLen = len(@aCache)
		acKeys = []

		for i = 1 to nLen
			acKeys = @aCache[i]
		next

		return acKeys

	def _KeyIsCached(cKey)

		if NOT (isString(cKey) and @trim(cKey) != "")
			StzRaise("Incorrect param type! cKey must be a non empty string.")
		ok

		if ring_find( This._CacheKeys(), lower(cKey))
			return TRUE
		else
			return FALSE
		ok

	def _RemoveFromCache(cKey)

		if NOT isString(cKey)
			StzRaise("Incorrect param type! cKey must be a non empty string.")
		ok

		if @trim(cKey) = ""
			return
		ok

		n = ring_find(This._CacheKeys(), lower(cKey))
		if n > 0
			del(@aCache, n)
		ok

	def _SetCache(cKey, value)
	    
	    # Remove existing key if present
		_RemoveFromCache(cKey)
	    
	    # Add new cache entry
	    @aCache + [cKey, value]
	
	def ClearCache()
	    @aCache = []
        @bSorted = FALSE
        @anSortedData = []

	def Cache()
	    return @aCache

    #================================#
    #  UTILITY AND ACCESSOR METHODS  #
    #================================#

    def Data()
        return @anData

    def DataType()
        return @cDataType

    def SortedData()
        if @cDataType = "numeric"
            This._SortIfNeeded()
            return @anSortedData
        ok
        return @anData


    def Export()
        # Export statistical results as structured data
        oExport = new stzHashList([])
        aExport = []

        aExport + ["data_type", @cDataType]
        aExport + ["count", This.Count()]
        aExport + ["unique_count", This.UniqueCount()]
        
        if @cDataType = "numeric"
            aExport + ["mean", This.Mean()]
            aExport + ["median", This.Median()]
            aExport + ["mode", This.Mode()]
            aExport + ["standard_deviation", This.StandardDeviation()]
            aExport + ["variance", This.Variance()]
            aExport + ["range", This.Range()]
            aExport + ["min", This.Min()]
            aExport + ["max", This.Max()]
            aExport + ["quartiles", This.Quartiles()]
            aExport + ["skewness", This.Skewness()]
            aExport + ["kurtosis", This.Kurtosis()]
            aExport + ["outliers", This.Outliers()]

        else
            aExport + ["mode", This.Mode()]
            aExport + ["diversity", This.Diversity()]
            aExport + ["entropy", This.EntropyIndex()]
            aExport + ["frequency_table", This.FrequencyTable()]

        ok
        
        return aExport


	def Values()
		return @anData

		def Content()
			return @anData

	def Copy()
		return new stzDataSet(This.Content())

	def Rules()
		return $aDomainInsightRules


    #==========================#
    #  PRIVATE HELPER METHODS  #
    #==========================#

	PRIVATE

    def _IsVarDefined(cVarName)
        # Check if instance variable is defined
        try
            eval("This." + cVarName)
            return TRUE
        catch
            return FALSE
        done

    def _SafeDivision(nNumerator, nDenominator)
        if nDenominator = 0
            return 0
        ok
        return nNumerator / nDenominator
