# Narrative
# --------
# pr()
#
# Extracted from stztablextest.ring, block #11.

load "../../stzBase.ring"

pr()

oTable = new stzTable([
	[ :NOM, :SALARY ],
	[ "Mahran", 5000 ],
	[ "Alia", 3500 ]
])

oTx = new stzTablex("{coltype(salary:number)}")

? oTx.Match(oTable)
#--> TRUE

? @@NL(oTx.Tokens())  # Check what was parsed
#-->
'
	[
		[ "type", "coltype" ],
		[ "value", "salary:number" ],
		[ "constraints", [  ] ],
		[ "min", 1 ],
		[ "max", 1 ],
		[ "negated", 0 ],
		[ "casesensitive", 0 ]
	]
]
'

pf()
# Executed in 0.05 second(s) in Ring 1.24
