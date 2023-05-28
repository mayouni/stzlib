load "stzlib.ring"


new stzNamedObject(:o1 = new Person("Ali"))
? @[:o1].Name()
#--> "Ali"

? className( @[:o1] ) # Ring function
#--> :Person

new stzNamedObject(:o2 = new Person("Mourad"))
? @[:o2].Name()
#--> "Mourad"

/*
new stzNamedObject(:o1 = "Mohsen")
? @[:o1].Name()
#--> Error message:
# The name you provided (:o1) is already used by an other object!
*/

class Person
	@cName

	def init(pcName)
		@cName = pcName

	def Name()
		return @cName
