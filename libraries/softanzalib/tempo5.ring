load "stzlib.ring"

/*-----------

pron()

oStr = new stzString("Welcome to the Ring programming language")
? oStr.SectionCS(:From = "RING", :To = :LastChar, :CaseSensitive = FALSE))
#--> Ring programming language

proff()
# Executed in 0.06 second(s)

/*-----------

pron()

oStr = new stzString("Welcome to the Ring programming language")
? oStr.Section(:From = "Ring", :To = "language")
# Ring programming language

proff()
# Executed in 0.06 second(s)

/*-----------

pron()

# Softanza make programming in Ring more expressive.

# To showcase this, let's consider how substr() function
# is used in Ring, and how Softanza offers a better way.

# In Ring, the substr() function does many things:
#	--> Finding a substring
#	--> Getting the substring starting at a given position
#	--> Getting the substring made of n given chars starting at a given position
#	--> Replacing a sbstring by an other substring (with or without casesensitivity)

# We are going to perform all these actions, using substr() and then Softanza,
# side by side, so you can make sense of the expressiveness of the library...

# Finding a substring

	cStr = "Welcome to the Ring programming language"
	? substr(cStr,"Ring")
	#--> 16

	# In Softanza we say:

	oStr = new stzString("Welcome to the Ring programming language")
	? oStr.FindFirst("Ring")
	#--> 16

	# NOTE : Find(cSubStr) returns all the occurrences of cSubStr

	? oStr.Find("Ring") # equivalent to FindAll("Ring")
	#--> [ 16 ]

# Getting the substring starting at a given position

	cStr = "Welcome to the Ring programming language"
	nPos = substr(cStr, "Ring") # gives 16
	? substr(cStr, nPos)
	#--> Ring programming language

	# In Softanza we say:

	oStr = new stzString("Welcome to the Ring programming language")
	? oStr.Section(:From = "RING", :To = :LastChar) # Or simply Section("Ring", :End)
	#--> Ring programming language

# Getting the substring made of n given chars starting at a given position

	cStr = "Welcome to the Ring programming language"
	nPos = substr(cStr,"Ring") # Gives nPos = 16
	? substr(cStr, nPos, 4)
	#--> Ring

	# In Softanza we say:

	oStr = new stzString("Welcome to the Ring programming language")
	? oStr.Range("Ring", 4)
	#--> Ring

# Replacing a sbstring by an other substring

	cStr = "Welcome to Python programming language"
	? substr(cStr, "Python", "Ring") # Replaces 'Python' with 'Ring'
	#--> Welcome to the Ring programming language

	# In Softanza we say:
	oStr = new stzString("Welcome to Python programming language")
	oStr.Replace("Python", :With = "Ring")
	? oStr.Content()
	#--> Welcome to Ring programming language

# Replacing a sbstring by an other substring with Case Sensitivity

	cStr = "Welcome to the Python programming language"
	? substr(cStr,"PYTHON", "Ring", 0) # WARNING: This is should be 1 and not 0!
	#--> Welcome to the Python programming language
	
	cStr = "Welcome to the Python programming language"
	? substr(cStr, "PYTHON", "Ring", 1) # WARNING: This is should be 0 and not 1!
	#--> Welcome to the Ring programming language

	# In Softanza we say:

	oStr = new stzString("Welcome to Python programming language")
	oStr.ReplaceCS("PYTHON", :With = "Ring", :CaseSensitive = FALSE)
	? oStr.Content()
	#--> Welcome to Ring programming language

	oStr = new stzString("Welcome to Python programming language")
	oStr.ReplaceCS("PYTHON", :With = "Ring", :CaseSensitive = TRUE)
	? oStr.Content()
	#--> Welcome to Python programming language
	
proff()
# Executed in 0.11 second(s)

/*---------

# Performance of stzString (using QString2 in background) is astonishing!


# Ket's compose a large string

str = "1|2|1|__*__|[ 10* 11* 12 ]|B|2|1|__*__|A*|3|__*__|B|[ 10* 11* 12 ]|B|"

for i = 1 to 1_000_000
	str += "SomeStringHereAndThere"
next
# Executed in 13.31 second(s)

pron()

str += "|1|2|1|__*__|[ 10* 11* 12 ]|B|2|1|__*__|A*|3|__*__|B|[ 10* 11* 12 ]|B|"
o1 = new stzString(str)
? @@(o1.FindThisBoundedBy("1", "|"))

# TODO: Try to compose the string by pushing the first part in the middle or a the end,
# and if stzString is still as performant!

proff()
# Executed in 0.15 second(s)

/*--------- TODO: review sort in stztable (I may use this Ring native solution)

pron()

aList = [ ["mahmoud", 15000] , ["ahmed", 14000 ] , ["samir", 16000 ] , ["mohammed", 12000 ] , ["ibrahim",11000 ] ]

aSorted = sort(aList, 1)
? @@(aSorted) + NL
#--> [ [ "ahmed", 14000 ], [ "ibrahim", 11000 ], [ "mahmoud", 15000 ], [ "mohammed", 12000 ], [ "samir", 16000 ] ]

aSorted = sort(aList, 2)
? @@(aSorted)
#--> [ [ "ibrahim", 11000 ], [ "mohammed", 12000 ], [ "ahmed", 14000 ], [ "mahmoud", 15000 ], [ "samir", 16000 ] ]

proff()
# Executed in 0.03 second(s)

/*---------
*/

pron()

aList = [ ["mahmoud", 15000] , ["ahmed", 14000 ] , ["samir", 16000 ] , ["mohammed", 12000 ] , ["ibrahim",11000 ] ]

o1 = new stzListOfPairs(aList) # Or stzListOfLists() if you want

? @@( o1.Sorted() ) + NL
#--> [ [ "ahmed", 14000 ], [ "ibrahim", 11000 ], [ "mahmoud", 15000 ], [ "mohammed", 12000 ], [ "samir", 16000 ] ]

? @@( o1.SortedBy(2) )
#--> [ [ "ibrahim", 11000 ], [ "mohammed", 12000 ], [ "ahmed", 14000 ], [ "mahmoud", 15000 ], [ "samir", 16000 ] ]

proff()

/*---------

pron()

o1 = new QString2()
o1.append("tunis * tunis * tunis")
? o1.count()
#--> 17

? o1.indexof("*", 6, 0) # Params --> str, startat, casesensitive
#--> 6

proff()

/*--------

pron()

aList = []
for i = 1 to 1_900_000
	aList + "sometext"
next
aList + "A" + "*" + "B" + "C" + "*" + "D" + "*" + "E"

o1 = new stzList(aList)
? o1.FindNext("*", :startingat = 2)
#--> 5

proff()
#--> Executed in 28.26 second(s)

/*-----------
*/
pron()

# Preparing the large list to work on
	aList = []
	for i = 1 to 1_900_000
		aList + "sometext"
	next
	aList + "A" + "*" + "B" + "C" + "*" + "D" + "*" + "E"
	# Takes 1.20 seconds

	o1 = new stzList(aList)
	# takes 1 second

	aHash = []
	aSeen = []

	for i = 1 to 1_900_008
		n = o1.FindNext(aList[i], i)
		
		if n = 0
			aSeen + aList[i]
			aHash + [ aList[i], [i] ]
		ok
	next

proff()

/*-----------
*/
pron()

# Preparing the large list to work on
	aList = []
	for i = 1 to 1_900_000
		aList + "sometext"
	next
	aList + "A" + "*" + "B" + "C" + "*" + "D" + "*" + "E"
	# Takes 1.20 seconds


	# Creating the stzList object

	o1 = new stzList(aList)
	
	? ELpasedTime()
	# Takes 1.32 seconds

	# Concatenating the items of the list
	
	aContent = aList
	nLen = len(aList)

	cSep = " "
	cResult = ""

	for i = 1 to nLen - 1
		cResult += aContent[i] + cSep
	next



proff()
# Executed in 13.00 second(s)

/*--------------------
*/

pron()

# Initializing the large list of strings

	o1 = new QStringList()
	for i = 1 to 1_900_000
		o1.append("sometext")
	next
	aList = [ "A", "*", "B", "C", "*", "D", "*", "E" ]
	nLen = len(aList)
	for i = 1 to nLen
		o1.append(aList[i])
	next
	
	? ElpasedTime()
	# (takes 11.87 seconds)

# Concatenating the strings in one string

	str = o1.join("")
	# Takes 0.05 seconds

proff()
# #(takes 11.63 seconds)
