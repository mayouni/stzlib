load "stzlib.ring"

pron()

aList = []
for i = 1 to 9_900_000
	aList + "sometext"
next
aList + "A" + "*" + "B" + "C" + "*" + "D"

o1 = new stzListOfStrings([ "A", "*", "B", "C", "*", "D" ])
? o1.FindNext("*", :startingat = 2)
#--> 5

proff()
