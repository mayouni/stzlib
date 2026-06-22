# Narrative
# --------
# Replacing list content by position and by ranked occurrence of a value.
#
# Two complementary content-editing idioms on stzList. First, ReplaceAt(n, :By = x)
# swaps the element at a single 1-based position, here turning the placeholder "*"
# at position 3 into "3". Second, ReplaceNextNthOccurrenceST scans forward for a
# repeated value and edits only the chosen one: with :Of = "_", :With = "5",
# :StartingAt = 3, the scan begins at position 3 and replaces the 2nd "_" it
# finds from there (the underscore at position 5), leaving the earlier ones intact.
# The "Next...StartingAt" form lets you target a specific occurrence without
# touching identical neighbours.
#
# Extracted from stzlisttest.ring, block #442.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "1", "2", "*", "4", "5" ])

o1.ReplaceAt(3, :By = "3")
? @@( o1.Content() )
#--> [ "1", "2", "3", "4", "5" ]

o1 = new stzList([ "1", "_", "3", "_", "_" ])
o1.ReplaceNextNthOccurrenceST( 2, :Of = "_", :With = "5", :StartingAt = 3)
? @@( o1.Content() )
#--> [ "1", "_", "3", "_", "5" ]

pf()
# Executed in 0.03 second(s)  in Ring 1.21
