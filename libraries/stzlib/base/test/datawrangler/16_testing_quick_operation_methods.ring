# Narrative
# --------
# Testing quick operation methods
#
# Extracted from stzdatawranglertest.ring, block #16.

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
