# Narrative
# --------
# stzSplitter validates its cut positions -- they must be unique and within
# range.
#
# A stzSplitter(5) splits a 5-element span, so cut positions must lie in
# 1..5. Passing [ 1, 6 ] (6 is out of range) is rejected with a clear
# error rather than silently producing garbage. We catch it here so the
# demonstration runs cleanly while still showing the guard fire.
#
# Extracted from stzlisttest.ring, block #558.

load "../../stzBase.ring"

pr()

o1 = new stzSplitter(5)

try
	? @@( o1.SplitBeforePositions([ 1, 6 ]) )
	? "(no error -- unexpected)"
catch
	? "Rejected (as expected): " + cCatchError
done
#--> Rejected (as expected): Incorrect param type! panPos must contain unique numbers between 1 and 5.

pf()
# Executed in almost 0 second(s)
