# Narrative
# --------
# TODO
#
# Extracted from stzchainofvaluetest.ring, block #10.
#ERR Error (R24) : Using uninitialized variable: v

load "../../stzBase.ring"

pr()

Until(v).Becomes(12).DoThis('{ v += 2 ? v }')

Until(v).BecomesEqualTo(12).DoThis('{ v += 2 ? v }')
Until(v).BecomesEqualTo(12).Do_.This_('{ v += 2 ? v }')
Until(v).BecomesEqualTo(12).Do_('{ v += 2 ? v }')

pf()
