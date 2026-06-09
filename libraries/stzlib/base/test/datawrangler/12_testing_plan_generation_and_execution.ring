# Narrative
# --------
# Testing plan generation and execution
#
# Extracted from stzdatawranglertest.ring, block #12.
#ERR Error (C22) : Function redefinition, function is already defined!

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

? BoxRound("GENERATING BASIC CLEANUP PLAN")
aPlan = o1.GeneratePlan("clean")
? " • Plan: " + aPlan[:title]
? " • Description: " + aPlan[:description]
? " • Steps:"
_aPlansteps1_ = aPlan[:steps]
_nPlansteps1Len_ = ring_len(_aPlansteps1_)
for _iLoopPlansteps1_ = 1 to _nPlansteps1Len_
	stepp = _aPlansteps1_[_iLoopPlansteps1_]
    ? "  ─ " + stepp[:description]
next

? ""
? BoxRound("EXECUTING BASIC CLEANUP PLAN")
aResult = o1.ExecutePlan("clean", TRUE)

? ""
? BoxRound("EXECUTION SUMMARY")
? " • Plan executed: " + aResult[:plan][:title]
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
