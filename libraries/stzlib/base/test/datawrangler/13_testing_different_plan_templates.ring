# Narrative
# --------
# Testing different plan templates
#
# Extracted from stzdatawranglertest.ring, block #13.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"


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
