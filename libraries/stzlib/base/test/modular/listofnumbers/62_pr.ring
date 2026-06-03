# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #62.

load "../../../stzBase.ring"


o1 = new stzString("whatisyournameplease?")

o1.SpacifySubStringsUsing(["is", "your", "name"], " ")
? o1.Content()
#--> what is your name please?

pf()
# Executed in 0.10 second(s)
