# Narrative
# --------
# TODO
#
# Extracted from stzchainofvaluetest.ring, block #11.

load "../../../stzBase.ring"


Until(v).BecomesEqualTo("1000").Execute('{ v += "0" ? v }')
Execute('{ v += "0" ? v }').Until(v).BecomesEqualTo("1000")
Unless.
