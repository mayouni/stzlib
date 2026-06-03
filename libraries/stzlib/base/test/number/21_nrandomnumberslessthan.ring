# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #21.

load "../../stzBase.ring"

pr()

? NRandomNumbersLessThan(3, 17_000)
#--> [ 16_997, 16_998, 16_998 ]

? 5RandomNumbersLessThan(17_000)
#--> [ 16_998, 16_997, 16_999, 16_997, 16_997 ]

pf()
# Executed in 0.04 second(s) in Ring 1.19
