# Narrative
# --------
# pr()
#
# Extracted from stzlistofstringstest.ring, block #89.
#ERR Error (R11) : Error in class name, class not found: stzlistofstrings

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([
	:tunis, :tunis, :tunis, :gatufsa, :tunis, :tunis, :gabes,
	:tunis, :tunis, :regueb, :tuta, :regueb, "Tunis"
])

? @@( o1.FindAllCS("Tunis", :CS = FALSE) )
#--> [ 1, 2, 3, 5, 6, 8, 9, 13 ]

pf()
# Executed in 0.04 second(s)
