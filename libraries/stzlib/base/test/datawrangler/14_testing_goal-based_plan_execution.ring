# Narrative
# --------
# Testing goal-based plan execution
#
# Extracted from stzdatawranglertest.ring, block #14.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

# (Dataset/headers setup -- the extraction dropped these; restored so the
#  example is self-contained.)
aMesyDataset = [
    ["  John Doe  ", "25", "john@email.com", "50000", "sales"],
    ["mary SMITH", '', "mary@company.com", "65000", "MARKETING"],
    ['', "35", "invalid-email", "NULL", "Sales"],
    ["John Doe", "25", "john@email.com", "50000", "sales"],
    ["Bob Wilson", "-5", "bob@email.com", "999999", "engineering"],
    ["Alice Brown", "28.5", "alice@email.com", '', "Sales"]
]
aMesyHeaders = ["Full_Name", "Age", "Email", "Salary", "Department"]

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
