# Narrative
# --------
# # we start speeking in Compuer-natural Code (CnC)...
#
# Extracted from stzchainofvaluetest.ring, block #2.

load "../../stzBase.ring"

Whatever(:v).DoThis('{ ? "Done! Anyway." }') # or if you want...
Whatever(:v).Is.DoThis('{ ? "Done! Anyway." }')

# But if you say:
Whatever(:v).Is(5) # you get nothing and the chain is stopped!

# Let's see why:
? Whatever(:v).Is(5).WhyChainStopped() #--> Well: it's semantic error!
