# Narrative
# --------
# #narration List Equality and Strict Equality in Softanza
#
# Extracted from stzlisttest.ring, block #507.

load "../../stzBase.ring"


pr()

# In Softanza, two lists are equal when they have same
# number of items and have same content
 
o1 = new stzList(1:3)

? o1.HasSameContentAs(3:1)
#--> TRUE

? o1.HasSameNumberOfItemsAs(3:1)
#--> TRUE

? o1.IsEqualTo(3:1) + NL
#--> TRUE

# While two lists are STRICTLY equal when they have
# same number of items, have same content, and same sorting order

# In other terms: when they are Equal (in the sense of
# IsEqualTo()) and have same sorting order
 
# Hence, 1:3 is equal to its reversed list 3:1
# but it is not STRICTLY equal to it

? Q(1:3).IsEqualTo(3:1)
#--> TRUE

? Q(1:3).IsStrictlyEqualTo(3:1)
#--> FALSE

# In fact, the two lists don't have the same sorting order!

? Q(1:3).SortingOrder()
#--> :Ascending

? Q(3:1).SortingOrder()
#--> :Descending

# Hence, 1:3 is STRICTLY equal only to itself

? Q(1:3).IsStrictlyEqualTo(1:3)
#--> TRUE

pf()
# Executed in 0.01 second(s).
