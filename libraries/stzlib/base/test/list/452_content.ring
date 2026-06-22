# Narrative
# --------
# Replacing list items by value, from the simplest case to several richer variants.
#
# The starting point is Replace(item, :With), which swaps every occurrence of a
# single value (aliased as ReplaceAll / ReplaceAllOccurrences). From there Softanza
# scales up: ReplaceMany takes a list of items and maps them all to one common
# replacement value; ReplaceManyByMany pairs each item with its own replacement
# one-by-one (handy for text interpolation and templating); and ReplaceItemByManyXT
# cycles through a list of replacements, alternating between them for each successive
# occurrence of the target item. All four operate in place inside the StzListQ block
# and are confirmed via Content().
#
# Extracted from stzlisttest.ring, block #452.

load "../../stzBase.ring"

pr()

# In Softanza, you can replace all occurrences of an item
# in the list by a provided value, by saying:

StzListQ([ "A", "B", "C", "A", "D", "B", "A" ]) {
	
	Replace("A", :With = "#")
	# Or ReplaceAll("A", :With = "#") or ReplaceAllOccurrences(:Of = "A", :With = "#')

	? Content()
	#--> [ "#", "B", "C", "#", "D", "B", "#" ]

}

# In case you need to make many replacements at once, then you are covered:
# just provide the list of items to replace and the value of replacement...

StzListQ([ "A", "B", "C", "A", "D", "B", "A" ]) {
	
	ReplaceMany([ "A", "B" ], :With = "#")
	? Content()
	#--> [ "#", "#", "C", "#", "D", "#", "#" ]

}

# You can even replace exitant items by many other new values, one by one,
# like this (useful in many scenarios of text interpolation and processing):

StzListQ([ "A", "B", "C", "A", "D", "B", "A" ]) {
	
	ReplaceManyByMany([ "A", "B" ], :With = [ "#1", "#2" ])
	? Content()
	#--> [ "#1", "#2", "C", "#1", "D", "#2", "#1" ]

}

# And if you want to replace the occurrences of a given item by alternating
# between several other items you provide, then this is possible:

StzListQ([ "A", "A", "A" , "A", "A" ]) {
	
	ReplaceItemByManyXT("A", :With = [ "#1", "#2" ])

	? Content()
	#--> [ "#1", "#2", "#1", "#2", "#1" ]

}

pf()
# Executed in 0.02 second(s).
