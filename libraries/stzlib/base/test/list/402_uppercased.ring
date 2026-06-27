# Narrative
# --------
# The (*) operator's right-hand forms. o1 * 3 repeats the list flat
# ([1,2,3,1,2,3,1,2,3]); o1 * Q(3) does the same but elevated (a stzList); a
# string rhs appends a suffix to each item (Q([...]) * ".ring"); and a Q()-wrapped
# string does the same elevated. The Q-elevation rule applies (raw rhs -> raw
# list, Q()/stz-object rhs -> chainable stzList of the same content).
#
# Extracted from stzlisttest.ring, block #402.

load "../../stzBase.ring"

pr()

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
