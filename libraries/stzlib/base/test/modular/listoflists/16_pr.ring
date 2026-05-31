# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #16.

load "../../../stzBase.ring"


? Q([ "mohannad", 100, 	"loves", "ring" ]).ContainsMany([ "amer", 34 ])
#--> FALSE

? Q([ "mohannad", 100, 	"loves", "ring" ]).ContainsCS("amer", TRUE)
#--> FALSE

? Q([ "mohannad", 100, 	"loves", "ring" ]).ContainsSubList([ "loves", "ring" ])
#--> TRUE

pf()
# Executed in 0.06 second(s) in Ring 1.21
