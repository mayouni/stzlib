# Narrative
# --------
# Replacing a positional section with a many-item list of a different size.
#
# ReplaceSectionByMany(n1, n2, aItems) excises the slice spanning positions
# n1..n2 (here 4..6, the three items "1","2","3") and splices the replacement
# list in its place. The replacement need not match the slice length: three
# removed items give way to four "*" items, so the list grows by one. The
# bordering items ("A","B","C" before, "D","E" after) keep their order and
# simply close around the new middle, demonstrating the size-flexible,
# range-anchored editing that distinguishes this from a one-to-one swap.
#
# Extracted from stzlisttest.ring, block #499.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", "C", "1", "2", "3", "D", "E" ])
o1.ReplaceSectionByMany(4, 6, [ "*", "*", "*", "*" ])
? @@( o1.Content() )
#--> [ "A", "B", "C", "*", "*", "*", "*", "D", "E" ]

pf()
# Executed in almost 0 second(s).
