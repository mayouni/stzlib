# Narrative
# --------
# Testing with single column data
#
# Extracted from stzdatawranglertest.ring, block #21.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


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
