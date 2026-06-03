# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #493.

load "../../stzBase.ring"

pr()

o1 = new stzList([ :Char, :String, :Number, :List, :Object, :CObject, :QObject, :Byte ])
? o1.RemoveItemsAtThesePositionsQ( 6:8 ).Content()
#--> [ :Char, :String, :Number, :List, :Object ]

pf()
# Executed in almost 0 second(s).
