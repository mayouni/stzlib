# Narrative
# --------
# Using a Python code inside Ring ===
#
# Extracted from stzextinpythonTest.ring, block #1.
#ERR Error (R50) : Object does not support operator overloading

load "../../stzBase.ring"


pr()

# Reversing a list, the Python way

? Q(1:5)['::-1']
#--> [ 5, 4, 3, 2, 1 ]

# Getting a part of the list (from 2 to 8) with a step of 2

? Q(1:10)['2:8:2']
#--> [ 2, 4, 6, 8 ]

pf()
# Executed in 0.01 second(s) in Ring 1.23
