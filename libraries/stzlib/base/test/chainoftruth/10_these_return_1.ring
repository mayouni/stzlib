# Narrative
# --------
# # These return 1
#
# Extracted from stzchainoftruthtest.ring, block #10.
#ERR Error (C28) : Expression is expected!

load "../../stzBase.ring"

pr()

? _("ring").IsA(:String).Which(:IsLowercase).Containing(TheLetter("g"))._
? _("ring").IsA(:String).Which(:IsLowercase).Containing(TheLetter("g")).Having('FirstChar() = "r"')._

pf()
