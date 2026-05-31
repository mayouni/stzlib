# Narrative
# --------
# Checking column names
#
# Extracted from stztablextest.ring, block #13.

load "../../../stzBase.ring"


pr()

oTable = new stzTable([
	[ :EMPLOYEE, :SALARY, :DEPARTMENT ],
	[ "Ali", 45000, "IT" ],
	[ "Sara", 52000, "HR" ]
])

oTx = new stzTablex("{colname(employee)}")
? oTx.Match(oTable)
#--> TRUE

oTx = new stzTablex("{colname(salary) & colname(department)}")
? oTx.Match(oTable)
#--> TRUE

oTx = new stzTablex("{colname(bonus)}")
? oTx.Match(oTable)
#--> FALSE

pf()
# Executed in 0.14 second(s) in Ring 1.24
