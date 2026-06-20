# Narrative
# --------
# TheseBoundsRemoved(open, close): the NON-mutating bound-stripper.
#
# It returns a fresh list with the matching opening/closing pair removed,
# leaving the original untouched (the mutating sibling is
# RemoveTheseBounds, shown in block #516). If the list isn't actually
# bounded by the given pair, it comes back unchanged.
#
# Extracted from stzlisttest.ring, block #518.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "{", "A", "B", "C", "}" ])

? o1.TheseBoundsRemoved("{", "}")
#--> [ "A", "B", "C" ]

pf()
# Executed in almost 0 second(s)
