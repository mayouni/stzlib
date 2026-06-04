# Narrative
# --------
# Testing data type validation
#
# Extracted from stzdatawranglertest.ring, block #6.
#ERR exit 1: +----------------------+

load "../../stzBase.ring"


pr()

aCustomerHeaders = [ "Name", "Age", "Email", "Salary", "Department" ]

aCustomerData = [
    [ "John Smith", 25, "john@email.com", 50000, "Sales" ],
    [ "  Mary Jones  ", '', "mary.jones@company.com", 65000, "marketing" ],
    [ "Bob Wilson", 35, "bob@email", "NULL", 911 ],
    [ "Alice Brown", 28, "alice@email.com", 55000, "" ],
    [ "John Smith", 25, "john@email.com", 50000, "Sales" ],  # Duplicate
    [ '', "45", "unknown@email.com", 75000, "Engineering" ],
    [ "Tom Davis", -5, "tom@email.com", 999999, ["sales"] ]    # Invalid age, potential outlier salary
]

o1 = new stzDataWrangler(aCustomerData, aCustomerHeaders)

? BoxRound("DATA TYPE VALIDATION")
aTypeIssues = o1.ValidateDataTypes()

? "Type inconsistencies found: " + len(aTypeIssues)
_nTypeIssues1Len_ = ring_len(aTypeIssues)
for _iLoopTypeIssues1_ = 1 to _nTypeIssues1Len_
	issue = aTypeIssues[_iLoopTypeIssues1_]
    ? "  • " + issue
next

#-->
'
╭──────────────────────╮
│ DATA TYPE VALIDATION │
╰──────────────────────╯
Type inconsistencies found: 2
  • Column Age has mixed types: numeric, string
  • Column Department has mixed types: string, numeric, list
'

pf()
# Executed in 0.01 second(s) in Ring 1.22
