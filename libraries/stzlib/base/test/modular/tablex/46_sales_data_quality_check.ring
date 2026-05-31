# Narrative
# --------
# Sales data quality check
#
# Extracted from stztablextest.ring, block #46.

load "../../../stzBase.ring"


pr()

oSales = new stzTable([
	[ :DATE, :PRODUCT, :AMOUNT, :QTY ],
	[ "2024-01-15", "A", 1000, 10 ],
	[ "2024-01-16", "B", 2000, 20 ],
	[ "2024-01-17", "A", 1500, 15 ]
])

# Check: has all columns, amounts are positive, products exist
oTx = new stzTablex("{cols(4) & @!nulls(product) & mincol(amount:>0) & sumcol(amount:>0)}")

? oTx.Match(oSales)
#--> TRUE

pf()
# Executed in 0.16 second(s) in Ring 1.24
