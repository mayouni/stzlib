# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #374.

load "../../../stzBase.ring"


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
#--> "T"

? o1.Section(:NthToLast = 3, :@)
#--> "A"

? o1.Section(:@, :@)
#--> [ "S", "O", "F", "T", "A", "N", "Z", "A" ]

//? @@( o1.Section(-99, 99) ) + NL
#--> ERROR: Line 2453 Indexes out of range! n1 and n2 must be inside the list.

pf()
# Executed in 0.12 second(s) in Ring 1.22
