load "../max/stzmax.ring"

#-----------------------------------#
#  TEST FILE OF THE stzStats CLASS  #
#-----------------------------------#

/*
#NOTE: The stzStats class provides solid statistical functionality across four main areas:

- Descriptive Statistics: Mean, median, mode, standard deviation, variance, range
- Distribution Analysis: Quartiles, percentiles, outlier detection  
- Frequency Analysis: Frequency tables, relative/percentage frequencies
- Data Quality: Normalization, standardization, completeness metrics

Key Features Tested in this file:
- Automatic data type detection (numeric/categorical/mixed)
- Robust handling of edge cases (empty data, single values, mixed types)
- Outlier detection using IQR method
- Data quality metrics including completeness and diversity
- Normalization (0-1 scale) and standardization (z-scores)

The test samples cover typical analytics scenarios you'd encounter in the Softanza Charting System, from basic descriptive stats to advanced distribution analysis and data quality assessment.
*/

/*--- Basic numeric data analysis with common statistical measures
*/
pr()

oStats = new stzStats([10, 15, 20, 25, 30, 35, 40])
oStats {
        # Mean: Average value of the dataset, calculated as sum of values divided by count
        ? Mean()
        #--> 25

        # Median: Middle value when data is ordered, splitting dataset into two equal parts
        ? Median() 
        #--> 25

        # Standard Deviation: Measures spread of data around the mean (in same units as data)
        ? StandardDeviation()
        #--> 10.80

        # Range: Difference between maximum and minimum values, showing data spread
        ? Range()
        #--> 30

        # Sum: Total of all values in the dataset
        ? Sum()
        #--> 175

		? Insight()
}

pf()
# Executed in almost 0 second(s) in Ring 1.22

# Insight: The data is symmetrically distributed (mean = median = 25) with moderate spread (standard deviation 10.80) and a range of 30, indicating a balanced dataset with values evenly spaced from 10 to 40.

/*--- Quartile analysis for distribution understanding

pr()

oStats = new stzStats([1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50])
oStats {
        # Q1 (First Quartile): Value below which 25% of data lies
        ? Q1()
        #--> 8.75

        # Q2 (Second Quartile): Same as median, 50% of data lies below this
        ? Q2()
        #--> 25

        # Q3 (Third Quartile): Value below which 75% of data lies
        ? Q3()
        #--> 36.25

        # IQR (Interquartile Range): Q3 - Q1, measures middle 50% spread
        ? IQR()
        #--> 27.50

        # Quartiles: Array of Q1, Q2, Q3 for distribution summary
        ? @@( Quartiles() )
        #--> [ 8.75, 25, 36.25 ]
}

pf()
# Executed in almost 0 second(s) in Ring 1.22

# Insight: The data has a wide spread (IQR = 27.50) with a median of 25, showing a balanced distribution. The quartiles (8.75, 25, 36.25) indicate that the middle 50% of values are spread between 8.75 and 36.25, suggesting moderate variability.

/*--- Outlier detection for data quality assessment

pr()

oStats = new stzStats([10, 12, 13, 15, 18, 20, 22, 25, 100])
oStats {
        # Outliers: Values outside 1.5 * IQR from Q1 or Q3, indicating unusual data points
        ? @@( FindOutliers() )
        #--> [100]

        # IsOutlier: Checks if a value is an outlier based on IQR method
        ? IsOutlier(100)
        #--> TRUE

        ? IsOutlier(15)
        #--> FALSE

        # Mean: Sensitive to outliers, pulled toward extreme values
        ? Mean()
        #--> 26.11

        # Median: Robust to outliers, better represents central tendency here
        ? Median()
        #--> 18
}

pf()
# Executed in almost 0 second(s) in Ring 1.22

# Insight: The dataset is heavily skewed by an outlier (100), inflating the mean (26.11) far above the median (18). Most values cluster tightly between 10 and 25, indicating the outlier significantly distorts the average.

/*--- Categorical data frequency analysis

pr()

oStats = new stzStats(["Red", "Blue", "Red", "Green", "Blue", "Red", "Yellow"])
oStats {
        # Mode: Most frequent value in the dataset
        ? Mode()
        #--> "Red"

        # Frequency Table: Counts occurrences of each unique value
        ? @@(FrequencyTable() )
        #--> [["Red", 3], ["Blue", 2], ["Green", 1], ["Yellow", 1]]

        # Percentage Frequency: Frequency as percentage of total count
        ? @@(PercentageFrequency())
        #--> [["Red", 42.86], ["Blue", 28.57], ["Green", 14.29], ["Yellow", 14.29]]

        # Unique Count: Number of distinct values in the dataset
        ? UniqueCount()
        #--> 4

        # Diversity: Measure of variety, calculated as ratio of unique values to total count
        ? Diversity()
        #--> 0.57
}

pf()
# Executed in 0.03 second(s) in Ring 1.22

# Insight: "Red" dominates the dataset (42.86% frequency), indicating a strong preference or occurrence. Moderate diversity (0.57) shows a mix of categories, but the distribution is uneven with "Red" and "Blue" being most common.

/*--- Data normalization and standardization for comparison

pr()

oStats = new stzStats([100, 200, 300, 400, 500])
oStats {
        # Normalize: Scales data to 0-1 range using (x - min) / (max - min)
        ? @@( Normalize() )
        #--> [0, 0.25, 0.5, 0.75, 1]

        # Standardize: Transforms data to have mean 0 and standard deviation 1 (z-scores)
        ? @@( Standardize() )
        #--> [-1.26, -0.63, 0, 0.63, 1.26]

        # Mean: Central value of the dataset
        ? Mean()
        #--> 300

        # Standard Deviation: Measure of data dispersion
        ? StandardDeviation()
        #--> 158.11
}

pf()
# Executed in almost 0 second(s) in Ring 1.22

# Insight: The data is evenly spaced (100 to 500) with a mean of 300 and high variability (standard deviation 158.11). Normalized values show a linear progression, and standardized z-scores confirm a symmetric distribution around the mean.

/*--- Data quality metrics for completeness assessment

pr()

oStats = new stzStats([10, 0, 20, NULL, 30, "", 40, 50])
oStats {
        # Count: Total number of values (including missing ones)
        ? Count()
        #--> 8

        # Missing Count: Number of NULL or empty values
        ? MissingCount()
        #--> 2

        # Completeness: Percentage of non-missing values
        ? Completeness()
        #--> 75

        # Unique Count: Number of distinct non-missing values
        ? UniqueCount()
        #--> 6

        # Diversity: Ratio of unique values to total non-missing count
        ? Diversity()
        #--> 0.75
}

pf()
# Executed in 0.01 second(s) in Ring 1.22

# Insight: The dataset has significant missing data (37.5% incomplete), reducing reliability. High diversity (0.75) among non-missing values suggests varied data, but the presence of NULL and empty entries requires attention for analysis.

/*--- Percentile analysis for detailed distribution insights

pr()

oStats = new stzStats([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
oStats {
        # Percentile: Value below which a given percentage of data lies
        ? Percentile(10)
        #--> 1

        ? Percentile(50)
        #--> 5

        ? Percentile(90)
        #--> 9

        ? Percentile(95)
        #--> 10

        # Median: Middle value, same as 50th percentile
        ? Median()
        #--> 5.5
}

pf()
# Executed in almost 0 second(s) in Ring 1.22

# Insight: The data is uniformly distributed from 1 to 10, with percentiles aligning closely with values (e.g., 50th percentile = 5, 90th = 9). The median (5.5) confirms a balanced, evenly spaced dataset.

/*--- Mixed data type handling and edge cases

pr()

oStats = new stzStats([1, "text", 3, 4, "another"])
oStats {
        # Mode: Most frequent value, treats numbers as strings in mixed data
        ? Mode()
        #--> 1

        # Count: Total number of values
        ? Count()
        #--> 5

        # Unique Count: Number of distinct values
        ? UniqueCount()
        #--> 5

        # Mean: Returns 0 for mixed data as non-numeric values are ignored
        ? Mean()
        #--> 0

        # Standard Deviation: Returns 0 when mean is 0 or data is non-numeric
        ? StandardDeviation()
        #--> 0
}

pf()
# Executed in 0.01 second(s) in Ring 1.22

# Insight: The mixed dataset (numeric and text) has no repeated values (unique count = 5), preventing meaningful numeric analysis (mean, standard deviation = 0). The mode ("1") suggests string-based processing dominates.

/*--- Empty dataset handling

pr()

oStats = new stzStats([])
oStats {
        # Count: Returns 0 for empty dataset
        ? Count()
        #--> 0

        # Mean: Returns 0 for empty dataset
        ? Mean()
        #--> 0

        # Median: Returns 0 for empty dataset
        ? Median()
        #--> 0

        # Mode: Returns NULL for empty dataset
        ? @@(Mode())
        #--> NULL

        # Completeness: Returns 0 for empty dataset
        ? Completeness()
        #--> 0
}

pf()
# Executed in almost 0 second(s) in Ring 1.22

# Insight: The empty dataset provides no actionable information, with all metrics (mean, median, mode, completeness) returning null or zero, indicating a need for data collection before analysis.

/*--- Single value dataset analysis

pr()

oStats = new stzStats([42])
oStats {
        # Mean: Equals the single value
        ? Mean()
        #--> 42

        # Median: Equals the single value
        ? Median()
        #--> 42

        # Mode: Equals the single value
        ? Mode()
        #--> 42

        # Standard Deviation: 0 as there's no variation
        ? StandardDeviation()
        #--> 0

        # Range: 0 as there's only one value
        ? Range()
        #--> 0
}

pf()
# Executed in almost 0 second(s) in Ring 1.22

# Insight: The single-value dataset (42) has no variability (standard deviation, range = 0), with all central tendency measures (mean, median, mode) equal, offering limited analytical insight.

/*--- Large dataset with repeated values for mode detection

pr()

oStats = new stzStats([1, 1, 1, 2, 2, 3, 3, 3, 3, 4, 5])
oStats {
        # Mode: Value with the highest frequency
        ? Mode()
        #--> 3

        # Frequency Table: Counts occurrences of each unique value
        ? @@( FrequencyTable() )
        #--> [["1", 3], ["2", 2], ["3", 4], ["4", 1], ["5", 1]]

        # Mean: Average of all values
        ? Mean()
        #--> 2.55

        # Variance: Average of squared deviations from the mean, measures dispersion
        ? Variance()
        #--> 1.67
}

pf()
# Executed in 0.02 second(s) in Ring 1.22

# Insight: The dataset is skewed toward lower values, with "3" being the most frequent (mode, 4 occurrences). Low mean (2.45) and variance (1.67) indicate a compact distribution with moderate variability.
