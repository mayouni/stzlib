# Narrative
# --------
# ERRO
#
# Extracted from stzchainoftruthtest.ring, block #13.
#ERR Error (R19) : Calling function with less number of parameters

load "../../stzBase.ring"

pr()

# These return 1
? Q("ring").IsQ().InLowercaseQ().Containing("in")
? _("ring").Is('Lowercase()').Having('NumberOfchars() = 4')._

pf()
