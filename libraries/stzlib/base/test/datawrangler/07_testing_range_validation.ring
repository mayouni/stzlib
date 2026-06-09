# Narrative
# --------
# Testing range validation
#
# Extracted from stzdatawranglertest.ring, block #7.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

aCustomerHeaders = [ "Name", "Age", "Email", "Salary", "Department" ]

aCustomerData = [
    [ "John Smith", 25, "john@email.com", 50000, "Sales" ],
    [ "  Mary Jones  ", '', "mary.jones@company.com", 65000, "marketing" ],
    [ "Bob Wilson", 35, "bob@email", "NULL", 911 ],
    [ "Alice Brown", 28, "alice@email.com", 55000, "" ],
    [ "John Smith", 25, "john@email.com", 50000, "Sales" ],  # Duplicate
    [ '', 45, "unknown@email.com", 75000, "Engineering" ],
    [ "Tom Davis", -5, "tom@email.com", 999999, "sales" ]    # Invalid age, potential outlier salary
]

o1 = new stzDataWrangler(aCustomerData, aCustomerHeaders)

# Define range rules: [ column_name, min_value, max_value ]

aRangeRules = [
    [ "Age", 18, 65 ],
    [ "Salary", 30000, 200000 ]
]

? BoxRound("RANGE VALIDATION")

aRangeIssues = o1.ValidateRanges(aRangeRules)

? "Range violations found: " + len(aRangeIssues)

_nRangeIssues1Len_ = ring_len(aRangeIssues)
for _iLoopRangeIssues1_ = 1 to _nRangeIssues1Len_
	issue = aRangeIssues[_iLoopRangeIssues1_]
    ? "  • " + issue
next

#-->
'
╭──────────────────╮
│ RANGE VALIDATION │
╰──────────────────╯
Range violations found: 2
  • Row 7, Age: -5 outside range [18, 65]
  • Row 7, Salary: 999999 outside range [30000, 200000]
'

pf()
# Executed in 0.01 second(s) in Ring 1.22
