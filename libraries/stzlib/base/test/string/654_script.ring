# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #654.
#ERR exit 1: Line 98 Bad parameters value, error in length!

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
