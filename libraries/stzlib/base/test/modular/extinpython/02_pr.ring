# Narrative
# --------
# pr()
#
# Extracted from stzextinpythonTest.ring, block #2.

load "../../../stzBase.ring"


# Reversing a list, in Python code:
'
range(1, 5)[::-1]
#--> [ 4, 3, 2, 1 ]
'

# Doing it in Ring, Python-way:

? range1Q([ 1, 5 ])['::-1']
#--> [ 4, 3, 2, 1 ]

pf()
# Executed in 0.01 second(s) in Ring 1.23
