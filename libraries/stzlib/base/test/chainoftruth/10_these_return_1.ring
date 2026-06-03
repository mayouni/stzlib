# Narrative
# --------
# # These return 1
#
# Extracted from stzchainoftruthtest.ring, block #10.

load "../../stzBase.ring"


? _("ring").IsA(:String).Which(:IsLowercase).Containing(TheLetter("g"))._
? _("ring").IsA(:String).Which(:IsLowercase).Containing(TheLetter("g")).Having('FirstChar() = "r"')._
