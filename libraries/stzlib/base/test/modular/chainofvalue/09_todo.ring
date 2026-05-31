# Narrative
# --------
# TODO
#
# Extracted from stzchainofvaluetest.ring, block #9.

load "../../../stzBase.ring"


OnlyWhen(v).Is.AStringQ().DoThis('{ ? "Done! As requested." }') #--> DoThis() : Do_().This_()

OnlyWhen(v).IsNotANumberQ().DoThis('{ ? "Done! As requested." }')
OnlyWhen(v).Is.NotANumberQ().DoThis('{ ? "Done! As requested." }')
OnlyWhen(v).IsNot.ANumberQ().DoThis('{ ? "Done! As requested." }')
OnlyWhen(v).Is.Not_.ANumberQ().DoThis('{ ? "Done! As requested." }')

SometimesWhen(n).IsANumberQ().DoThis('{ ? "Done! Because I am lucky ;)" }')
