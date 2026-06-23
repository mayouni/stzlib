# Narrative
# --------
# RemoveAllExcept: keep only the listed value(s); drop everything else.
#
# The complement of a filter-remove -- everything that is NOT "♥" goes, so the
# mixed list collapses to its three hearts [ "♥","♥","♥" ] (order and
# duplicates of the kept value preserved). RemoveItemsOtherThan() is the
# spelled-out alias.
#
# Extracted from stzlisttest.ring, block #84.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "♥", 1, 2, 2, "♥", "♥", 3 ])
o1.RemoveAllExcept("♥") # Or RemoveItemsOtherThan()

? @@( o1.Content() )
#--> [ "♥", "♥", "♥" ]

pf()
# Executed in 0.04 second(s)
