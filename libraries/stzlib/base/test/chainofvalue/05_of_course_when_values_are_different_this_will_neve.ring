# Narrative
# --------
# # Of course, when values are different, this will never execute:
#
# Extracted from stzchainofvaluetest.ring, block #5.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

SometimesWhen(:v).Is("3").DoThis('{ ? "Done! Because I am lucky ;)" }') #-->NULL
SometimesWhen(:v).Is("3").ChainStatus() #--> :Stopped
? SometimesWhen(:v).Is("3").WhyChainStopped() # Because equality will never happen,
# since values are actually different!

pf()
