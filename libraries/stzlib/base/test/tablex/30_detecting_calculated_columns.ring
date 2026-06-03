# Narrative
# --------
# Detecting calculated columns
#
# Extracted from stztablextest.ring, block #30.

load "../../stzBase.ring"


pr()

oTable = new stzTable([
	[ :PRICE, :QTY ],
	[ 100, 5 ],
	[ 200, 3 ]
])

# Add calculated total column
oTable.AddCalculatedCol(:TOTAL, '@(:PRICE) * @(:QTY)')

oTx = new stzTablex("{calculated(total)}")
? oTx.Match(oTable)
#--> TRUE

oTx = new stzTablex("{calculated(price)}")
? oTx.Match(oTable)
#--> FALSE

pf()
# Executed in 0.14 second(s) in Ring 1.24
