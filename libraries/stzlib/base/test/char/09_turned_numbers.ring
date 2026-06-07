# Narrative
# --------
# TURNED NUMBERS
#
# Extracted from stzchartest.ring, block #9.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

? @@(TurnedNumbersUnicodes())
#--> [ 8586, 8587 ]

? @@(TurnedNumbers()) #NOTE: Idem
#--> [ "↊", "↋" ]

? @@( Q([ "↊", "↋" ]).Names() )
#--> [ "TURNED DIGIT TWO", "TURNED DIGIT THREE" ]

? @@(TurnedNumbersXT()) # Or TurnedNumberAndTheirUnicodes()
#--> [ [ "↊", 8586 ], [ "↋", 8587 ] ]

pf()
# Executed in 0.09 second(s) in Ring 1.23
# Executed in 0.51 second(s) in Ring 1.20
