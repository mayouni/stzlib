# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #477.
#ERR Error (R14) : Calling Method without definition: itemswxt

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "m", "n", "B", "A", "x", "C", "z", "B" ])

? o1.ItemsWXT( :Where = 'Q(@item).IsAnUppercase()')
#--> [ "A", "B", "A", "C", "B" ]

? ElapsedTime() + NL
#--> 0.18 second(s)

# The other extended form (provides more features, like code transpilation
# and executable section identification) takes more time ( about 0.92 second).
? o1.ItemsWXT( :Where = 'Q(@item).IsAnUppercase()')
#--> #--> [ "A", "B", "A", "C", "B" ]

pf()
# Executed in 0.29 second(s).
