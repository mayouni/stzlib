# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #964.

load "../../stzBase.ring"


o1 = new stzString("--345--89--")
o1.ReplaceSection(8, 9, "~")
? o1.Content()
# --345--~--

pf()
# Executed in 0.01 second(s).
