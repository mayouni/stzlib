# Narrative
# --------
# Section / SectionXT slice a stzList between two positions, with named and
# mirror-index anchors.
#
# Section(n1, n2) returns the contiguous run from position n1 to n2 inclusive
# (order-normalized). SectionXT additionally accepts a NEGATIVE endpoint that
# counts back from the end (-2 == two-from-last), so SectionXT(2,-2) == the
# [2..4] slice. Both ends also accept the named markers :First / :Last, so
# Section(:First, :Last) reproduces the whole list. The :@ marker mirrors the
# partner index: Section(3, :@) and Section(:@, 3) both mean Section(3, 3),
# yielding the single-item slice [ "3" ].
#
# Extracted from stzlisttest.ring, block #335.

load "../../stzBase.ring"

pr()

o1 = new stzList(["1","2","3","4","5"])

? o1.Section(2, 4)
#--> [ "2", "3", "4" ]

? o1.SectionXT(2, -2)
#--> [ "2", "3", "4" ]

? o1.Section(:First, :Last)
#--> [ "1", "2", "3", "4", "5" ]

? o1.Section(3, :@)
#--> [ "3" ]

? o1.Section(:@, 3)
#--> [ "3" ]

pf()
# Executed in 0.01 second(s)
