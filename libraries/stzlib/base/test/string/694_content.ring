# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #694.

load "../../stzBase.ring"

pr()

o1 = new stzString("one two three four")
o1.ReplaceMany([ "two", "four" ], :By = "---")
? o1.Content()
#--> "one --- three ---"

pf()
# Executed in 0.01 second(s).
