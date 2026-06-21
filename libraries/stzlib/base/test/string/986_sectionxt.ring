# Narrative
# --------
# stzString.SectionXT(): the order-tolerant, negative-aware substring slicer.
#
# Section(n1, n2) returns the substring between two positions. The XT variant
# relaxes the bounds: SectionXT(5, 3) treats the pair as unordered and yields
# the same window as Section(3, 5) -> "345". A negative second argument is read
# as a length walking forward from the first position, so SectionXT(5, -3)
# takes 3 characters starting at position 5 -> "567". The Softanza idiom is to
# let the operation normalize sloppy bounds instead of forcing the caller to
# pre-sort them.
#
# Repositioned from test/list (stzlisttest.ring, block #202): this is a
# stzString test, so it belongs under test/string.

load "../../stzBase.ring"

pr()

o1 = new stzString("123456789")

? o1.SectionXT(5, 3) # Same as Section(3, 5)
#--> 345

? o1.SectionXT(5, -3)
#--> 567

pf()
# Executed in 0.01 second(s) in Ring 1.21
