# Narrative
# --------
# Section() with a RICH boundary vocabulary -- a FEATURE STUB.
#
# The intent is one Section() that accepts many ways to name its two bounds:
# plain numbers (Section(1,4), order-tolerant), named pairs (:From=1, :To=4),
# value bounds (:From="F", :To="A"), end-relative anchors (:NthToLastItem,
# :LastItem, :EndOfList) and the :@ mirror token. Only the plain-number and
# :@ forms are implemented today; the named-param / value / anchor bounds are
# NOT, so SectionCS raises "Incorrect params! n1 and n2 must be numbers." at
# the first :From/:To call. The recorded outputs below document the intended
# full API. Left as a documented stub until the extended bounds are built
# (chip filed); see the simpler working slice in 335_section / 203_section.
#
# Extracted from stzlisttest.ring, block #374.
#ERR Incorrect params! n1 and n2 must be numbers.  (extended Section bounds pending)

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
#--> "T"

? o1.Section(:NthToLast = 3, :@)
#--> "A"

? o1.Section(:@, :@)
#--> [ "S", "O", "F", "T", "A", "N", "Z", "A" ]

//? @@( o1.Section(-99, 99) ) + NL
#--> ERROR: Line 2453 Indexes out of range! n1 and n2 must be inside the list.

pf()
# Executed in 0.12 second(s) in Ring 1.22
