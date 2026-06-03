# Narrative
# --------
# StartProfiler()
#
# Extracted from stzStringTest.ring, block #391.
#ERR Error (R14) : Calling Method without definition: concatenatext

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "Ring", "Python", "PHP", "JS" ])
? o1.ConcatenateXT(", ")
#--> Ring, Python, PHP, JS

? o1.ConcatenateXT(:Using = ", ")
#--> Ring, Python, PHP, JS

? o1.Concatenate()
#--> RingPythonPHPJS

? o1.ConcatenateUsing(", ")
#--> Ring, Python, PHP, JS

StopProfiler()

pf()
# Executed in 0.01 second(s)
