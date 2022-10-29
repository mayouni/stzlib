load "stzlib.ring"


? StzClasses()

/*--------------------

o1 = new stzNumber(12500)
? o1.Is(:StzNumber)
? o1.Is(:String)

/*--------------------

o1 = new stzString("hello")
? o1.Is(:StzString)

/*--------------------

o1 = new stzGrid([ [1,2,3], [4,5,6], [7,8,9] ])
? o1.Is(:StzGrid) # from stzObject based on the name of the class
? o1.IsAGrid() # used by natural code in stzChainOfTruth

/*--------------------

o1 = new Person { name = "Ali" age = 32 job = "Developer" }

# NOTE: if you provide the name of the object in a string (as :o1),
# then you can get the variable name of the object using ObjectVarName()

StzObjectQ( :o1 ) {

	? "ID: " + ObjectUID() + NL

	? "Object Name: " + ObjectVarName() + NL

	? "Object class: " + ObjectClassName() + NL

	? "Attributes:"
	? ObjectAttributes()

	? "Values:"
	? ObjectValues()

	? "Attributes and their values:"
	? ObjectAttributesAndValues()

	? "Methods:"
	? ObjectMethods()

	? "Object listified:"
	? Listify()

}

class Person
	name
	age
	job

	def init(cName)
		name = cName

	def show()
		? "Name : " + name
		? "Age  : " + age
		? "Job  : " + job

/*----------------

o1 = new QString()
? IsQObject(o1)
? IsQtObject(o1)

# Both return TRUE --> Flexible syntax!

/*----------------

? len(RingQtClasses())

o1 = new stzString("n")

? IsConstraintObjectParam(o1)
? IsConstraintObjectParam(:In = o1)
? IsConstraintObjectParam(:InObject = o1)
? IsConstraintObjectParam(:On = o1)
? IsConstraintObjectParam(:OnObject = o1)
