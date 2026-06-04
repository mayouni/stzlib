# Narrative
# --------
# pr()
#
# Extracted from stzGlobalTest.ring, block #13.
#ERR TIMEOUT (>15s)

load "../../stzBase.ring"

pr()

# Contrariwise, this Ring for/in loop takes too long to complete!
# (500 thousand times and not 5 million like in the example above!)

_a1500_0001_ = 1:500_000
_n1500_0001Len_ = ring_len(_a1500_0001_)
for _iLoop1500_0001_ = 1 to _n1500_0001Len_
	n = _a1500_0001_[_iLoop1500_0001_]
	// Do nothing
next

# In Notepad 1.19+, click on the pause button on the right of the Input control
# at the bottom of the Output window to stop the execution;

pf()
