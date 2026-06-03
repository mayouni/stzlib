# Narrative
# --------
# # All these return 1
#
# Extracted from stzchainoftruthtest.ring, block #21.

load "../../stzBase.ring"

pr()

? _("ring").ContainsNo("x").ContainsNo("y")._
? _("ring").ContainsNo("x").Nor("y")._
? _("ring").ContainsNeighther("x").Nor("y")._

pf()
