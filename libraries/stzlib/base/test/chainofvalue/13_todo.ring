# Narrative
# --------
# TODO
#
# Extracted from stzchainofvaluetest.ring, block #13.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

//Until(v).Becomes.EqualTo(12).DoThis('{ v += 2 ? v }')
#Until(v).Becomes.DoubleOf(6).DoThis('{ v += 2 ? v }')

pf()
