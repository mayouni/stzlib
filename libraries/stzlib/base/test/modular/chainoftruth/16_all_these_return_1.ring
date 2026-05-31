# Narrative
# --------
# # All these return 1
#
# Extracted from stzchainoftruthtest.ring, block #16.

load "../../../stzBase.ring"


? _(8).IsA(:Number).Which('IsDoubleOf(4)')._
? _(8).IsA(:Number).Which('IsEven()')._
? _(8).IsA(:Number).Which('IsEven')._
