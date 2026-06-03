# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #28.
#ERR Error (R14) : Calling Method without definition: numberofoccurrenceofcharleftside

load "../../stzBase.ring"

pr()

? Q("---ring").NumberOfOccurrenceOfCharLeftSide("-")
#--> 3

? Q("ring---").HowManyOccurrenceOfCharRightSide("-")
#--> 3

? Q("---سلام").NumberOfOccurrenceOfCharLeftSide("-")
#--> 3

? Q("سلام---").NumberOfOccurrenceOfCharRightSide("-")
#--> 3

#--

? Q("---ring").NumberOfOccurrenceOfCharStartSide("-")
#--> 3

? Q("ring---").HowManyOccurrenceOfCharEndSide("-")
#--> 3

? Q("---سلام").NumberOfOccurrenceOfCharEndSide("-")
#--> 3

? Q("سلام---").NumberOfOccurrenceOfCharStartSide("-")
# #--> 3

pf()
# Executed in 0.02 second(s) in Ring 1.21
