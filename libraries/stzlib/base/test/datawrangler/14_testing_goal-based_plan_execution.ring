# Narrative
# --------
# Testing goal-based plan execution
#
# Extracted from stzdatawranglertest.ring, block #14.

load "../../stzBase.ring"


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
