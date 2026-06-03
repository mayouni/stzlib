# Narrative
# --------
# pr()
#
# Extracted from stzsubstringTest.ring, block #11.

load "../../stzBase.ring"


o1 = new stzSubString("ring", :in = "I LOVE THE ring LANGUAGE!")

? o1.SubString()
#--> ring

? o1.String()
#--> I LOVE THE ring LANGUAGE!

? o1.CaseSensitive()
#--> TRUE

? o1.Uppercased()
#--> I LOVE THE RING LANGUAGE!

? o1.String()
#--> I LOVE THE ring LANGUAGE!

? o1.NumberOfChars()
#--> 4

pf()
# Executed in 0.05 second(s)
