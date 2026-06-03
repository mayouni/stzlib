# Narrative
# --------
# Testing chainable operations
#
# Extracted from stzdatawranglertest.ring, block #17.

load "../../stzBase.ring"


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
