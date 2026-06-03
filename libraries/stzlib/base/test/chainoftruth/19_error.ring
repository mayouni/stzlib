# Narrative
# --------
# ERROR
#
# Extracted from stzchainoftruthtest.ring, block #19.
#ERR Error (C28) : Expression is expected!

load "../../stzBase.ring"

pr()

# All these return 1

# Well, nothing prevents you from saying
? _("ring").Containing("i")._
# But, it's linguistically more elegant to say:
? _("ring").Contains("i")._
# or
? _("ring").IsContaining("i")._

pf()
