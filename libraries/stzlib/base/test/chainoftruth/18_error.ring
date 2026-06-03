# Narrative
# --------
# ERROR
#
# Extracted from stzchainoftruthtest.ring, block #18.
#ERR Error (R24) : Using uninitialized variable: pthing

load "../../stzBase.ring"

pr()

? _("ring").IsNotA(:String)._	#--> FALSE
? _("ring").IsNotA(:String).Which('Contains("x")')._	#--> TRUE
? _("ring").IsNotA(:String).Which('Contains("i")')._	#--> FALSE

pf()
