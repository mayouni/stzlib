# Narrative
# --------
# Extracted from stzlisttest.ring, block #622.

load "../../stzBase.ring"


pr()

# In the following example, we check if the entire list ["a", "b", "c"] exists
# as a single item within the list ["a", "b", "c", "x", "z"].

# Although you might expect this to return TRUE, it actually returns FALSE.
? Q(["a", "b", "c"]).ExistsIn(["a", "b", "c", "x", "z"])
#--> FALSE

# The result is FALSE because there are no occurrences of ["a", "b", "c"] as a 
# single list element within the larger list.
? @@(Q(["a", "b", "c", "x", "z"]).FindAll(["a", "b", "c"]))
#--> []

# However, if we modify the list to include ["a", "b", "c"] as an item:
? Q(["a", "b", "c"]).ExistsIn(["a", "b", "c", "x", "z", ["a", "b", "c"]])
#--> TRUE

# This returns TRUE because the last element of the second list is now an item of
# type list that matches ["a", "b", "c"], satisfying the ExistsIn() condition.

# Now, let's restart from the beginning with a different method: ExistIn(),
# which omits the "s" at the end. This method uses a different semantic approach.

? Q(["a", "b", "c"]).ExistIn(["a", "b", "c", "x", "z"])
#--> TRUE

# Here, the result is TRUE because ExistIn() implies checking if the sequence
# ["a", "b", "c"] exists within the list as a sub-sequence, rather than as a 
# single item. This method accounts for multiple consecutive items rather than 
# a single item, as with ExistsIn().

pf()
# Executed in almost 0 second(s) in Ring 1.27
# Executed in 0.02 second(s) before
