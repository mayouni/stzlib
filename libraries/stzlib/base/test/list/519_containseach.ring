# Narrative
# --------
# Confirms a list contains every item of a probe set with ContainsEach.
#
# Softanza distinguishes "contains all of these" from "contains any of
# these". ContainsEach asks whether the host list holds every member of
# the given subset, returning a single TRUE/FALSE verdict rather than a
# per-item breakdown. ContainsEachOneOfThese is the readable alias for
# the same all-present test. Here the host holds "A", "B" and "C", so
# both calls report TRUE.
#
# Extracted from stzlisttest.ring, block #519.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "1", "2", "A", "B", "C", "3", "4" ])

? o1.ContainsEach([ "A", "B", "C" ])
#--> TRUE

? o1.ContainsEachOneOfThese([ "A", "B", "C" ])
#--> TRUE

pf()
# Executed in 0.02 second(s).
