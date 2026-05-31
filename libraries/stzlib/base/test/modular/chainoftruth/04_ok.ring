# Narrative
# --------
# ok
#
# Extracted from stzchainoftruthtest.ring, block #4.

load "../../../stzBase.ring"


pr()

# All these return 1:

? Q(1234).IsAQ(:Number).StzType()//WhichQ().IsEven()
? Q("ring").IsAQ(:String).WhichQ().IsLowercase()
? Q([]).IsAQ(:List).WhichQ().IsEmpty()
#TODO // an example for objects

pf()
