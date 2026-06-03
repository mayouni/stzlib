# Narrative
# --------
# ERROR
#
# Extracted from stzchainoftruthtest.ring, block #17.

load "../../stzBase.ring"

pr()

# All these return 1

? _(9).IsNot('DoubleOf(4)')._
? _(9).IsA(:Number).Which('IsNotEven')._
? _(9).IsNotA(:Number).Which('IsEven')._

pf()
