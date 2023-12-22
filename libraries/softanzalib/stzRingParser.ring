//load "stzlib.ring"

cMyCode =
'
func main
	// Automatically commenting all lines execp variable declarations
	n1 = 10
	n2 = "20"
	o1 = new Person { prename = "Mansour" name = "Ayouni" }
	a = [1,2,3,o1]

	? Sum(n1, n2)

func Sum(pn1,pn2)
	return pn1 + pn2

class Person
	prename
	name
	
	def fullname()
		return prename + " " + name
'

o1 = new stzRingParser(cMyCode)
o1.run()

class stzRingParser
	cRingCode

	def init(pcRingCode)
		cRingCode = pcRingCode

	def Content()
		return cRingCode

		def Value()
			return Content()

	def ShowCode()
		? cRingCode

		#< @FuntionMisspelledForm

		def ShwoCode()
			This.ShowCode()

		#>

	def Scan()
		oSandBox = new stzSandBox(cRingCode)
		oSandBox.Scan()

	def Run()
		eval(cRingCode)

	def vars()
		oSandBox = new stzSandBox(cRingCode)
		oSandBox.Run()

class stzSandBox
	
	def init(pcRingCode)
		write("stzTemp.ring", pcRingCode)

	def run()
		eval(read("stzTemp.ring"))


