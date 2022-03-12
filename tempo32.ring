_aVariables = []
_Functions = []
_Classes = []

func main
	n1 = 10
	n2 = 20
	o1 = new Person { name = "Mansour" }

	? Sum(n1, n2)
	? ""

	cTempLine = 
	write( "stzTemp.ring", "_aVariables = " + list2Code(locals()) )
	_aFunctions = functions()
	_aClasses = classes()

	? "Variables:"
	? _aVariables

	? "Functions:"
	? _aFunctions

	? "Classes:"
	? _aClasses
	/*
	_cLoadedCode
	_aDependencyTree

	_cMainCode
	_acComments
	_aLinesOfCode
	_cLineOfCodeNumber(n)

	_cFunctionCode(cFunc)
	_bIsPureFunction(cFunc)
	_aFunctionParams(cFunc)
	_aFunctionVariables
	_aFunctionCalls
	_FunctionCallPath( _aFunctionCall )

	_aRingFunctions

	_cClassCode(cClass)
	_cClassRegion
	_aClassInitiParam
	_aClassAttributes
	_aClassMethods

	_VarTypes
	_VarLists
	_VarObjects
	_VarNumbers
	_VarStrings

	_VarValues

	_VarOccurrence
	_VarDeclarations
	_VarUpdates
	_VarAffectations

	_Scopes
	_VarScope
	_ScopeConflicts

	*/

func Sum(pn1,pn2)
	//? locals()
	return pn1 + pn2

func Prod(n,n1)
	return n1 * n2

class Person
	name
