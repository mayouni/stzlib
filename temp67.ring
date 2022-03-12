load "stzlib.ring"

o1 = new stzList([
	1, new Person("Mansour"),
	2, new Animal("Cat"), 3,
	new Thing("Pizza") ])

? o1.ApplyCode("classname(oEachObject)", :ToRingObjects)
		
class Person
	name
	def init(pName)
		name = pName

class Animal
	name
	def init(pName)
		name = pName

class Thing
	name
	def init(pName)
		name = pName

/*
o1 = new stzList([ "Mahmoud", ["Tea", "Coke", "Milk"],
		   "Mansour", ["Ice","Milk", "Cream", "Tea"],
		   "Teebah", [ "Ice", "Milk" ] ])

? o1.ApplyCode('find(aEachList,"Milk")', :ToRingLists)
		
#=> [ "Mahmoud", 2, "Mansour", 3 ]

/*
o1 = new stzList([ "Ring", 3, "Mahmoud", 18, "Mansour", 22 ])

o1 {
	ApplyCode("nEachNumber * 2", :ToRingNumbers)
	? Content()
	# => [ "Ring", 6, "Mahmoud", 36, "Mansour", 44 ]

	o1.ApplyCode("UPPER(cEachString)", :ToRingStrings) 
	? Content()
	# => [ "RING", 6, "MAHMOUD", 36, "MANSOUR", 44 ]
}  


