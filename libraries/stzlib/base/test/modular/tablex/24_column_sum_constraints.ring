# Narrative
# --------
# Column sum constraints
#
# Extracted from stztablextest.ring, block #24.

load "../../../stzBase.ring"


pr()

oTable = new stzTable([
	[ :PRODUCT, :SALES ],
	[ "A", 10000 ],
	[ "B", 20000 ],
	[ "C", 30000 ]
])

oTx = new stzTablex("{sumcol(sales:60000)}")
? oTx.Match(oTable)
#--> TRUE

oTx = new stzTablex("{sumcol(sales:>50000)}")
? oTx.Match(oTable)
#--> TRUE

oTx = new stzTablex("{sumcol(sales:<50000)}")
? oTx.Match(oTable)
#--> FALSE

pf()
# Executed in 0.17 second(s) in Ring 1.24
