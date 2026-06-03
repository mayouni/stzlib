# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #115.
#ERR Error (R14) : Calling Method without definition: orientation

load "../../stzBase.ring"

pr()

o1 = new stzChar("و")

? o1.Content() #--> و
? o1.Unicode() #--> 1608
? o1.NumberOfBytes() #--> 2
? o1.Orientation() #--> righttoleft
? o1.UnicodeDirectionNumber() #--> "13"
? o1.UnicodeDirection() #--> righttoleftarabic

? @@(o1.Bytes())
#--> [ "�", "�" ]

pf()
# Executed in 0.02 second(s) in Ring 1.23
