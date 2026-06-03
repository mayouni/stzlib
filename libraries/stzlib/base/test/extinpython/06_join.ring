# Narrative
# --------
# pr()
#
# Extracted from stzextinpythonTest.ring, block #6.

load "../../stzBase.ring"

pr()

# In Python, this code concatenates a list of items into a string
# using a given separator:

# ' + '.join([ "a", "b", "c" ])
#--> a + b + c

# In Ring, with Softanza, we can use the same code like this:

? Q(' + ').join([ "a", "b", "c" ])
#--> a + b + c

pf()
# Executed in 0.01 second(s) in Ring 1.23
# Executed in 0.03 second(s) in Ring 1.21
# Executed in 0.05 second(s) in Ring 1.20
