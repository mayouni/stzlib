# Narrative
# --------
# ERROR
#
# Extracted from stzchainoftruthtest.ring, block #18.

load "../../stzBase.ring"

pr()

? _("ring").IsNotA(:String)._	#--> FALSE
? _("ring").IsNotA(:String).Which('Contains("x")')._	#--> TRUE
? _("ring").IsNotA(:String).Which('Contains("i")')._	#--> FALSE

pf()
