# Narrative
# --------
# pr()
#
# Extracted from stzrandomtest.ring, block #1.

load "../../../stzBase.ring"


nCards = 1:52
oGameDeck = new stzList(nCards)

oGameDeck.Randomize()
anPlayerHand = oGameDeck.FirstN(5)

? @@(anPlayerHand)
#--> #--> [ 48, 20, 6, 51, 35 ]

pf()
# Executed in 0.01 second(s) in Ring 1.23
