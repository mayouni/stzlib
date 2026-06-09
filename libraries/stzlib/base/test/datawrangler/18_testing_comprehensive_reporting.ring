# Narrative
# --------
# Testing comprehensive reporting
#
# Extracted from stzdatawranglertest.ring, block #18.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


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
    _nIssues1Len_ = ring_len(aIssues)
    for _iLoopIssues1_ = 1 to _nIssues1Len_
    	issue = aIssues[_iLoopIssues1_]
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
