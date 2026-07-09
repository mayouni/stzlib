# Narrative
# --------
# Finding list positions by a boolean condition block: FindW and FindWCS.
#
# FindW evaluates a code block against each item (This[@i] is the current
# element, @i its 1-based index) and returns the positions where the block is
# true. Here the block keeps string items equal to "ring", so only position 3
# qualifies, yielding [ 3 ].
#
# FindWCS adds a :CS dial, but the dial governs the engine's own matching, not
# the literal "=" written inside the user block: Ring's "=" stays case-
# sensitive, so the block still matches only the exact "ring". Hence
# FindWCS(..., :CS = FALSE) also returns just [ 3 ] -- "RING" and "Ring" are
# not matched by the block's own equality test.
#
# Extracted from stzlisttest.ring, block #212.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2, "ring", 4, 5, "RING", 7, "Ring" ])

? o1.FindW('{
	isString(This[@i]) and This[@i] = "ring"
}')
#--> [ 3 ]

? o1.FindWCS('{
	isString(This[@i]) and This[@i] = "ring"
}', :CS = FALSE)
#--> [ 3 ]

pf()
# Executed in almost 0 second(s) in Ring 1.27
# Executed in 0.13 second(s) before
