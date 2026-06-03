# Narrative
# --------
# Complex nested conditions
#
# Extracted from stztablextest.ring, block #35.

load "../../stzBase.ring"


pr()

oTable = new stzTable([
	[ :ID, :NAME, :AGE, :SALARY ],
	[ 1, "Ali", 28, 45000 ],
	[ 2, "Sara", 32, 52000 ]
])

oTx = new stzTablex("{(cols(3) | cols(4)) & unique(id) & (avgcol(salary:>40000) | avgcol(age:>30))}")
? oTx.Match(oTable)
#--> TRUE

pf()
# Executed in 0.08 second(s) in Ring 1.24

#--------------------------#
#  MULTIPLE TABLE MATCHING #
#--------------------------#
