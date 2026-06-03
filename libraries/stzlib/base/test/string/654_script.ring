# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #654.
#ERR Error (R3) : Calling Function without definition: tq

load "../../stzBase.ring"

pr()

# Let's take this example of a turkish letter ı that should be
# uppercased to İ and not I

? TQ("ı").Script()
#--> latin (in fact this is a turk letter) (TQ --> stzText object)

? Q("ı").StringCase()
#--> lowercase

? Q("İ").StringCase()
#--> uppercase

pf()
# Executed in 0.07 second(s)
