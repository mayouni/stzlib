# Narrative
# --------
# JSON
#
# Extracted from stztabletest.ring, block #10.
#ERR Error (R14) : Calling Method without definition: tojsonxt

load "../../stzBase.ring"


pr()

aData = [
	[
		"product",
		[ "Apple", "Orange", "Banana" ]
	],
	[
		"price",
		[ "$1.50", "$1.20", "$0.80" ]
	],
	[
		"stock",
		[ "100", "150", "200" ]
	]
]

o1 = new stzTable(aData)
? o1.ToJsonXT()
'
{
	"product": [
		"Apple",
		"Orange",
		"Banana"
	],
	"price": [
		"$1.50",
		"$1.20",
		"$0.80"
	],
	"stock": [
		"100",
		"150",
		"200"
	]
}
'

pf()
# Executed in 0.01 second(s) in Ring 1.22
