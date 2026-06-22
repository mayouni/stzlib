# Narrative
# --------
# Distinguishes Softanza list equality from strict equality.
#
# Two lists are EQUAL (IsEqualTo) when they share the same number of
# items and the same content, regardless of order -- so 1:3 equals its
# reverse 3:1, confirmed by HasSameContentAs and HasSameNumberOfItemsAs.
# Two lists are STRICTLY equal (IsStrictlyEqualTo) only when they are
# equal AND share the same sorting order. Since 1:3 is sorted ascending
# and 3:1 descending, they are equal but not strictly equal; 1:3 is
# strictly equal only to itself. SortingOrder() reports the order as a
# lowercase string ("ascending" / "descending"), not a symbol.
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
#--> ascending

? Q(3:1).SortingOrder()
#--> descending

# Hence, 1:3 is STRICTLY equal only to itself

? Q(1:3).IsStrictlyEqualTo(1:3)
#--> TRUE

pf()
# Executed in 0.01 second(s).
