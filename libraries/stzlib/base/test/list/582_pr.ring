# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #582.
#ERR Error (R50) : Object does not support operator overloading

load "../../stzBase.ring"

pr()

o1 = new stzList(["file1", "file2", "file3" ])

? @@( o1 / 3 ) + NL
#--> [ [ "file1" ], [ "file2" ], [ "file3" ] ]

# o1 content remains the same:

? @@( o1.Content() )
#--> [ "file1", "file2", "file3" ]

pf()
# Executed in 0.02 second(s).
