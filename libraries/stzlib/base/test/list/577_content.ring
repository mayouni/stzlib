# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #577.
#ERR Error (R14) : Calling Method without definition: removew

load "../../stzBase.ring"

pr()

o1 = new stzList(1:5)

o1.RemoveW('{
	isNumber(This[@i]) and This[@i] > 3
}')

? o1.Content()
#--> [ 1, 2, 3 ]

pf()
# Executed in 0.05 second(s).
