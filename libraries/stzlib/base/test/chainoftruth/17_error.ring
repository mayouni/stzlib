# Narrative
# --------
# ERROR
#
# Extracted from stzchainoftruthtest.ring, block #17.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"

pr()

# All these return 1

? _(9).IsNot('DoubleOf(4)')._
? _(9).IsA(:Number).Which('IsNotEven')._
? _(9).IsNotA(:Number).Which('IsEven')._

pf()
