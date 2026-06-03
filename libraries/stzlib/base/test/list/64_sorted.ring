# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #64.

load "../../stzBase.ring"

pr()

o1 = new stzList([ ["03", "04"], 3, ["01","02"], 1, "Two", 2, "One" ])
? @@( o1.Sorted() ) # Or o1.SortedInAscending()
#--> [ 1, 2, 3, "One", "Two", [ "01", "02" ], [ "03", "04" ] ]

? @@( o1.SortedInDescending() )
#--> [ [ "03", "04" ], [ "01", "02" ], "Two", "One", 3, 2, 1 ]

pf()
# Executed in 0.06 second(s)
