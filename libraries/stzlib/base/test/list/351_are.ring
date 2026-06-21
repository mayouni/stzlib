# Narrative
# --------
# Are() asks one question of a whole list: do ALL its items match a predicate?
#
# The predicate can be a single symbol (:Strings) or a list of symbols that
# must ALL hold for every item. Here ["ONE","TWO","THREE"] is checked against
# :Strings, then against the same spec wrapped in a list ([:Strings]), then
# against compound specs ([:Uppercase,:Strings] and [:Uppercase,:Latin,:Strings]).
# All four hold, so each call returns TRUE (printed by Ring as 1). The fifth
# call repeats the uppercase+strings check without a recorded expectation; it
# also yields TRUE. This is the universal-quantifier idiom: Are() = "for all".
#
# Extracted from stzlisttest.ring, block #351.

load "../../stzBase.ring"

pr()

? Q([ "ONE", "TWO", "THREE" ]).Are(:Strings)
#--> TRUE

? Q([ "ONE", "TWO", "THREE" ]).Are([ :Strings ])
#--> TRUE

? Q([ "ONE", "TWO", "THREE" ]).Are([ :Uppercase, :Strings ])
#--> TRUE

? Q([ "ONE", "TWO", "THREE" ]).Are([ :Uppercase, :Latin, :Strings ])
#--> TRUE

? Q([ "ONE", "TWO", "THREE" ]).Are([ :Uppercase, :Strings ])

pf()
# Executed in 0.28 second(s) in Ring 1.21
