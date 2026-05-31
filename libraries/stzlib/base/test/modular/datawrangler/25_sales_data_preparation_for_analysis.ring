# Narrative
# --------
# Sales data preparation for analysis
#
# Extracted from stzdatawranglertest.ring, block #25.

load "../../../stzBase.ring"


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
