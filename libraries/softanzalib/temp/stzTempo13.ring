load "stzlib.ring"

@name = "Tiba"
@age = "9"
@message = "Love"

o1 = new stzString("My name is {@name} and my age is {@age}. My message to you is {@message}!")
? render(o1)

func render(obj)
	aTemp = parse(obj)
	for a in aTemp
		cTemp = obj.ReplaceSection(a[:PosStart],a[:PosEnd],a[:Value])
		obj = new stzString(cTemp)
		aTemp = parse(obj)
	next
	
	return o1.Content()

func parse(obj)
	aTemp = findCouple(obj,"{","}")
	aRes = []

	for item in aTemp
		cVar = obj.Section(item[1],item[2])

		eval("cValue = " + cVar)
		aRes + [ ["Variable", cVar], ["Value", cValue], ["PosStart", item[1]-1], ["PosEnd", item[2]+1] ]
	next
? aRes
	return aRes

func findCouple(obj,p1,p2)
	a1 = obj.FindFirst(p1)
	a2 = obj.Findfirst(p2)

	a = []
	for i = 1 to min(len(a1),len(a2))
		a + [ a1[i]+1, a2[i]-1 ]
	next i

	return a

// Divides the string into parts based on given character positions
func DivideOnPositions(pStr, paPositions)
	aPositions = [1] + paPositions + len(paPositions)
	aCouples = toListOf(2)	// --> stzList / (len(stzList) / 2)
	aResult = []
	
func sayhello()
	return "Hello!"
