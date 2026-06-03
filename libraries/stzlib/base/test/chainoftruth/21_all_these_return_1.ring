# Narrative
# --------
# # All these return 1
#
# Extracted from stzchainoftruthtest.ring, block #21.
#ERR Error (C28) : Expression is expected!

load "../../stzBase.ring"

pr()

? _("ring").ContainsNo("x").ContainsNo("y")._
? _("ring").ContainsNo("x").Nor("y")._
? _("ring").ContainsNeighther("x").Nor("y")._

pf()
