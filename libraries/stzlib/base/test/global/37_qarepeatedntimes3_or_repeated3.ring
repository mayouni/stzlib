# Narrative
# --------
# ? Q("A").RepeatedNTimes(3) # Or Repeated(3)
#
# Extracted from stzGlobalTest.ring, block #37.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

#--> "AAA"

? @@( Q([1,2]).RepeatedNTimes(3) ) # Or Repeated(3)
#--> [ [ 1, 2 ], [ 1, 2 ], [ 1, 2 ] ]

? Q(10).RepeatedNTimes(3) # Or Repeated(3)
#--> [ 30, 30, 30 ]

# Don't confuse it with
? Q(10).Times(3)
#--> 30

pf()
