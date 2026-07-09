# Narrative
# --------

#
# Extracted from stzlisttest.ring, block #577.

load "../../stzBase.ring"

pr()

o1 = new stzList(1:5)

o1.RemoveW('{
	isNumber(This[@i]) and This[@i] > 3
}')

? o1.Content()
#--> [ 1, 2, 3 ]

pf()
# Executed in almost 0 second(s) in Ring 1.27
# Executed in 0.05 second(s) before
