# Narrative
# --------
# Testing missing value handling with different strategies
#
# Extracted from stzdatawranglertest.ring, block #4.

load "../../../stzBase.ring"


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

# MISSING VALUES BEFORE HANDLING

	? o1._CountMissingValues()
	#--> 4

# Handle missing values with auto strategy

	nProcessed = o1.HandleMissingValues("auto")

# AFTER AUTO MISSING VALUE HANDLING:

	# Values processed
	? nProcessed
	#--> 4
	
	# Remaining missing values
	? o1._CountMissingValues()
	#--> 0

# Test different strategies (FILL ZERO STRATEGY)

o2 = new stzDataWrangler(aCustomerData, aCustomerHeaders)
nFilled = o2.HandleMissingValues("fill_zero")

	# Values filled with zero
	? nFilled
	#--> 4

pf()
# Executed in 0.01 second(s) in Ring 1.22
