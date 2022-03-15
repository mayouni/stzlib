load "softanzalib.ring"

func main
	n1 = 10
	n2 = "20"
	o1 = new Person { id = "o1" prename = "Mansour" name = "Ayouni" }
	a = [1,2,3,o1]

	? Sum(n1, n2)

	// Metaprogramming >> Variables names
 	aTemp = locals()
	aVarNames = []
	for i = 1 to len(aTemp)-1
		aVarNames + aTemp[i]
	next
? avarnames

	// MetaProgramming >> Variables types
	aVarTypes = []
	for cVar in aVarNames
		eval("aVarTypes + [ cVar , type(" + cVar + ") ]")
	next

	// Metaprogramming >> Variables values
	aVarValues = []
	for cVar in aVarNames
		n = find(aVarNames, cVar)

		cCurrentType = aVarTypes[n][2]
		if  cCurrentType = "OBJECT" or cCurrentType = "LIST"
			cCode = "aVarValues + [cVar, '" + aVarNames[n] + "']"
? cCode
		else
			cCode = "aVarValues + [cVar , " + cVar + "]"
? cCode
		ok
		eval(cCode)
	next

	// Metaprogramming >> Variables names, types, and values

	aVars = []
	for cVarName in aVarNames
		//aVars + [ cVarName, [ aVarTypes[cVarName], aVarValues[cVarName] ] ]
		aVars + [ [ :varname, cVarName ],
			  [ :vartype, aVarTypes[cVarName] ],
			  [ :varvalue, aVarValues[cVarName] ]
                        ]
	next

	// Metaprogramming >> Functions
	aFuncs = []
	for i=2 to len(functions())
		aFuncs + functions()[i]
	next

	// Metaprogramming >> Classes
	aClassz = []
	for i=1 to len(classes())-1
		aClassz + classes()[i]
	next


	oCodeAnalyzer = new stzCodeAnalyzer(aVars, aFuncs, aClassz)
	//? oCodeAnalyzer.Vars()
/*	? oCodeAnalyzer.Funcs()
	? oCodeAnalyzer.Classz()
*/
func Sum(pn1,pn2)
	return pn1 + pn2

class Person
	id
	prename
	name
	
	def fullname()

class stzCodeAnalyzer
	aVars = []
	aFuncs = []
	aClassz = []

	def init(paVars, paFuncs, paClassz)
		aVars = paVars
		aFuncs = paFuncs
		aClassz = paClassz

	def Vars()
		aResult = []
		cVarName = ""

		for var in aVars
			cVarName = var
			if isList(var[:varvalue])

				// If One item of that list is a hashlist
				// containing the key :id
				// then this is an object, return its name!
				
				oTempList = new stzList(var[:varvalue])
				aHashLists = oTempList.OnlyHashLists()
				oListOfLists = new stzListOfLists(aHashLists)
				if oListOfLists.ContainsItem(:id)
					aTempList = oListOfLists.ListsContainingItem(:id)[1]
					cVarName = aTempList[2]
				ok
			ok
			aResult + cVarName
		next
		return aResult

	def VarTypeAndValue(cVar)
		return aVars[cVar]

	def VarType(cVar)
		return aVars[cVar][1]

	def VarValue(cVar)
		return aVars[cVar][2]

	def Funcs()
		return aFuncs

	def Classz()
		return aClassz

	

