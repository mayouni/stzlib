# Narrative
# --------

#
# Extracted from stzlisttest.ring, block #647.

load "../../stzBase.ring"

pr()

o1 = new stzList(  [	:name, :age, 	:job		])
? o1.AssociateWith([ 	"Ali", 	24, 	"Programmer" 	])
? @@NL( o1.Content() )
#--> [
#	[ "name", "Ali" ],
#	[ "age", 24 ],
#	[ "job", "Programmer" ]
# ]

pf()
# Executed in almost 0 second(s).
