# Narrative
# --------
# pr()
#
# Extracted from stztabletest.ring, block #11.

load "../../../stzBase.ring"


cJson = '{
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
}'


? IsJson(cJson)
#--> TRUE


o1 = new stzTable([])
o1.FromJson(cJson)
o1.Show()
'
╭─────────┬───────┬───────╮
│ Product │ Price │ Stock │
├─────────┼───────┼───────┤
│ Apple   │ $1.50 │   100 │
│ Orange  │ $1.20 │   150 │
│ Banana  │ $0.80 │   200 │
╰─────────┴───────┴───────╯
'

pf()
# Executed in 0.06 second(s) in Ring 1.22
