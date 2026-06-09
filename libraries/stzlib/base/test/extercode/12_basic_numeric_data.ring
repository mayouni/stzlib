# Narrative
# --------
# Basic Numeric Data
#
# Extracted from stzextercodetest.ring, block #12.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

R = new stzExterCode("R")

R.SetCode('
res <- list(
    numbers = c(1, 2, 3, 4, 5),
    mean = mean(c(1, 2, 3, 4, 5))
)
')

R.Execute()
? @@(R.Result())
#--> [
#    [ "numbers", [1, 2, 3, 4, 5] ],
#    [ "mean", 3 ]
# ]

? R.Duration()
#--> 0.48

pf()
# Executed in 0.49 second(s) in Ring 1.23
