# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #802.
#ERR Error (R14) : Calling Method without definition: removerightoccurrenceq

load "../../stzBase.ring"

pr()

o1 = new stzString("<<script>>func return :done<<script>>")
? o1.RemoveAllQ("<<script>>").Content()
#--> "func return :done"

o1 = new stzString("<<script>>func return :done<<script>>")
? o1.RemoveLeftOccurrenceQ("<<script>>").Content()
#--> "func return :done<<script>>"

o1 = new stzString("<<script>>func return :done<<script>>")
? o1.RemoveRightOccurrenceQ("<<script>>").Content()
#--> "<<script>>func return :done"

o1.RemoveNFirstChars(10)
? o1.Content()
#--> "func return :done"

pf()
# Executed in 0.01 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.17
