# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #693.

load "../../stzBase.ring"


o1 = new stzString("one two three four")
o1.ReplaceAll( "two", "---")
? o1.Content()
#--> "one --- three four"

pf()
# Executed in 0.01 second(s).
