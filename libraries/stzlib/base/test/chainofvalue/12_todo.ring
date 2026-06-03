# Narrative
# --------
# TODO
#
# Extracted from stzchainofvaluetest.ring, block #12.

load "../../stzBase.ring"

pr()

? Until(v).Becomes.ANumber().DoThis('{
		v += "0"

		if v = "1000"
			v = 0+ v
		ok

		? v + " : " + ring_type(v)
}')

pf()
