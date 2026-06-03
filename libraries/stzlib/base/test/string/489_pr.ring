# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #489.

load "../../stzBase.ring"


? Q("h e l l o").RemoveSpacesQ().UppercaseQ().Content() + NL
#--> "HELLO"

? QH("h e l l o").RemoveSpacesQ().UppercaseQ().History()
#--> [ "h e l l o", "hello", "HELLO" ]

pf()
# Executed in 0.01 second(s) in Ring 1.22
