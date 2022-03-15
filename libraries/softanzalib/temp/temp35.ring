load "softanzalib.ring"

o1 = new Person { prename = "Mansour" name = "Ayouni" age = 45 }
a1 = [ :prename = "Mansour", :name = "Ayouni", :age = 45 ]

if SameValue(o1, a1)


class Person
	prename
	name
	age
	
	def Show()
		? prename
