# Narrative
# --------
# TODO
#
# Extracted from stzchainofvaluetest.ring, block #10.

load "../../stzBase.ring"

pr()

Until(v).Becomes(12).DoThis('{ v += 2 ? v }')

Until(v).BecomesEqualTo(12).DoThis('{ v += 2 ? v }')
Until(v).BecomesEqualTo(12).Do_.This_('{ v += 2 ? v }')
Until(v).BecomesEqualTo(12).Do_('{ v += 2 ? v }')

pf()
