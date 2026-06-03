# Narrative
# --------
# _("G").IsThe(:Lowercase).Of("g")._
#
# Extracted from stzchainoftruthtest.ring, block #25.
#ERR Error (R13) : Object is required

load "../../stzBase.ring"

pr()

? _("G").IsAString().Which(:IsLetter)._

pf()
