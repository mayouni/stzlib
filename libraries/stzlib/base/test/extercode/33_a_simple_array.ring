# Narrative
# --------
# A simple array
#
# Extracted from stzextercodetest.ring, block #33.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

njs = new stzExterCode("nodejs")
njs.SetCode('

// Create a simple array
const res = [10, 20, 30, 40, 50];

') # End of NodeJS code

njs.Execute()
? @@( njs.Result() )
#--> [10, 20, 30, 40, 50]

pf()
# Executed in 0.34 second(s) in Ring 1.23
