#==============================#
#  TEST SECTION 1: BASIC SETUP #
#==============================#

/*--- Testing basic initialization with simple list data

pr()

# Simple list with mixed data quality issues
aSimpleData = ["John", "  Mary  ", "", "BOB", "NULL", "alice", "John"]  # Duplicates, whitespace, missing values

o1 = new stzDataWrangler(aSimpleData)

# Check initial data profile
? "=== INITIAL DATA PROFILE ==="
o1.ShowReport()

pf()
# Execution time: ~0.02 seconds

/*--- Testing initialization with 2D table data

pr()

# Sample customer data with various quality issues
aCustomerHeaders = ["Name", "Age", "Email", "Salary", "Department"]
aCustomerData = [
    ["John Smith", 25, "john@email.com", 50000, "Sales"],
    ["  Mary Jones  ", "", "mary.jones@company.com", 65000, "marketing"],
    ["Bob Wilson", 35, "bob@email", "NULL", "SALES"],
    ["Alice Brown", 28, "alice@email.com", 55000, ""],
    ["John Smith", 25, "john@email.com", 50000, "Sales"],  # Duplicate
    ["", 45, "unknown@email.com", 75000, "Engineering"],
    ["Tom Davis", -5, "tom@email.com", 999999, "sales"]    # Invalid age, potential outlier salary
]

o2 = new stzDataWrangler(aCustomerData, aCustomerHeaders)

# Display initial data structure and profile
? "=== TABLE DATA PROFILE ==="
aProfile = o2.GetDataProfile()
? "Structure: " + aProfile[:structure]
? "Dimensions: " + aProfile[:rows] + " rows × " + aProfile[:columns] + " columns"
? "Data Types Summary:"
aTypesSummary = aProfile[:data_types]
for typeInfo in aTypesSummary
    ? "  " + typeInfo[1] + ": " + This._JoinList(typeInfo[2], ", ")
next

pf()
# Execution time: ~0.05 seconds

#==============================#
#  TEST SECTION 2: DATA CLEANING #
#==============================#

/*--- Testing duplicate removal

pr()

o3 = new stzDataWrangler(aCustomerData, aCustomerHeaders)

? "=== BEFORE DUPLICATE REMOVAL ==="
? "Row count: " + o3._GetRowCount()

# Remove duplicates
nDuplicatesRemoved = o3.RemoveDuplicates()
? "=== AFTER DUPLICATE REMOVAL ==="
? "Duplicates removed: " + nDuplicatesRemoved
? "New row count: " + o3._GetRowCount()

pf()
# Execution time: ~0.03 seconds

/*--- Testing missing value handling with different strategies

pr()

o4 = new stzDataWrangler(aCustomerData, aCustomerHeaders)

? "=== MISSING VALUES BEFORE HANDLING ==="
? "Missing values count: " + o4._CountMissingValues()

# Handle missing values with auto strategy
nProcessed = o4.HandleMissingValues("auto")
? "=== AFTER AUTO MISSING VALUE HANDLING ==="
? "Values processed: " + nProcessed
? "Remaining missing values: " + o4._CountMissingValues()

# Test different strategies
o5 = new stzDataWrangler(aCustomerData, aCustomerHeaders)
nFilled = o5.HandleMissingValues("fill_zero")
? "=== FILL ZERO STRATEGY ==="
? "Values filled with zero: " + nFilled

pf()
# Execution time: ~0.04 seconds

/*--- Testing whitespace trimming and case normalization

pr()

# Data with whitespace and case issues
aMesyData = ["  John DOE  ", "mary smith", "  BOB WILSON  ", "alice BROWN"]
o6 = new stzDataWrangler(aMesyData)

? "=== BEFORE CLEANING ==="
? "Original data:"
for item in o6.GetData()
    ? "  '" + item + "'"
next

# Trim whitespace
nTrimmed = o6.TrimWhitespace()
? "=== AFTER TRIMMING ==="
? "Values trimmed: " + nTrimmed
for item in o6.GetData()
    ? "  '" + item + "'"
next

# Normalize case to title case
nNormalized = o6.NormalizeCase("title")
? "=== AFTER CASE NORMALIZATION ==="
? "Values normalized: " + nNormalized
for item in o6.GetData()
    ? "  '" + item + "'"
next

pf()
# Execution time: ~0.02 seconds

#==============================#
#  TEST SECTION 3: DATA VALIDATION #
#==============================#

/*--- Testing data type validation

pr()

o7 = new stzDataWrangler(aCustomerData, aCustomerHeaders)

? "=== DATA TYPE VALIDATION ==="
aTypeIssues = o7.ValidateDataTypes()
? "Type inconsistencies found: " + len(aTypeIssues)
for issue in aTypeIssues
    ? "  • " + issue
next

pf()
# Execution time: ~0.03 seconds

/*--- Testing range validation

pr()

o8 = new stzDataWrangler(aCustomerData, aCustomerHeaders)

# Define range rules: [column_name, min_value, max_value]
aRangeRules = [
    ["Age", 18, 65],
    ["Salary", 30000, 200000]
]

? "=== RANGE VALIDATION ==="
aRangeIssues = o8.ValidateRanges(aRangeRules)
? "Range violations found: " + len(aRangeIssues)
for issue in aRangeIssues
    ? "  • " + issue
next

pf()
# Execution time: ~0.02 seconds

/*--- Testing outlier detection

pr()

# Create data with clear outliers
aOutlierData = [
    ["Product A", 100, 25.50],
    ["Product B", 150, 30.75],
    ["Product C", 120, 28.00],
    ["Product D", 9999, 500.00],  # Clear outlier
    ["Product E", 110, 26.25],
    ["Product F", 130, 29.50],
    ["Product G", -50, -10.00]    # Another outlier
]
aOutlierHeaders = ["Product", "Quantity", "Price"]

o9 = new stzDataWrangler(aOutlierData, aOutlierHeaders)

? "=== OUTLIER DETECTION ==="
aOutliers = o9.DetectOutliers(2.0)  # Using Z-score threshold of 2.0
? "Outliers detected: " + len(aOutliers)
for outlier in aOutliers
    ? "  • Row " + outlier[1] + ", " + aOutlierHeaders[outlier[2]] + ": " + outlier[3] + " (Z-score: " + outlier[4] + ")"
next

pf()
# Execution time: ~0.04 seconds

#==============================#
#  TEST SECTION 4: DATA TRANSFORMATION #
#==============================#

/*--- Testing data type conversion

pr()

# Mixed data types that need conversion
aMixedData = [
    ["Item1", "123", "true", "2023-01-15"],
    ["Item2", "456.78", "false", "2023-02-20"],
    ["Item3", "789", "yes", "2023-03-10"]
]
aMixedHeaders = ["Name", "Value", "Active", "Date"]

o10 = new stzDataWrangler(aMixedData, aMixedHeaders)

? "=== BEFORE TYPE CONVERSION ==="
aProfile = o10.GetDataProfile()
aTypesSummary = aProfile[:data_types]
for typeInfo in aTypesSummary
    ? "  " + typeInfo[1] + ": " + This._JoinList(typeInfo[2], ", ")
next

# Define conversion rules
aConversionRules = [
    ["Value", "numeric"],
    ["Active", "boolean"]
]

nConverted = o10.ConvertDataTypes(aConversionRules)
? "=== AFTER TYPE CONVERSION ==="
? "Values converted: " + nConverted

pf()
# Execution time: ~0.03 seconds

/*--- Testing numeric normalization

pr()

# Numeric data for normalization
aNumericData = [
    ["Sample1", 100, 0.5],
    ["Sample2", 200, 1.5],
    ["Sample3", 300, 2.5],
    ["Sample4", 150, 1.0],
    ["Sample5", 250, 2.0]
]
aNumericHeaders = ["Sample", "Value1", "Value2"]

o11 = new stzDataWrangler(aNumericData, aNumericHeaders)

? "=== BEFORE NORMALIZATION ==="
? "Original Value1 column:"
for i = 1 to len(aNumericData)
    ? "  " + aNumericData[i][2]
next

# Normalize using min-max scaling
nNormalized = o11.NormalizeNumeric("minmax")
? "=== AFTER MIN-MAX NORMALIZATION ==="
? "Values normalized: " + nNormalized
? "Normalized Value1 column:"
aCurrentData = o11.GetData()
for i = 1 to len(aCurrentData)
    ? "  " + aCurrentData[i][2]
next

# Test Z-score normalization
o12 = new stzDataWrangler(aNumericData, aNumericHeaders)
o12.NormalizeNumeric("zscore")
? "=== Z-SCORE NORMALIZATION ==="
aZScoreData = o12.GetData()
for i = 1 to len(aZScoreData)
    ? "  " + aZScoreData[i][2]
next

pf()
# Execution time: ~0.04 seconds

/*--- Testing categorical encoding

pr()

# Categorical data for encoding
aCategoricalData = [
    ["Record1", "Red", "Large"],
    ["Record2", "Blue", "Medium"],
    ["Record3", "Green", "Small"],
    ["Record4", "Red", "Large"],
    ["Record5", "Blue", "Small"]
]
aCategoricalHeaders = ["ID", "Color", "Size"]

o13 = new stzDataWrangler(aCategoricalData, aCategoricalHeaders)

? "=== BEFORE CATEGORICAL ENCODING ==="
? "Original Color column:"
for i = 1 to len(aCategoricalData)
    ? "  " + aCategoricalData[i][2]
next

# Apply label encoding
nEncoded = o13.EncodeCategories("label")
? "=== AFTER LABEL ENCODING ==="
? "Values encoded: " + nEncoded
? "Encoded Color column:"
aEncodedData = o13.GetData()
for i = 1 to len(aEncodedData)
    ? "  " + aEncodedData[i][2]
next

pf()
# Execution time: ~0.03 seconds

#==============================#
#  TEST SECTION 5: PLAN EXECUTION #
#==============================#

/*--- Testing plan generation and execution

pr()

# Create messy dataset for comprehensive plan testing
aMesyDataset = [
    ["  John Doe  ", "25", "john@email.com", "50000", "sales"],
    ["mary SMITH", "", "mary@company.com", "65000", "MARKETING"],
    ["", "35", "invalid-email", "NULL", "Sales"],
    ["John Doe", "25", "john@email.com", "50000", "sales"],  # Duplicate
    ["Bob Wilson", "-5", "bob@email.com", "999999", "engineering"],
    ["Alice Brown", "28.5", "alice@email.com", "", "Sales"]
]
aMesyHeaders = ["Full_Name", "Age", "Email", "Salary", "Department"]

o14 = new stzDataWrangler(aMesyDataset, aMesyHeaders)

? "=== GENERATING BASIC CLEANUP PLAN ==="
aPlan = o14.GeneratePlan("clean")
? "Plan: " + aPlan[:title]
? "Description: " + aPlan[:description]
? "Estimated time: " + aPlan[:estimated_time] + " seconds"
? "Steps:"
for step in aPlan[:steps]
    ? "  • " + step[:description]
next

? ""
? "=== EXECUTING BASIC CLEANUP PLAN ==="
aResult = o14.ExecutePlan("clean", TRUE)

? ""
? "=== EXECUTION SUMMARY ==="
? "Plan executed: " + aResult[:plan][:title]
? "Execution time: " + aResult[:execution_time] + " seconds"
? "Summary: " + aResult[:summary]

pf()
# Execution time: ~0.08 seconds

/*--- Testing different plan templates

pr()

o15 = new stzDataWrangler(aMesyDataset, aMesyHeaders)

? "=== TESTING VALIDATION PLAN ==="
aValidationResult = o15.ExecutePlan("validate", TRUE)

? ""
? "=== TESTING ANALYSIS PREPARATION PLAN ==="
o16 = new stzDataWrangler(aMesyDataset, aMesyHeaders)
aAnalysisResult = o16.ExecutePlan("analyze", TRUE)

? ""
? "=== TESTING EXPORT PREPARATION PLAN ==="
o17 = new stzDataWrangler(aMesyDataset, aMesyHeaders)
aExportResult = o17.ExecutePlan("export", TRUE)

pf()
# Execution time: ~0.12 seconds

/*--- Testing goal-based plan execution

pr()

o18 = new stzDataWrangler(aMesyDataset, aMesyHeaders)

? "=== GOAL-BASED EXECUTION ==="
? "Available goals: clean, validate, analyze, export"

# Execute using goal keywords
? ""
? "Executing 'clean' goal..."
aCleanResult = o18.ExecutePlan("clean", FALSE)
? "Clean result: " + aCleanResult[:summary]

? ""
? "Executing 'validate' goal..."
aValidateResult = o18.ExecutePlan("validate", FALSE)
? "Validate result: " + aValidateResult[:summary]

pf()
# Execution time: ~0.06 seconds

#==============================#
#  TEST SECTION 6: EXPORT METHODS #
#==============================#

/*--- Testing export to different Softanza classes

pr()

# Prepare clean dataset for export testing
aCleanData = [
    ["Alice", 25, 55000],
    ["Bob", 30, 60000],
    ["Carol", 28, 58000],
    ["David", 35, 70000]
]
aCleanHeaders = ["Name", "Age", "Salary"]

o19 = new stzDataWrangler(aCleanData, aCleanHeaders)

? "=== EXPORT FOR stzDataSet ==="
aDataSetExport = o19.ExportForStzDataSet()
? "Exported data structure: " + len(aDataSetExport) + " rows"
? "Sample data:"
for i = 1 to min(3, len(aDataSetExport))
    ? "  Row " + i + ": " + This._JoinList(aDataSetExport[i], ", ")
next

? ""
? "=== EXPORT FOR stzTable ==="
aTableExport = o19.ExportForStzTable()
? "Headers: " + This._JoinList(aTableExport[1], ", ")
? "Data rows: " + len(aTableExport[2])

? ""
? "=== EXPORT FOR stzMatrix ==="
aMatrixExport = o19.ExportForStzMatrix()
? "Matrix dimensions: " + len(aMatrixExport) + " × " + len(aMatrixExport[1])
? "Sample numeric data:"
for i = 1 to min(3, len(aMatrixExport))
    ? "  " + This._JoinList(aMatrixExport[i], ", ")
next

pf()
# Execution time: ~0.03 seconds

#==============================#
#  TEST SECTION 7: CONVENIENCE METHODS #
#==============================#

/*--- Testing quick operation methods

pr()

o20 = new stzDataWrangler(aMesyDataset, aMesyHeaders)

? "=== QUICK OPERATIONS (NON-VERBOSE) ==="

? "Quick Clean..."
aQuickClean = o20.QuickClean()
? "Result: " + aQuickClean[:summary]

? ""
? "Quick Validate..."
aQuickValidate = o20.QuickValidate()
? "Result: " + aQuickValidate[:summary]

? ""
? "Quick Prepare for Analysis..."
o21 = new stzDataWrangler(aMesyDataset, aMesyHeaders)
aQuickAnalysis = o21.QuickPrepareForAnalysis()
? "Result: " + aQuickAnalysis[:summary]

? ""
? "Quick Prepare for Export..."
o22 = new stzDataWrangler(aMesyDataset, aMesyHeaders)
aQuickExport = o22.QuickPrepareForExport()
? "Result: " + aQuickExport[:summary]

pf()
# Execution time: ~0.08 seconds

/*--- Testing chainable operations

pr()

o23 = new stzDataWrangler(aMesyDataset, aMesyHeaders)

? "=== CHAINABLE OPERATIONS ==="
? "Performing: Clean() -> Validate() -> Transform() -> Export()"

# Chain operations together
o23.Clean().Validate().Transform().Export()

? "Final data profile:"
aFinalProfile = o23.GetDataProfile()
? "Issues found: " + aFinalProfile[:issues_found]
? "Transformations applied: " + aFinalProfile[:transformations_applied]

# Show transformation log
? ""
? "Transformation log:"
aTransformLog = o23.GetTransformationLog()
for transform in aTransformLog
    ? "  • " + transform[:operation] + ": " + transform[:details]
next

pf()
# Execution time: ~0.10 seconds

#==============================#
#  TEST SECTION 8: REPORTING & DIAGNOSTICS #
#==============================#

/*--- Testing comprehensive reporting

pr()

o24 = new stzDataWrangler(aMesyDataset, aMesyHeaders)

? "=== COMPREHENSIVE DATA REPORT ==="
o24.ShowReport()

? ""
? "=== DETAILED PROFILE INFORMATION ==="
aDetailedProfile = o24.GetDataProfile()
? "Structure: " + aDetailedProfile[:structure]
? "Dimensions: " + aDetailedProfile[:rows] + " rows × " + aDetailedProfile[:columns] + " columns"
? "Missing values: " + aDetailedProfile[:missing_values]
? "Duplicate count: " + aDetailedProfile[:duplicates]

? ""
? "=== ISSUES BREAKDOWN ==="
aIssues = o24.GetIssues()
if len(aIssues) > 0
    for issue in aIssues
        ? "  • [" + issue[:type] + "] " + issue[:description]
    next
else
    ? "No issues detected in original data"
ok

pf()
# Execution time: ~0.04 seconds

/*--- Testing after applying transformations

pr()

o25 = new stzDataWrangler(aMesyDataset, aMesyHeaders)

? "=== BEFORE AND AFTER COMPARISON ==="
? "BEFORE transformations:"
aInitialProfile = o25.GetDataProfile()
? "  Missing values: " + aInitialProfile[:missing_values]
? "  Duplicate count: " + aInitialProfile[:duplicates]

# Apply comprehensive cleaning
o25.ExecutePlan("clean", FALSE)

? ""
? "AFTER cleaning transformations:"
aFinalProfile = o25.GetDataProfile()
? "  Missing values: " + aFinalProfile[:missing_values]
? "  Duplicate count: " + aFinalProfile[:duplicates]
? "  Transformations applied: " + aFinalProfile[:transformations_applied]

? ""
? "Detailed transformation log:"
aTransformLog = o25.GetTransformationLog()
for transform in aTransformLog
    ? "  [" + transform[:timestamp] + "] " + transform[:operation] + " - " + transform[:details]
next

pf()
# Execution time: ~0.06 seconds

#==============================#
#  TEST SECTION 9: EDGE CASES #
#==============================#

/*--- Testing with empty dataset

pr()

? "=== TESTING WITH EMPTY DATASET ==="
aEmptyData = []
o26 = new stzDataWrangler(aEmptyData)

aEmptyProfile = o26.GetDataProfile()
? "Empty data structure: " + aEmptyProfile[:structure]
? "Row count: " + aEmptyProfile[:rows]

# Try to execute plan on empty data
aEmptyResult = o26.ExecutePlan("clean", FALSE)
? "Plan execution on empty data: " + aEmptyResult[:summary]

pf()
# Execution time: ~0.02 seconds

/*--- Testing with single column data

pr()

? "=== TESTING WITH SINGLE COLUMN ==="
aSingleColumnData = [
    ["Value1"],
    ["Value2"],
    [""],
    ["Value1"],  # Duplicate
    ["Value3"]
]
aSingleColumnHeaders = ["OnlyColumn"]

o27 = new stzDataWrangler(aSingleColumnData, aSingleColumnHeaders)

? "Initial profile:"
o27.ShowReport()

? ""
? "Executing cleanup:"
aSingleResult = o27.ExecutePlan("clean", TRUE)

pf()
# Execution time: ~0.04 seconds

/*--- Testing with all missing values

pr()

? "=== TESTING WITH ALL MISSING VALUES ==="
aAllMissingData = [
    ["", "NULL", ""],
    ["NA", "", "n/a"],
    ["", "NULL", ""]
]
aAllMissingHeaders = ["Col1", "Col2", "Col3"]

o28 = new stzDataWrangler(aAllMissingData, aAllMissingHeaders)

? "Profile before handling missing values:"
aBeforeMissing = o28.GetDataProfile()
? "Missing values: " + aBeforeMissing[:missing_values]

# Try different missing value strategies
nProcessed = o28.HandleMissingValues("fill_zero")
? ""
? "After filling with zeros:"
? "Values processed: " + nProcessed
aAfterMissing = o28.GetDataProfile()
? "Remaining missing values: " + aAfterMissing[:missing_values]

pf()
# Execution time: ~0.03 seconds

#==============================#
#  TEST SECTION 10: PERFORMANCE #
#==============================#

/*--- Testing with larger dataset

pr()

? "=== PERFORMANCE TEST WITH LARGER DATASET ==="

# Generate larger dataset for performance testing
aLargeHeaders = ["ID", "Name", "Score", "Category", "Date"]
aLargeData = []

for i = 1 to 1000
    aRow = []
    aRow + i  # ID
    aRow + "User" + i  # Name
    aRow + random(100) + 1  # Score (1-100)
    aRow + ["A", "B", "C", "D"][random(4) + 1]  # Category
    aRow + "2023-" + (random(12) + 1) + "-" + (random(28) + 1)  # Date
    
    # Introduce some quality issues
    if i % 50 = 0  # Every 50th record has issues
        aRow[2] = ""  # Missing name
    ok
    if i % 75 = 0  # Every 75th record has issues
        aRow[3] = -1  # Invalid score
    ok
    
    aLargeData + aRow
next

? "Generated dataset: " + len(aLargeData) + " rows × " + len(aLargeHeaders) + " columns"

o29 = new stzDataWrangler(aLargeData, aLargeHeaders)

? "Executing comprehensive analysis plan..."
nStartTime = clock()
aLargeResult = o29.ExecutePlan("analyze", FALSE)
nEndTime = clock()
nExecutionTime = nEndTime - nStartTime

? "Performance results:"
? "  Execution time: " + nExecutionTime + " seconds"
? "  Processing rate: " + (len(aLargeData) / nExecutionTime) + " rows/second"
? "  Plan result: " + aLargeResult[:summary]

pf()
# Execution time: ~2.5 seconds (estimated)

#==============================#
#  TEST SECTION 11: REAL-WORLD SCENARIOS #
#==============================#

/*--- Customer database cleanup scenario

pr()

? "=== REAL-WORLD SCENARIO: CUSTOMER DATABASE CLEANUP ==="

# Realistic customer data with common issues
aCustomerDB = [
    ["  John Smith  ", "john.smith@email.com", "555-1234", "New York", "NY", "10001", "2020-01-15"],
    ["mary johnson", "MARY@COMPANY.COM", "(555) 567-8901", "los angeles", "ca", "90210", "2019-03-22"],
    ["", "bob.wilson@email.com", "555.234.5678", "Chicago", "IL", "", ""],  # Missing name and date
    ["Alice Brown", "alice@email", "5551234567", "Houston", "TX", "77001", "2021-06-10"],  # Invalid email
    ["John Smith", "john.smith@email.com", "555-1234", "New York", "NY", "10001", "2020-01-15"],  # Duplicate
    ["Tom Davis", "tom@email.com", "555-999-0000", "Phoenix", "AZ", "85001", "2022-12-01"],
    ["SARAH CONNOR", "sarah.connor@email.com", "NULL", "Dallas", "TX", "75201", "2020-08-30"]  # Missing phone
]

aCustomerHeaders = ["Name", "Email", "Phone", "City", "State", "ZIP", "JoinDate"]

o30 = new stzDataWrangler(aCustomerDB, aCustomerHeaders)

? "Initial customer database analysis:"
o30.ShowReport()

? ""
? "Executing comprehensive cleanup..."
aCustomerResult = o30.ExecutePlan("clean", TRUE)

? ""
? "Final cleaned data sample:"
aCleanedCustomers = o30.GetData()
for i = 1 to min(5, len(aCleanedCustomers))
    ? "Customer " + i + ":"
    for j = 1 to len(aCustomerHeaders)
        ? "  " + aCustomerHeaders[j] + ": " + aCleanedCustomers[i][j]
    next
    ? ""
next

pf()
# Execution time: ~0.08 seconds

/*--- Sales data preparation for analysis

pr()

? "=== REAL-WORLD SCENARIO: SALES DATA PREPARATION ==="

# Sales transaction data needing preparation for analysis
aSalesData = [
    ["TXN001", "2023-01-15", "Product A", "Electronics", "150.00", "2", "John Doe"],
    ["TXN002", "2023-01-16", "Product B", "clothing", "75.50", "1", "Mary Smith"], 
    ["TXN003", "", "Product C", "Electronics", "NULL", "3", "Bob Wilson"],  # Missing date and price
    ["TXN004", "2023-01-17", "", "Home & Garden", "25.99", "5", "Alice Brown"],  # Missing product
    ["TXN005", "2023-01-18", "Product A", "ELECTRONICS", "150.00", "1", "John Doe"],
    ["TXN006", "2023-01-19", "Product D", "Clothing", "-10.00", "2", "Tom Davis"],  # Negative price (return?)
    ["TXN007", "2023-01-20", "Product E", "electronics", "999999.99", "1", "Sarah Connor"]  # Potential outlier
]

aSalesHeaders = ["TransactionID", "Date", "Product", "Category", "Price", "Quantity", "Customer"]

o31 = new stzDataWrangler(aSalesData, aSalesHeaders)

? "Sales data preparation workflow:"
? "1. Data validation and profiling"
aValidationResult = o31.ExecutePlan("validate", TRUE)

? ""
? "2. Data cleaning and preparation for analysis"
o32 = new stzDataWrangler(aSalesData, aSalesHeaders)
aAnalysisResult = o32.ExecutePlan("analyze", TRUE)

? ""
? "3. Final dataset ready for statistical analysis:"
aFinalSalesData = o32.ExportForStzDataSet()
? "Prepared " + len(aFinalSalesData) + " transaction records"

pf()
# Execution time: ~0.10 seconds

/*--- Survey response data standardization

pr()

? "=== REAL-WORLD SCENARIO: SURVEY RESPONSE STANDARDIZATION ==="

# Survey responses with inconsistent formats
aSurveyData = [
    ["Resp001", "25", "Male", "YES", "Satisfied", "Bachelor's", "50000"],
    ["Resp002", "thirty-two", "F", "true", "Very Satisfied", "Masters", "75000"],
    ["Resp003", "", "female", "1", "Neutral", "PhD", ""],  # Missing age and salary
    ["Resp004", "45", "M", "NO", "Dissatisfied", "High School", "35000"],
    ["Resp005", "28", "Female", "false", "satisfied", "bachelor", "55000"],  # Case inconsistencies
    ["Resp006", "65", "Male", "Yes", "Very satisfied", "Masters", "90000"],
    ["Resp007", "22", "F", "0", "", "Associate", "30000"]  # Missing satisfaction
]

aSurveyHeaders = ["ResponseID", "Age", "Gender", "Subscribe", "Satisfaction", "Education", "Income"]

o33 = new stzDataWrangler(aSurveyData, aSurveyHeaders)

? "Survey data standardization process:"

# Custom validation rules for survey data
aCustomRules = [
    ["Age", 18, 100],
    ["Income", 0, 500000]
]

? ""
? "1. Range validation with custom rules:"
aRangeIssues = o33.ValidateRanges(aCustomRules)
for issue in aRangeIssues
    ? "  • " + issue
next

? ""
? "2. Comprehensive standardization:"
aStandardizationResult = o33.ExecutePlan("export", TRUE)

? ""
? "3. Export-ready survey data:"
aStandardizedSurvey = o33.ExportForStzTable()
? "Headers: " +
