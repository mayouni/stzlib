# Narrative
# --------
# pr()
#
# Extracted from stzrandomtest.ring, block #23.

load "../../stzBase.ring"

pr()

? AllNumbersInQQX([ -2, -4, -21 ]).AreNegativeX()
#--> TRUE

? AllNumbersInQQX([ -2, 8, -4, -21 ]).AreNegativeX()
#--> FALSE

#--

? NoNumberInQQX([ -2, -4, -21 ]).IsPositiveX()
#--> TRUE

? NoNumberInQQX([  -2, -4, -21, 10800 ]).IsPositiveX()
#--> FALSE

? NoNumberInQQX([ 2, 4, 21 ]).IsNegativeX()
#--> TRUE

? NoNumberInQQX([  2, 4, 21, -10800 ]).IsNegativeX()
#--> FALSE

pf()
# Executed in 0.02 second(s) in Ring 1.22
