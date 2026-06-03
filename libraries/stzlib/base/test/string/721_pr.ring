# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #721.

load "../../stzBase.ring"


? StzStringQ("@char___@char___@char").ReplaceAllQ("@char","@item").Content()
#--> @item___@item___@item

pf()
# Executed in 0.01 second(s).
