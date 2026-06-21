# Narrative
# --------
# Section() with a rich boundary vocabulary.
#
# One Section() accepts many ways to name its two bounds, each resolved to a
# numeric position: plain numbers (Section(1,4), order-tolerant); named pairs
# (:From = 1, :To = 4); a value present in the list (a :From value resolves to
# its FIRST occurrence, a :To value to its LAST); end-relative anchors
# (:NthToLastItem = k -> NumberOfItems()-k, :LastItem / :EndOfList -> the end);
# and the :@ mirror token (:@ adopts the partner index, and :@ on both sides
# spans the whole list). A single-position section returns a one-item list.
#
# Extracted from stzlisttest.ring, block #374.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "S", "O", "F", "T", "A", "N", "Z", "A" ])

? o1.Section(1, 4)
#--> [ "S", "O", "F", "T" ]

? o1.Section(4, 1)
#--> [ "S", "O", "F", "T" ]

? o1.Section(:From = 1, :To = 4)
#--> [ "S", "O", "F", "T" ]

? o1.Section(:From = (:NthToLastItem = 3), :To = :LastItem)
#--> [ "A", "N", "Z", "A" ]

? o1.Section(:From = "F", :To = "A")
#--> [ "F", "T", "A", "N", "Z", "A" ]

? o1.Section( :From = "A", :To = :EndOfList )
#--> [ "A", "N", "Z", "A" ]

? o1.Section(4, :@)
#--> [ "T" ]

? o1.Section(:NthToLast = 3, :@)
#--> [ "A" ]

? o1.Section(:@, :@)
#--> [ "S", "O", "F", "T", "A", "N", "Z", "A" ]

pf()
# Executed in 0.12 second(s)
