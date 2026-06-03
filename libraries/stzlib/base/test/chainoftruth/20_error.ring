# Narrative
# --------
# ERROR
#
# Extracted from stzchainoftruthtest.ring, block #20.
#ERR Error (C28) : Expression is expected!

load "../../stzBase.ring"

pr()

# All these are semantically equivalent and return 1

? _("ring").ContainingNo("x")._
? _("ring").IsContainingNo("x")._

? _("ring").ContainsNo("x")._	
? _("ring").DoesNotContain("x")._

pf()
