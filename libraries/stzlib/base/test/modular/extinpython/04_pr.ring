# Narrative
# --------
# pr()
#
# Extracted from stzextinpythonTest.ring, block #4.

load "../../../stzBase.ring"


# Used to suppoprt external code from 0-based languages

? range0(3)
#--> [0, 1, 2]

? range0([ 1, 3 ]) 
#--> [1, 2]

? range0([ 2, 8, 3 ])
#--> [2, 5]

# Used in Ring 1-based lists

? range1(3)
#--> [1, 2, 3]

? range1([ 1, 3 ]) 
#--> [1, 2, 3]

? range1([ 2, 8, 3 ])
#--> [2, 5, 8]

# Special accessor (python-like), used here to reverse the list

? range1(':5:-1')
#--> [ 5, 4, 3, 2, 1 ]

? range0(':5:-1')
#--> [ 4, 3, 2, 1, 0 ]

pf()
# Executed in 0.02 second(s).
