# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #285.
#ERR Error (R14) : Calling Method without definition: spacifyxt

load "../../stzBase.ring"

pr()

o1 = new stzString("99999999999999")
o1.SpacifyXT(
	:Using     = [ " ", :AndThen = ".", :LastNChars = 6 ],
	:Step      = [ 2, :AndThen = 3],
	:Direction = :Backward
)

? o1.Content()
#--> 99 99 99 99.999 999

StopProfiler()

pf()
# Executed in 0.02 second(s) in Ring 1.21
