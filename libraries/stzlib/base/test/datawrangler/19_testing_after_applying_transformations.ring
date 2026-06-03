# Narrative
# --------
# Testing after applying transformations
#
# Extracted from stzdatawranglertest.ring, block #19.

load "../../stzBase.ring"


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
