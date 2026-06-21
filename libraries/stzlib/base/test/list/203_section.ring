# Narrative
# --------
# Slicing a list four ways: Section / SectionXT / Range / RangeXT.
#
# Section(n1, n2) returns the contiguous run between two 1-based positions and
# normalizes order, so Section(3,5) and Section(5,3) both give the forward
# slice. SectionXT is the eXtended form: an endpoint may be NEGATIVE (counts
# back from the end, so -3 = position 5), and when the (normalized) first
# index exceeds the second the slice comes back REVERSED -- which is why
# SectionXT(-3,3) yields [ "5","4","3" ]. Range(start, count) takes a length
# rather than an end position; RangeXT adds the negative-start convenience
# (-5 = position 3) and routes through SectionXT.
#
# (The original recorded outputs were an inconsistent design sketch -- e.g.
# they expected RangeXT to walk backward; the values below are the real run
# against the restored negative-index SectionXT/RangeXT.)
#
# Extracted from stzlisttest.ring, block #203.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "1", "2", "3", "4", "5", "6", "7" ])

? o1.Section(3, 5)
#--> [ "3", "4", "5" ]

? o1.Section(5, 3)
#--> [ "3", "4", "5" ]

? o1.SectionXT(3, -3)
#--> [ "3", "4", "5" ]

? o1.SectionXT(-3, 3)
#--> [ "5", "4", "3" ]

? o1.Range(3, 3)
#--> [ "3", "4", "5" ]

? o1.RangeXT(3, 3)
#--> [ "3", "4", "5" ]

? o1.RangeXT(-5, 3)
#--> [ "3", "4", "5" ]

pf()
# Executed in almost 0 second(s)
