# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #212.

load "../../../stzBase.ring"


o1 = new stzList([ 1, 2, "ring", 4, 5, "RING", 7, "Ring" ])

? o1.FindW('{
	isString(This[@i]) and This[@i] = "ring"
}')
#--> [ 3 ]

? o1.FindWCS('{
	isString(This[@i]) and This[@i] = "ring"
}', :CS = FALSE)
#--> [ 3, 6, 8 ]

pf()
# Executed in 0.13 second(s) in Ring 1.21
