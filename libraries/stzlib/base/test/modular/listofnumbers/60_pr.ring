# Narrative
# --------
# pr()
#
# Extracted from stzlistofnumberstest.ring, block #60.

load "../../../stzBase.ring"


o1 = new stzString("helloringprogrammer!")
o1.SpacifySubStringUsing("ring", "_")
? o1.Content()
#--> hello_ring_programmer!

pf()
# Executed in 0.04 second(s)
