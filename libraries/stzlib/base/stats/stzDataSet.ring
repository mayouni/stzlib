
#==========================================================================#
#  stzDataSet Cass - Statistics Layer of the Softanza Analytics Framework  #
#     Four Pillars: Comparison | Composition | Distribution | Relation     #
#==========================================================================#

# Global configuration for missing values
$aSTAT_MISSING_VALUES = [ "", 'NA', 'NULL', 'n/a', '#N/A' ]

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
        :recommendation = "Outliers detected ({len(Outliers())} values) can distort statistics. Apply TrimmedMean(10) and RobustScale(), or investigate data quality."
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

#TODO Move the data setting to a stzDataSetData.ring file and host it in /data subfolder

# Helper Functions
func StzMissingValues()
    return $aSTAT_MISSING_VALUES

	func MissingValues()
		return StzMissingValues()

	func @MissingValues()
		return StzMissingValues()

func StzDataSetTemplates()
    _aResult_ = $aEmptyInsightTemplates

    _nLen_ = len($aNumericInsightTemplates)
    for i = 1 to _nLen_
        _aResult_ + $aNumericInsightTemplates[i]
    next

    _nLen_ = len($aCategoricalInsightTemplates)
    for i = 1 to _nLen_
        _aResult_ + $aCategoricalInsightTemplates[i]
    next

    _nLen_ = len($aMixedInsightTemplates)
    for i = 1 to _nLen_
        _aResult_ + $aMixedInsightTemplates[i]
    next

    return _aResult_

	func DataSetTemplates()
		return StzDataSetTemplates()

func StzDataSetTemplatesXT(cType)
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

	func DataSetTemplatesXT(cType)
		return StzDataSetTemplatesXT(cType)

func StzTrend(panDataSet)
	return StzDataSetQ(panDataSet).Trend()

	func Trend(panDataSet)
		return StzTrend(panDataSet)

	func TrendAnalysis(panDataSet)
		return StzTrend(panDataSet)

func StzGeneratePlanFor(paData, cGoal)
    _oStats_ = new stzDataSet(paData)
    return _oStats_.GeneratePlan(cGoal)

	func GeneratePlanFor(paData, cGoal)
		return StzGeneratePlanFor(paData, cGoal)

func StzExecutePlanFor(paData, cGoal)
    _oStats_ = new stzDataSet(paData)
    return _oStats_.ExecutePlan(cGoal, TRUE)

	func ExecutePlanFor(paData, cGoal)
		return StzExecutePlanFor(paData, cGoal)

func StzPlanSummaryFor(paData, cGoal)
    _oStats_ = new stzDataSet(paData)
    return _oStats_.PlanSummary(cGoal)

	func PlanSummaryFor(paData, cGoal)
		return StzPlanSummaryFor(paData, cGoal)

func StzDataSetQ(paData)
	return new stzDataSet(paData)

func StzCompareDatasets(paData1, paData2)
	_oStats1_ = new stzDataSet(paData1)
	_oStats2_ = new stzDataSet(paData2)
	return _oStats1_.CompareWith(_oStats2_)

	func CompareDatasets(paData1, paData2)
		return StzCompareDatasets(paData1, paData2)

#-------------#
#  THE CLASS  #
#-------------#

class stzDataSet from stzObject

    @anData = []
    @cDataType = "numeric"  # numeric, categorical, mixed, empty
    @bSorted = FALSE
    @anSortedData = []
    @aCache = []  # Standard Ring hash list as [ [:key, value], ... ]

	@bChain = FALSE
	@bFirstChain = FALSE

    @nMinSampleSize = 3  # Minimum for advanced statistics
    @pEngineStats = NULL

    def ClassName()
        return "stzdataset"

        def StzClassName()
            return This.ClassName()

    def init(paData)
        if CheckParams()
            if NOT isList(paData)
                StzRaise("stzDataSet requires a list of data")
            ok
        ok

        @anData = This._CleanData(paData)
        This._DetectDataType()
        This._InitializeCache()
        This._InitEngine()

    def _CleanData(paData)
        # Remove missing values and prepare data
        _aCleanData_ = []
        _nLen_ = len(paData)

        for i = 1 to _nLen_
            if NOT This._IsMissing(paData[i])
                _aCleanData_ + paData[i]
            ok
        next
        
        return _aCleanData_

    def _IsMissing(item)
        if isNull(item)
            return TRUE
        ok

        # A nested list/object is data, never a missing-value marker --
        # and "" + aList raises R21 (operator on incorrect type).
        if isList(item) or isObject(item)
            return FALSE
        ok

        _cStr_ = "" + item
        return StzFindFirst(_cStr_, $aSTAT_MISSING_VALUES) > 0

    def _DetectDataType()
        if len(@anData) = 0
            @cDataType = "empty"
            return
        ok

        _nNumeric_ = 0
        _nCategorical_ = 0
        _nLen_ = len(@anData)

        for i = 1 to _nLen_
            if IsNumber(@anData[i])
                _nNumeric_++
            else
                _nCategorical_++
            ok
        next

        if _nNumeric_ = _nLen_
            @cDataType = "numeric"
        but _nCategorical_ = _nLen_
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
        if This._EngineAvailable()
            return StzEngineStatsMean(@pEngineStats)
        ok
        _nSum_ = 0
        _nLen_ = len(@anData)
        for i = 1 to _nLen_
            _nSum_ += @anData[i]
        next
        return _nSum_ / _nLen_

		def Average()
			return This.Mean()

		def Avrg()
			return This.Mean()


    def Median()
        if @cDataType != "numeric" or len(@anData) = 0
            return 0
        ok
        if This._EngineAvailable()
            return StzEngineStatsMedian(@pEngineStats)
        ok
        This._SortIfNeeded()
        _nLen_ = len(@anSortedData)
        if _nLen_ % 2 = 1
            return @anSortedData[ceil(_nLen_/2)]
        else
            return (@anSortedData[_nLen_/2] + @anSortedData[_nLen_/2 + 1]) / 2
        ok


	def Mode()
	    if len(@anData) = 0
	        return NULL
	    ok
	
	    _cKey_ = "mode"
	    _cached_ = This._GetCached(_cKey_)
	
	    if NOT isNull(_cached_)
	        return _cached_
	    ok
	
	    _nLen_ = len(@anData)
	    _aFreqHash_ = []
	
	    for i = 1 to _nLen_
	        _cItemKey_ = "" + @anData[i]
	        _bFound_ = FALSE
	        
	        # Search for existing key in frequency list
		_nLenFreq_ = len(_aFreqHash_)
	        for j = 1 to _nLenFreq_
	            if _aFreqHash_[j][1] = _cItemKey_
	                _aFreqHash_[j][2]++
	                _bFound_ = TRUE
	                exit
	            ok
	        next
	        
	        # Add new key if not found
	        if NOT _bFound_
	            _aFreqHash_ + [_cItemKey_, 1]
	        ok
	    next
	
	    _nMaxFreq_ = 0
	    _cModeKey_ = ""
	    _nLenFreq_ = len(_aFreqHash_)
	
	    for i = 1 to _nLenFreq_
	        if _aFreqHash_[i][2] > _nMaxFreq_
	            _nMaxFreq_ = _aFreqHash_[i][2]
	            _cModeKey_ = _aFreqHash_[i][1]
	        ok
	    next
	
	    This._SetCache(_cKey_, _cModeKey_)
	    return _cModeKey_

	    def MostFrequentValue()
		return This.Mode()

    def StandardDeviation()
        if @cDataType != "numeric" or len(@anData) <= 1
            return 0
        ok
        if This._EngineAvailable()
            return StzEngineStatsStdDev(@pEngineStats)
        ok
        _nMean_ = This.Mean()
        _nSumSquares_ = 0
        _nLen_ = len(@anData)
        for i = 1 to _nLen_
            _nDiff_ = @anData[i] - _nMean_
            _nSumSquares_ += (_nDiff_ * _nDiff_)
        next
        return sqrt(_nSumSquares_ / (_nLen_ - 1))

		def StdDev()
			return This.StandardDeviation()


	def Variance()
	    if @cDataType != "numeric" or len(@anData) <= 1
	        return 0
	    ok
	    if This._EngineAvailable()
	        return StzEngineStatsVariance(@pEngineStats)
	    ok
	    _nMean_ = This.Mean()
	    _nSumSquares_ = 0
	    _nLen_ = len(@anData)
	    for i = 1 to _nLen_
	        _nDiff_ = @anData[i] - _nMean_
	        _nSumSquares_ += (_nDiff_ * _nDiff_)
	    next
	    return _nSumSquares_ / (_nLen_ - 1)

		def Var()
			return This.Variance()

		def V()
			return This.Variance()


    def Range()
        if @cDataType != "numeric" or len(@anData) = 0
            return 0
        ok
        if This._EngineAvailable()
            return StzEngineStatsRange(@pEngineStats)
        ok
        return This.Max() - This.Min()

    def Min()
        if @cDataType != "numeric" or len(@anData) = 0
            return NULL
        ok
        if This._EngineAvailable()
            return StzEngineStatsMin(@pEngineStats)
        ok
        return @min(@anData)

    def Max()
        if @cDataType != "numeric" or len(@anData) = 0
            return NULL
        ok
        if This._EngineAvailable()
            return StzEngineStatsMax(@pEngineStats)
        ok
        return @max(@anData)

    def Sum()
        if @cDataType != "numeric"
            return 0
        ok
        if This._EngineAvailable()
            return StzEngineStatsSum(@pEngineStats)
        ok
        _nLen_ = len(@anData)
        _nSum_ = 0
        for i = 1 to _nLen_
            _nSum_ += @anData[i]
        next
        return _nSum_


    def Count()
        return len(@anData)


    def GeometricMean()
        if @cDataType != "numeric" or len(@anData) = 0
            return 0
        ok
        if This._EngineAvailable()
            return StzEngineStatsGeometricMean(@pEngineStats)
        ok
        _nLen_ = len(@anData)
        for i = 1 to _nLen_
            if @anData[i] <= 0
                return 0
            ok
        next
        _nProduct_ = 1
        for i = 1 to _nLen_
            _nProduct_ *= @anData[i]
        next
        return pow(_nProduct_, 1/_nLen_)

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
        if This._EngineAvailable()
            return StzEngineStatsHarmonicMean(@pEngineStats)
        ok
        _nSum_ = 0
        _nLen_ = len(@anData)
        for i = 1 to _nLen_
            if @anData[i] = 0
                return 0
            ok
            _nSum_ += (1 / @anData[i])
        next
        return _nLen_ / _nSum_

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
        if This._EngineAvailable()
            return StzEngineStatsCoeffOfVariation(@pEngineStats)
        ok
        return This.StandardDeviation() / abs(This.Mean()) * 100

		def CoVar()
			return This.CoefficientOfVariation()

		def CoVariance()
			return This.CoefficientOfVariation()

		def CV()
			return This.CoefficientOfVariation()


	#---

    def CompareWith(_oOtherStats_)
        # Comprehensive comparison with another dataset
        if _oOtherStats_.Count() = 0 or This.Count() = 0
            return "Cannot compare with empty dataset"
        ok
        
        _aComparison_ = []
        
        if @cDataType = "numeric" and _oOtherStats_.DataType() = "numeric"
            # Numeric comparison
            _nMean1_ = This.Mean()
            _nMean2_ = _oOtherStats_.Mean()
            _nMeanDiff_ = ((_nMean1_ - _nMean2_) / _nMean2_) * 100
            
            _aComparison_ + ("Mean difference: " + _nMeanDiff_ + "%")
            
            _nStd1_ = This.StandardDeviation()
            _nStd2_ = _oOtherStats_.StandardDeviation()
            
            if _nStd1_ > _nStd2_ * 1.5
                _aComparison_ + "Dataset 1 shows higher variability"
            but _nStd2_ > _nStd1_ * 1.5
                _aComparison_ + "Dataset 2 shows higher variability"
            else
                _aComparison_ + "Similar variability patterns"
            ok
            
            # Correlation if same size
            if This.Count() = _oOtherStats_.Count()
                _nCorr_ = This.CorrelationWith(_oOtherStats_)
                if abs(_nCorr_) > 0.7
                    _cDirection_ = iff(_nCorr_ > 0, "positive", "negative")
                    _aComparison_ + ( "Strong " + _cDirection_ + " correlation (" + _nCorr_ + ")" )
                ok
            ok
        else
            # Categorical or mixed comparison
            _nDiv1_ = This.Diversity()
            _nDiv2_ = _oOtherStats_.Diversity()
            
            if abs(_nDiv1_ - _nDiv2_) > 0.2
                _cHigher_ = iff(_nDiv1_ > _nDiv2_, "Dataset 1", "Dataset 2")
                _aComparison_ + ( _cHigher_ + " shows higher diversity" )
            else
                _aComparison_ + "Similar diversity levels"
            ok
        ok
        
        return _aComparison_

		def CompareTo(_oOtherStats_)
			return This.CompareWith(_oOtherStats_)

		def Compare(_oOtherStats_)
			if isList(_oOtherStats_) and IsWithOrToNamedParamList(_oOtherStats_)
				_oOtherStats_ = _oOtherStats_[2]
			ok

			return This.CompareWith(_oOtherStats_)


    def SimilarityScore(_oOtherStats_)
        # Calculate similarity score between datasets (0-1 scale)
        if _oOtherStats_.Count() = 0 or This.Count() = 0
            return 0
        ok
        
        if @cDataType != _oOtherStats_.DataType()
            return 0  # Different data types
        ok
        
        if @cDataType = "numeric"
            # Numeric similarity based on statistical properties
            _nMeanSim_ = 1 - abs(This.Mean() - _oOtherStats_.Mean()) / (abs(This.Mean()) + abs(_oOtherStats_.Mean()) + 1)
            _nStdSim_ = 1 - abs(This.StandardDeviation() - _oOtherStats_.StandardDeviation()) / (This.StandardDeviation() + _oOtherStats_.StandardDeviation() + 1)
            
            return (_nMeanSim_ + _nStdSim_) / 2

        else
            # Categorical similarity based on overlap
            _aUnique1_ = This.UniqueValues()
            _aUnique2_ = _oOtherStats_.UniqueValues()
            
            _nIntersection_ = 0
			_nLen_ = len(_aUnique1_)

            for i = 1 to _nLen_
                if StzFindFirst(_aUnique2_, _aUnique1_[i]) > 0
                    _nIntersection_++
                ok
            next
            
            _nUnion_ = len(_aUnique1_) + len(_aUnique2_) - _nIntersection_
            return _nIntersection_ / _nUnion_
        ok

		def SimilarityScoreWith(_oOtherStats_)
			return This.SimilarityScore(_oOtherStats_)

		def SimScore(_oOtherStats_)
			return This.SimilarityScore(_oOtherStats_)

		def SimScoreWith(_oOtherStats_)
			return SimilarityScore(_oOtherStats_)

	#---

    def ConfidenceInterval(_nConfidence_)
        if _nConfidence_ = 0
            _nConfidence_ = 95
        ok

        # Calculate confidence interval for the mean
        if @cDataType != "numeric" or len(@anData) < 2
            return [0, 0]
        ok
        
        _nMean_ = This.Mean()
        _nStdDev_ = This.StandardDeviation()
        _nLen_ = len(@anData)
        
        # Using t-distribution approximation
        _nAlpha_ = (100 - _nConfidence_) / 100
        _nTValue_ = 1.96  # Approximation for 95% confidence
        
        if _nConfidence_ = 90
            _nTValue_ = 1.645

        but _nConfidence_ = 99
            _nTValue_ = 2.576
        ok
        
        _nMarginError_ = _nTValue_ * (_nStdDev_ / sqrt(_nLen_))
        
        return [_nMean_ - _nMarginError_, _nMean_ + _nMarginError_]

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
	    
	    _cKey_ = "weightedmean_" + This._HashList(aWeights)
	    _nCached_ = This._GetCached(_cKey_)
	    
	    if NOT IsNull(_nCached_)
	        return _nCached_
	    ok
	    
	    _nWeightedSum_ = 0
	    _nWeightSum_ = 0
	    _nLen_ = len(@anData)
	    
	    for i = 1 to _nLen_
	        _nWeightedSum_ += @anData[i] * aWeights[i]
	        _nWeightSum_ += aWeights[i]
	    next
	    
	    if _nWeightSum_ = 0
	        return 0
	    ok
	    
	    _nResult_ = _nWeightedSum_ / _nWeightSum_
	    This._SetCache(_cKey_, _nResult_)
	    return _nResult_

		def WMean(aWeights)
			return This.WMean(aWeights)


	def TrimmedMean(nTrimPercent)
	    if @cDataType != "numeric" or len(@anData) = 0
	        return 0
	    ok

	    if nTrimPercent < 0 or nTrimPercent >= 50
	        StzRaise("Trim percentage must be between 0 and 50")
	    ok

	    if This._EngineAvailable()
	        return StzEngineStatsTrimmedMean(@pEngineStats, nTrimPercent)
	    ok

	    _cKey_ = "trimmedmean_" + nTrimPercent
	    _nCached_ = This._GetCached(_cKey_)
	    
	    if NOT IsNull(_nCached_)
	        return _nCached_
	    ok
	    
	    This._SortIfNeeded()
	    _nLen_ = len(@anSortedData)
	    _nTrimCount_ = floor((_nLen_ * nTrimPercent) / 100)
	    
	    if _nTrimCount_ * 2 >= _nLen_
	        return This.Median()
	    ok
	    
	    _nSum_ = 0
	    _nStart_ = _nTrimCount_ + 1
	    _nEnd_ = _nLen_ - _nTrimCount_
	    
	    for i = _nStart_ to _nEnd_
	        _nSum_ += @anSortedData[i]
	    next
	    
	    _nResult_ = _nSum_ / (_nEnd_ - _nStart_ + 1)
	    This._SetCache(_cKey_, _nResult_)
	    return _nResult_
	
		def TMean(nTrimPercent)
			return This.TrimmedMean(nTrimPercent)


	def PercentileRank(nValue)
	    if @cDataType != "numeric" or len(@anData) = 0
	        return 0
	    ok
	    
	    This._SortIfNeeded()
	    _nLen_ = len(@anSortedData)
	    _nBelow_ = 0
	    _nEqual_ = 0
	    
	    for i = 1 to _nLen_
	        if @anSortedData[i] < nValue
	            _nBelow_++
	        but @anSortedData[i] = nValue
	            _nEqual_++
	        ok
	    next
	    
	    return ((_nBelow_ + (_nEqual_ / 2)) / _nLen_) * 100

		def PRank(nValue)
			return This.PercentileRank(nValue)


    #============================================================#
    #  PILLAR 2: COMPOSITION - Frequency & Categorical Analysis  #
    #============================================================#

	def FrequencyTable()
	    _cKey_ = "freq_table"
	    _cached_ = This._GetCached(_cKey_)

	    if NOT isNull(_cached_)
	        return _cached_
	    ok
	
	    _aFreqHash_ = []
	    _nLen_ = len(@anData)
	
	    for i = 1 to _nLen_
	        _cItemKey_ = "" + @anData[i]
	
	        if isNumber(_aFreqHash_[_cItemKey_])
	            _aFreqHash_[_cItemKey_]++
	        else
	            _aFreqHash_[_cItemKey_] = 1
	        ok
	    next
	
	    # Convert hash to array of pairs
	    _aFreqTable_ = []
	    _aKeysaFreqHash1_ = keys(_aFreqHash_)
	    _nKeysaFreqHash1Len_ = len(_aKeysaFreqHash1_)
	    for _iLoopKeysaFreqHash1_ = 1 to _nKeysaFreqHash1Len_
	    	_cKey_ = _aKeysaFreqHash1_[_iLoopKeysaFreqHash1_]
	        _aFreqTable_ + [_cKey_, _aFreqHash_[_cKey_]]
	    next
	
	    This._SetCache(_cKey_, _aFreqTable_)
	    return _aFreqTable_
	
		def FreqTable()
			return This.FrequencyTable()


	def RelativeFrequency()
	    _aFreqTable_ = This.FrequencyTable()
	
	    _nTotal_ = This.Count()
	    _aRelFreq_ = []
	
	    _nLen_ = len(_aFreqTable_)
	
	    for i = 1 to _nLen_
	        _nRelativeFreq_ = _aFreqTable_[i][2] / _nTotal_
	        _aRelFreq_ + [_aFreqTable_[i][1], _nRelativeFreq_]
	    next
	    
	    return _aRelFreq_
	
		def RelFreq()
		    return This.RelativeFrequency()
	

    def PercentageFrequency()

        _aRelFreq_ = This.RelativeFrequency()
        _aPercFreq_ = []

        _nLen_ = len(_aRelFreq_)

        for i = 1 to _nLen_
            _nPercentage_ = _aRelFreq_[i][2] * 100
            _aPercFreq_ + [_aRelFreq_[i][1], _nPercentage_]
        next
        
        return _aPercFreq_

		def PercentFreq()
			return This.PercentageFrequency()


    def UniqueCount()
        return len(This.UniqueValues())

		def UCount()
			return len(This.UniqueValues())


    def UniqueValues()
        _cKey_ = "unique_values"
        _cached_ = This._GetCached(_cKey_)

        if NOT isNull(_cached_)
            return _cached_
        ok

		_nLen_ = len(@anData)
        _aUnique_ = []

        for i = 1 to _nLen_
            if StzFindFirst(_aUnique_, @anData[i]) = 0
                _aUnique_ + @anData[i]
            ok
        next
        
        This._SetCache(_cKey_, _aUnique_)
        return _aUnique_


		def UVals()
			return This.UniqueValues()

		def UValues()
			return This.UniqueValues()


    def Diversity()
        # Unique values / Total values
        _nTotal_ = This.Count()
        if _nTotal_ = 0
            return 0
        ok
        return This.UniqueCount() / _nTotal_

		def DiversityIndex()
			return This.Diversity()


    def EntropyIndex()
        # Shannon entropy for diversity measurement
        if len(@anData) = 0
            return 0
        ok
        
        _aFreqTable_ = This.FrequencyTable()
        _nTotal_ = This.Count()
        _nEntropy_ = 0
        
		_nLen_ = len(_aFreqTable_)

        for i = 1 to _nLen_
            _nProbability_ = _aFreqTable_[i][2] / _nTotal_
            if _nProbability_ > 0
                _nEntropy_ -= _nProbability_ * log(_nProbability_) / log(2)
            ok
        next
        
        return _nEntropy_

		def Entropy()
			return This.EntropyIndex()


	#---

	def ContingencyTable(oOtherDataSet)
	    if NOT isObject(oOtherDataSet)
	        StzRaise("ContingencyTable requires another stzDataSet object")
	    ok
	    
	    _aData1_ = @anData
	    _aData2_ = oOtherDataSet.Data()
	    
	    if len(_aData1_) != len(_aData2_)
	        StzRaise("Both datasets must have same length")
	    ok
	    
	    _aUniqueX_ = This.UniqueValues()
	    _aUniqueY_ = oOtherDataSet.UniqueValues()
	    _aTable_ = []
	    
	    # Initialize table
		_nLenX_ = len(_aUniqueX_)
		_nLenY_ = len(_aUniqueY_)

	    for i = 1 to _nLenX_
	        _aRow_ = []
	        for j = 1 to _nLenY_
	            _aRow_ + 0
	        next
	        _aTable_ + [_aUniqueX_[i], _aRow_]
	    next
	    
	    # Count occurrences
	    _nLen_ = len(_aData1_)
	    for k = 1 to _nLen_
	        _nXIndex_ = StzFindFirst(_aUniqueX_, _aData1_[k])
	        _nYIndex_ = StzFindFirst(_aUniqueY_, _aData2_[k])
	        if _nXIndex_ > 0 and _nYIndex_ > 0
	            _aTable_[_nXIndex_][2][_nYIndex_]++
	        ok
	    next
	    
	    return [_aUniqueY_, _aTable_]
	
		def ContingTable()
			return This.ContingencyTable()


	def ModeCount()
	    if len(@anData) = 0
	        return 0
	    ok
	    
	    _cKey_ = "modecount"
	    _nCached_ = This._GetCached(_cKey_)
	    
	    if NOT IsNull(_nCached_)
	        return _nCached_
	    ok
	    
	    _aFreqTable_ = This.FrequencyTable()
	    if len(_aFreqTable_) = 0
	        return 0
	    ok
	    
	    _nMaxFreq_ = 0
	    _nLen_ = len(_aFreqTable_)
	    
	    for i = 1 to _nLen_
	        if _aFreqTable_[i][2] > _nMaxFreq_
	            _nMaxFreq_ = _aFreqTable_[i][2]
	        ok
	    next
	    
	    This._SetCache(_cKey_, _nMaxFreq_)
	    return _nMaxFreq_


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
		if This._EngineAvailable()
			return StzEngineStatsPercentile(@pEngineStats, nPercent)
		ok
		return This.PercentileXT(nPercent, "interpolation")


	def PercentileXT(nPercent, _cMethod_) # interpolation or nearest
	    if @cDataType != "numeric" or len(@anData) = 0
	        return 0
	    ok
	    
	    # Default to interpolation method
	    if _cMethod_ = NULL
	        _cMethod_ = "interpolation"
	    ok
	    
	    This._SortIfNeeded()
	    _nLen_ = len(@anSortedData)
	    
	    if _cMethod_ = "nearest" or _cMethod_ = "nearestrank"
	        _nRank_ = ceil((_nLen_ * nPercent) / 100)
	        
	        if _nRank_ < 1
	            _nRank_ = 1
	        but _nRank_ > _nLen_
	            _nRank_ = _nLen_
	        ok
	        
	        return @anSortedData[_nRank_]

	    else
	        # Linear interpolation method (default)
	        _nPosition_ = ((_nLen_ - 1) * nPercent) / 100 + 1
	        
	        if _nPosition_ <= 1
	            return @anSortedData[1]
	        but _nPosition_ >= _nLen_
	            return @anSortedData[_nLen_]
	        ok
	        
	        # Linear interpolation
	        _nLower_ = floor(_nPosition_)
	        _nUpper_ = _nLower_ + 1
	        _nFraction_ = _nPosition_ - _nLower_
	        
	        if _nUpper_ > _nLen_
	            return @anSortedData[_nLower_]
	        ok
	        
	        _nLowerVal_ = @anSortedData[_nLower_]
	        _nUpperVal_ = @anSortedData[_nUpper_]
	        return _nLowerVal_ + (_nFraction_ * (_nUpperVal_ - _nLowerVal_))
	    ok


	def Q1()
		if This._EngineAvailable()
			return StzEngineStatsQ1(@pEngineStats)
		ok
		return This.Percentile(25)

		def Q1XT(_cMethod_)
		    return This.PercentileXT(25, _cMethod_)
	
	def Q2()
		if This._EngineAvailable()
			return StzEngineStatsQ2(@pEngineStats)
		ok
		return This.Median()

		def Q2XT(_cMethod_)
		    # Median is typically the same regardless of method
		    return This.Median()
	
	def Q3()
		if This._EngineAvailable()
			return StzEngineStatsQ3(@pEngineStats)
		ok
		return This.Percentile(75)

		def Q3XT(_cMethod_)
		    return This.PercentileXT(75, _cMethod_)
	
	def IQR()
		if This._EngineAvailable()
			return StzEngineStatsIQR(@pEngineStats)
		ok
		return This.Q3() - This.Q1()

		def IQRXT(_cMethod_)
		    return This.Q3XT(_cMethod_) - This.Q1XT(_cMethod_)
	

	def Quartiles()
		return [This.Q1(), This.Q2(), This.Q3()]

	def QuartilesXT(_cMethod_)
	    return [This.Q1XT(_cMethod_), This.Q2XT(_cMethod_), This.Q3XT(_cMethod_)]


	#---

    def Skew()
        if @cDataType != "numeric" or len(@anData) < @nMinSampleSize
            return 0
        ok

        if This._EngineAvailable()
            return StzEngineStatsSkewness(@pEngineStats)
        ok

        _cKey_ = "skewness"
        _nCached_ = This._GetCached(_cKey_)

        if NOT isNull(_nCached_)
            return _nCached_
        ok
        
        _nMean_ = This.Mean()
        _nStdDev_ = This.StandardDeviation()
        
        if _nStdDev_ = 0
            return 0
        ok
        
        _nLen_ = len(@anData)
        _nSum_ = 0
        
        for i = 1 to _nLen_
            _nStandardized_ = (@anData[i] - _nMean_) / _nStdDev_
            _nSum_ += (_nStandardized_ * _nStandardized_ * _nStandardized_)
        next
        
        _nSkew_ = _nSum_ / ((_nLen_ - 1) * (_nLen_ - 2))
        This._SetCache(_cKey_, _nSkew_)
        return _nSkew_

		def Skewness()
			return Skew()


    def Kurtosis()
        if @cDataType != "numeric" or len(@anData) < 4
            return 0
        ok

        if This._EngineAvailable()
            return StzEngineStatsKurtosis(@pEngineStats)
        ok

        _cKey_ = "kurtosis"
        _nCached_ = This._GetCached(_cKey_)

        if NOT isNull(_nCached_)
            return _nCached_
        ok
        
        _nMean_ = This.Mean()
        _nStdDev_ = This.StandardDeviation()
        
        if _nStdDev_ = 0
            return 0
        ok
        
        _nLen_ = len(@anData)
        _nSum_ = 0
        
        for i = 1 to _nLen_
            _nStandardized_ = (@anData[i] - _nMean_) / _nStdDev_
            _nSum_ += (_nStandardized_ * _nStandardized_ * _nStandardized_ * _nStandardized_)
        next
        
        _nKurt_ = (_nSum_ / _nLen_) * (_nLen_ * (_nLen_ + 1)) / ((_nLen_ - 1) * (_nLen_ - 2) * (_nLen_ - 3))
        _nAdjustment_ = (3 * (_nLen_ - 1) * (_nLen_ - 1)) / ((_nLen_ - 2) * (_nLen_ - 3))
        
        _nResult_ = _nKurt_ - _nAdjustment_
        This._SetCache(_cKey_, _nResult_)
        return _nResult_

		def Kurtos()
			return Kurtosis()


	def ContainsOutliers()
		if This._EngineAvailable()
			return StzEngineStatsContainsOutliers(@pEngineStats)
		ok
		return len(This.Outliers()) > 0

    def Outliers()
        if @cDataType != "numeric"
            return []
        ok
        
        _cKey_ = "outliers"
        _cached_ = This._GetCached(_cKey_)

        if NOT IsNull(_cached_)
            return _cached_
        ok
        
        _nQ1_ = This.Q1()
        _nQ3_ = This.Q3()
        _nIQR_ = This.IQR()
        
        _nLowerBound_ = _nQ1_ - (1.5 * _nIQR_)
        _nUpperBound_ = _nQ3_ + (1.5 * _nIQR_)
        
        _aOutliers_ = []
        _nLen_ = len(@anData)
        for i = 1 to _nLen_
            if @anData[i] < _nLowerBound_ or @anData[i] > _nUpperBound_
                _aOutliers_ + @anData[i]
            ok
        next
        
        This._SetCache(_cKey_, _aOutliers_)
        return _aOutliers_

    def IsOutlier(nValue)
        _aOutliers_ = This.Outliers()
        return StzFindFirst(nValue, _aOutliers_) > 0


    def ZScores()
        if @cDataType != "numeric"
            return []
        ok
        
        _nMean_ = This.Mean()
        _nStdDev_ = This.StandardDeviation()
        
        if _nStdDev_ = 0
            return @anData  # No variation
        ok
        
        _aZScores_ = []
		_nLen_ = len(@anData)
        for i = 1 to _nLen_
            _nZScore_ = (@anData[i] - _nMean_) / _nStdDev_
            _aZScores_ + _nZScore_
        next
        
        return _aZScores_


    def MovingAverage(_nWindow_)
        if _nWindow_ = 0
            _nWindow_ = 3
        ok
        # Calculate moving average with specified window
        if @cDataType != "numeric" or _nWindow_ <= 0
            return @anData
        ok
        
        if len(@anData) < _nWindow_
            return @anData
        ok
        
        _aMovingAvg_ = []
        _nLen_ = len(@anData)
        
        for i = 1 to (_nLen_ - _nWindow_ + 1)
            _nSum_ = 0
            for j = i to (i + _nWindow_ - 1)
                _nSum_ += @anData[j]
            next
            _aMovingAvg_ + (_nSum_ / _nWindow_)
        next
        
        return _aMovingAvg_

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
	    
	    _nLenData_ = len(@anData)
	    
	    # For simple cases (2-3 points), use basic trend
	    if _nLenData_ <= 3
	        return This._SimpleSeriesTrend()
	    ok
	    
	    # Calculate consecutive differences
	    _aDifferences_ = []
	    for i = 2 to _nLenData_
	        _aDifferences_ + (@anData[i] - @anData[i-1])
	    next
	    
	    # Classify each difference
	    _aTrends_ = []
	    _nTolerance_ = This._CalculateTolerance()
		_nLenDiff_ = len(_aDifferences_)
	    for i = 1 to _nLenDiff_
	        _aTrends_ + This._ClassifyDifference(_aDifferences_[i], _nTolerance_)
	    next
	    
	    # Build segments - walker visits data positions without overlap
	    _aTrendSegments_ = []
	    _cCurrentTrend_ = _aTrends_[1]
	    _nSegmentStart_ = 1  # Start at first data position
	    _nLenTrends_ = len(_aTrends_)

	    for i = 2 to _nLenTrends_
	        if _aTrends_[i] != _cCurrentTrend_
	            # Trend change detected at difference i
	            # Previous segment covers from nSegmentStart to position i
	            _nSegmentLength_ = i - _nSegmentStart_ + 1
	            _aTrendSegments_ + [_cCurrentTrend_, _nSegmentLength_]
	            _cCurrentTrend_ = _aTrends_[i]
	            _nSegmentStart_ = i + 1  # Next segment starts AFTER transition point
	        ok
	    next
	    
	    # Add final segment
	    _nFinalLength_ = _nLenData_ - _nSegmentStart_ + 1
	    _aTrendSegments_ + [_cCurrentTrend_, _nFinalLength_]
	    
	    return _aTrendSegments_

	    def Trend()
		return This.TrendAnalysis()


	def _SimpleSeriesTrend()
	    _nLen_ = len(@anData)
	    if _nLen_ = 2
	        _nDiff_ = @anData[2] - @anData[1]
	        _nTolerance_ = This._CalculateTolerance()
	        _cTrend_ = This._ClassifyDifference(_nDiff_, _nTolerance_)
	        return [[_cTrend_, 2]]
	    ok
	    
	    # For 3 points, check if consistent trend
	    _nDiff1_ = @anData[2] - @anData[1]
	    _nDiff2_ = @anData[3] - @anData[2]
	    _nTolerance_ = This._CalculateTolerance()
	    
	    _cTrend1_ = This._ClassifyDifference(_nDiff1_, _nTolerance_)
	    _cTrend2_ = This._ClassifyDifference(_nDiff2_, _nTolerance_)
	    
	    if _cTrend1_ = _cTrend2_
	        return [[_cTrend1_, 3]]
	    else
	        return [[_cTrend1_, 2], [_cTrend2_, 2]]
	    ok
	
	def _CalculateTolerance()
	    # Calculate tolerance based on data scale and variability
	    _nRange_ = This.Range()
	    _nStdDev_ = This.StandardDeviation()
	    
	    # Use smaller of 1% of range or 10% of standard deviation
	    _nRangeTolerance_ = _nRange_ * 0.01
	    _nStdTolerance_ = _nStdDev_ * 0.1
	    
	    _nTolerance_ = iff(_nRangeTolerance_ < _nStdTolerance_ and _nRangeTolerance_ > 0, 
	                    _nRangeTolerance_, _nStdTolerance_)
	    
	    # Ensure minimum tolerance to avoid over-sensitivity
	    if _nTolerance_ < 0.001
	        _nTolerance_ = 0.001
	    ok
	    
	    return _nTolerance_
	
	def _ClassifyDifference(_nDiff_, _nTolerance_)
	    if abs(_nDiff_) <= _nTolerance_
	        return "stable"
	    but _nDiff_ > 0
	        return "up"
	    else
	        return "down"
	    ok


	#---

	def Deciles()
	    if @cDataType != "numeric" or len(@anData) = 0
	        return []
	    ok
	    
	    _cKey_ = "deciles"
	    _aCached_ = This._GetCached(_cKey_)
	    
	    if NOT IsNull(_aCached_)
	        return _aCached_
	    ok
	    
	    _aDeciles_ = []
	    for i = 10 to 90 step 10
	        _aDeciles_ + This.Percentile(i)
	    next
	    
	    This._SetCache(_cKey_, _aDeciles_)
	    return _aDeciles_
	

	def BoxPlotStats() # Prepare data series for stzBoxPlot

	    if @cDataType != "numeric" or len(@anData) = 0
	        return []
	    ok
	    
	    _cKey_ = "boxplotstats"
	    _aCached_ = This._GetCached(_cKey_)
	    
	    if NOT IsNull(_aCached_)
	        return _aCached_
	    ok
	    
	    _nQ1_ = This.Q1()
	    _nQ2_ = This.Q2()
	    _nQ3_ = This.Q3()
	    _nIQR_ = This.IQR()
	    
	    _nLowerFence_ = _nQ1_ - (1.5 * _nIQR_)
	    _nUpperFence_ = _nQ3_ + (1.5 * _nIQR_)
	    
	    This._SortIfNeeded()
	    _nWhiskerLow_ = @anSortedData[1]
	    _nWhiskerHigh_ = @anSortedData[len(@anSortedData)]
	    
	    # Find actual whisker values within fences
	    _nLen_ = len(@anSortedData)
	    for i = 1 to _nLen_
	        if @anSortedData[i] >= _nLowerFence_
	            _nWhiskerLow_ = @anSortedData[i]
	            exit
	        ok
	    next
	    
	    for i = _nLen_ to 1 step -1
	        if @anSortedData[i] <= _nUpperFence_
	            _nWhiskerHigh_ = @anSortedData[i]
	            exit
	        ok
	    next
	    
	    _aResult_ = [
	        [:min, This.Min()],
	        [:q1, _nQ1_],
	        [:median, _nQ2_],
	        [:q3, _nQ3_],
	        [:max, This.Max()],
	        [:whisker_low, _nWhiskerLow_],
	        [:whisker_high, _nWhiskerHigh_],
	        [:iqr, _nIQR_]
	    ]
	    
	    This._SetCache(_cKey_, _aResult_)
	    return _aResult_
	
		def BoxPlotData()
			return This.BoxPlot()


	def NormalityTest()
	    # Simplified normality test based on skewness and kurtosis
	    if @cDataType != "numeric" or len(@anData) < 4
	        return [["test", "insufficient_data"], ["p_value", 0], ["is_normal", 0]]
	    ok
	    
	    _cKey_ = "normalitytest"
	    _aCached_ = This._GetCached(_cKey_)
	    
	    if NOT IsNull(_aCached_)
	        return _aCached_
	    ok
	    
	    _nSkew_ = This.Skewness()
	    _nKurt_ = This.Kurtosis()  # Already excess kurtosis (normal = 0)
	    
	    # Normal distribution: skewness ≈ 0, excess kurtosis ≈ 0
	    # Use stricter thresholds since your data shows high deviations
	    _bIsNormal_ = (abs(_nSkew_) < 1) and (abs(_nKurt_) < 1)
	    
	    # Calculate p-value based on combined deviation
	    _nSkewDev_ = abs(_nSkew_)
	    _nKurtDev_ = abs(_nKurt_) 
	    _nCombinedDev_ = sqrt(_nSkewDev_ * _nSkewDev_ + _nKurtDev_ * _nKurtDev_)
	    
	    # Exponential decay for p-value
	    _nPValue_ = exp(-_nCombinedDev_)
	    
	    if _nPValue_ > 1
	        _nPValue_ = 1
	    ok
	    
	    _nIsNormalFlag_ = 0
	    if _bIsNormal_
	        _nIsNormalFlag_ = 1
	    ok
	    
	    _aResult_ = [
	        ["test", "heuristic"],
	        ["skewness", _nSkew_],
	        ["kurtosis", _nKurt_],
	        ["p_value", _nPValue_],
	        ["is_normal", _nIsNormalFlag_]
	    ]
	    
	    This._SetCache(_cKey_, _aResult_)
	    return _aResult_

		def Normality()
			return This.NormalityTest()


    #===========================================================#
    #  PILLAR 4: RELATION - Correlation & Association Analysis  #
    #===========================================================#

    def CorrelationWith(_oOtherStats_)
        if @cDataType != "numeric" or _oOtherStats_.DataType() != "numeric"
            return 0
        ok

        _aOtherData_ = _oOtherStats_.Data()
        if len(@anData) != len(_aOtherData_) or len(@anData) < 2
            return 0
        ok

        if This._EngineAvailable() and _oOtherStats_._EngineAvailable()
            return StzEngineStatsCorrelation(@pEngineStats, _oOtherStats_._EngineHandle())
        ok

        _nMean1_ = This.Mean()
        _nMean2_ = _oOtherStats_.Mean()
        _nLen_ = len(@anData)
        _nSumProduct_ = 0
        _nSumSq1_ = 0
        _nSumSq2_ = 0
        
        for i = 1 to _nLen_
            _nDiff1_ = @anData[i] - _nMean1_
            _nDiff2_ = _aOtherData_[i] - _nMean2_
            _nSumProduct_ += _nDiff1_ * _nDiff2_
            _nSumSq1_ += _nDiff1_ * _nDiff1_
            _nSumSq2_ += _nDiff2_ * _nDiff2_
        next
        
        if _nSumSq1_ = 0 or _nSumSq2_ = 0
            return 0
        ok
        
        return _nSumProduct_ / sqrt(_nSumSq1_ * _nSumSq2_)

		def CorelWith(_oOtherStats_)
			return This.CorrelationWith(_oOtherStats_)

		def Corel(_oOtherStats_)
			return This.CorrelationWith(_oOtherStats_)

		def Cor(_oOtherStats_)
			return This.CorrelationWith(_oOtherStats_)


    def CovarianceWith(_oOtherStats_)
        if @cDataType != "numeric" or _oOtherStats_.DataType() != "numeric"
            return 0
        ok

        _aOtherData_ = _oOtherStats_.Data()
        if len(@anData) != len(_aOtherData_) or len(@anData) < 2
            return 0
        ok

        if This._EngineAvailable() and _oOtherStats_._EngineAvailable()
            return StzEngineStatsCovariance(@pEngineStats, _oOtherStats_._EngineHandle())
        ok

        _nMean1_ = This.Mean()
        _nMean2_ = _oOtherStats_.Mean()
        _nLen_ = len(@anData)
        _nSum_ = 0
        
        for i = 1 to _nLen_
            _nSum_ += (@anData[i] - _nMean1_) * (_aOtherData_[i] - _nMean2_)
        next
        
        return _nSum_ / (_nLen_ - 1)

		def CovarWith(_oOtherStats_)
			return This.CovarianceWith(_oOtherStats_)

		def CVWith(_oOtherStats_)
			return This.CovarianceWith(_oOtherStats_)

    def RankCorrelationWith(_oOtherStats_)
        if @cDataType != "numeric" or _oOtherStats_.DataType() != "numeric"
            return 0
        ok

        _aOtherData_ = _oOtherStats_.Data()
        if len(@anData) != len(_aOtherData_) or len(@anData) < 2
            return 0
        ok

        if This._EngineAvailable() and _oOtherStats_._EngineAvailable()
            return StzEngineStatsRankCorrelation(@pEngineStats, _oOtherStats_._EngineHandle())
        ok

        # Create rankings
        _aRanks1_ = This._GetRanks(@anData)
        _aRanks2_ = This._GetRanks(_aOtherData_)
        
        # Calculate correlation of ranks
        _oRank1_ = new stzDataSet(_aRanks1_)
        _oRank2_ = new stzDataSet(_aRanks2_)
        
        return _oRank1_.CorrelationWith(_oRank2_)

		def RankCorelWith(_oOtherStats_)
			return This.RankCorrelationWith(_oOtherStats_)

		def NonParametricCorrelation()
			return This.RankCorrelationWith(_oOtherStats_)


    def _GetRanks(aData)
        _aIndexed_ = []
        _nLen_ = len(aData)
        
        # Create value-index pairs
        for i = 1 to _nLen_
            _aIndexed_ + [aData[i], i]
        next
        
        # Sort by value

        _aIndexed_ = @SortOn(1, _aIndexed_)
        
        # Assign ranks
        _aRanks_ = []
        for i = 1 to _nLen_
            _aRanks_ + 0  # Initialize
        next
        
        for i = 1 to _nLen_
            _nOriginalIndex_ = _aIndexed_[i][2]
            _aRanks_[_nOriginalIndex_] = i
        next
        
        return _aRanks_

	def ChiSquareWith(_oOtherStats_)
	    # Chi-square test for independence (categorical data)
	    if @cDataType != "categorical" or _oOtherStats_.DataType() != "categorical"
	        return 0
	    ok
	    
	    _aOtherData_ = _oOtherStats_.Data()
	    if len(@anData) != len(_aOtherData_) or len(@anData) < 2
	        return 0
	    ok
	    
	    # Create cache key using stringified list
	    _cKey_ = "chi_square_" + @@(_oOtherStats_.Data())
	    _nCached_ = This._GetCached(_cKey_)

	    if NOT isNull(_nCached_)
	        return _nCached_
	    ok
	    
	    # Get unique categories for both datasets
	    _aUnique1_ = This.UniqueValues()
	    _aUnique2_ = _oOtherStats_.UniqueValues()
	    
	    if len(_aUnique1_) = 0 or len(_aUnique2_) = 0
	        return 0
	    ok
	    
	    # Initialize contingency table
	    _nRows_ = len(_aUnique1_)
	    _nCols_ = len(_aUnique2_)
	    _aContingency_ = []
	    for i = 1 to _nRows_
	        _aRow_ = []
	        for j = 1 to _nCols_
	            _aRow_ + 0
	        next
	        _aContingency_ + _aRow_
	    next
	    
	    # Populate contingency table with observed frequencies
	    _nLen_ = len(@anData)
	    for i = 1 to _nLen_
	        _nRow_ = StzFindFirst(_aUnique1_, @anData[i])
	        _nCol_ = StzFindFirst(_aUnique2_, _aOtherData_[i])
	        if _nRow_ > 0 and _nCol_ > 0
	            _aContingency_[_nRow_][_nCol_]++
	        ok
	    next
	    
	    # Calculate row and column totals
	    _aRowTotals_ = []
	    _aColTotals_ = []
	    _nGrandTotal_ = 0
	    
	    for i = 1 to _nRows_
	        _nRowTotal_ = 0
	        for j = 1 to _nCols_
	            _nRowTotal_ += _aContingency_[i][j]
	        next
	        _aRowTotals_ + _nRowTotal_
	        _nGrandTotal_ += _nRowTotal_
	    next
	    
	    for j = 1 to _nCols_
	        _nColTotal_ = 0
	        for i = 1 to _nRows_
	            _nColTotal_ += _aContingency_[i][j]
	        next
	        _aColTotals_ + _nColTotal_
	    next
	    
	    # Check for zero totals
	    if _nGrandTotal_ = 0
	        return 0
	    ok
	    
	    # Calculate chi-square statistic
	    _nChiSquare_ = 0
	    for i = 1 to _nRows_
	        for j = 1 to _nCols_
	            _nObserved_ = _aContingency_[i][j]
	            _nExpected_ = (_aRowTotals_[i] * _aColTotals_[j]) / _nGrandTotal_
	            if _nExpected_ > 0
	                _nChiSquare_ += ((_nObserved_ - _nExpected_) * (_nObserved_ - _nExpected_)) / _nExpected_
	            ok
	        next
	    next
	    
	    _nResult_ = _nChiSquare_
	    This._SetCache(_cKey_, _nResult_)
	    return _nResult_

		def CategoricalAssociationWith(_oOtherStats_)
			return This.ChiSquareWith(_oOtherStats_)

	#---

	def RegressionCoefficients(oOtherDataSet)
	    if @cDataType != "numeric" or oOtherDataSet.DataType() != "numeric"
	        return [[:slope, 0], [:intercept, 0], [:r_squared, 0]]
	    ok
	    
	    _aOtherData_ = oOtherDataSet.Data()
	    if len(@anData) != len(_aOtherData_) or len(@anData) < 2
	        return [[:slope, 0], [:intercept, 0], [:r_squared, 0]]
	    ok
	    
	    _nMeanX_ = This.Mean()
	    _nMeanY_ = oOtherDataSet.Mean()
	    _nLen_ = len(@anData)
	    _nSumXY_ = 0
	    _nSumXX_ = 0
	    
	    for i = 1 to _nLen_
	        _nDiffX_ = @anData[i] - _nMeanX_
	        _nDiffY_ = _aOtherData_[i] - _nMeanY_
	        _nSumXY_ += _nDiffX_ * _nDiffY_
	        _nSumXX_ += _nDiffX_ * _nDiffX_
	    next
	    
	    if _nSumXX_ = 0
	        return [[:slope, 0], [:intercept, _nMeanY_], [:r_squared, 0]]
	    ok
	    
	    _nSlope_ = _nSumXY_ / _nSumXX_
	    _nIntercept_ = _nMeanY_ - (_nSlope_ * _nMeanX_)
	    _nCorr_ = This.CorrelationWith(oOtherDataSet)
	    _nRSquared_ = _nCorr_ * _nCorr_
	    
	    return [[:slope, _nSlope_], [:intercept, _nIntercept_], [:r_squared, _nRSquared_]]
	
		def RCoefficients(oOtherDataSet)
			return This.RegressionCoefficients(oOtherDataSet)


	def PartialCorrelation(oDataSetY, oDataSetZ)
	    # Partial correlation between X and Y controlling for Z
	    if @cDataType != "numeric" or oDataSetY.DataType() != "numeric" or oDataSetZ.DataType() != "numeric"
	        return 0
	    ok
	    
	    _nRxy_ = This.CorrelationWith(oDataSetY)
	    _nRxz_ = This.CorrelationWith(oDataSetZ)
	    _nRyz_ = oDataSetY.CorrelationWith(oDataSetZ)
	    
	    _nDenom_ = sqrt((1 - _nRxz_ * _nRxz_) * (1 - _nRyz_ * _nRyz_))
	    
	    if _nDenom_ = 0
	        return 0
	    ok
	    
	    return (_nRxy_ - _nRxz_ * _nRyz_) / _nDenom_
	
		def PCorrelation(oDataSetY, oDataSetZ)
			return This.PartialCorrelation(oDataSetY, oDataSetZ)

		def PartCorrelation(oDataSetY, oDataSetZ)
			return This.PartialCorrelation(oDataSetY, oDataSetZ)

		def PartCorel(oDataSetY, oDataSetZ)
			return This.PartialCorrelation(oDataSetY, oDataSetZ)


	def MutualInformation(oOtherDataSet)
	    # Simplified mutual information for categorical data
	    _aData1_ = @anData
	    _aData2_ = oOtherDataSet.Data()
	    
	    if len(_aData1_) != len(_aData2_) or len(_aData1_) = 0
	        return 0
	    ok
	    
	    # Create joint frequency table
	    _aJointFreq_ = []
	    _nTotal_ = len(_aData1_)
	    
	    for i = 1 to _nTotal_
	        _cPair_ = "" + _aData1_[i] + "_" + _aData2_[i]
	        _nIndex_ = This._FindInFreqList(_aJointFreq_, _cPair_)
	        if _nIndex_ = 0
	            _aJointFreq_ + [_cPair_, 1]
	        else
	            _aJointFreq_[_nIndex_][2]++
	        ok
	    next
	    
	    # Calculate marginal frequencies
	    _aFreq1_ = This.FrequencyTable()
	    _aFreq2_ = oOtherDataSet.FrequencyTable()
	    
	    # Calculate mutual information
	    _nMI_ = 0
	    _nJointLen_ = len(_aJointFreq_)
	    
	    for i = 1 to _nJointLen_
	        _nJointProb_ = _aJointFreq_[i][2] / _nTotal_
	        
	        # Extract individual values from pair
	        _aPair_ = split(_aJointFreq_[i][1], "_")
	        _cVal1_ = _aPair_[1]
	        _cVal2_ = _aPair_[2]
	        
	        _nMarg1_ = This._GetFreqValue(_aFreq1_, _cVal1_) / _nTotal_
	        _nMarg2_ = This._GetFreqValue(_aFreq2_, _cVal2_) / _nTotal_
	        
	        if _nJointProb_ > 0 and _nMarg1_ > 0 and _nMarg2_ > 0
	            _nMI_ += _nJointProb_ * log(_nJointProb_ / (_nMarg1_ * _nMarg2_)) / log(2)
	        ok
	    next
	    
	    return _nMI_
	
	    #< @FunctionAlternativeForms

	    def MutualInformationWith(oOtherDataSet)
		return This.MutualInformation(oOtherDataSet)

	    def MutualInfo(oOtherDataSet)
		return This.MutualInformation(oOtherDataSet)

	    def MutualInfoWith(oOtherDataSet)
		return This.MutualInformation(oOtherDataSet)

	    #>

	# Helper methods for new functionality
	
	def _HashList(aList)
	    _cHash_ = ""
	    _nLen_ = len(aList)
	    for i = 1 to _nLen_
	        _cHash_ += "" + aList[i] + "_"
	    next
	    return _cHash_
	
	def _FindInFreqList(aFreqList, _cValue_)
	    _nLen_ = len(aFreqList)
	    for i = 1 to _nLen_
	        if aFreqList[i][1] = _cValue_
	            return i
	        ok
	    next
	    return 0
	
	def _GetFreqValue(_aFreqTable_, _cValue_)
	    _nLen_ = len(_aFreqTable_)
	    for i = 1 to _nLen_
	        if _aFreqTable_[i][1] = _cValue_
	            return _aFreqTable_[i][2]
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
        
        _nMin_ = This.Min()
        _nMax_ = This.Max()
        _nRange_ = _nMax_ - _nMin_
        
        if _nRange_ = 0
            return @anData  # All values are the same
        ok
        
        _aNormalized_ = []
		_nLen_ = len(@anData)

        for i = 1 to _nLen_
            _nNormalized_ = (@anData[i] - _nMin_) / _nRange_
            _aNormalized_ + _nNormalized_
        next
        
        return _aNormalized_


    def Standardize()
        # Z-score standardization
        if @cDataType != "numeric"
            return @anData
        ok
        
        _nMean_ = This.Mean()
        _nStdDev_ = This.StandardDeviation()
        
        if _nStdDev_ = 0
            return @anData  # No variation
        ok
        
        _aStandardized_ = []
		_nLen_ = len(@anData)

        for i = 1 to _nLen_
            _nStandardized_ = (@anData[i] - _nMean_) / _nStdDev_
            _aStandardized_ + _nStandardized_
        next
        
        return _aStandardized_
 
		def Standardise()
			return This.Standardize()


    def RobustScale()
        # Scale using median and IQR (robust to outliers)
        if @cDataType != "numeric"
            return @anData
        ok
        
        _nMedian_ = This.Median()
        _nIQR_ = This.IQR()
        
        if _nIQR_ = 0
            return @anData
        ok
        
        _aScaled_ = []
		_nLen_ = len(@anData)

        for i = 1 to _nLen_
            _nScaled_ = (@anData[i] - _nMedian_) / _nIQR_
            _aScaled_ + _nScaled_
        next
        
        return _aScaled_


		def RScale()
			return This.RobustScale()

    #=============================#
    #  DATA QUALITY AND GUIDANCE  #
    #=============================#

    def ValidateData()
        # Validate data integrity and quality
        _acIssues_ = []

        if len(@anData) = 0
            _acIssues_ + "Dataset is empty"
            return _acIssues_
        ok
        
        if @cDataType = "numeric"
            # Check for infinite or NaN values
			_nLen_ = len(@anData)
            for i = 1 to _nLen_
                if isNull(@anData[i])
                    aIssues + "Contains null values"
                    exit
                ok
            next

            # Check for extreme outliers
            _aOutliers_ = This.Outliers()
            if len(_aOutliers_) > (This.Count() * 0.2)
                _acIssues_ + "High proportion of outliers detected"
            ok
            
            # Check for variance
            if This.StandardDeviation() = 0
                _acIssues_ + "No variance in data (all values identical)"
            ok
        ok
        
        if len(_acIssues_) = 0
            _acIssues_ + "Data quality appears good"
        ok
        
        return _acIssues_

		def Validate()
			return This.ValidateData()

		def Issues()
			return This.ValidateData()


    #=============================#
    #  INSIGHT GENERATION SYSTEM  #
    #=============================#

    def _GenerateInsights()
        _aTemplates_ = DataSetTemplates()
        _nLen_ = len(_aTemplates_)
        _acInsights_ = []
        
        for i = 1 to _nLen_
            if This._EvaluateCondition(_aTemplates_[i][:condition])
                _acInsights_ + This._InterpolateTemplate(_aTemplates_[i][:template])
            ok
        next
        
        return _acInsights_

    def _GenerateInsightXT(cType)
        _aTemplates_ = DataSetTemplatesXT(cType)
        _nLen_ = len(_aTemplates_)
        _acInsights_ = []
        
        for i = 1 to _nLen_
            if This._EvaluateCondition(_aTemplates_[i][:condition])
                _acInsights_ + This._InterpolateTemplate(_aTemplates_[i][:template])
            ok
        next
        
        return _acInsights_

    def Insights()
        return This._GenerateInsights()

        def StatInsights()
            return This._GenerateInsights()

        def StatsInsights()
            return This._GenerateInsights()

        def NativeInsights()
            return This._GenerateInsights()

    def InsightsXT()
        _acResults_ = This.Insights()
        
        _nLen_ = len($aDomainInsightRules)
        
        for i = 1 to _nLen_
            _cDomain_ = $aDomainInsightRules[i][1]
            _aDomain_ = $aDomainInsightRules[i][2]
            _nLenDomain_ = len(_aDomain_)
            
            for j = 1 to _nLenDomain_
                if This._EvaluateCondition(_aDomain_[j][:condition])
                    _acResults_ + This._InterpolateTemplate(_aDomain_[j][:template])
                ok
            next
        next
        
        return _acResults_

    def InsightsOfDomain(_cDomain_)
        _acResults_ = []
        
        if HasKey($aDomainInsightRules, _cDomain_)
            _nLen_ = len($aDomainInsightRules[_cDomain_])
            
            for i = 1 to _nLen_
                if This._EvaluateCondition($aDomainInsightRules[_cDomain_][i][:condition])
                    _acResults_ + This._InterpolateTemplate($aDomainInsightRules[_cDomain_][i][:template])
                ok
            next
        ok
        
        return _acResults_

	def InsightsForDomain(_cDomain_)
		return This.InsightsOfDomain(_cDomain_)

    #===============================#
    #  RECOMMENDATIONS SYSTEM       #
    #===============================#

    def RecommendAnalysis()
        _nLen_ = len($aRecommendations)
        _aResults_ = []
        
        for i = 1 to _nLen_
            _aTemplate_ = $aRecommendations[i]
            
            if This._EvaluateCondition(_aTemplate_[:condition])
                _cRecommendation_ = This._InterpolateTemplate(_aTemplate_[:recommendation])
                
                _aResults_ + _cRecommendation_
            ok
        next
        
        return _aResults_

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

    def _GenerateReport(_aTemplate_)
        _cFormat_ = _aTemplate_[:format]
        _aSections_ = _aTemplate_[:sections]

        _cReport_ = ""
        
        _nSections1Len_ = len(_aSections_)
        for _iLoopSections1_ = 1 to _nSections1Len_
        	_aSection_ = _aSections_[_iLoopSections1_]
            # Check for inheritance (first element is :inherit)
            if len(_aSection_) >= 2 and _aSection_[1] = :inherit

                # Handle inheritance
                _cInheritedTemplate_ = _aSection_[2]
                eval("aInheritedSections = " + _cInheritedTemplate_ + "[:sections]")
           
                _nInheritedSections1Len_ = len(aInheritedSections)
                for _iLoopInheritedSections1_ = 1 to _nInheritedSections1Len_
                	_aInheritedSection_ = aInheritedSections[_iLoopInheritedSections1_]
                    _cReport_ += This._ProcessSection(_aInheritedSection_, _cFormat_)
                next

            else
                _cReport_ += This._ProcessSection(_aSection_, _cFormat_)
            ok
        next
        
        return @trim(_cReport_)


	def _ProcessSection(_aSection_, _cFormat_)
	    _cSectionContent_ = ""
	    
	    _cKey_ = _aSection_[1][1]
	    if _cKey_ = :condition
	        if NOT This._EvaluateCondition(_aSection_[2][2])
	            return ""
	        ok
	    ok
	    if _cKey_ = :title
	        _cTitle_ = _aSection_[1][2]
	        if _cFormat_ = "text"
	            _cSectionContent_ += (NL + BoxifyRound(_cTitle_) + NL)
	        ok
	    ok
	    
	    _vContent_ = _aSection_[2][2]
	    if isString(_vContent_)
	        _cSectionContent_ += This._InterpolateContent(_vContent_) + NL
	
	    but isList(_vContent_)
	        if _cFormat_ = "text"
				_nLen_ = len(_vContent_)
				for i = 1 to _nLen_
					_cItem_ = _vContent_[i]
	                _cSectionContent_ += "• " + @trim(This._InterpolateContent(_cItem_)) + NL
					if i < _nLen_
						_cSectionContent_ += NL
					ok
	            next
	        ok
	    ok
	    
	    return _cSectionContent_


    #===============================#
    #  CORE INTERPOLATION METHODS   #
    #===============================#

    def _EvaluateCondition(cCondition)
        if cCondition = @trim("")
            StzRaise("Can't evaluate the condition! cCondition must not be be an empty string.")
        ok
        
        try
            _cCode_ = '_bResult_ = (' + cCondition + ')'
            eval(_cCode_)
            return _bResult_
        catch
            return FALSE
        done

    def _InterpolateTemplate(_cTemplate_)
        return This._InterpolateContent(_cTemplate_)


	def _InterpolateContent(cContent)
	    if NOT isString(cContent)
	        return cContent
	    ok
	    
	    _oTempStr_ = new stzString(cContent)
	    
	    # Handle special cases first
	    if _oTempStr_.Contains("{Insights()}")
	        _acInsights_ = This.Insights()
	        _cInsightText_ = ""
	        _nLen_ = len(_acInsights_)
	
	        for i = 1 to _nLen_
	            _cInsightText_ += "• " + _acInsights_[i]
	            if i < _nLen_
	                _cInsightText_ += NL + NL  # Added extra NL
	            ok
	        next
	        _oTempStr_.Replace("{Insights()}", _cInsightText_)
	    ok
	    
	    if _oTempStr_.Contains("{Recommendations()}")
	        _acRecommendations_ = This.Recommendations()
		_nLen_ = len(_acRecommendations_)
	        _cRecommendText_ = ""
	        for i = 1 to _nLen_
	            _cRecommendText_ += "• " + _acRecommendations_[i] + NL + NL  # Added extra NL
	        next
	        _oTempStr_.Replace("{Recommendations()}", _cRecommendText_)
	    ok
	  
	    # Find all remaining method calls and replace them one by one
	    _nMaxIterations_ = 50
	    _nIterations_ = 0
	    
	    while _oTempStr_.Contains("{") and _oTempStr_.Contains("}") and _nIterations_ < _nMaxIterations_
	        _nIterations_++
	        
	        _nStart_ = _oTempStr_.FindFirst("{")
	        _nEnd_ = _oTempStr_.FindNext("}", _nStart_)
	        
	        if _nEnd_ = 0
	            break
	        ok
	        
	        # Extract method name without braces
	        _cMethod_ = _oTempStr_.Section(_nStart_ + 1, _nEnd_ - 1)
	        _cCode_ = '_value_ = ' + _cMethod_
			eval(_cCode_)
	        _cValue_ = This._FormatValue(_value_)
	        _oTempStr_.ReplaceSection(_nStart_, _nEnd_, _cValue_)

	    end
	    
	    return _oTempStr_.Content()
	

    def _FormatValue(_value_)
        if isNumber(_value_)
            if _value_ = floor(_value_)
                return "" + _value_
            else
                return @@(_value_)
            ok

        but isString(_value_)
            return _value_

        but isList(_value_)
            _cResult_ = "["
            _nValueLen_ = len(_value_)
            for i = 1 to _nValueLen_
                _cResult_ += This._FormatValue(_value_[i])
                if i < len(_value_)
                    _cResult_ += ", "
                ok
            next
            _cResult_ += "]"
            return _cResult_
        else
            return "" + _value_
        ok


    #===============================#
    #  RULE MANAGEMENT METHODS      #
    #===============================#

    def AddInsightRule(_cDomain_, cCondition, _cInsight_)
        if NOT HasKey($aDomainInsightRules, _cDomain_)
            $aDomainInsightRules[_cDomain_] = []
        ok
        $aDomainInsightRules[_cDomain_] + [:condition = cCondition, :template = _cInsight_]

    def AddRule(_cDomain_, cCondition, _cInsight_)
        This.AddInsightRule(_cDomain_, cCondition, _cInsight_)

    def AddWeightedRule(_cDomain_, cCondition, _cInsight_, _nWeight_)
        if _nWeight_ = NULL _nWeight_ = 1 ok
        if NOT HasKey($aDomainInsightRules, _cDomain_)
            $aDomainInsightRules[_cDomain_] = []
        ok
        $aDomainInsightRules[_cDomain_] + [:condition = cCondition, :template = _cInsight_, :weight = _nWeight_]

    def PrioritizedInsights(_cDomain_)
        _aResults_ = []
        
        if HasKey($aDomainInsightRules, _cDomain_)
            _aRules_ = $aDomainInsightRules[_cDomain_]
            
            _nRules1Len_ = len(_aRules_)
            for _iLoopRules1_ = 1 to _nRules1Len_
            	_aRule_ = _aRules_[_iLoopRules1_]
                if This._EvaluateCondition(_aRule_[:condition])
                    _cInsight_ = This._InterpolateTemplate(_aRule_[:template])
                    _nWeight_ = 1
                    
                    if HasKey(_aRule_, :weight)
                        _nWeight_ = _aRule_[:weight]
                    ok
                    
                    _aResults_ + [_cInsight_, _nWeight_]
                ok
            next
            
            # Sort by weight descending
            _aResults_ = SortOnXT(2, _aResults_, :Descending)
        ok
        
        return _aResults_

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

        _cTemplate_ = This._ResolvePlanTemplate(cNameOrGoalOrTemplate)

        if _cTemplate_ = NULL
            StzRaise("Unknown Plan name, goal or template: " + cNameOrGoalOrTemplate)
        ok

		_n_ = StzFindFirst(_cTemplate_, This._PlanNames())

		if _n_ = 0
			StzRaise("Inexistant Plan template name!")
		ok

        _aTemplate_ = $aPlanTemplates[_n_][2]
        _aExecutableSteps_ = This._FilterPlanSteps(_aTemplate_[:steps])

        return [
            :template = _cTemplate_,
			:name = _aTemplate_[:name],
            :title = _aTemplate_[:title],
            :description = _aTemplate_[:description],
            :steps = _aExecutableSteps_,
            :total_steps = len(_aExecutableSteps_),
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
		_nLen_ = len(acPlans)
		for i = 1 to _nLen_
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

	_nTime_ = clock()

        if bVerbose = NULL bVerbose = TRUE ok
        
        _aPlan_ = This.GeneratePlan(cNameOrGoalOrTemplate)
        _aResults_ = []
        _aErrors_ = []
        
        if bVerbose
            ? BoxRound("Executing Plan: " + _aPlan_[:title])

		? "• Name: {" + _aPlan_[:name] + "}"
           	? "• Goal: " + _aPlan_[:description]
            	? "• Steps: " + _aPlan_[:total_steps] + NL
        ok
        
        _nStepNum_ = 1
        _aPlansteps2_ = _aPlan_[:steps]
        _nPlansteps2Len_ = len(_aPlansteps2_)
        for _iLoopPlansteps2_ = 1 to _nPlansteps2Len_
        	_aStep_ = _aPlansteps2_[_iLoopPlansteps2_]
            if bVerbose
                ? "✅ Step " + _nStepNum_ + "/" + _aPlan_[:total_steps] + ": " + _aStep_[:description]
            ok
            
            try
                _vResult_ = This._ExecutePlanStep(_aStep_)
                _aResults_ + [
                    :step = _nStepNum_,
                    :function = _aStep_[:function],
                    :description = _aStep_[:description],
                    :result = _vResult_,
                    :status = "success"
                ]
                
                if bVerbose
                    ? "╰─> " + This._FormatStepResult(_aStep_[:function], _vResult_) + NL
                ok
                

            catch
                _aErrors_ + [
                    :step = _nStepNum_,
                    :function = _aStep_[:function],
                    :error = CatchError()
                ]
                
                if bVerbose
                    ? "❌ Error: " + CatchError() + NL
                ok
            done
            
            _nStepNum_++
        next
        
        if bVerbose
	    _nTime_ = (clock() - _nTime_) / clockspersecond()
            ? "( Plan completed in " + _nTime_ + "s : " + len(_aResults_) + " successful step(s), " + len(_aErrors_) + " error(s) )"
        ok
        
        return [
            :plan = _aPlan_,
            :results = _aResults_,
            :errors = _aErrors_,
            :success_rate = (len(_aResults_) / _aPlan_[:total_steps]) * 100
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

        _aPlan_ = This.GeneratePlan(cNameOrGoalOrTemplate)
        _cSummary_ = BoxifyRound("Plan: " + oPlan[:title]) + NL

		if @bChain = FALSE or
			(@bChain = TRUE and @bFirstChain)

			_cSummary_ += "• Data: " + @@(This.Content()) + NL
		ok

		_cSummary_ += "• Name: {" + _aPlan_[:name] + "}" + NL
        _cSummary_ += "• Goal: " + _aPlan_[:description] + NL
        _cSummary_ += "• Steps (" + _aPlan_[:total_steps] + "):" + NL
        
        _nStep_ = 1
        _aPlansteps1_ = _aPlan_[:steps]
        _nPlansteps1Len_ = len(_aPlansteps1_)
        for _iLoopPlansteps1_ = 1 to _nPlansteps1Len_
        	_aStep_ = _aPlansteps1_[_iLoopPlansteps1_]
            _cSummary_ += "  " + _nStep_ + ". " + _aStep_[:description]
            if HasKey(_aStep_, :condition)
                _cSummary_ += " (conditional)"
            ok
            if HasKey(_aStep_, :args)
                _cSummary_ += " [params: " + This._FormatArgs(_aStep_[:args]) + "]"
            ok
            _cSummary_ += NL
            _nStep_++
        next
        
        return _cSummary_
    
    
    def AddPlan(cName, _cTitle_, cDescription, aSteps)
        /*
        Create a custom Plan template
        @param _cTitle_: Plan title
        @param cDescription: Plan description  
        @param aSteps: Array of step definitions
        */
 
		
        _cKey_ = "custom_" + StzLower(cName)

        $aPlanTemplates[cName] = [
			:name = cName,
            :title = _cTitle_,
            :description = cDescription,
            :steps = aSteps
        ]
        
        return _cKey_
    

	def SuggestPlan()
	    _cDataType_ = This.DataType()
	    _nCount_ = This.Count()
	    
	    if _nCount_ < 3 or _cDataType_ != "numeric"
	        return :EDA
	    ok
	    
	    # Zero variance check
	    if This.StandardDeviation() = 0
	        return :EDA
	    ok
	    
	    # Check outliers first
	    if This.ContainsOutliers()
	        _nOutlierPct_ = (len(This.Outliers()) / _nCount_) * 100
	        if _nOutlierPct_ > 5
	            return :OUTLIERS
	        ok
	    ok
	    
	    # High variability
	    _nCV_ = This.CoefficientOfVariation()
	    if _nCV_ > 50
	        return :QUALITY
	    ok
	    
	    # Trending data detection
	    if _nCount_ >= 5
	        _aTrend_ = This.TrendAnalysis()
	        if len(_aTrend_) = 1 and _aTrend_[1][1] != "stable"
	            return :TRENDS
	        ok
	    ok
	    
	    # Check normality
	    if _nCount_ >= 8
	        _nSkew_ = abs(This.Skewness())
	        _nKurt_ = abs(This.Kurtosis())
	        
	        _nSkewLimit_ = iff(_nCount_ < 30, 1.0, 0.75)
	        _nKurtLimit_ = iff(_nCount_ < 30, 5.0, 2.0)
	        
	        if _nSkew_ < _nSkewLimit_ and _nKurt_ < _nKurtLimit_
	            return :NORMALITY
	        ok
	    ok
	    
	    return :EDA
	

	def AdaptiveAnalysis()
	    # Multi-stage intelligent analysis workflow
	    
	    ? "~> Start with basic exploration..."
	    ? "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" + NL
	    
	    # Stage 1: Always start with EDA
	    This.ExecutePlan("eda")
	    
	    # Stage 2: Check for outliers
	    if This.ContainsOutliers()
	        ? ""
	        ? "~> Outliers found, performing detailed outlier analysis..."
	        ? "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" + NL
	        This.ExecutePlan("outliers")
	    ok
	    
	    # Stage 3: If sufficient data, test normality
	    if This.Count() >= 20
	        ? ""
	        ? "~> Sufficient sample size, testing normality assumptions..."
	        ? "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" + NL
	        This.ExecutePlan("normality")
	    ok
	    
	    # Stage 4: High variability triggers quality control
	    if This.CoefficientOfVariation() > 40
	        ? ""
	        ? "~> High variability detected, running quality assessment..."
	        ? "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" + NL
	        This.ExecutePlan("quality")
	    ok
	    
	    # Stage 5: Detect trends if sequential data
	    if This.Count() >= 5
	        _aTrend_ = This.TrendAnalysis()
	        if len(_aTrend_) >= 2 or (len(_aTrend_) = 1 and _aTrend_[1][1] != "stable")
	            ? ""
	            ? "~> Trend pattern identified, analyzing temporal behavior..."
	            ? "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	            This.ExecutePlan("trends")
	        ok
	    ok
	
	    def AdaptiveAnalysisXT(bVerbose)
	        # Version with verbosity control
	        @bAdaptiveVerbose = bVerbose
	        This.AdaptiveAnalysis()

    #===============================#
    #  Plan HELPER METHODS      #
    #===============================#
    
	def _PlanNames()
		_nLen_ = len($aPlanTemplates)
		_acResult_ = []

		for i = 1 to _nLen_
			_acResult_ + $aPlanTemplates[i][1]
		next

		return _acResult_

	def _PlanTemplates()
		_nLen_ = len($aPlanTemplates)
		_acResult_ = []

		for i = 1 to _nLen_
			_acResult_ + $aPlanTemplates[i][2]
		next

		return _acResult_

	def _PlanGoals()
		_nLen_ = len($aPlanGoals)
		_acResult_ = []

		for i = 1 to _nLen_
			_acResult_ + $aPlanGoals[i][1]
		next

		return _acResult_

    def _ResolvePlanTemplate(_cInput_)
        _cInput_ = Lower(@trim(_cInput_))

		# Check if it's a Plan name
		if StzFindFirst(_cInput_, _PlanNames())
			return _cInput_
		ok

        # Check if it's a direct template key
		if StzFindFirst(_cInput_, _PlanTemplates())
			return _cInput_
		ok
        
        # Check goal mappings
		if StzFindFirst(_cInput_, _PlanGoals())
			return $aPlanGoals[_cInput_]
		ok
        
        return NULL
    
    def _FilterPlanSteps(aSteps)

        _aFiltered_ = []
        
        _nSteps1Len_ = len(aSteps)
        for _iLoopSteps1_ = 1 to _nSteps1Len_
        	_aStep_ = aSteps[_iLoopSteps1_]
            _bInclude_ = TRUE
        
            # Check if step has condition
            if HasKey(_aStep_, :condition)
                _bInclude_ = This._EvaluateCondition(_aStep_[:condition])
            ok
            
            # Check if required step
            if HasKey(_aStep_, :required) and _aStep_[:required] = TRUE
                _bInclude_ = TRUE
            ok
            
            if _bInclude_
                _aFiltered_ + _aStep_
            ok
        next

        return _aFiltered_
    
    def _ExecutePlanStep(_aStep_)
        _cFunction_ = _aStep_[:function]
        _aArgs_ = []

        if HasKey(_aStep_, :args)
            _aArgs_ = _aStep_[:args]
        ok

        # Correlation/pairwise steps need a SECOND dataset. A single-dataset
        # ExecutePlan can't supply one, so skip them gracefully instead of
        # eval-calling a 1-arg method with 0 args (R19, "too few params").
        if len(_aArgs_) = 0 and This._NeedsPairedDataset(_cFunction_)
            return "skipped (needs a second dataset)"
        ok

        # Build execution code
        _cCode_ = "_result_ = " + _cFunction_ + "("
        if len(_aArgs_) > 0
            _nArgsLen_2 = len(_aArgs_)
            for i = 1 to _nArgsLen_2
                _cCode_ += _aArgs_[i]
                if i < len(_aArgs_)
                    _cCode_ += ", "
                ok
            next
        ok
        _cCode_ += ")"
        
        eval(_cCode_)
        return _result_

    # Functions that require a second/paired dataset as an argument.
    def _NeedsPairedDataset(_cFunction_)
        _aPaired_ = [ "CorrelationWith", "RankCorrelationWith", "PartialCorrelation",
                    "CovarianceWith", "CompareWith", "CompareTo" ]
        _nLen_ = len(_aPaired_)
        for i = 1 to _nLen_
            if _cFunction_ = _aPaired_[i]
                return TRUE
            ok
        next
        return FALSE

    def _FormatStepResult(_cFunction_, _vResult_)
        switch _cFunction_
        on "DataType"
            return "Data type: " + _vResult_

        on "Count"
            return "Sample size: " + _vResult_

        on "Mean"
            return "Mean: " + @@(_vResult_)

        on "Median" 
            return "Median: " + @@(_vResult_)

        on "StandardDeviation"
            return "Std Dev: " + @@(_vResult_)

        on "ContainsOutliers"
            return "Outliers present: " + _vResult_

        on "NormalityTest"
            return "Normality p-value: " + @@(_vResult_[2])

        on "TrendAnalysis"
            # TrendAnalysis returns a list of [trend, length] segments;
            # "string + list" raises R21, so summarise the segment count.
            if isList(_vResult_)
                return "Trend: " + len(_vResult_) + " segment(s)"
            ok
            return "Trend: " + @@(_vResult_)

        other

            if isNumber(_vResult_)
                return _cFunction_ + ": " + @@(_vResult_)

            but isString(_vResult_)
                return _cFunction_ + ": " + _vResult_

            but isList(_vResult_)
                return _cFunction_ + ": " + len(_vResult_) + " value(s)"

            else
                return _cFunction_ + ": completed"
            ok

        off
    
    def _FormatArgs(_aArgs_)
        _cResult_ = ""
        _nArgsLen_ = len(_aArgs_)
        for i = 1 to _nArgsLen_
            _cResult_ += _aArgs_[i]
            if i < len(_aArgs_)
                _cResult_ += ", "
            ok
        next
        return _cResult_


	#=======================#
	#  SIMPLE CACHE SYSTEM  #
	#=======================#

	def _InitializeCache()
	    @aCache = []

	def _InitEngine()
	    if @cDataType = "numeric" and len(@anData) > 0
	        @pEngineStats = StzEngineStatsCreate(@anData)
	    ok

	def _EngineAvailable()
	    return @pEngineStats != NULL

	def _EngineHandle()
	    return @pEngineStats
	
	def _GetCached(_cKey_)
	    return @aCache[_cKey_]

	def _CacheKeys()
		_nLen_ = len(@aCache)
		_acKeys_ = []

		for i = 1 to _nLen_
			_acKeys_ = @aCache[i]
		next

		return _acKeys_

	def _KeyIsCached(_cKey_)

		if NOT (isString(_cKey_) and @trim(_cKey_) != "")
			StzRaise("Incorrect param type! cKey must be a non empty string.")
		ok

		if StzFindFirst(StzLower(_cKey_), This._CacheKeys())
			return TRUE
		else
			return FALSE
		ok

	def _RemoveFromCache(_cKey_)

		if NOT isString(_cKey_)
			StzRaise("Incorrect param type! cKey must be a non empty string.")
		ok

		if @trim(_cKey_) = ""
			return
		ok

		_n_ = StzFindFirst(StzLower(_cKey_), This._CacheKeys())
		if _n_ > 0
			del(@aCache, _n_)
		ok

	def _SetCache(_cKey_, value)
	    
	    # Remove existing key if present
		_RemoveFromCache(_cKey_)
	    
	    # Add new cache entry
	    @aCache + [_cKey_, value]
	
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
        _oExport_ = new stzHashList([])
        _aExport_ = []

        _aExport_ + ["data_type", @cDataType]
        _aExport_ + ["count", This.Count()]
        _aExport_ + ["unique_count", This.UniqueCount()]
        
        if @cDataType = "numeric"
            _aExport_ + ["mean", This.Mean()]
            _aExport_ + ["median", This.Median()]
            _aExport_ + ["mode", This.Mode()]
            _aExport_ + ["standard_deviation", This.StandardDeviation()]
            _aExport_ + ["variance", This.Variance()]
            _aExport_ + ["range", This.Range()]
            _aExport_ + ["min", This.Min()]
            _aExport_ + ["max", This.Max()]
            _aExport_ + ["quartiles", This.Quartiles()]
            _aExport_ + ["skewness", This.Skewness()]
            _aExport_ + ["kurtosis", This.Kurtosis()]
            _aExport_ + ["outliers", This.Outliers()]

        else
            _aExport_ + ["mode", This.Mode()]
            _aExport_ + ["diversity", This.Diversity()]
            _aExport_ + ["entropy", This.EntropyIndex()]
            _aExport_ + ["frequency_table", This.FrequencyTable()]

        ok
        
        return _aExport_


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
