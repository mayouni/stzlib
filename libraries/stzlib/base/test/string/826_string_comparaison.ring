# Narrative
# --------
# STRING COMPARAISON
#
# Extracted from stzStringTest.ring, block #826.
#ERR Error (R41) : Invalid numeric string

load "../../stzBase.ring"


pr()

o1 = new stzString("reserve")
? o1.UnicodeCompareWithCS("RESERVE", :CaseSensitive = FALSE )
#--> :Equal

o1 = new stzString("réservé")
? o1.UnicodeCompareWithCS("RESERVE", :CaseSensitive = FALSE )
#--> :Greater

o1 = new stzString("reserv")
? o1.UnicodeCompareWithCS("RESERVE", :CaseSensitive = FALSE )
#--> :Less

pf()
# Executed in 0.01 second(s).
