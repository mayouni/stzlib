# Narrative
# --------
# pr()
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
