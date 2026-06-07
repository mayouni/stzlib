# Narrative
# --------
# ok
#
# Extracted from stzchainoftruthtest.ring, block #4.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

# All these return 1:

? Q(1234).IsAQ(:Number).StzType()//WhichQ().IsEven()
? Q("ring").IsAQ(:String).WhichQ().IsLowercase()
? Q([]).IsAQ(:List).WhichQ().IsEmpty()
#TODO // an example for objects

pf()
