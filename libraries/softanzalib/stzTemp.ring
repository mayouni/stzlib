
func main
	// Automatically commenting all lines execp variable declarations
	n1 = 10
	n2 = "20"
	o1 = new Person { prename = "Mansour" name = "Ayouni" }
	a = [1,2,3]

	? Sum(n1, n2)

func Sum(pn1,pn2)
	return pn1 + pn2

class Person
	prename
	name
	
	def fullname()
		return prename + " " + name
