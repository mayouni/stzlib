# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #74.

load "../../stzBase.ring"

pr()

StzNamedListQ(:langs = [ :Ring, :Ruby, :Python ]) {

	? Name()
	#--> :myage

	? Content()
	#--> [ :Ring, :Ruby, :Pyhton ]

	? StzType()
	#--> :stzlist

}

pf()
# Executed in 0.03 second(s)
