# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #402.

load "../../stzBase.ring"


o1 = new stzList([ 1, 2, 3 ])

? @@( o1 * 3 )	#--> Leads to a normal Ring list
#--> [ 1, 2, 3, 1, 2, 3, 1, 2, 3 ]

? @@( o1 * Q(3) / 3 ) + NL
#     \___ ___/   \__ Leads to an output as a normal Ring list
#         V
#   A stzList object due to the use of the Q() small function

#--> [ [ 1, 2, 3 ], [ 1, 2, 3 ], [ 1, 2, 3 ] ]

#---

? Q([ "file1", "file2", "file3" ]) * ".ring"
#--> [ "file1.ring", "file2.ring", "file3.ring" ]

? ( Q([ "file1", "file2", "file3" ]) * Q(".ring") ) .Uppercased()
#   \______________________ ______________________/ \_____ _____/
#                          V                              V
#               StzList object (via Q())           Applied to the stzList object

#--> [ "FILE1.RING", "FILE2.RING", "FILE3.RING" ]


? Q([ "file1", "file2", "file3" ]) * Q(".ring").Uppercased()
#   \_____________ _____________/    \__________ _________/
#                 V                             V
#      StzList object (via Q())    An uppercasded ".RING" string
#
#   \__________________________ _________________________/
#                              V
# ~> Equivalent to: ? Q[ "file1", "file2", "file3" ]) * ".RING"

#--> [ "file1.RING", "file2.RING", "file3.RING" ]

pf()
# Executed in 0.05 second(s).
