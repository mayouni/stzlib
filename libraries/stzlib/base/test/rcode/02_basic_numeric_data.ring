# Narrative
# --------
# Basic Numeric Data
#
# Extracted from stzrcodetest.ring, block #2.

load "../../stzBase.ring"


pr()

R() {
# Start of R code
@('
res <- list(
    numbers = c(1, 2, 3, 4, 5),
    mean = mean(c(1, 2, 3, 4, 5))
)
') # End of R code

# Back to Ring

Run()
? @@(Result())

}  # Closing brace of the R() object

#--> [
#    [ "numbers", [1, 2, 3, 4, 5] ],
#    [ "mean", 3 ]
# ]

pf()
# Executed in 0.31 second(s) in Ring 1.22
