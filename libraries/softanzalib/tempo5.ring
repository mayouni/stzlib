load "stzlib.ring"






/*---------
# Performance of QString2 is astonisshing!



str = "1|2|1|__*__|[ 10* 11* 12 ]|B|2|1|__*__|A*|3|__*__|B|[ 10* 11* 12 ]|B|"

for i = 1 to 1_000_000
	str += "SomeStringHereAndThere"
next
# Executed in 13.31 second(s)

pron()

str += "|1|2|1|__*__|[ 10* 11* 12 ]|B|2|1|__*__|A*|3|__*__|B|[ 10* 11* 12 ]|B|"
o1 = new stzString(str)
? @@(o1.FindThisBoundedBy("1", "|"))

proff()
# Executed in 0.15 second(s)

/*--------- TODO: review sort in stztable (I may use this Ring native solution)

aList = [ ["mahmoud",15000] , ["ahmed", 14000 ] , ["samir", 16000 ] , ["mohammed", 12000 ] , ["ibrahim",11000 ] ]
aList2 = sort(aList,1)
see aList2

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
