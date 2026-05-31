# Narrative
# --------
# Employee database validation
#
# Extracted from stztablextest.ring, block #45.

load "../../../stzBase.ring"


pr()

oEmployees = new stzTable([
	[ :ID, :NAME, :EMAIL, :SALARY, :DEPT ],
	[ 1, "Ali Hassan", "ali@company.com", 45000, "IT" ],
	[ 2, "Sara Ahmed", "sara@company.com", 52000, "HR" ],
	[ 3, "Omar Ali", "omar@company.com", 48000, "IT" ]
])

# Validate: unique IDs, no null emails, reasonable salaries
oTx = new stzTablex("{unique(id) & @!nulls(email) & avgcol(salary:>40000) & avgcol(salary:<60000)}")

? oTx.Match(oEmployees)
#--> TRUE

pf()
# Executed in 0.19 second(s) in Ring 1.24
