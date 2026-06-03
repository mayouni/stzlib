# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #577.

load "../../stzBase.ring"


o1 = new stzList(1:5)

o1.RemoveW('{
	isNumber(This[@i]) and This[@i] > 3
}')

? o1.Content()
#--> [ 1, 2, 3 ]

pf()
# Executed in 0.05 second(s).
