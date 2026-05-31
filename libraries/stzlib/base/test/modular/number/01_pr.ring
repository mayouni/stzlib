# Narrative
# --------
# pr()
#
# Extracted from stznumbertest.ring, block #1.

load "../../../stzBase.ring"


nOriginalPrice = 150
nDiscountRate = 15

nDiscountAmount = NPercentOf(nDiscountRate, nOriginalPrice)
nFinalPrice = nOriginalPrice - nDiscountAmount

? nFinalPrice
#--> 127.50

pf()
# Executed in almost 0 second(s) in Ring 1.23
