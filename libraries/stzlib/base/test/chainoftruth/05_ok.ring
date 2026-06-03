# Narrative
# --------
# ok
#
# Extracted from stzchainoftruthtest.ring, block #5.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"

pr()

# All these are 0:

? _(1234).IsA(:String).Which(:IsEven)._
? _("ring").IsA(:Number).Which(:IsUppercase)._
? _("ring").IsA(:String).Which(:IsUppercase)._
#TODO // an example for objects

pf()
