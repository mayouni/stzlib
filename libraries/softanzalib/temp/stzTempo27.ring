load "softanzalib.ring"

o1 = new Person { id = :o1 name = "Mansour" age = "44" job = "Programmer" }
o2 = new Person { id = :o2 name = "Mansour" age = "44" job = "Programmer" }

stz = new stzObject(o1)
stz {
/*
	? ObjectClass()
	? ObjectAttributes()
	? ObjectMethods()
*/
//	? PropertiesAndValues()
	? IsEqualTo(o2)
}

class Person
	id
	name
	age
	job

	def id()
		return id

	def Name()
		return name

	def SetName(pcName)
		name = pcName

	def Show()
		? name + " " + age + " " + job
