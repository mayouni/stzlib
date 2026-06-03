# Narrative
# --------
# Case sensitivity in grouped check
#
# Extracted from stztablextest.ring, block #10.

load "../../stzBase.ring"


pr()

oTable = new stzTable([
	[ :DEPT ],
	[ "IT" ],
	[ "it" ],
	[ "HR" ]
])

# Case-insensitive (IT and it are same group)
oTx = new stzTablex("{grouped(dept)}")
oTx.EnableDebug()
? oTx.Match(oTable)
#--> TRUE

# Case-sensitive (IT and it are different)
oTx = new stzTablex("{@cs:grouped(dept)}")
? oTx.Match(oTable)
#--> FALSE

#--> DEBUG OUTPUT
'
=== CheckGrouped ===
Token: [ [ "type", "grouped" ], [ "value", "dept" ], [ "constraints", [ ] ], [ "min", 1 ], [ "max", 1 ], [ "negated", 0 ], [ "casesensitive", 0 ] ]
Column name: dept
Has column: 1
Case sensitive: 0
Column data: [ "IT", "it", "HR" ]
Comparing [1] 'IT' vs [2] 'it': 1
Comparing [2] 'it' vs [3] 'HR': 0
Consecutive duplicates found: 1
'

pf()
# Executed in 0.12 second(s) in Ring 1.24
