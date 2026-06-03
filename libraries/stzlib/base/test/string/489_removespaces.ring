# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #489.
#ERR Error (R3) : Calling Function without definition: setkeepinghistoryto

load "../../stzBase.ring"

pr()

? Q("h e l l o").RemoveSpacesQ().UppercaseQ().Content() + NL
#--> "HELLO"

? QH("h e l l o").RemoveSpacesQ().UppercaseQ().History()
#--> [ "h e l l o", "hello", "HELLO" ]

pf()
# Executed in 0.01 second(s) in Ring 1.22
