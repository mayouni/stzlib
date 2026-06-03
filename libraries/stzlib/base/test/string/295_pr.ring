# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #295.

load "../../stzBase.ring"


? @@( Q(" ").Unspacified() )
#--> ""

? @@( Q("  ").Unspacified() )
#--> " "

? @@( Q("   ").Unspacified() )
#--> " "

? @@( Q(" ♥").Unspacified() )
#--> "♥"

? @@( Q("♥ ").Unspacified() )
#--> "♥"

? @@( Q(" ♥ ").Unspacified() )
#--> "♥"

? Q("r  in  g ").Unspacified() # Does not remove spaces inside!
#--> "r  in  g"

? Q("    r  in  g ").Unspacified()
#--> "r  in  g"

pf()
# Executed in 0.02 second(s).
