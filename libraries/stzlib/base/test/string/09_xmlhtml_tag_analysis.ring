# Narrative
# --------
# #narration XML/HTML tag analysis
#
# Extracted from stzStringTest.ring, block #9.

load "../../stzBase.ring"


pr()

# If you parse this XML snippet with a valid tool, an error will
# be raised. Let's see how Softanza could help in identifying it.

# First, we put the code in an stzString object:

xml = "<product><name>Phone<name></name><price>599</price></product>"
oXML = new stzString(xml)

# Then, we use SubStringsBoundedBy() to get the list of all XML entities
# used within the code (which are bounded by "<" and ">" chars).

# At the same time, we elevate the list to an stzList object using
# the Q() helper function.

# Finally, we use ItemsAndTheirNumberOfOccurrence() on it:

? @@( Q( oXML.SubStringsBoundedBy([ "<", ">" ]) ).
  ItemsAndTheirNumberOfOccurrence() ) + NL

# And so we get:

#--> [
#	[ "product", 1 ],
#	[ "name", 2 ],		#~> Focus on this line!
#	[ "/name", 1 ],
#	[ "price", 1 ],
#	[ "/price", 1 ],
#	[ "/product", 1 ]
# ]

# All entities should have an equal number of opening and
# closing tags, which is TRUE for all except "name" (look at
# lines 2 and 3 of the list—you'll see 2 versus 1).

# The issue, then, is that we have an additional "<name>" entity
# that we should remove. To fix it, we say:

oXML.RemoveNth(2, "<name>")

# Look at the result:

? oXML.Content()
#--> <product><name>Phone</name><price>599</price></product>

# Now you can feed it back to your XML parser with total peace of mind!

pf()
# Executed in 0.03 second(s) in Ring 1.22
