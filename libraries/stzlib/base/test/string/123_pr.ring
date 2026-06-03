# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #123.

load "../../stzBase.ring"


o1 = new stzString("<<***>>**<<***>>")

? o1.Between("<<", :and = ">>")
#--> [ "***", "***" ]

? o1.BoundedBy(["<<", ">>"])
#--> [ "***", "***" ]

pf()
# Executed in 0.13 second(s)
