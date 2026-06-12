# Narrative
# --------
# Testing initialization with 2D table data
#
# Extracted from stzdatawranglertest.ring, block #2.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

# Sample customer data with various quality issues

aCustomerHeaders = [ "Name", "Age", "Email", "Salary", "Department" ]

aCustomerData = [
    [ "John Smith", 25, "john@email.com", 50000, "Sales" ],
    [ "  Mary Jones  ", "", "mary.jones@company.com", 65000, "marketing" ],
    [ "Bob Wilson", 35, "bob@email", "NULL", "SALES" ],
    [ "Alice Brown", 28, "alice@email.com", 55000, "" ],
    [ "John Smith", 25, "john@email.com", 50000, "Sales" ],  # Duplicate
    [ "", 45, "unknown@email.com", 75000, "Engineering" ],
    [ "Tom Davis", -5, "tom@email.com", 999999, "sales" ]    # Invalid age, potential outlier salary
]

o1 = new stzDataWrangler(aCustomerData, aCustomerHeaders)

# Display initial data structure and profile

? BoxRound("TABLE DATA PROFILE")
aProfile = o1.GetDataProfile()

? "• Structure: " + aProfile[:structure]
? "• Dimensions: " + aProfile[:rows] + " rows × " + aProfile[:columns] + " columns"
? "• Data Types Summary:"

aTypesSummary = aProfile[:data_types]

_nTypesSummary1Len_ = len(aTypesSummary)
for _iLoopTypesSummary1_ = 1 to _nTypesSummary1Len_
	typeInfo = aTypesSummary[_iLoopTypesSummary1_]
    ? " ─ " + typeInfo[1] + ": " + o1._JoinList(typeInfo[2], ", ")
next

#-->
'
╭────────────────────╮
│ TABLE DATA PROFILE │
╰────────────────────╯
• Structure: table
• Dimensions: 7 rows × 5 columns
• Data Types Summary:
 ─ Name: string
 ─ Age: numeric
 ─ Email: string
 ─ Salary: numeric
 ─ Department: string
'

pf()
# Executed in 0.02 second(s) in Ring 1.22

#================================#
#  TEST SECTION 2: DATA CLEANING #
#================================#
