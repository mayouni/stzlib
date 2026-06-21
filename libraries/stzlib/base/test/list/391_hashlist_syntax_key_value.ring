# Narrative
# --------
# Shows how Softanza recognizes a Ring hashlist literal via IsHashList().
#
# In Ring the [ :key = value, ... ] form builds a genuine hashlist (a list
# of [key, value] pairs), so IsHashList() returns true for it and for the
# equivalent explicit [ ["name","Mansour"], ["age",45] ] form. The trap is
# the quoted [ "name" = "Mansour", ... ] form: here = is the equality
# operator, not a key binding, so each entry collapses to a boolean test.
# Since "name" != "Mansour" and "age" != 45, IsHashList() returns false and
# @@() reveals the list actually holds [ 0, 0 ] -- two failed comparisons.
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
