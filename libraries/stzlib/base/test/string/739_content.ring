# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #739.

load "../../stzBase.ring"

pr()

o1 = new stzString("Use these two letters: س and ص.")
o1.ReplaceAllChars( :With = "*" )
? o1.Content()
#--> "*******************************"

pf()
# Executed in 0.01 second(s).
