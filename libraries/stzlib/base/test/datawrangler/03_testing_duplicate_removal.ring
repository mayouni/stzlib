# Narrative
# --------
# Testing duplicate removal
#
# Extracted from stzdatawranglertest.ring, block #3.

load "../../stzBase.ring"


pr()

aCustomerHeaders = [ "Name", "Age", "Email", "Salary", "Department" ]

aCustomerData = [
    [ "John Smith", 25, "john@email.com", 50000, "Sales" ],
    [ "  Mary Jones  ", '', "mary.jones@company.com", 65000, "marketing" ],
    [ "Bob Wilson", 35, "bob@email", "NULL", "SALES" ],
    [ "Alice Brown", 28, "alice@email.com", 55000, "" ],
    [ "John Smith", 25, "john@email.com", 50000, "Sales" ],  # Duplicate
    [ '', 45, "unknown@email.com", 75000, "Engineering" ],
    [ "Tom Davis", -5, "tom@email.com", 999999, "sales" ]    # Invalid age, potential outlier salary
]

o1 = new stzDataWrangler(aCustomerData, aCustomerHeaders)

# BEFORE DUPLICATE REMOVAL

? "Initial row count: " + o1._GetRowCount()

# Remove duplicates

nDuplicatesRemoved = o1.RemoveDuplicates()

# AFTER DUPLICATE REMOVAL

? "Duplicates removed: " + nDuplicatesRemoved
? "New row count: " + o1._GetRowCount()

#-->
'
Initial row count: 7
Duplicates removed: 1
New row count: 6
'

pf()
# Executed in 0.01 second(s) in Ring 1.22
