load "../max/stzmax.ring"



/*---------------------

cList = '[ "A", "T", "B", 5, "C", "A", "A", "D", "E", 2, 7, "D" , 8 ]'

? StringIsListInString(cList) #--> _TRUE_

/*---------------------

cList = '[ "A", "T", [ :hi, :bye ], 5, "C", "A", "A", 2 ]'

? StringIsListInString(cList) #--> _TRUE_

/*---------------------
*/
obj1 = new Person { name = "foued" }
obj2 = new Person { name = "kamel" }

cList = '[ "A", "T", [ :hi, :bye ], 5, obj1, "C", "A", obj2, "A", 2 ]'

? StringIsListInString(cList) #--> _TRUE_

class Person name

/*---------------------

? PluralOfStzClassName("stzList") #--> :stzLists
? PluralOfStzClassName("stzListOfStrings") #--> :stzListsOfStrings

//? QR([ "H", "USS", "EI", "N" ], :stzListOfStrings).Concatenated()
/*
obj1 = new Person { name = "foued" }
obj2 = new Person { name = "kamel" }

StzListInStringQ('[ "A", "T", [ :hi, :bye ], 4, obj1, "C", "A", obj2, "A", 10 ]') {

	? List()[3] #--> [ :hi, :bye ]
	? List()[7] #--> "A"

	? ListQ().NumberOfItems() #--> 10
	? ListQR(:stzList).NumberOfItems() #--> 10
	
}

class Person name

/*---------------------

n = 10
cStr = "Mime"
aList = [ "me", "you" ]
obj = new Person { name = "foued" }

o1 = new stzListInString( '[ "A", 7, cStr, [ :hi1, :bye1 ], n, 5.2, obj, [ "hi2", "bye2" ], "C", aList ]' )

? o1.Variables() # FIX PERFORMANCE ISSUE
? o1.Types()
? o1.VariablesAndTheirTypes()

class Person name

