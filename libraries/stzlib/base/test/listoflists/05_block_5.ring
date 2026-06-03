# Narrative
# --------
# #ring #qt
#
# Extracted from stzlistofliststest.ring, block #5.

load "../../stzBase.ring"


pr()

# In Ring and Qt and other programming languages, sort is made
# based on asscii (or unicode) values of the chars. And hance,
# "X" comes before "x" because UPPER chars come before
# lower chars in ascci range

# Let's check it in Ring

? sort([ "x", "X" ])
# [ "X" ,"x" ]

? ascii("X") #--> 88
? ascii("a") #--> 97

# And in Qt via a stzListOfStrings object (base on QStringList)

oQList = new stzListOfStrings([ "X", "x" ])
oQList.sort()
? oQList.Content()
#--> [ "X" ,"x" ]

# The same thing applies the the multi-dimensional sort:

aLists = [
	[ "mazen", 300, "X", 1 ],
	[ "amer", 300, "a", 1 ]
]

? @@NL( sort(aLists, 3) )
#--> [
#	[ "mazen", 300, "X", 1 ],
#	[ "amer", 300, "a", 1 ]
# ]

pf()
# Executed in 0.02 second(s).
