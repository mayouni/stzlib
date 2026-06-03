# Narrative
# --------
# ERROR
#
# Extracted from stzchainoftruthtest.ring, block #6.
#ERR Error (C28) : Expression is expected!

load "../../stzBase.ring"

pr()

# All these return 1:

? _("Ring").IsA(:String).Where('NumberOfChars() = 4')._
? _("Ring").IsA(:String).Having('FirstChar() = "R"')._
? _("Ring").IsA(:String).That('Contains("in")')._
? _("Ring").IsA(:String).Containing('in')._

pf()
