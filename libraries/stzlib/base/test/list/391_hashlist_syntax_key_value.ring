# Narrative
# --------
# #narration HASHLIST SYNTAX :key = value
#
# Extracted from stzlisttest.ring, block #391.

load "../../stzBase.ring"


pr()

# In Ring, this is how we can declare a hashlist using the :key = value syntax

? IsHashList([ :name = "Mansour", :age = 45 ])
#--> TRUE

# Which is equivalent to the fellowing normal list declaration:

? IsHashList([ [ "name", "Mansour"], [ "age", 45] ])
#--> TRUE

# But, becareful when using a normal string with =, it won't lead to a hashlist

? IsHashList([ "name" = "Mansour", "age" = 45 ]) + NL
#--> FALSE

# In fact, what we wrote are two FALSE expressions, since "name" is different
# from "Mansour" and "age" is different from 45:

? @@( [ "name" = "Mansour", "age" = 45 ] )
#--> [ 0, 0 ]

pf()
# Executed in almost 0 second(s).
