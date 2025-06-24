load "../max/stzmax.ring"

#==============================#
#  TEST SECTION 1: BASIC SETUP #
#==============================#

/*--- Testing basic initialization with simple list data

pr()

# Simple list with mixed data quality issues with # Duplicates, whitespace, missing values
aSimpleData = [ "John", "  Mary  ", '', "BOB", "NULL", "alice", "John" ]

o1 = new stzDataWrangler(aSimpleData, [])

# Check initial data profile
o1.ShowReport()
#-->
'
╭───────────────────────╮
│ DATA WRANGLING REPORT │
╰───────────────────────╯
• Structure: list
• Dimensions: 7 rows × 0 columns
• Issues Found: 0
• Transformations: 1

🔄 TRANSFORMATIONS APPLIED:
╰─> Data loaded: {Structure: list}
'

pf()
# Executed in 0.02 second(s) in Ring 1.22

/*--- Testing initialization with 2D table data

pr()

# Sample customer data with various quality issues

aCustomerHeaders = [ "Name", "Age", "Email", "Salary", "Department" ]

aCustomerData = [
    [ "John Smith", 25, "john@email.com", 50000, "Sales" ],
    [ "  Mary Jones  ", "", "mary.jones@company.com", 65000, "marketing" ],
    [ "Bob Wilson", 35, "bob@email", "NULL", "SALES" ],
    [ "Alice Brown", 28, "alice@email.com", 55000, "" ],
    [ "John Smith", 25, "john@email.com", 50000, "Sales" ],  # Duplicate
    [ "", 45, "unknown@email.com", 75000, "Engineering" ],
    [ "Tom Davis", -5, "tom@email.com", 999999, "sales" ]    # Invalid age, potential outlier salary
]

o1 = new stzDataWrangler(aCustomerData, aCustomerHeaders)

# Display initial data structure and profile

? BoxRound("TABLE DATA PROFILE")
aProfile = o1.GetDataProfile()

? "• Structure: " + aProfile[:structure]
? "• Dimensions: " + aProfile[:rows] + " rows × " + aProfile[:columns] + " columns"
? "• Data Types Summary:"

aTypesSummary = aProfile[:data_types]

for typeInfo in aTypesSummary
    ? " ─ " + typeInfo[1] + ": " + o1._JoinList(typeInfo[2], ", ")
next

#-->
'
╭────────────────────╮
│ TABLE DATA PROFILE │
╰────────────────────╯
• Structure: table
• Dimensions: 7 rows × 5 columns
• Data Types Summary:
 ─ Name: string
 ─ Age: numeric
 ─ Email: string
 ─ Salary: numeric
 ─ Department: string
'

pf()
# Executed in 0.02 second(s) in Ring 1.22

#================================#
#  TEST SECTION 2: DATA CLEANING #
#================================#

/*--- Testing duplicate removal

pr()

aCustomerHeaders = [ "Name", "Age", "Email", "Salary", "Department" ]

aCustomerData = [
    [ "John Smith", 25, "john@email.com", 50000, "Sales" ],
    [ "  Mary Jones  ", '', "mary.jones@company.com", 65000, "marketing" ],
    [ "Bob Wilson", 35, "bob@email", "NULL", "SALES" ],
    [ "Alice Brown", 28, "alice@email.com", 55000, "" ],
    [ "John Smith", 25, "john@email.com", 50000, "Sales" ],  # Duplicate
    [ '', 45, "unknown@email.com", 75000, "Engineering" ],
    [ "Tom Davis", -5, "tom@email.com", 999999, "sales" ]    # Invalid age, potential outlier salary
]

o1 = new stzDataWrangler(aCustomerData, aCustomerHeaders)

# BEFORE DUPLICATE REMOVAL

? "Initial row count: " + o1._GetRowCount()

# Remove duplicates

nDuplicatesRemoved = o1.RemoveDuplicates()

# AFTER DUPLICATE REMOVAL

? "Duplicates removed: " + nDuplicatesRemoved
? "New row count: " + o1._GetRowCount()

#-->
'
Initial row count: 7
Duplicates removed: 1
New row count: 6
'

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Testing missing value handling with different strategies

pr()

aCustomerHeaders = [ "Name", "Age", "Email", "Salary", "Department" ]

aCustomerData = [
    [ "John Smith", 25, "john@email.com", 50000, "Sales" ],
    [ "  Mary Jones  ", '', "mary.jones@company.com", 65000, "marketing" ],
    [ "Bob Wilson", 35, "bob@email", "NULL", "SALES" ],
    [ "Alice Brown", 28, "alice@email.com", 55000, "" ],
    [ "John Smith", 25, "john@email.com", 50000, "Sales" ],  # Duplicate
    [ '', 45, "unknown@email.com", 75000, "Engineering" ],
    [ "Tom Davis", -5, "tom@email.com", 999999, "sales" ]    # Invalid age, potential outlier salary
]

o1 = new stzDataWrangler(aCustomerData, aCustomerHeaders)

# MISSING VALUES BEFORE HANDLING

	? o1._CountMissingValues()
	#--> 4

# Handle missing values with auto strategy

	nProcessed = o1.HandleMissingValues("auto")

# AFTER AUTO MISSING VALUE HANDLING:

	# Values processed
	? nProcessed
	#--> 4
	
	# Remaining missing values
	? o1._CountMissingValues()
	#--> 0

# Test different strategies (FILL ZERO STRATEGY)

o2 = new stzDataWrangler(aCustomerData, aCustomerHeaders)
nFilled = o2.HandleMissingValues("fill_zero")

	# Values filled with zero
	? nFilled
	#--> 4

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Testing whitespace trimming and case normalization

pr()

# Data with whitespace and case issues
aMesyData = ["  John DOE  ", "mary smith", "  BOB WILSON  ", "alice BROWN"]
o1 = new stzDataWrangler(aMesyData, [])


# Trim whitespace
nTrimmed = o1.TrimWhitespace()

	# Values trimmed
	? nTrimmed
	#--> 2

	? @@(o1.GetData()) + NL
	#--> [ "John DOE", "mary smith", "BOB WILSON", "alice BROWN" ]

# Normalize case to title case
nNormalized = o1.NormalizeCase("title")

	# Values normalized
	? nNormalized
	#--> 2

	# Normalised content
	? @@(o1.GetData())
	#--> [ "John Doe", "Mary Smith", "Bob Wilson", "Alice Brown" ]

pf()
# Executed in 0.01 second(s) in Ring 1.22

#===================================#
#  TEST SECTION 3: DATA VALIDATION  #
#===================================#

/*--- Testing data type validation

pr()

aCustomerHeaders = [ "Name", "Age", "Email", "Salary", "Department" ]

aCustomerData = [
    [ "John Smith", 25, "john@email.com", 50000, "Sales" ],
    [ "  Mary Jones  ", '', "mary.jones@company.com", 65000, "marketing" ],
    [ "Bob Wilson", 35, "bob@email", "NULL", 911 ],
    [ "Alice Brown", 28, "alice@email.com", 55000, "" ],
    [ "John Smith", 25, "john@email.com", 50000, "Sales" ],  # Duplicate
    [ '', "45", "unknown@email.com", 75000, "Engineering" ],
    [ "Tom Davis", -5, "tom@email.com", 999999, ["sales"] ]    # Invalid age, potential outlier salary
]

o1 = new stzDataWrangler(aCustomerData, aCustomerHeaders)

? BoxRound("DATA TYPE VALIDATION")
aTypeIssues = o1.ValidateDataTypes()

? "Type inconsistencies found: " + len(aTypeIssues)
for issue in aTypeIssues
    ? "  • " + issue
next

#-->
'
╭──────────────────────╮
│ DATA TYPE VALIDATION │
╰──────────────────────╯
Type inconsistencies found: 2
  • Column Age has mixed types: numeric, string
  • Column Department has mixed types: string, numeric, list
'

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Testing range validation

pr()

aCustomerHeaders = [ "Name", "Age", "Email", "Salary", "Department" ]

aCustomerData = [
    [ "John Smith", 25, "john@email.com", 50000, "Sales" ],
    [ "  Mary Jones  ", '', "mary.jones@company.com", 65000, "marketing" ],
    [ "Bob Wilson", 35, "bob@email", "NULL", 911 ],
    [ "Alice Brown", 28, "alice@email.com", 55000, "" ],
    [ "John Smith", 25, "john@email.com", 50000, "Sales" ],  # Duplicate
    [ '', 45, "unknown@email.com", 75000, "Engineering" ],
    [ "Tom Davis", -5, "tom@email.com", 999999, "sales" ]    # Invalid age, potential outlier salary
]

o1 = new stzDataWrangler(aCustomerData, aCustomerHeaders)

# Define range rules: [ column_name, min_value, max_value ]

aRangeRules = [
    [ "Age", 18, 65 ],
    [ "Salary", 30000, 200000 ]
]

? BoxRound("RANGE VALIDATION")

aRangeIssues = o1.ValidateRanges(aRangeRules)

? "Range violations found: " + len(aRangeIssues)

for issue in aRangeIssues
    ? "  • " + issue
next

#-->
'
╭──────────────────╮
│ RANGE VALIDATION │
╰──────────────────╯
Range violations found: 2
  • Row 7, Age: -5 outside range [18, 65]
  • Row 7, Salary: 999999 outside range [30000, 200000]
'

pf()
# Executed in 0.01 second(s) in Ring 1.22

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

aOutlierHeaders = [ "Product", "Quantity", "Price" ]

o1 = new stzDataWrangler(aOutlierData, aOutlierHeaders)

? BoxRound("OUTLIER DETECTION")
aOutliers = o1.DetectOutliers(2.0)  # Using Z-score threshold of 2.0
? "Outliers detected: " + len(aOutliers)

for outlier in aOutliers
    ? "  • Row " + outlier[1] + ", " + aOutlierHeaders[outlier[2]] + ": " + outlier[3] + " (Z-score: " + outlier[4] + ")"
next

#-->
'
Outliers detected: 2
  • Row 4, Quantity: 9999 (Z-score: 2.27)
  • Row 4, Price: 500 (Z-score: 2.26)
'

pf()
# Executed in 0.02 second(s) in Ring 1.22

#=======================================#
#  TEST SECTION 4: DATA TRANSFORMATION  #
#=======================================#

/*--- Testing data type conversion

pr()

# Mixed data types that need conversion
aMixedData = [
    ["Item1", "123", "true", "2023-01-15"],
    ["Item2", "456.78", "false", "2023-02-20"],
    ["Item3", "789", "yes", "2023-03-10"]
]
aMixedHeaders = ["Name", "Value", "Active", "Date"]

o1 = new stzDataWrangler(aMixedData, aMixedHeaders)

? "BEFORE TYPE CONVERSION:"
aProfile = o1.GetDataProfile()
aTypesSummary = aProfile[:data_types]
for typeInfo in aTypesSummary
    ? " • " + typeInfo[1] + ": " + o1._JoinList(typeInfo[2], ", ")
next

? ""

# Define conversion rules
aConversionRules = [
    ["Value", "numeric"],
    ["Active", "boolean"]
]

nConverted = o1.ConvertDataTypes(aConversionRules)
? "AFTER TYPE CONVERSION:"
? " • Values converted: " + nConverted
? " • Ddata: " + @@(o1.GetData())

#-->
'
BEFORE TYPE CONVERSION:
 • Name: string
 • Value: string
 • Active: boolean, string
 • Date: date

AFTER TYPE CONVERSION:
 • Values converted: 5
 • Ddata: [ [ "Item1", 123, 1, "2023-01-15" ], [ "Item2", 456.78, "false", "2023-02-20" ], [ "Item3", 789, 1, "2023-03-10" ] ]
'

pf()
# Executed in 0.01 second(s) in Ring 1.22

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

o1 = new stzDataWrangler(aNumericData, aNumericHeaders)

? BoxRound("BEFORE NORMALIZATION")

aColumn = []
for i = 1 to len(aNumericData)
    aColumn + aNumericData[i][2]
next
? "• Data: " + @@(aColumn) + NL

# Normalize using min-max scaling
nNormalized = o1.NormalizeNumeric("minmax")
? BoxRound("AFTER MIN-MAX NORMALIZATION")
? "• Values normalized: " + nNormalized
? "• Normalized Value1 column:"
? @@( o1.GetData() ) + NL

# Test Z-score normalization
o2 = new stzDataWrangler(aNumericData, aNumericHeaders)
o2.NormalizeNumeric("zscore")
? BoxRound("Z-SCORE NORMALIZATION")
? @@( o2.GetData() )

#-->
'
╭──────────────────────╮
│ BEFORE NORMALIZATION │
╰──────────────────────╯
[ 100, 200, 300, 150, 250 ]

╭─────────────────────────────╮
│ AFTER MIN-MAX NORMALIZATION │
╰─────────────────────────────╯
• Values normalized: 10
• Normalized Value1 column:
[ [ "Sample1", 0, 0 ], [ "Sample2", 0.50, 0.50 ], [ "Sample3", 1, 1 ], [ "Sample4", 0.25, 0.25 ], [ "Sample5", 0.75, 0.75 ] ]

Z-SCORE NORMALIZATION:
[ 0.50, 1.50, 2.50, 1, 2 ]
'

pf()
# Executed in 0.04 second(s) in Ring 1.22

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

o1 = new stzDataWrangler(aCategoricalData, aCategoricalHeaders)

? BoxRound("BEFORE CATEGORICAL ENCODING")
aColumn = []
for i = 1 to len(aCategoricalData)
    aColumn + aCategoricalData[i][2]
next
? "• Data: " + @@(aColumn) + NL

# Apply label encoding

nEncoded = o1.EncodeCategories("label")
#~> We support three possible strategies of categorical encoding:
# - "label" (0,1,2...),
" - "onehot" (binary columns),
# - "ordinal" (custom order)

? BoxRound("AFTER LABEL ENCODING")
? "• Values encoded: " + nEncoded
? "• Encoded Color column:"
? @@(o1.GetData())

#-->
'
╭─────────────────────────────╮
│ BEFORE CATEGORICAL ENCODING │
╰─────────────────────────────╯
• Data: [ "Red", "Blue", "Green", "Red", "Blue" ]

╭──────────────────────╮
│ AFTER LABEL ENCODING │
╰──────────────────────╯
• Values encoded: 10
• Encoded Color column:
[ [ 0, 0, 0 ], [ 1, 1, 1 ], [ 2, 2, 2 ], [ 3, 0, 0 ], [ 4, 1, 2 ] ]
'

pf()
# Executed in 0.02 second(s) in Ring 1.22

#==================================#
#  TEST SECTION 5: PLAN EXECUTION  #
#==================================#

/*--- Testing plan generation and execution

pr()

# Create messy dataset for comprehensive plan testing
aMesyDataset = [
    ["  John Doe  ", "25", "john@email.com", "50000", "sales"],
    ["mary SMITH", '', "mary@company.com", "65000", "MARKETING"],
    ['', "35", "invalid-email", "NULL", "Sales"],
    ["John Doe", "25", "john@email.com", "50000", "sales"],  # Duplicate
    ["Bob Wilson", "-5", "bob@email.com", "999999", "engineering"],
    ["Alice Brown", "28.5", "alice@email.com", '', "Sales"]
]
aMesyHeaders = ["Full_Name", "Age", "Email", "Salary", "Department"]

o1 = new stzDataWrangler(aMesyDataset, aMesyHeaders)

? BoxRound("GENERATING BASIC CLEANUP PLAN")
aPlan = o1.GeneratePlan("clean")
? " • Plan: " + aPlan[:title]
? " • Description: " + aPlan[:description]
? " • Steps:"
for stepp in aPlan[:steps]
    ? "  ─ " + stepp[:description]
next

? ""
? BoxRound("EXECUTING BASIC CLEANUP PLAN")
aResult = o1.ExecutePlan("clean", TRUE)

? ""
? BoxRound("EXECUTION SUMMARY")
? " • Plan executed: " + aResult[:plan]//[:title]
? " • Execution time: " + aResult[:execution_time] + " seconds"
? " • Summary: " + aResult[:summary]

#-->
'
╭───────────────────────────────╮
│ GENERATING BASIC CLEANUP PLAN │
╰───────────────────────────────╯
 • Plan: Basic Data Cleanup
 • Description: Remove duplicates, handle missing values, normalize formats
 • Steps:
  ─ Fill or remove missing values
  ─ Clean whitespace from text
  ─ Standardize text case
  ─ Remove duplicate rows

╭──────────────────────────────╮
│ EXECUTING BASIC CLEANUP PLAN │
╰──────────────────────────────╯
• Executing Plan: Basic Data Cleanup
• Remove duplicates, handle missing values, normalize formats

❌ Fill or remove missing values...
╰─> Error: Error (R19) : Calling function with less number of parameters

✅ Clean whitespace from text...
╰─> Cleaned 1 text values

❌ Standardize text case...
╰─> Error: Error (R19) : Calling function with less number of parameters

✅ Remove duplicate rows...
╰─> Removed 1 duplicate rows


( Plan execution completed in 0.03 second(s): 2 successful, 2 errors )

╭───────────────────╮
│ EXECUTION SUMMARY │
╰───────────────────╯
 • Plan executed: 
 • Execution time:  seconds
 • Summary: 
'

pf()
# Executed in 0.07 second(s) in Ring 1.22

/*--- Testing different plan templates

pr()

# Create messy dataset for comprehensive plan testing
aMesyDataset = [
    ["  John Doe  ", "25", "john@email.com", "50000", "sales"],
    ["mary SMITH", '', "mary@company.com", "65000", "MARKETING"],
    ['', "35", "invalid-email", "NULL", "Sales"],
    ["John Doe", "25", "john@email.com", "50000", "sales"],  # Duplicate
    ["Bob Wilson", "-5", "bob@email.com", "999999", "engineering"],
    ["Alice Brown", "28.5", "alice@email.com", '', "Sales"]
]
aMesyHeaders = ["Full_Name", "Age", "Email", "Salary", "Department"]

o1 = new stzDataWrangler(aMesyDataset, aMesyHeaders)

? BoxRound("TESTING VALIDATION PLAN")
o1.ExecutePlan("validate", TRUE)
#-->
'
╭─────────────────────────╮
│ TESTING VALIDATION PLAN │
╰─────────────────────────╯
• Executing Plan: Data Quality Validation
• Validate data types, formats, and constraints

✅ Check data type consistency...
╰─> Found 1 type inconsistencies

❌ Check numeric ranges...
╰─> Error: Error (R19) : Calling function with less number of parameters

✅ Validate text formats...
╰─> Format validation completed

❌ Identify potential outliers...
╰─> Error: Error (R19) : Calling function with less number of parameters


( Plan execution completed in 0.00 second(s): 2 successful, 2 errors )
'

? ""
? BoxRound("TESTING ANALYSIS PREPARATION PLAN")
o2 = new stzDataWrangler(aMesyDataset, aMesyHeaders)
o2.ExecutePlan("analyze", TRUE)
#-->
'
╭───────────────────────────────────╮
│ TESTING ANALYSIS PREPARATION PLAN │
╰───────────────────────────────────╯
'


? ""
? BoxRound("TESTING EXPORT PREPARATION PLAN")
o3 = new stzDataWrangler(aMesyDataset, aMesyHeaders)
o3.ExecutePlan("export", TRUE)
#-->
'
╭─────────────────────────────────╮
│ TESTING EXPORT PREPARATION PLAN │
╰─────────────────────────────────╯
• Executing Plan: Prepare for Export
• Format data for external systems

❌ Clean column names...
╰─> Error: Bad parameter type!

❌ Replace with export-friendly values...
╰─> Error: Error (R19) : Calling function with less number of parameters

❌ Standardize date formats...
╰─> Error: Bad parameter type!

✅ Final validation check...
╰─> Export validation - 2 issues found


( Plan execution completed in 0.00 second(s): 1 successful, 3 errors )
'

pf()
# Executed in 0.04 second(s) in Ring 1.22

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

#==================================#
#  TEST SECTION 6: EXPORT METHODS  #
#==================================#

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

o1 = new stzDataWrangler(aCleanData, aCleanHeaders)

? BoxRound("EXPORT FOR stzDataSet")

aDataSetExport = o1.ExportForStzDataSet()
? "• Class name: " + StzDataSetQ(aDataSetExport).ClassName()
? "• Exported data structure: " + len(aDataSetExport) + " rows"
? "• Sample data:"
for i = 1 to min([3, len(aDataSetExport)])
    ? " ─ Row " + i + ": " + o1._JoinList(aDataSetExport[i], ", ")
next
#-->
'
╭───────────────────────╮
│ EXPORT FOR stzDataSet │
╰───────────────────────╯
• Class name: stzdataset
• Exported data structure: 4 rows
• Sample data:
 ─ Row 1: Alice, 25, 55000
 ─ Row 2: Bob, 30, 60000
 ─ Row 3: Carol, 28, 58000
'

#---

? ""
? BoxRound("EXPORT FOR stzTable")
aTableExport = o1.ExportForStzTable()
? "• Headers: " + o1._JoinList(aTableExport[1], ", ")
? "• Data rows: " + len(aTableExport[2])
#-->
'
╭─────────────────────╮
│ EXPORT FOR stzTable │
╰─────────────────────╯
• Headers: Name, Age, Salary
• Data rows: 4
'

#---

? ""
? BoxRound("EXPORT FOR stzMatrix")
aMatrixExport = o1.ExportForStzMatrix()

? "• Class name: " + StzMatrixQ(aDataSetExport).ClassName()
? "• Matrix dimensions: " + len(aMatrixExport) + " × " + len(aMatrixExport[1])
? "• Sample numeric data:"

for i = 1 to min([3, len(aMatrixExport)])

	if i = 1
		cSepLeft = "╭"
		cSepRight = "╮"
	but i = 2
		cSepLeft = "│"
		cSepRight = "│"
	but i = 3
		cSepLeft = "╰"
		cSepRight = "╯"
	ok

    ? ' ' + cSepLeft + " " + o1._JoinList(aMatrixExport[i], ", ") + " " + cSepRight

next

#-->
'
╭──────────────────────╮
│ EXPORT FOR stzMatrix │
╰──────────────────────╯
• Class name: stzmatrix
• Matrix dimensions: 4 × 3
• Sample numeric data:
 ╭ 0, 25, 55000 ╮
 │ 0, 30, 60000 │
 ╰ 0, 28, 58000 ╯
'

pf()
# Executed in 0.06 second(s) in Ring 1.22

#=======================================#
#  TEST SECTION 7: CONVENIENCE METHODS  #
#=======================================#

/*--- Testing quick operation methods

pr()

aMesyDataset = [
    ["  John Doe  ", "25", "john@email.com", "50000", "sales"],
    ["mary SMITH", '', "mary@company.com", "65000", "MARKETING"],
    ['', "35", "invalid-email", "NULL", "Sales"],
    ["John Doe", "25", "john@email.com", "50000", "sales"],  # Duplicate
    ["Bob Wilson", "-5", "bob@email.com", "999999", "engineering"],
    ["Alice Brown", "28.5", "alice@email.com", '', "Sales"]
]
aMesyHeaders = ["Full_Name", "Age", "Email", "Salary", "Department"]

o1 = new stzDataWrangler(aMesyDataset, aMesyHeaders)

# QUICK OPERATIONS (NON-VERBOSE)

? "Quick Clean..."
aQuickClean = o1.QuickClean()
? "Result: " + aQuickClean[:summary]

? ""
? "Quick Validate..."
aQuickValidate = o1.QuickValidate()
? "Result: " + aQuickValidate[:summary]

? ""
? "Quick Prepare for Analysis..."
o2 = new stzDataWrangler(aMesyDataset, aMesyHeaders)
aQuickAnalysis = o2.QuickPrepareForAnalysis()
if isList(aQuickAnalysis)
	? "Result: " + aQuickAnalysis[:summary]
ok

? ""
? "Quick Prepare for Export..."
o3 = new stzDataWrangler(aMesyDataset, aMesyHeaders)
aQuickExport = o3.QuickPrepareForExport()
? "Result: " + aQuickExport[:summary]

#-->
'
Quick Clean...
Result: 2 successful, 2 errors

Quick Validate...
Result: 2 successful, 2 errors

Quick Prepare for Analysis...

Quick Prepare for Export...
Result: 1 successful, 3 errors
'

pf()
# Executed in 0.04 second(s) in Ring 1.22

/*--- Testing chainable operations

pr()

aMesyDataset = [
    [ "  John Doe  ", "25", "john@email.com", "50000", "sales" ],
    [ "mary SMITH", '', "mary@company.com", "65000", "MARKETING" ],
    [ '', "35", "invalid-email", "NULL", "Sales" ],
    [ "John Doe", "25", "john@email.com", "50000", "sales" ],  # Duplicate
    [ "Bob Wilson", "-5", "bob@email.com", "999999", "engineering" ],
    [ "Alice Brown", "28.5", "alice@email.com", '', "Sales" ]
]
aMesyHeaders = ["Full_Name", "Age", "Email", "Salary", "Department"]

o1 = new stzDataWrangler(aMesyDataset, aMesyHeaders)


? BoxRound("CHAINABLE OPERATIONS")
? "• Performing: Clean() -> Validate() -> Transform() -> Export()"

# Chain operations together
o1.Clean().Validate().Transform().Export()

? "• Final data profile:"
aFinalProfile = o1.GetDataProfile()
? " ─ Issues found: " + aFinalProfile[:issues_found]
? " ─ Transformations applied: " + aFinalProfile[:transformations_applied]

# Show transformation log
? ""
? "• Transformation log:"
aTransformLog = o1.GetTransformationLog()
for transform in aTransformLog
    ? " ─ " + transform[:operation] + ": " + transform[:details]
next

? ""
? @@(o1.GetData())
#--> See why the data is not altered

pf()
# Executed in 0.05 second(s) in Ring 1.22

#===========================================#
#  TEST SECTION 8: REPORTING & DIAGNOSTICS  #
#===========================================#

/*--- Testing comprehensive reporting

pr()

aMesyDataset = [
    ["  John Doe  ", "25", "john@email.com", "50000", "sales"],
    ["mary SMITH", '', "mary@company.com", "65000", "MARKETING"],
    ['', "35", "invalid-email", "NULL", "Sales"],
    ["John Doe", "25", "john@email.com", "50000", "sales"],  # Duplicate
    ["Bob Wilson", "-5", "bob@email.com", "999999", "engineering"],
    ["Alice Brown", "28.5", "alice@email.com", '', "Sales"]
]
aMesyHeaders = ["Full_Name", "Age", "Email", "Salary", "Department"]


o1 = new stzDataWrangler(aMesyDataset, aMesyHeaders)

# COMPREHENSIVE DATA REPORT
o1.ShowReport()

? ""
? BoxRound("DETAILED PROFILE INFORMATION")
aDetailedProfile = o1.GetDataProfile()
? "• Structure: " + aDetailedProfile[:structure]
? "• Dimensions: " + aDetailedProfile[:rows] + " rows × " + aDetailedProfile[:columns] + " columns"
? "• Missing values: " + aDetailedProfile[:missing_values]
? "• Duplicate count: " + aDetailedProfile[:duplicates]

? ""
? BoxRound("ISSUES BREAKDOWN")
aIssues = o1.GetIssues()
if len(aIssues) > 0
    for issue in aIssues
        ? "• [" + issue[:type] + "] " + issue[:description]
    next
else
    ? "No issues detected in original data"
ok

#-->
'
╭───────────────────────╮
│ DATA WRANGLING REPORT │
╰───────────────────────╯
• Structure: table
• Dimensions: 6 rows × 5 columns
• Issues Found: 0
• Transformations: 1

🔄 TRANSFORMATIONS APPLIED:
╰─> Data loaded: {{ Structure: table }}

╭──────────────────────────────╮
│ DETAILED PROFILE INFORMATION │
╰──────────────────────────────╯
• Structure: table
• Dimensions: 6 rows × 5 columns
• Missing values: 4
• Duplicate count: 0

╭──────────────────╮
│ ISSUES BREAKDOWN │
╰──────────────────╯
No issues detected in original data
'

pf()
# Execution time: ~0.04 seconds

/*--- Testing after applying transformations

pr()

aMesyDataset = [
    ["John Doe", "25", "john@email.com", "50000", "sales"],
    ["mary SMITH", '', "mary@company.com", "65000", "MARKETING"],
    ['', "35", "invalid-email", "NULL", "Sales"],
    ["John Doe", "25", "john@email.com", "50000", "sales"],  # Duplicate
    ["Bob Wilson", "-5", "bob@email.com", "999999", "engineering"],
    ["Alice Brown", "28.5", "alice@email.com", '', "Sales"]
]
aMesyHeaders = ["Full_Name", "Age", "Email", "Salary", "Department"]

o1 = new stzDataWrangler(aMesyDataset, aMesyHeaders)

? BoxRound("BEFORE ANY TRNASFORMATION")

aInitialProfile = o1.GetDataProfile()
? "• Missing values: " + aInitialProfile[:missing_values]
? "• Duplicate count: " + aInitialProfile[:duplicates]

# Apply comprehensive cleaning
o1.ExecutePlan("clean", FALSE)

? ""
? BoxRound("AFTER CLEANING THE DATA")
aFinalProfile = o1.GetDataProfile()
? "• Missing values: " + aFinalProfile[:missing_values]
? "• Duplicate count: " + aFinalProfile[:duplicates]
? "• Transformations applied: " + aFinalProfile[:transformations_applied]

? ""
? BoxRound("DETAILED TRANSFORMATION LOG")
aTransformLog = o1.GetTransformationLog()
for transform in aTransformLog
    ? "• [" + transform[:timestamp] + "] " + transform[:operation] + " - " + transform[:details]
next

#-->
'
╭───────────────────────────╮
│ BEFORE ANY TRNASFORMATION │
╰───────────────────────────╯
• Missing values: 4
• Duplicate count: 1

╭─────────────────────────╮
│ AFTER CLEANING THE DATA │
╰─────────────────────────╯
• Missing values: 4
• Duplicate count: 0
• Transformations applied: 2

╭─────────────────────────────╮
│ DETAILED TRANSFORMATION LOG │
╰─────────────────────────────╯
• [18/06/2025 15:07:44] Data loaded - { Structure: table }
• [18/06/2025 15:07:44] TrimWhitespace - 0 values cleaned
'

pf()
# Executed in 0.09 second(s) in Ring 1.22

#==============================#
#  TEST SECTION 9: EDGE CASES #
#==============================#

/*--- Testing with empty dataset

pr()

# TESTING WITH EMPTY DATASET

aEmptyData = []
aHeaders = []

o1 = new stzDataWrangler(aEmptyData, aHeaders)

aEmptyProfile = o1.GetDataProfile()
? "• Empty data structure: " + aEmptyProfile[:structure]
? "• Row count: " + aEmptyProfile[:rows]
#-->
'
• Empty data structure: empty
• Row count: 0
'

# Try to execute plan on empty data
? ""
aEmptyResult = o1.ExecutePlan("clean", FALSE)
? "• Plan execution on empty data: " + aEmptyResult[:summary]

pf()
# • Plan execution on empty data: 2 successful, 2 errorss

/*--- Testing with single column data

pr()

# TESTING WITH SINGLE COLUMN

aSingleColumnData = [
    [ "Value1" ],
    [ "Value2" ],
    [ "" ],
    [ "Value1" ],  # Duplicate
    [ "Value3" ]
]
aSingleColumnHeaders = ["OnlyColumn"]

o1 = new stzDataWrangler(aSingleColumnData, aSingleColumnHeaders)

# Initial profile
o1.ShowReport()
#-->
'
╭───────────────────────╮
│ DATA WRANGLING REPORT │
╰───────────────────────╯
• Structure: table
• Dimensions: 5 rows × 1 columns
• Issues Found: 0
• Transformations: 1

🔄 TRANSFORMATIONS APPLIED:
╰─> Data loaded: {Structure: table}
'

? ""
? BoxRound("Executing cleanup:")
o1.ExecutePlan("clean", TRUE)
#-->
'
╭────────────────────╮
│ Executing cleanup: │
╰────────────────────╯
• Executing Plan: Basic Data Cleanup
• Remove duplicates, handle missing values, normalize formats

❌ Fill or remove missing values...
╰─> Error: Error (R19) : Calling function with less number of parameters

✅ Clean whitespace from text...
╰─> Cleaned 0 text values

❌ Standardize text case...
╰─> Error: Error (R19) : Calling function with less number of parameters

✅ Remove duplicate rows...
╰─> Removed 1 duplicate rows

( Plan execution completed in 0.01 second(s): 2 successful, 2 errors )
'
pf()
# Executed in 0.04 second(s) in Ring 1.22

/*--- Testing with all missing values

pr()

# TESTING WITH ALL MISSING VALUES

aAllMissingData = [
    [ '', "NULL", "" ],
    [ "NA", '', "n/a" ],
    [ '', "NULL", "" ]
]
aAllMissingHeaders = [ "Col1", "Col2", "Col3" ]

o1 = new stzDataWrangler(aAllMissingData, aAllMissingHeaders)

? "Profile before handling missing values:"
aBeforeMissing = o1.GetDataProfile()
? "• Missing values: " + aBeforeMissing[:missing_values]

# Try different missing value strategies
nProcessed = o1.HandleMissingValues("fill_zero")
? ""
? "After filling with zeros:"
? "• Values processed: " + nProcessed
aAfterMissing = o1.GetDataProfile()
? "• Remaining missing values: " + aAfterMissing[:missing_values]

#-->
'
Profile before handling missing values:
• Missing values: 9

After filling with zeros:
• Values processed: 9
• Remaining missing values: 0
'

pf()
# Executed in almost 0 second(s) in Ring 1.22

#===============================#
#  TEST SECTION 10: PERFORMANCE #
#===============================#

/*--- Testing with larger dataset

pr()

# Generate larger dataset for performance testing
aLargeHeaders = ["ID", "Name", "Score", "Category", "Date"]
aLargeData = []

for i = 1 to 100_000
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

o1 = new stzDataWrangler(aLargeData, aLargeHeaders)

? "Executing comprehensive analysis plan..."
nStartTime = clock()
aLargeResult = o1.ExecutePlan("analyze", FALSE)
nEndTime = clock()
nExecutionTime = (nEndTime - nStartTime) / clockspersecond()

? "Performance results:"
? "• Execution time: " + nExecutionTime + " seconds"
? "• Processing rate: " + (len(aLargeData) / nExecutionTime) + " rows/second"


//? "• Plan result: " + aLargeResult[:summary] #TODO See why aLargeResult = ""!

pf()
# Executed in 2.02 second(s) in Ring 1.22

#=========================================#
#  TEST SECTION 11: REAL-WORLD SCENARIOS  #
#=========================================#

/*--- Customer database cleanup scenario

pr()

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

o1 = new stzDataWrangler(aCustomerDB, aCustomerHeaders)

? "Initial customer database analysis:"
o1.ShowReport()

? ""
? "Executing comprehensive cleanup..."
aCustomerResult = o1.ExecutePlan("clean", TRUE)

? ""
? "Final cleaned data sample:"
aCleanedCustomers = o1.GetData()
for i = 1 to min([5, len(aCleanedCustomers)])
    ? "Customer " + i + ":"
    for j = 1 to len(aCustomerHeaders)
        ? "• " + aCustomerHeaders[j] + ": " + aCleanedCustomers[i][j]
    next
    ? ""
next

#-->
'
Initial customer database analysis:
╭───────────────────────╮
│ DATA WRANGLING REPORT │
╰───────────────────────╯
• Structure: table
• Dimensions: 7 rows × 7 columns
• Issues Found: 0
• Transformations: 1

🔄 TRANSFORMATIONS APPLIED:
╰─> Data loaded: {Structure: table}

Executing comprehensive cleanup...
• Executing Plan: Basic Data Cleanup
• Remove duplicates, handle missing values, normalize formats

❌ Fill or remove missing values...
╰─> Error: Error (R19) : Calling function with less number of parameters

✅ Clean whitespace from text...
╰─> Cleaned 1 text values

❌ Standardize text case...
╰─> Error: Error (R19) : Calling function with less number of parameters

✅ Remove duplicate rows...
╰─> Removed 1 duplicate rows

( Plan execution completed in 0.05 second(s): 2 successful, 2 errors )

Final cleaned data sample:
Customer 1:
• Name: John Smith
• Email: john.smith@email.com
• Phone: 555-1234
• City: New York
• State: NY
• ZIP: 10001
• JoinDate: 2020-01-15

Customer 2:
• Name: mary johnson
• Email: MARY@COMPANY.COM
• Phone: (555) 567-8901
• City: los angeles
• State: ca
• ZIP: 90210
• JoinDate: 2019-03-22

Customer 3:
• Name: 
• Email: bob.wilson@email.com
• Phone: 555.234.5678
• City: Chicago
• State: IL
• ZIP: 
• JoinDate: 

Customer 4:
• Name: Alice Brown
• Email: alice@email
• Phone: 5551234567
• City: Houston
• State: TX
• ZIP: 77001
• JoinDate: 2021-06-10

Customer 5:
• Name: Tom Davis
• Email: tom@email.com
• Phone: 555-999-0000
• City: Phoenix
• State: AZ
• ZIP: 85001
• JoinDate: 2022-12-01
'

pf()
# Executed in 0.07 second(s) in Ring 1.22

/*--- Sales data preparation for analysis

pr()

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

o1 = new stzDataWrangler(aSalesData, aSalesHeaders)

? BoxRound("Sales data preparation workflow")
? "1. Data validation and profiling"
aValidationResult = o1.ExecutePlan("validate", TRUE)

? ""
? "2. Data cleaning and preparation for analysis"
o2 = new stzDataWrangler(aSalesData, aSalesHeaders)
aAnalysisResult = o2.ExecutePlan("analyze", TRUE)

? ""
? "3. Final dataset ready for statistical analysis:"
aFinalSalesData = o2.ExportForStzDataSet()
? "Prepared " + len(aFinalSalesData) + " transaction records"

#-->
'
╭─────────────────────────────────╮
│ Sales data preparation workflow │
╰─────────────────────────────────╯
1. Data validation and profiling
• Executing Plan: Data Quality Validation
• Validate data types, formats, and constraints

✅ Check data type consistency...
╰─> Found 1 type inconsistencies

❌ Check numeric ranges...
╰─> Error: Error (R19) : Calling function with less number of parameters

✅ Validate text formats...
╰─> Format validation completed

❌ Identify potential outliers...
╰─> Error: Error (R19) : Calling function with less number of parameters

( Plan execution completed in 0.00 second(s): 2 successful, 2 errors )

2. Data cleaning and preparation for analysis

3. Final dataset ready for statistical analysis:
Prepared 7 transaction records

Executed in 0.02 second(s) in Ring 1.22
'

pf()
# Execution time: ~0.10 seconds

/*--- Survey response data standardization
*/
pr()

# REAL-WORLD SCENARIO: SURVEY RESPONSE STANDARDIZATION

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

o1 = new stzDataWrangler(aSurveyData, aSurveyHeaders)

? BoxRound("Survey data standardization process")

# Custom validation rules for survey data
aCustomRules = [
    ["Age", 18, 100],
    ["Income", 0, 500000]
]

? ""
? "1. Range validation with custom rules:"
aRangeIssues = o1.ValidateRanges(aCustomRules)
for issue in aRangeIssues
    ? " • " + issue
next

? ""
? "2. Comprehensive standardization:"
aStandardizationResult = o1.ExecutePlan("export", TRUE)

? ""
? "3. Export-ready survey data:"
aStandardizedSurvey = o1.ExportForStzTable()
? StzTableQ(aStandardizedSurvey).ClassName()

#-->
'
╭─────────────────────────────────────╮
│ Survey data standardization process │
╰─────────────────────────────────────╯

1. Range validation with custom rules:

2. Comprehensive standardization:
• Executing Plan: Prepare for Export
• Format data for external systems

❌ Clean column names...
╰─> Error: Bad parameter type!

❌ Replace with export-friendly values...
╰─> Error: Error (R19) : Calling function with less number of parameters

❌ Standardize date formats...
╰─> Error: Bad parameter type!

✅ Final validation check...
╰─> Export validation - 2 issues found

( Plan execution completed in 0.00 second(s): 1 successful, 3 errors )

3. Export-ready survey data:
stztable

'
pf()
# Executed in 0.02 second(s) in Ring 1.22
