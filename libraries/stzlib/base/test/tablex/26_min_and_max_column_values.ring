# Narrative
# --------
# Min and max column values
#
# Extracted from stztablextest.ring, block #26.

load "../../stzBase.ring"


pr()

oTable = new stzTable([
	[ :PRODUCT, :PRICE ],
	[ "A", 10 ],
	[ "B", 50 ],
	[ "C", 30 ]
])

oTx = new stzTablex("{mincol(price:10)}")
? oTx.Match(oTable)
#--> TRUE

oTx = new stzTablex("{maxcol(price:50)}")
? oTx.Match(oTable)
#--> TRUE

oTx = new stzTablex("{mincol(price:>0) & maxcol(price:<100)}")
? oTx.Match(oTable)
#--> TRUE

pf()
# Executed in 0.23 second(s) in Ring 1.24

#--------------------------#
#  DATA QUALITY TESTS      #
#--------------------------#
