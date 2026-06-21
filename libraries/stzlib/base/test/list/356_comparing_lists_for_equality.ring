# Narrative
# --------
# Comparing two lists for equality by VALUE rather than by reference.
#
# Ring compares lists by reference, so [ 1, 2 ] = [ 1, 2 ] is FALSE (two
# distinct objects). The classic workaround casts both to strings
# (list2str(...) = list2str(...) -> TRUE). Softanza offers a direct idiom:
# elevate the left list with Q(), and the overloaded "=" operator routes into
# stzList.IsEqualTo() for a by-value comparison -- so Q([ 1, 2 ]) = [ 1, 2 ] is
# TRUE. (The operator only engages when the right-hand side is a list, leaving
# every other comparison untouched.) The closing example shows why it matters:
# the same if-guard that silently takes the "Ooops!" branch with a raw list
# takes the success branch once the list is Q()-wrapped.
#
# Extracted from stzlisttest.ring, block #356.

load "../../stzBase.ring"


pr()

# In Ring, you can't check two equal listq for equality,
# and if you do, you get FALSE as result:

? [ 1, 2 ] = [ 1, 2 ]
#--> FALSE

# That's because Ring compares lists by reference not
# by value. When you create two separate lists [ 1, 2 ],
# even though they contain the same values, they are
# distinct objects in memory.

# We can do it differently in Ring by casting the
# lists to strings using lis2str like this:

? list2str([ 1, 2 ]) = list2str([ 1, 2 ])
#--> TRUE

# Softanza provides a more direct and elegant solution by
# simply using the Q() small function with the first list:

? Q([ 1, 2 ]) = [ 1, 2 ]
#--> TRUE

# Hence, the first [ 1, 2 ] is elevated to a stzList, and
# the = operator is used to call internally the IsEqual()
# method to compare the object content with the second list.

# It seems to be a minor feature, but in practice it can
# save us some tricky situations like this:

aMyList = [ 1, 2 ]

if aMyList = [ 1, 2 ]
	? "I'm done :)"
else
	? "Ooops!"
ok
#--> Ooops!

# Here is the same code enabled with Softanza Q() magic:

aMyList = [ 1, 2 ]

if Q(aMyList) = [ 1, 2 ]
	? "I'm really done! Thanks Softanza :)"
else
	? "Ooops!"
ok
#--> "I'm really done! Thanks Softanza :)"

pf()
# Executed in 0.01 second(s).
