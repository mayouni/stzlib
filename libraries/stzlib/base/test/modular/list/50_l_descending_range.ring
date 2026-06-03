# Narrative
# --------
# The L() small function accepts a "start:end" range string and
# produces the corresponding integer list. When start > end the
# range counts DOWN, so L('8:5') is [ 8, 7, 6, 5 ].
#
# Extracted from stzlisttest.ring, the L()-helper block.

load "../../../stzBase.ring"

pr()

? L('8:5')
#--> [ 8, 7, 6, 5 ]

pf()
