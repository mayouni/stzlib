# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #61.

load "../../../stzBase.ring"


o1 = new stzString("whatisyournameplease?")
o1.SpacifySubStringsUsing(["is", "your", "name"], "_")
#--> what_is_your_name_please?

? o1.Content()

pf()
# Executed in 0.09 second(s)
