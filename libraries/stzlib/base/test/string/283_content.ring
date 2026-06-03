# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #283.
#ERR Error (R14) : Calling Method without definition: spacifyxt

load "../../stzBase.ring"

pr()

o1 = new stzString("9999999999")

o1.SpacifyXT(
	:Using     = [ " ", :AndThen = ".", :LastNChars = 2 ],
	:Step      = [ 3, 2 ],
	:Direction = [ :Backward, :AndThen = 'forward' ]
)

? o1.Content()
#--> 99 999 999.99

pf()
# Executed in 0.03 second(s).
