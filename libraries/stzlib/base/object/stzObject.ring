#---------------------------------------------------------------#
# 			     SOFTANZA LIBRARY (V0.9)                        #
#---------------------------------------------------------------#
#                                                               #
# 	Description	: The class for managing softanza objects       #
#	Version		: V1.1.0.6 (2019, 2024)                         #
#	Author		: Mansour Ayouni (kalidianow@gmail.com)         #
#                                                               #
#===============================================================#

/*
	Mainly, this class servers as a parent for the common features
	ot its inherited classes, namely stzNumber, stzString, stzList, etc.
	#TODO // All the common features are not abstructed yet. Some of them
	# are duplicated due to semantic differences between classes.

	All the meta data provided by Ring to objects are provided by this class:

		o1 = new Person { name = "Ali" age = 32 job = "Developer" }
		
		StzObjectQ( :o1 ) {
		
			? "ID: " + ObjectUID() + NL
		
			? "Object Name: " + ObjectVarName() + NL	# Return "o1"
		
			? "Object class: " + ObjectClassName() + NL
		
			? "Attributes:"
			? ObjectAttributes()
		
			? "Values:"
			? ObjectValues()
		
			? "Attributes and their values:"
			? ObjectAttributesAndValues()
		
			? "Methods:"
			? ObjectMethods()
		
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


	Also, this class is useful to make several operations on objects
	that are required by the SoftanzaLib.

	Planned features of the stzObject class include the following:

	- we can send the name of a method to that object and ask it to try 
	to execute it => ExecuteMethod(cMethod)

	- we can call a method to be executed on a new object
	=> pvtExecuteMethodOn(cMethod,pNewValue)

	- we can sepcify it to be of type Container
	
	- we can tranform its type using: ToString(), ToNumber(), ToObject(), and ToList()

	- we can trace the object lifetime in the runtime using LifeTime()
	=> Tells us how many times the object is called
	=> Maintains the values of the states of the objects created and are live in the program
	=> Gives us an idea of the object scope using Scope()
	=> Gives us an idea of the object interactions with external code

	- we can serialize the state of the object at a given time, or many times, in a string
	or text file or binary file or database

	- we can tell it to be instanciated only once using bIsSingleton = _TRUE_

	- we can define its job in the program by defining its type using cObjectJob

	=> cObjectJob  = :Worker	Performs a task and returs a result
	=> 		 :Observer	Observes the execution of other objects
	=> 		 :Presenter	Presents outputs to the user depending on its platform
	=> 		 :Reader	Reads data and provides it to other objects in native form
	=> 		 :Connector	Connects to data sources and return a connexion object
	=> 		 :Transformer	Transforms between data structures and text formats
	=> 		 :Writer	Writes data in a physical medium (string, text file, image...)
	=> 		 :Organiser	Defines an organization schema of objects (in term of layers and services)
	=> 		 :Calculator	Performs various calculations
	=> 		 :Translator	Translates texts between languages
	=> 		 :Parser	Parses a string
	=>		 :Painter	...
	=>		 :Charter	...
	=>		 :Timer		...
	=>		 ...


*/

  ///////////////////
 //   FUNCTIONS   //
///////////////////

func StzObjectQ(pObject)
	return new stzObject(pObject)

#TODO Abstract stzNamedObject into the MAX layer

func StzNamedObject(paNamed)
	if CheckingParams()
		if NOT (isList(paNamed) and Q(paNamed).IsPairOfStringAndObject())
			StzRaise("Incorrect param type! paNamed must be a pair of string and object.")
		ok
	ok

	oObject = Q(paNamed[2])
	oObject.SetName(paNamed[1])
	return oObject

	func StzNamedObjectQ(paNamed)
		return StzNamedObject(paNamed)

	func StzNamedObjectXTQ(paNamed)
		return StzNamedObject(paNamed)

func NamedObject(pcObjName)
	? @@(_avars)
	if CheckingParams()
		
	ok

func StzObjectMethods()
	return Stz(:Object, :Methods)

func StzObjectAttributes()
	return Stz(:Object, :Attributes)

func StzObjectClassName()
	return "stzobject"

	func StzObjectClass()
		return "stzobject"

func IsNotObject(p)
	return NOT isObject(p)

	func @IsNotObject(p)
		return IsNotObject(p)

	func IsNotAnObject(p)
		return IsNotObject(p)

	func @IsNotAnObject(p)
		return IsNotObject(p)

func ObjectVarName(pObject)
	
	if NOT isObject(pObject)
		StzRaise("Incorrect param type! pObject must be an object.")
	ok

	cResult = :@NoName
	if ObjectIsStzObject(pObject)
		cResult = pObject.VarName()
	ok

	return cResult

	func ObjectName(pObject) #NOTE the difference with classname(pObject)
		return ObjectVarName(pObject)

	func @ObjectVarName(pObject)
		return ObjectVarName(pObject)

	func @ObjectName(pObject)
		return ObjectVarName(pObject)

func ObjectIsNamed(pObject)
	if ObjectVarName(pObject) != :@NoName
		return _TRUE_
	else
		return _FALSE_
	ok

	func @ObjectIsNamed(pObject)
		return ObjectIsNamed(pObject)

func ObjectIsUnnamed(pObject)
	return NOT ObjectIsNamed(pObject)

	func @ObjectIsUnnamed(pObject)
		return ObjectIsUnnamed(pObject)

#--

func PluralOfRingType(cType)
	if CheckingParams()
		if NOT IsString(cPlural)
			StzRaise("Incorrect param type! cPlural must be a string.")
		ok
	ok

	if NOT IsRingType(cType)
		StzRaise("Incorrect param! cType is not a valid Ring type.")
	ok

	cType = lower(cType)
	acRingTypesXT = RingTypesXT()
	nLen = len(acRingTypesXT)

	cResult = ""
	for i = 1 to nLen
		if acRingTypesXT[i][1] = cType
			cResult = acRingTypesXT[i][2]
			exit
		ok
	next

	if cResult = ""
		StzRaise("Can't get a plural of a Ring type form string!")
	else
		return cResult
	ok

func RingTypesPlurals()
	acResult = []
	aRingTypesXT = RingTypesXT()
	nLen = len(aRingTypesXT)

	for i = 1 to nLen
		acResult + aRingTypesXT[i][2]
	next

	return acResult

	func PluralsOfRingTypes()
		return RingTypesPlurals()

func IsPluralOfRingType(cPlural)
	if CheckingParams()
		if NOT IsString(cPlural)
			StzRaise("Incorrect param type! cPlural must be a string.")
		ok
	ok

	cPlural = lower(cPlural)
	acRingTypesPlurals = RingTypesPlurals()
	nLen = len(acRingTypesPlurals)

	bResult = _FALSE_

	for i = 1 to nLen
		if acRingTypesPlurals[i] = cPlural
			bResult = _TRUE_
			exit
		ok
	next

	return bResult

	#< @FunctionAlternativeForms

	func IsRingTypePlural(cPlural)
		return IsPluralOfRingType(cPlural)

	func IsPluralOfARingType(cPlural)
		return IsPluralOfRingType(cPlural)

	func IsARingTypePlural(cPlural)
		return IsPluralOfRingType(cPlural)

	func IsRingTypeInPlural(cPlural)
		return IsPluralOfRingType(cPlural)

	func IsARingTypInePlural(cPlural)
		return IsPluralOfRingType(cPlural)
	#--

	func @IsPluralOfRingType(cPlural)
		return IsPluralOfRingType(cPlural)

	func @IsRingTypePlural(cPlural)
		return IsPluralOfRingType(cPlural)

	func @IsPluralOfARingType(cPlural)
		return IsPluralOfRingType(cPlural)

	func @IsARingTypePlural(cPlural)
		return IsPluralOfRingType(cPlural)

	func @IsRingTypeInPlural(cPlural)
		return IsPluralOfRingType(cPlural)

	func @IsARingTypInePlural(cPlural)
		return IsPluralOfRingType(cPlural)

	#>
	
func RingTypesXT()
	return _aRingTypesXT
	
func PluralToRingType(cPlural)
	if CheckingParams()
		if NOT isString(cPlural)
			StzRaise("Incorrect param type! cPlural must be a string.")
		ok
	ok

	cPlural = lower(cPlural)
	acRingTypesXT = RingTypesXT()
	nLen = len(acRingTypesXT)

	cResult = ""

	for i = 1 to nLen
		if acRingTypesXT[i][2] = cPlural
			cResult = acRingTypesXT[i][1]
			exit
		ok
	next

	if cResult = ""
		StzRaise("Plural does not exist or can't be be found!")
	else
		return cResult
	ok

func PluralOfStzClassName(cClass)

	return StzClassesXT()[cClass]

	#< @FunctionAlternativeForms

	func PluralOfStzType(cClass)
		return PluralOfStzClassName(cClass)

	func PluralOfStzClass(cClass)
		return PluralOfStzClassName(cClass)

	func StzTypeToPlural(cClass)
		return PluralOfStzClassName(cClass)

	func StzClassNameToPlural(cClass)
		return PluralOfStzClassName(cClass)

	func StzClassToPlural(cClass)
		return PluralOfStzClassName(cClass)

	#--

	func PluralOfThisStzClass(cClass)
		return PluralOfStzClassName(cClass)

	func PluralOfThisStzClassName(cClass)
		return PluralOfStzClassName(cClass)

	func PluralOfThisStzType(cClass)
		return PluralOfStzClassName(cClass)

	#>

func StzClassesPlurals()
	acResult = []

	acClassesXT = StzClassesXT()
	nLen = len(acClassesXT)

	for i = 1 to nLen
		acResult + acClassesXT[i][2]
	next

	return acResult

	def PluralsOfStzClasses()
		return StzClassesPlurals()

	def PluralsOfStzClassesNames()
		return StzClassesPlurals()

	def StzTypesPlurals()
		return StzClassesPlurals()

	def PluralsOfStzTypes()
		return StzClassesPlurals()

func IsPluralOfAStzType(cPlural)
	if CheckingParams()
		if NOT isString(cPlural)
			StzRaise("Incorrect param! cPlural must be a string.")
		ok
	ok

	cPlural = lower(cPlural)
	acPlurals = StzClassesPlurals()
	nLen = len(acPlurals)

	if find(acPlurals, cPlural) > 0
		return _TRUE_
	else
		return _FALSE_
	ok

	#< @FunctionAlternativeForms

	func IsPluralOfStzType(cPlural)
		return IsPluralOfAStzType(cPlural)

	func IsStzTypePlural(cPlural)
		return IsPluralOfAStzType(cPlural)

	func IsPluralOfAStzClass(cPlural)
		return IsPluralOfAStzType(cPlural)

	func IsPluralOfStzClass(cPlural)
		return IsPluralOfAStzType(cPlural)

	func IsStzClassPlural(cPlural)
		return IsPluralOfAStzType(cPlural)

	func IsPluralOfAStzClassName(cPlural)
		return IsPluralOfAStzType(cPlural)

	func IsPluralOfStzClassName(cPlural)
		return IsPluralOfAStzType(cPlural)

	func IsStzClassNamePlural(cPlural)
		return IsPluralOfAStzType(cPlural)

	#--

	func IsStzTypeInPlural(cPlural)
		return IsPluralOfAStzType(cPlural)

	func IsAStzTypeInPlural(cPlural)
		return IsPluralOfAStzType(cPlural)

	#==

	func @IsPluralOfAStzType(cPlural)
		return IsPluralOfAStzType(cPlural)

	func @IsPluralOfStzType(cPlural)
		return IsPluralOfAStzType(cPlural)

	func @IsStzTypePlural(cPlural)
		return IsPluralOfAStzType(cPlural)

	func @IsPluralOfAStzClass(cPlural)
		return IsPluralOfAStzType(cPlural)

	func @IsPluralOfStzClass(cPlural)
		return IsPluralOfAStzType(cPlural)

	func @IsStzClassPlural(cPlural)
		return IsPluralOfAStzType(cPlural)

	func @IsPluralOfAStzClassName(cPlural)
		return IsPluralOfAStzType(cPlural)

	func @IsPluralOfStzClassName(cPlural)
		return IsPluralOfAStzType(cPlural)

	func @IsStzClassNamePlural(cPlural)
		return IsPluralOfAStzType(cPlural)

	#--

	func @IsStzTypeInPlural(cPlural)
		return IsPluralOfAStzType(cPlural)

	func @IsAStzTypeInPlural(cPlural)
		return IsPluralOfAStzType(cPlural)

	#>

func PluralToStzType(cPlural)
	if CheckingParams()
		if NOT isString(cPlural)
			StzRaise("Incorrect param! cPlural must be a string.")
		ok
	ok

	cPlural = lower(cPlural)
	
	acTypesXT = StzTypesXT()

	nLen = len(acTypesXT)

	cResult = ""

	for i = 1 to nLen
		if acTypesXT[i][2] = cPlural
			cResult = acTypesXT[i][1]
			exit
		ok
	next

	if cResult = ""
		StzRaise("Not a plural of a stzType or can't find it!")
	ok

	return cResult

	#< @FunctionAlternativeForms

	func PluraltoStzClass(cPlural)
		return PluralToStzType(cPlural)

	func PluraltoStzClassName(cPlural)
		return PluralToStzType(cPlural)

	#>

func IsStzObject(pObject)

	if isObject(pObject) and Q(classname(pObject)).ExistsIn( StzTypes() )
		return _TRUE_
	else
		return _FALSE_
	ok

	#< @FunctionAlternativeForms

	func ObjectIsStzObject(pObject)
		return IsStzObject(pObject)

	func @IsStzObject(pObject)
		return IsStzObject(pObject)

	#--

	func IsAStzObject(pObject)
		return IsStzObject(pObject)

	func @IsAStzObject(pObject)
		return IsStzObject(pObject)

	func ObjectIsAStzObject(pObject)
		return IsStzObject(pObject)

	#>

func IsNamedObject(pObject) 
	if isObject(pObject) and @IsStzObject(pObject) and pObject.IsNamed()
		return _TRUE_

	else
		return _FALSE_
	ok

	#< @FunctionAlternativeForms

	func ObjectIsNamedObject(pObject)
		return IsNamedObject(pObject)

	func @IsNamedObject(pObject)
		return IsNamedObject(pObject)

	#--

	func IsANamedObject(pObject)
		return IsNamedObject(pObject)

	func @IsANamedObject(pObject)
		return IsNamedObject(pObject)

	#>

func IsUnnamedObject(pObject)
	return NOT IsNamedObject(pObject)

	#< @FunctionAlternativeForms

	func ObjectIsUnnamedObject()
		return IsUnnamedObject(pObject)

	func @IsUnnamedObject(pObject)
		return IsUnnamedObject(pObject)

	#--

	func IsAUnnamedObject(pObject)
		return IsUnnamedObject(pObject)

	func @IsAnUnnamedObject(pObject)
		return IsUnnamedObject(pObject)

	#>

func AreEqualObjects(paObjects)
	if NOT AreNamedObjects(paObjects)
		StzRaise("Incorrect param type! paObjects must be a list of named objects.")
	ok

	acNames = ObjectsNames(paObjects)
	if len(U(acNames)) = 1	# A bit of magic sometimes ;)
		return _TRUE_
	else
		return _FALSE_
	ok

	#< @FunctionAlternativeForms

	func AreEqualNamedObjects(paObjects)
		return AreEqualObjects(paObjects)

	func @AreEqualObjects(paObjects)
		return AreEqualObjects(paObjects)

	func @AreEqualNamedObjects(paObjects)
		return AreEqualObjects(paObjects)

	#>

func AreNamedObjects(paObjects) 
	if isList(paObjects) and IsListOfObjects(paObjects)
		bResult = _TRUE_

		nLen = len(paObjects)
		for i = 1 to nLen
			if NOT IsNamedObject(paObjects[i])
				bResult = _FALSE_
				exit
			ok
		next

		return bResult
	else
		return _FALSE_
	ok

	#< @FunctionAlternativeForms

	func @AreNamedObjects(paObjects)
		return AreNamedObjects(paObjects)

	#>

func AreUnnamedObjects(paObjects)
	return NOT AreNamedObjects(paObjects)

	func @AreUnnamedObjects(paObjects)
		return AreUnnamedObjects(paObjects)

func ObjectsNames(paObjects)
	if CheckingParams()
		if NOT isList(paObjects)
			StzRaise("Incorrect param type! paObjects must be a list.")
		ok
	ok

	acResult = []
	nLen = len(paObjects)

	for i = 1 to nLen
		if isObject(paObjects[i])
			acResult + @@(paObjects[i])
		ok
	next

	return acResult

	#< @FunctionAlternativeForms

	func ObjectsVarNames(paObjects)
		return ObjectsNames(paObjects)

	func ObjectsVarsNames(paObjects)
		return ObjectsNames(paObjects)

	#--

	func @ObjectsNames(paObjects)
		return ObjectsNames(paObjects)

	func @ObjectsVarNames(paObjects)
		return ObjectsNames(paObjects)

	func @ObjectsVarsNames(paObjects)
		return ObjectsNames(paObjects)

	#>

/* NOTE: The following section of code is generated with
	 stzCodeGenerators and then pasted here
*/

#< @StartOfGenCode >

func IsStzNaturalCode(pObject)
	if isObject(pObject) and classname(pObject) = "stznaturalcode"
		return _TRUE_
	else
		return _FALSE_
	ok

	func ObjectIsStzNaturalCode(pObject)
		return IsStzNaturalCode(pObject)

	func @IsStzNaturalCode(pObject)
		return IsStzNaturalCode(pObject)

	#--

	func IsAStzNaturalCode(pObject)
		return IsStzNaturalCode(pObject)

	func @IsAStzNaturalCode(pObject)
		return IsStzNaturalCode(pObject)


func IsStzChainOfValue(pObject)
	if isObject(pObject) and classname(pObject) = "stzchainofvalue"
		return _TRUE_
	else
		return _FALSE_
	ok

	func ObjectIsStzchainofvalue(pObject)
		return IsStzchainofvalue(pObject)

	func @IsStzChainOfValue(pObject)
		return IsStzChainOfValue(pObject)

	#--

	func IsAStzChainOfValue(pObject)
		return IsStzChainOfValue(pObject)

	func @IsAStzChainOfValue(pObject)
		return IsStzChainOfValue(pObject)

func IsStzchainofTruth(pObject)
	if isObject(pObject) and classname(pObject) = "stzchainoftruth"
		return _TRUE_
	else
		return _FALSE_
	ok

	func ObjectIsStzchainoftruth(pObject)
		return IsStzchainoftruth(pObject)

	func @IsStzchainoftruth(pObject)
		return IsStzchainoftruth(pObject)

	#--

	func IsAStzchainofTruth(pObject)
		return IsStzchainofTruth(pObject)

	func @IsAStzchainofTruth(pObject)
		return IsStzchainofTruth(pObject)

func IsStzChainOfCode(pObject)
	if isObject(pObject) and classname(pObject) = "stzchainofcode"
		return _TRUE_
	else
		return _FALSE_
	ok

	func ObjectIsStzchainofcode(pObject)
		return IsStzchainofcode(pObject)

	func @IsStzchainofcode(pObject)
		return IsStzchainofcode(pObject)

	#--

	func IsAStzchainofCode(pObject)
		return IsStzchainofCode(pObject)

	func @IsAStzchainofTCode(pObject)
		return IsStzchainofCode(pObject)

func IsStzTransform(pObject)
	if isObject(pObject) and classname(pObject) = "stztransform"
		return _TRUE_
	else
		return _FALSE_
	ok

	func ObjectIsStztransform(pObject)
		return IsStztransform(pObject)

	func @IsStztransform(pObject)
		return IsStztransform(pObject)

	#--

	func IsAStzTransform(pObject)
		return IsStzTransform(pObject)

	func @IsAStzTransform(pObject)
		return IsStzTransform(pObject)

func IsStzDecimalToBinary(pObject)
	if isObject(pObject) and classname(pObject) = "stzdecimaltobinary"
		return _TRUE_
	else
		return _FALSE_
	ok

	func ObjectIsStzdecimaltobinary(pObject)
		return IsStzdecimaltobinary(pObject)

	func @IsStzdecimaltobinary(pObject)
		return IsStzdecimaltobinary(pObject)

	#--

	func IsAStzDecimalToBinary(pObject)
		return IsStzDecimalToBinary(pObject)

	func @IsAStzDecimalToBinary(pObject)
		return IsStzDecimalToBinary(pObject)

func IsStzListOfNumbers(pObject)
	if isObject(pObject) and classname(pObject) = "stzlistofnumbers"
		return _TRUE_
	else
		return _FALSE_
	ok

	func ObjectIsStzlistofnumbers(pObject)
		return IsStzlistofnumbers(pObject)

	func @IsStzlistofnumbers(pObject)
		return IsStzlistofnumbers(pObject)

	#--

	func IsAStzListOfNumbers(pObject)
		return IsStzListOfNumbers(pObject)

	func @IsAStzListOfNumbers(pObject)
		return IsStzListOfNumbers(pObject)

func IsStzListOfUnicodes(pObject)
	if isObject(pObject) and classname(pObject) = "stzlistofunicodes"
		return _TRUE_
	else
		return _FALSE_
	ok

	func ObjectIsStzlistofunicodes(pObject)
		return IsStzlistofunicodes(pObject)

	func @IsStzlistofunicodes(pObject)
		return IsStzlistofunicodes(pObject)

	#--

	func IsAStzListOfUnicodes(pObject)
		return IsStzListOfUnicodes(pObject)

	func @IsAStzListOfUnicodes(pObject)
		return IsStzListOfUnicodes(pObject)

func IsStzBinaryNumber(pObject)
	if isObject(pObject) and classname(pObject) = "stzbinarynumber"
		return _TRUE_
	else
		return _FALSE_
	ok

	func ObjectIsStzBinaryNumber(pObject)
		return IsStzbinarynumber(pObject)

	func @IsStzbinarynumber(pObject)
		return IsStzbinarynumber(pObject)

	#--

	func IsAStzBinaryNumber(pObject)
		return IsStzBinaryNumber(pObject)

	func @IsAStzBinaryNumber(pObject)
		return IsStzBinaryNumber(pObject)

func IsStzHexNumber(pObject)
	if isObject(pObject) and classname(pObject) = "stzhexnumber"
		return _TRUE_
	else
		return _FALSE_
	ok

	func ObjectIsStzhexnumber(pObject)
		return IsStzhexnumber(pObject)

	func @IsStzhexnumber(pObject)
		return IsStzhexnumber(pObject)

	#--

	func IsAStzHexNumber(pObject)
		return IsStzHexNumber(pObject)

	func @IsAStzHexNumber(pObject)
		return IsStzHexNumber(pObject)

func IsStzOctalNumber(pObject)
	if isObject(pObject) and classname(pObject) = "stzoctalnumber"
		return _TRUE_
	else
		return _FALSE_
	ok

	func ObjectIsStzoctalnumber(pObject)
		return IsStzoctalnumber(pObject)

	func @IsStzoctalnumber(pObject)
		return IsStzoctalnumber(pObject)

	#--

	func IsAStzOctalNumber(pObject)
		return IsStzOctalNumber(pObject)

	func @IsAStzOctalNumber(pObject)
		return IsStzOctalNumber(pObject)

func IsStzString(pObject)
	if isObject(pObject) and classname(pObject) = "stzstring"
		return _TRUE_
	else
		return _FALSE_
	ok

	func ObjectIsStzstring(pObject)
		return IsStzstring(pObject)

	func @IsStzstring(pObject)
		return IsStzstring(pObject)

	#--

	func IsAStzString(pObject)
		return IsStzString(pObject)

	func @IsAStzString(pObject)
		return IsStzString(pObject)

func IsStzlistOfStrings(pObject)
	if isObject(pObject) and classname(pObject) = "stzlistofstrings"
		return _TRUE_
	else
		return _FALSE_
	ok

	func ObjectIsStzlistofstrings(pObject)
		return IsStzlistofstrings(pObject)

	func @IsStzlistofstrings(pObject)
		return IsStzlistofstrings(pObject)

	#--

	func IsAStzListOfStrings(pObject)
		return IsStzlistOfStrings(pObject)

	func @IsAStzListOfStrings(pObject)
		return IsStzlistOfStrings(pObject)

func IsStzlistInString(pObject)
	if isObject(pObject) and classname(pObject) = "stzlistinstring"
		return _TRUE_
	else
		return _FALSE_
	ok

	func ObjectIsStzlistinstring(pObject)
		return IsStzlistinstring(pObject)

	func @IsStzlistinstring(pObject)
		return IsStzlistinstring(pObject)

	#--

	func IsAStzListInString(pObject)
		return IsStzlistInString(pObject)

	func @IsAStzListInString(pObject)
		return IsStzlistInString(pObject)

func IsStzListOfBytes(pObject)
	if isObject(pObject) and classname(pObject) = "stzlistofbytes"
		return _TRUE_
	else
		return _FALSE_
	ok

	func ObjectIsStzlistofbytes(pObject)
		return IsStzlistofbytes(pObject)

	func @IsStzlistofbytes(pObject)
		return IsStzlistofbytes(pObject)

	#--

	func IsAStzListOfBytes(pObject)
		return IsStzlistOfBytes(pObject)

	func @IsAStzListOfBytes(pObject)
		return IsStzlistOfBytes(pObject)

func IsStzMultilingualString(pObject)
	if isObject(pObject) and classname(pObject) = "stzmultistring"
		return _TRUE_
	else
		return _FALSE_
	ok

	func ObjectIsStzmultilingualstring(pObject)
		return IsStzmultilingualstring(pObject)

	func @IsStzmultilingualstring(pObject)
		return IsStzmultilingualstring(pObject)

	#--

	func IsAStzMultilingualString(pObject)
		return IsStzMultilingualString(pObject)

	func @IsAStzMultilingualString(pObject)
		return IsStzMultilingualString(pObject)

	#==

	func IsStzmultistring(pObject)
		return IsStzMultilingualString(pObject)

	func ObjectIsStzmultistring(pObject)
		return IsStzMultilingualString(pObject)

	func @IsStzmultistring(pObject)
		return IsStzMultilingualString(pObject)

	#--

	func IsAStzMultiString(pObject)
		return IsStzMultilingualString(pObject)

	func @IsAStzMultiString(pObject)
		return IsStzMultilingualString(pObject)

	#>


func IsStzchar(pObject)
	if isObject(pObject) and classname(pObject) = "stzchar"
		return _TRUE_
	else
		return _FALSE_
	ok

	func ObjectIsStzchar(pObject)
		return IsStzchar(pObject)

	func @IsStzchar(pObject)
		return IsStzchar(pObject)

	#--

	func IsAStzChar(pObject)
		return IsStzChar(pObject)

	func ObjectIsAStzchar(pObject)
		return IsStzchar(pObject)

	func @IsAStzchar(pObject)
		return IsStzchar(pObject)

func IsStzlistofchars(pObject)
	if isObject(pObject) and classname(pObject) = "stzlistofchars"
		return _TRUE_
	else
		return _FALSE_
	ok

	func ObjectIsStzlistofchars(pObject)
		return IsStzlistofchars(pObject)

	func @IsStzlistofchars(pObject)
		return IsStzlistofchars(pObject)

	#--

	func IsAStzListOfChars(pObject)
		return IsStzlistofchars(pObject)

	func ObjectIsAStzlistofchars(pObject)
		return IsStzlistofchars(pObject)

	func @IsAStzlistofchars(pObject)
		return IsStzlistofchars(pObject)

func IsStzlist(pObject)
	if isObject(pObject) and classname(pObject) = "stzlist"
		return _TRUE_
	else
		return _FALSE_
	ok

	func ObjectIsStzlist(pObject)
		return IsStzlist(pObject)

	func @IsStzlist(pObject)
		return IsStzlist(pObject)
		
	#--

	func IsAStzList(pObject)
		return IsStzlist(pObject)

	func ObjectIsAStzlist(pObject)
		return IsStzlist(pObject)

	func @IsAStzlist(pObject)
		return IsStzlist(pObject)

func IsStzHashlist(pObject)
	if isObject(pObject) and classname(pObject) = "stzhashlist"
		return _TRUE_
	else
		return _FALSE_
	ok

	#< @FunctionAlternativeForms

	func ObjectIsStzHashlist(pObject)
		return IsStzHashlist(pObject)

	func @IsStzHashlist(pObject)
		return IsStzHashlist(pObject)

	#--

	func IsAStzHashList(pObject)
		return IsStzHashlist(pObject)

	func ObjectIsAStzHashlist(pObject)
		return IsStzHashlist(pObject)

	func @IsAStzHashlist(pObject)
		return IsStzHashlist(pObject)

	#==

	func IsStzAssociativeList(pObject)
		return IsStzHashlist(pObject)

	func ObjectIsStzassociativelist(pObject)
		return IsStzHashlist(pObject)

	func @IsStzassociativelist(pObject)
		return IsStzHashlist(pObject)

	#--

	func IsAStzAssociativeList(pObject)
		return IsStzHashlist(pObject)

	func ObjectIsAStzAssociativelist(pObject)
		return IsStzHashlist(pObject)

	func @IsAStzAssociativelist(pObject)
		return IsStzHashlist(pObject)

	#>

func IsStzlistofhashlists(pObject)
	if isObject(pObject) and classname(pObject) = "stzlistofhashlists"
		return _TRUE_
	else
		return _FALSE_
	ok

	#< @FunctionAlternativeForms

	func ObjectIsStzListOfHashlists(pObject)
		return IsStzlistofhashlists(pObject)

	func @IsStzListOfHashlists(pObject)
		return IsStzlistofhashlists(pObject)

	#--

	func IsAStzListOfHashLists(pObject)
		return IsStzlistofhashlists(pObject)

	func ObjectIsAStzListOfHashlists(pObject)
		return IsStzlistofhashlists(pObject)

	func @IsAStzListOfHashlists(pObject)
		return IsStzlistofhashlists(pObject)

	#==

	func IsStzListOfAssociativeLists(pObject)
		return IsStzlistofhashlists(pObject)

	func ObjectIsStzListOfAssociativeLists(pObject)
		return IsStzlistofhashlists(pObject)

	func @IsStzListOfAssociativeLists(pObject)
		return IsStzlistofhashlists(pObject)

	#--

	func IsAStzListOfAssociativeLists(pObject)
		return IsStzlistofhashlists(pObject)

	func ObjectIsAStzListOfAssociativeLists(pObject)
		return IsStzlistofhashlists(pObject)

	func @IsAStzListOfAssociativeLists(pObject)
		return IsStzlistofhashlists(pObject)

	#>


func IsStzset(pObject)
	if isObject(pObject) and classname(pObject) = "stzset"
		return _TRUE_
	else
		return _FALSE_
	ok

	func ObjectIsStzset(pObject)
		return IsStzset(pObject)

	func @IsStzset(pObject)
		return IsStzset(pObject)

	#--

	func IsAStzSet(pObject)
		return IsStzSet(pObject)

	func ObjectIsAStzset(pObject)
		return IsStzset(pObject)

	func @IsAStzset(pObject)
		return IsStzset(pObject)

func IsStzlistofsets(pObject)
	if isObject(pObject) and classname(pObject) = "stzlistofsets"
		return _TRUE_
	else
		return _FALSE_
	ok

	func ObjectIsStzlistofsets(pObject)
		return IsStzlistofsets(pObject)

	func @IsStzlistofsets(pObject)
		return IsStzlistofsets(pObject)

	#--

	func IsAStzListOfSets(pObject)
		return IsStzlistofsets(pObject)

	func ObjectIsAStzListOfSets(pObject)
		return IsStzlistofsets(pObject)

	func @IsAStzListOfSets(pObject)
		return IsStzlistofsets(pObject)

func IsStzlistoflists(pObject)
	if isObject(pObject) and classname(pObject) = "stzlistoflists"
		return _TRUE_
	else
		return _FALSE_
	ok

	func ObjectIsStzlistoflists(pObject)
		return IsStzlistoflists(pObject)

	func @IsStzlistoflists(pObject)
		return IsStzlistoflists(pObject)

	#--

	func IsAStzListOfLists(pObject)
		return IsStzlistofLists(pObject)

	func ObjectIsAStzListOfLists(pObject)
		return IsStzlistofLists(pObject)

	func @IsAStzListOfLists(pObject)
		return IsStzlistofLists(pObject)

func IsStzlistofpairs(pObject)
	if isObject(pObject) and classname(pObject) = "stzlistofpairs"
		return _TRUE_
	else
		return _FALSE_
	ok

	func ObjectIsStzlistofpairs(pObject)
		return IsStzlistofpairs(pObject)

	func @IsStzlistofpairs(pObject)
		return IsStzlistofpairs(pObject)

	#--

	func IsAStzListOfPairs(pObject)
		return IsStzlistofPairs(pObject)

	func ObjectIsAStzListOfPairs(pObject)
		return IsStzlistofPairs(pObject)

	func @IsAStzListOfPairs(pObject)
		return IsStzlistofPairs(pObject)

func IsStztree(pObject)
	if isObject(pObject) and classname(pObject) = "stztree"
		return _TRUE_
	else
		return _FALSE_
	ok

	func ObjectIsStztree(pObject)
		return IsStztree(pObject)

	func @IsStztree(pObject)
		return IsStztree(pObject)

	#--

	func IsAStzTree(pObject)
		return IsStzTree(pObject)

	func ObjectIsAStztree(pObject)
		return IsStztree(pObject)

	func @IsAStztree(pObject)
		return IsStztree(pObject)

func IsStzwalker(pObject)
	if isObject(pObject) and classname(pObject) = "stzwalker"
		return _TRUE_
	else
		return _FALSE_
	ok

	func ObjectIsStzwalker(pObject)
		return IsStzwalker(pObject)

	func @IsStzwalker(pObject)
		return IsStzwalker(pObject)

	#--

	func IsAStzWalker(pObject)
		return IsStzwalker(pObject)

	func ObjectIsAStzWalker(pObject)
		return IsStzwalker(pObject)

	func @IsAStzWalker(pObject)
		return IsStzwalker(pObject)

func IsStztable(pObject)
	if isObject(pObject) and classname(pObject) = "stztable"
		return _TRUE_
	else
		return _FALSE_
	ok

	func ObjectIsStztable(pObject)
		return IsStztable(pObject)

	func @IsStztable(pObject)
		return IsStztable(pObject)

	#--

	func IsAStzTable(pObject)
		return IsStzTable(pObject)

	func ObjectIsAStzTable(pObject)
		return IsStzTable(pObject)

	func @IsAStzTable(pObject)
		return IsStzTable(pObject)

func IsStzlocale(pObject)
	if isObject(pObject) and classname(pObject) = "stzlocale"
		return _TRUE_
	else
		return _FALSE_
	ok

	func ObjectIsStzlocale(pObject)
		return IsStzlocale(pObject)

	func @IsStzlocale(pObject)
		return IsStzlocale(pObject)

	#--

	func IsAStzLocale(pObject)
		return IsStzLocale(pObject)

	func ObjectIsAStzLocale(pObject)
		return IsStzLocale(pObject)

	func @IsAStzLocale(pObject)
		return IsStzLocale(pObject)

func IsStzgrid(pObject)
	if isObject(pObject) and classname(pObject) = "stzgrid"
		return _TRUE_
	else
		return _FALSE_
	ok

	func ObjectIsStzgrid(pObject)
		return IsStzgrid(pObject)

	func @IsStzgrid(pObject)
		return IsStzgrid(pObject)

	#--

	func IsAStzGrid(pObject)
		return IsStzGrid(pObject)

	func ObjectIsAStzGrid(pObject)
		return IsStzGrid(pObject)

	func @IsAStzGrid(pObject)
		return IsStzGrid(pObject)

func IsStzNullObject(pObject)
	if isObject(pObject) and classname(pObject) = "stznullobject"
		return _TRUE_
	else
		return _FALSE_
	ok

	#< @FunctionAlternativeForms

	func IsNullObject(pObject)
		return IsStzNullObject(pObject)

	func ObjectIsStzNullObject(pObject)
		return IsTzNullObject(pObject)

	func ObjectIsNullObject(pObject)
		return IsStzNullObject(pObject)

	#--

	func @IsStzNullObject(pObject)
		return IsStzNullObject(pObject)

	func @IsNullObject(pObject)
		return IsStzNullObject(pObject)

	#==

	func IsAStzNullObject(pObject)
		return IsStzNullObject(pObject)

	func IsANullObject(pObject)
		return IsStzNullObject(pObject)

	func ObjectIsStzANullObject(pObject)
		return IsStzNullObject(pObject)

	func ObjectIsANullObject(pObject)
		return IsStzNullObject(pObject)

	#--

	func @IsAStzNullObject(pObject)
		return IsStzNullObject(pObject)

	func @IsANullObject(pObject)
		return IsStzNullObject(pObject)

	#>

func IsStzFalseObject(pObject)
	if isObject(pObject) and classname(pObject) = "stzfalseobject"
		return _TRUE_
	else
		return _FALSE_
	ok

	#< @FunctionAlternativeForms

	func IsFalseObject(pObject)
		return IsStzFalseObject(pObject)

	func ObjectIsStzFalseObject(pObject)
		return IsStzFalseObject(pObject)

	func ObjectIsFalseObject(pObject)
		return IsStzFalseObject(pObject)

	#--

	func @IsStzFalseObject(pObject)
		return IsStzFalseObject(pObject)

	func @IsFalseObject(pObject)
		return IsStzFalseObject(pObject)

	#==

	func IsAStzFalseObject(pObject)
		return IsStzFalseObject(pObject)

	func IsAFalseObject(pObject)
		return IsStzFalseObject(pObject)

	func ObjectIsStzAFalseObject(pObject)
		return IsStzFalseObject(pObject)

	func ObjectIsAFalseObject(pObject)
		return IsStzFalseObject(pObject)

	#--

	func @IsAStzFalseObject(pObject)
		return IsStzFalseObject(pObject)

	func @IsAFalseObject(pObject)
		return IsStzFalseObject(pObject)

	#>

func IsStzTrueObject(pObject)
	if isObject(pObject) and classname(pObject) = "stzfalseobject"
		return _TRUE_
	else
		return _FALSE_
	ok

	#< @FunctionAlternativeForms

	func IsTrueObject(pObject)
		return IsStzTrueObject(pObject)

	func ObjectIsStzTrueObject(pObject)
		return IsStzTrueObject(pObject)

	func ObjectIsTrueObject(pObject)
		return IsStzTrueObject(pObject)

	#--

	func @IsStzTrueObject(pObject)
		return IsStzTrueObject(pObject)

	func @IsTrueObject(pObject)
		return IsStzTrueObject(pObject)

	#==

	func IsAStzTrueObject(pObject)
		return IsStzTrueObject(pObject)

	func IsATrueObject(pObject)
		return IsStzTrueObject(pObject)

	func ObjectIsStzATrueObject(pObject)
		return IsStzTrueObject(pObject)

	func ObjectIsATrueObject(pObject)
		return IsStzTrueObject(pObject)

	#--

	func @IsAStzTrueObject(pObject)
		return IsStzTrueObject(pObject)

	func @IsATrueObject(pObject)
		return IsStzTrueObject(pObject)

	#>

#< @EndOfGenCode >

func ObjectClassName(cObjectVarName)
	return StzObjectQ(cObjectVarName).ObjectClassName()

func ObjectAttributes(cObjectVarName)
	return StzObjectQ(cObjectVarName).ObjectAttributes()

func ObjectValues(cObjectVarName)
	return StzObjectQ(cObjectVarName).ObjectValues()

func ObjectAttributesAndValues(cObjectVarName)
	return StzObjectQ(cObjectVarName).ObjectAttributesAndValues()

func ObjectMethods(cObjectVarName)
	return StzObjectQ(cObjectVarName).ObjectMethods()

func ObjectToList(cObjectVarName)
	return StzObjectQ(cObjectVarName).ObjectToList()


  ///////////////
 //   CLASS   //
///////////////

class stzObject
	@content

	@cVarName = :@NoName

	These
	Those

	def init(pObject)

		# Creating an object from an existing object
		if isObject(pObject)
			@content = pObject

		# Creating an object from the name of an existing object
		but IsNonNullString(pObject)

			cCode = 'bOk = isObject(' + pObject + ')'
			eval(cCode)
			if NOT bOk
				StzRaise("Can't create a stzObject from the provided string! The string must be a valid object name.")
			ok

			@cVarName = pObject

			cCode = "@content = " + pObject
			eval(cCode)

		but IsNullString(pObject)
			StzRaise("Can't create a stzObject from an empty string!")
		
		else
			StzRaise("Type error: you must provide an object or an object varname inside a string!")
		ok

		if ObjectKeepingTime() = _TRUE_
			StartObjectTime()
		ok

		These = This
		Those = This

	def Content()
		return @content

		def Object()
			return This.Content()

		def ReturnIt() # Used for natural-coding
			return This.Content()

		def AndReturnIt()
			return This.Content()

		def ThenReturnIt()
			return This.Content()

		def AndThenReturnit()
			return This.Content()

	def VarName()
		return @cVarName

		#< @FunctionFluentForm

		def VarNameQ()
			return new stzString( This.VarName() )

		#>

		#< @FunctionAlternativeForms

		def ObjectName()
			return This.VarName()

			def ObjectNameQ()
				return This.VarNameQ()

		def Name()
			return This.VarName()

			def NameQ()
				return This.VarNameQ()

		def ObjectVarName()
			return This.VarName()

			def ObjectVarNameQ()
				return This.VarNameQ()

		#>

	def IsUnnamed()
		if This.VarName() = :@NoName
			return _TRUE_
		else
			return _FALSE_
		ok

		#< @FunctionAlternativeForms

		def IsUnnamedObject()
			return This.IsUnnamed()

		def HasNoName()
			return This.IsUnnamed()

		def IsNotNamed()
			return This.IsUnnamed()

		def IsNotNamedObject()
			return This.IsUnnamed()

		def IsAnUnnamedObject()
			return This.IsUnnamed()

		def IsNotANamedObject()
			return This.IsUnnamed()

		#>

	def IsNamed()
		if This.Name() != "" and This.Name() != :@NoName
			return _TRUE_
		else
			return _FALSE_
		ok

		#< @FunctionAlternativeForms

		def IsNamedObject()
			return This.IsNamed()

		def HasName()
			return This.IsNamed()

		def HasAName()
			return This.IsNamed()

		def IsANamedObject()
			return This.IsNamed()

		#>

	def SetVarName(pcVarName)
		if isList(pcVarName) and Q(pcVarName).IsToOrAsNamedParams()
			pcVarName = pcVarName[2]
		ok

		if NOT isString(pcVarName)
			StzRaise("Incorrect param type! pcVarName must be a string.")
		ok

		@cVarName = pcVarName
		SetV([ [pcVarName, This ] ])	# Save the name to read it with v(pcVarName)

		#< @FunctionAlternativeForms

		def SetVarNameTo(pcVarName)
			This.SetVarName(pcVarName)

		def SetObjectVarName(pcVarName)
			This.SetVarName(pcVarName)

		def SetObjectVarNameTo(pcVarName)
			This.SetVarName(pcVarName)

		def SetObjectName(pcVarName)
			This.SetVarName(pcVarName)

		def SetName(pcVarName)
			This.SetVarName(pcVarName)

		def RenameIt(pcVarName)
			This.SetVarName(pcVarName)

		#>

	def Copy()
		return new stzObject(@content)

	def ObjectClassName() # Depricated, use ClassName()
		return classname(This)

	def ObjectAttributes() # Depricated, use Attributes() instead
		return ring_attributes(This)

	def ObjectValues()
		aResult = []
		acAttributes = This.ObjectAttributes()
		nLen = len(acAttributes)

		for i = 1 to nLen 
			cCode = "aResult + This." + acAttributes[i]
			eval(cCode)
		next
		return aResult

		def AttributesValues()
			return This.ObjectValues()

	def ObjectAttributesAndValues()
		aResult = Association([
				This.ObjectAttributes(),
				This.ObjectValues()
		])

		return aResult

		def AttributesXT()
			return This.ObjectAttributesAndValues()

		def AttributesAndValues()
			return This.ObjectAttributesAndValues()

		def AttributesAndTheirValues()
			return This.ObjectAttributesAndValues()

		def ObjectAttributesAndTheirValues()
			return This.ObjectAttributesAndValues()

	def ObjectMethods() # Depricated, use Methods() instead
		return methods(This.Object())

	  #------------------#
	 #   CHECKING TYPE  #
	#------------------#

	def Type()
		return :Object
		#NOTE: Unlike Ring, Softanza returns the type in lowercase

		def RingType()
			return :Object

	def TypeXT()
		return [ This.Content(), This.Type() ]

	def StzType()
		return :stzObject
		#WARNING: The same function should exist inside each Softanza class
		#--> if we call it on a stzOject we get :stzobject, but if wa call
		#    on an other softanza type, say stzString or stzList for example,
		#    we get, not :stzobject as a result, but :stzstring and stzlist!

	def StzTypeXT()
		return [ :stzObject, This.Content() ]

	def IsStzNumber()
		if This.StzType() = :stzNumber
			return _TRUE_
		else
			return _FALSE_
		ok

		#< @FunctionAlternativeForm

		def IsAStzNumber()
			return This.IsStzNumber()

		#>

		#< @FunctionNegativeForm

		def IsNotStzNumber()
			return NOT This.IsStzNumber()

		def IsNotAStzNumber()
			return NOT This.IsStzNumber()

		#>
	
	def IsStzString()

		if This.StzType() = :stzString
			return _TRUE_
		else
			return _FALSE_
		ok

		#< @FunctionAlternativeForm

		def IsAStzString()
			return This.IsStzString()

		#>

		#< @FunctionNegativeForm

		def IsNotStzString()
			return NOT This.IsStzString()

		def IsNotAStzString()
			return NOT This.IsStzString()

		#>
	
	def IsStzList()
		if This.StzType() = :stzList
			return _TRUE_
		else
			return _FALSE_
		ok

		#< @FunctionAlternativeForm

		def IsAStzList()
			return This.IsStzList()

		#>

		#< @FunctionNegativeForm

		def IsNotStzList()
			return NOT This.IsStzList()

		def IsNotAStzList()
			return NOT This.IsStzList()

		#>
	
	def IsStzGrid()
		if This.StzType() = :stzgrid
			return _TRUE_
		else
			return _FALSE_
		ok

		#< @FunctionAlternativeForm

		def IsAStzGrid()
			return This.IsStzGrid()

		#>

		#< @FunctionNegativeForm

		def IsNotStzGrid()
			return NOT This.IsStzGrid()

		def IsNotAStzGrid()
			return NOT This.IsStzGrid()

		#>

	def IsStzObject()
		return _TRUE_

		#< @FunctionAlternativeForm

		def IsAStzObject()
			return _TRUE_

		#>

		#< @FunctionNegativeForm

		def IsNotStzObject()
			return _FALSE_
	
		def IsNotAStzObject()
			return This.IsNotAnObject()

		#>

	def HasSameTypeAs(p)
		return isObject(p)

	def HasSameStzTypeAs(p)
		if isObject(p) and Q(p).IsStzType() and
		   Q(p).StzType() = This.StzType()

			return _TRUE_
		else
			return _FALSE_
		ok

	def IsOneOfTheseTypes(paTypes)

		/* EXAMPLE

		? Q("2").IsOneOfTheseTypes([ :Number, :String, :List ])
		#--> _TRUE_

		# can also be written use :Or = ...
		? Q("2").IsOneOfTheseTypes([ :Number, :Or = :String, :Or = :List ])
		#--> _TRUE_
		*/

		if NOT isList(paTypes)
			StzRaise("Incorrect param type! paTypes must be a list.")
		ok

		_aTypes_ = paTypes
		_nLen_ = len(paTypes)

		for @i = 1 to _nLen_
			if isList(_aTypes_[@i]) and Q(_aTypes_[@i]).IsOrNamedParam()
				_aTypes_[@i] = _aTypes_[@i][2]
			ok
		next

		_bResult_ = _FALSE_

		for @i = 1 to _nLen_

			_cType_ = _aTypes_[@i]

			if _cType_ = "number" or _cType_ = "string" or _cType_ = "list"
				_cType_ = "A" + _cType_

			but _cType_ = "object"
				_cType_ = "anobject"
			ok

			if (This.IsA(_cType_) or This.Is(_cType_))
				_bResult_ = _TRUE_
				exit
			ok
		next

		return _bResult_

		#< @FunctionNegativeForm

		def IsNotOneOfTheseTypes(paTypes)
			return NOT This.IsOneOfTheseTypes(paTypes)
		#>

	def IsEachOneOfTheseTypes(paTypes)
		if NOT isList(paTypes)
			StzRaise("Incorrect param type! paTypes must be a list.")
		ok

		_aTypes_ = paTypes
		_nLen_ = len(_aTypes_)

		for @i = 1 to _nLen_
			if isList(_aTypes_[@i]) and Q(_aTypes_[@i]).IsOrOrAndNamedParam()
				_aTypes_[@i] = _aTypes_[@i][2]
			ok
		next

		_bResult_ = _TRUE_

		for @i = 1 to _nLen_

			if NOT (This.IsA(_aTypes_[@i]) or This.Is(_aTypes_[@i]))
				_bResult_ = _FALSE_
				exit
			ok
		next

		return _bResult_

	def IsNumberOrString()
		content = This.Content()
		if isNumber(content) or isString(content)
			return _TRUE_
		else
			return _FALSE_
		ok

		def IsStringOrNumber()
			return This.IsNumberOrString()

	def IsStringOrList()
		content = This.Content()

		if isString(content) or isList(content)
			return _TRUE_
		else
			return _FALSE_
		ok

		def IsListOrString()
			return This.IsListOrString()

	#==

	def IsFalseObject()
		if This.StzType() = :stzFlaseObject
			return _TRUE_
		else
			return _FALSE_
		ok

		#-- @Misspelled

		def IsFalseObejct()
			return This.IsFalseObject()

	def IsTrueObject()
		if This.StzType() = :stzFlaseObject
			return _TRUE_
		else
			return _FALSE_
		ok

	def IsNullObject()
		if This.StzType() = :stzNullObject
			return _TRUE_
		else
			return _FALSE_
		ok

	#=====

	def IsAXT(pacStr)

		/* EAMPLE
		? Q("ring").IsAXT([ :Lowercase, :Latin, :String ])
		*/

		if CheckingParams()

			if NOT isList(pacStr) 
				StzRaise("Incorrect param type! pacStr must be a list.")
			ok

			if NOT @IsListOfStrings(pacStr)
				StzRaise("Incorrect param type! pacStr must be a list of strings.")
			ok
		ok

		# Checking those functions against the object value

		nLen = len(pacStr)
		if nLen = 0
			return _FALSE_
		ok

		bResult = _TRUE_

		for i = 1 to nLen
			cCode = 'bResult = @is' + pacStr[i] + '(' + @@(this.Content()) + ')'

			eval(cCode)
			if bResult = _FALSE_
				exit
			ok
		next

		return bResult

		#-- @FunctionluentForm

		def IsAXTQ(pcType)
			if this.IsAXT(pcType) = _TRUE_

				content = This.Content()
		
				if isNumber(content)
					return new stzNumber(content)
		
				but isString(content)
					return new stzString(content)
		
				but isList(content)
					return new stzList(content)
		
				but isObject(content)
					return new stzObject(content)
		
				ok
			else
				return AFalseObject()
			ok

		#-- @FunctionAlternativeForm

		def IsAnXT(pacStr)
			return This.IsAXT(pacStr)

			def IsAnXTQ(pacStr)
				return This.IsAXTQ(pacStr)

			def IsAnXTQRT(pacStr, pcReturnType)
				return This.IsAXTQRT(pacStr, pcReturnType)

		#-- @FunctionNegativeForm

		def IsNotAXT(pacStr)
			return NOT This.IsAXT(pacStr)

			def IsNotAXTQ(pacStr)
				return NOT This.IsAXTQ(pacStr)

			def IsNotAXTQRT(pacStr, pcReturnType)
				return NOT This.IsAXTQRT(pacStr, pcReturnType)

		def IsNotAnXT(pacStr)
			return NOT This.IsAXT(pacStr)

			def IsNotAnXTQ(pacStr)
				return NOT This.IsAXTQ(pacStr)

			def IsNotAnXTQRT(pacStr, pcReturnType)
				return NOT This.IsAXTQRT(pacStr, pcReturnType)

	def IsA(pcType)
		/* Example

		? Q([ :name = "mio", :age = 12 ]).IsA(:HashList)
		--> _TRUE_

		? Q("ring").IsA([ :Lowercase, :Latin, :String ])

		*/

		if isList(pcType)
			return This.IsAXT(pcType)
		else
			return This.IsAXT([ pcType ])
		ok

		#< @FunctionFluentForm

		def IsAQ(pcType)

			if isList(pcType)
				return This.IsAXTQ(pcType)
			ok
	
			if This.IsA(pcType) = _TRUE_

				if pcType = "number" or pcType = "stznumber"
					return This.ToStzNumber()

				but pcType = "string" or pcType = "stzstring"
					return This.ToStzString()

				but pcType = "char" or pcType = "stzchar"
					return This.ToStzChar()

				but pcType = "list" or pcType = "stzlist"
					return This.ToStzList()

				but pctype = "object" or pcType = "stzobject"
					return This
				ok
			else
				return AFalseObject()
			ok

		def IsAQM(pcType)
			SetMainObject(This)
			return This.IsAQ(pcType)

		def IsAQMM(pcType)
			return MainObject()

		def IsAM(pcType)
			SetMainObject(This)
			return This.IsA(pcType)

			def IsAMQ(pcType)
				SetMainObject(This)
				return This.IsAQ(pcType)

		def IsAMM(pcType)
			return MainObject()

		#>

		#< @FunctionAlternativeForms

		def IsAn(pcType)
			return This.IsA(pcType)

			def IsAnQ(pcType)
				return This.IsAQ(pcType)

			def IsAnQM(pcType)
				return MainObject()

		def IsAnM(pcType)
			SetMainObject(This)
			return THis.IsAn(pcType)

			def IsAnMQ(pcType)
				SetMainObject(This)
				return This.IsAnQ(pcType)

		def IsAnMM(pctype)
			return MainObject()

		#--

		def AreA(pcType)
			return This.IsA(pcType)

			def AreAQ(pcType)
				return This.IsAQ(pcType)

			def AreAQM(pcType)
				return MainObject()

		def AreAM(pcType)
			SetMainObject(This)
			return This.AreA(pcType)

			def AreAMQ(pcType)
				SetMainObject(This)
				return This.AreAQ(pcType)

		def AreAMM(pcType)
			return MainObject()

		#--

		def AreAn(pcType)
			return This.IsA(pcType)

			def AreAnQ(pcType)
				return This.IsAQ(pcType)

			def AreAnQM(pcType)
				return MainObject()

		def AreAnM(pcType)
			SetMainObject(This)
			return This.AreAn(pcType)

			def AreAnMQ(pcType)
				SetMainObject(This)
				return This.AreAnQ(pcType)

		def AreAnMM(pcType)
			return MainObject()

		#--

		def IsThe(pcType)
			return This.IsA(pcType)

			def IsTheQ(pcType)
				return This.IsAQ(pcType)

			def IsTheQM(pcType)
				return MainObject()

		def IsTheM(pcType)
			SetMainObject(This)
			return This.IsThe(pcType)

			def IsTheMQ(pcType)
				SetMainObject(This)
				return This.IsTheQ(pcType)

		def IsTheMM(pcType)
			return MainObject()

		#--

		def AreThe(pcType)
			return This.IsA(pcType)

			def AreTheQ(pcType)
				return This.IsAQ(pcType)

			def AreTheQM(pcType)
				return MainObject()

		def AreTheM(pcType)
			SetMainObject(This)
			return This.AreThe(pcType)

			def AreTheMQ(pcType)
				SetMainObject(This)
				return This.AreTheQ(pcType)

		def AreTheMM(pcType)
			return MainObject()

		#>

	def Is(pcType)
		return This.IsA(pcType)

		def IsQ(pcType)
			if This.Is(pcType) = _TRUE_

				if pcType = "number" or pcType = "stznumber" or
				   pcType = "anumber" or pcType = "astznumber"
					return This.ToStzNumber()

				but pcType = "string" or pcType = "stzstring" or
				    pcType = "astring" or pcType = "astzstring"
					return This.ToStzString()

				but pcType = "char" or pcType = "stzchar" or
				    pcType = "achar" or pcType = "astzchar"
					return This.ToStzChar()

				but pcType = "list" or pcType = "stzlist" or
				    pcType = "alist" or pcType = "astzlist"
					return This.ToStzList()

				but pctype = "object" or pcType = "stzobject" or
				    pctype = "aobject" or pcType = "astzobject" or
				    pcType = "anobject"
					return This
				ok
			else
				return AFalseObject()
			ok

		def IsQM(pcType)
			return MainObject()

		def IsM(pcType)
			SetMainObject(This)
			return This.IsM(pcType)

			def IsMQ(pcType)
				SetMainObject(This)
				return This.IsQ(pcType)

		def IsMM(pcType)
			return MainObject()

	def Are(pcType)
		/* Example

		? Q([ 10, 20, 30 ]).Are(:Numbers)

		--> _TRUE_
		*/
 
		if NOT This.IsAList()
			return _FALSE_
		ok

		if NOT ( @IsRingTypeInPlural(pcType) or @IsStzTypeInPlural(pcType) )
			StzRaise("Incorrect param type! pcType must be a Ring type or Softanza type in plural.")
		ok

		cCode = 'bResult = This.IsListOf'+ pcType + '()'
		eval(cCode)
		return bResult

		#< @FunctionAlternativeForms

		def AreQ(pcType)
			if This.Are(pcType) = _TRUE_

				if pcType = "numbers" or pcType = "stznumbers"
					return This.ToStzListOfNumbers()

				but pcType = "strings" or pcType = "stzstrings"
					return This.ToStzListOfStrings()

				but pcType = "chars" or pcType = "stzchars"
					return This.ToStzListOfChars()

				but pcType = "lists" or pcType = "stzlists"
					return This.ToStzListOfLists()

				but pctype = "objects" or pcType = "stzobjects"
					return This.ToStzListOfObjects()
				ok
			else
				return AFalseObject()
			ok

		def AreQM(pcType)
			return MainObject()
			
		def AreM(pcType)
			SetMainObject(This)
			return This.Are(pcType)

			def AreMQ(pcType)
				SetMainObject(This)
				return This.AreQ(pcType)

		def AreMM(pcType)
			return MainObject()

		#>

		def AreAll(pcType)
			return This.Are(pcType)

			def AreAllQ(pcType)
				return This.AreQ(pcType)

			def AreAllQM(pcType)
				return MainObject()

		def AreAllM(pcType)
			SetMainObject(This)
			return this.AreAll(pcType)

			def AreAllMQ(pcType)
				SetMainObject(pcType)
				return This.AreAllQ(pcType)

		def AreAllMM(pcType)
			return MainObject()

	def AreBothA(pcType)

		if NOT (This.StzType() = "stzlist" and This.NumberOfItems() = 2)
			return AFalseObject()
		ok

		item1 = This.Content()[1]
		item2 = This.Content()[2]
		if isList(item2) and Q(item2).IsAndNamedParam()

			item2 = item2[2]
		ok

		This.UpdateWith([ item1, item2 ])

		return This.IsA(pcType)

		#< @FunctionFluentForm

		def AreBothAQ(pcType)

			if NOT (This.StzType() = "stzlist" and This.NumberOfItems() = 2)
				return AFalseObject()
			ok
	
			item1 = This.Content()[1]
			item2 = This.Content()[2]
			if isList(item2) and Q(item2).IsAndNamedParam()
	
				item2 = item2[2]
			ok
	
			This.UpdateWith([ item1, item2 ])

			return This.AreQ(pcType)

		def AreBothAQM(pcType)
			return MainObject()

		#>

		#< @FunctionAlternativeForms

		def AreBothAn(pcType)
			return This.AreBothA(pcType)

			def AreBothAnQ(pcType)
				return This.AreBothAQ(pcType)

			def AreBothAnQM(pcType)
				return MainObject()

		#--

		def AreBoth(pcType)
			return This.AreBothA(pcType)

			def AreBothQ(pcType)
				return This.AreBothAQ(pcType)

			def AreBothQM(pcType)
				return MainObject(This)

			def AreBothMQ(pcType)
				SetMainObject(This)
				return This

		def AreBothM(pcType)
			SetMainObject(This)
			return This.AreBoth(pcType)

		def AreBothMM(pcType)
			return MainObject()

		#--

		def BothAreA(pcType)
			return This.AreBothA(pcType)

			def BothAreAQ(pcType)
				return This.AreBothAQ(pcType)

			def BothAreAQM(pcType)
				return MainObject()

			def BothAreAMQ(pcType)
				SetMainObject(This)
				return This

		def AreBothAM(pcType)
			SetMainObject(This)
			return This.AreBothA(pcType)

			def AreBothAMQ(pcType)
				SetMainObject(This)
				return This.AreBothAQ(pcType)

		def AreBothAMM(pcType)
			return MainObject()

		#--

		def BothAreAn(pcType)
			return This.AreBothA(pcType)

			def BothAreAnQ(pcType)
				return This.AreBothAQ(pcType)

			def BothAreAnQM(pcType)
				return MainObject()

			def BothAreAnMQ(pcType)
				SetMainObject(This)
				return This

		def AreBothAnM(pcType)
			SetMainObject(This)
			return This.AreBothAn(pcType)

			def AreBothAnMQ(pcType)
				SetMainObject(This)
				return This.AreBothAnQ(pcType)

		def AreBothAnMM(pcType)
			return MainObject()

		#--

		def BothAre(pcType)
			return This.AreBoth(pcType)

			def BothAreQ(pcType)
				return This.AreBothQ(pcType)

			def BothAreQM(pcType)
				return MainObject()

		def BothAreM(pcType)
			return this.AreBothM(pcType)

			def BothAreMQ(pcType)
				return This.AreBothMQ(pcType)

		def BothAreMM(pcType)
			return MainObject()

		#--

		def AreTwo(pcType)
			return AreBothA(pcType)

			def AreTwoQ(pcType)
				return AreBothAQ(pcType)

			def AreTwoQM(pcType)
				return MainObject()

		def AreTwoM(pcType)
			SetMainObject(This)
			return This.AreTwo(pcType)

			def AreTwoMQ(pcType)
				SetMainObject(This)
				return This.AreTwoM(pcType)

		def AreTwoMM(pcType)
			return MainObject()

		#>

	def Which()
		return This

		def WichM()
			SetMainObject(This)
			return This

			def WichMQ()
				return This.WichM()
	
		def WichMM()
			return MainObject()

		def WhichQ()
			return This.Which()

		def WhichQM()
			return MainObject()

		def whichMQ()
			SetMainObject(This)
			return This
		#--
	
		def That()
			return This

		def ThatM()
			SetMainObject(This)
			return This

		def ThatMM()
			return MainObject()

		def ThatQ()
			return This

		def ThatQM()
			return MainObject()

		def ThatMQ()
			SetMainObject(This)
			return This

	def WhichIs()
		return This

		def WhichIsQ()
			return This.WhichIs()

		def WhichIsM()
			SetMainObject(This)
			return This

			def WhichIsMQ()
				return This.WhichIsM()

		def WhichIsQM()
			return MainObject()

		def WhichIsMM()
			return MainObject()

		#--

		def ThatIs()
			return This

		def ThatIsQ()
			return This.ThatIs()

		def ThatIsM()
			SetMainObject(This)
			return This

			def ThatIsMQ()
				return This.ThatIsM()

		def ThatiIsMM()
			return MainObject()

	def WhichAre()
		return This

		def WhichAreQ()
			return This.WhichAre()

		def WhichAreM()
			SetMainObject(This)
			return This

		def WhichAreMQ()
			return MainObject()

		def WhichAreMM()
			return MainObject()

		#--

		def ThatAre()
			return This

		def ThatAreQ()
			return This.ThatAre()

		def ThatAreM()
			SetMainObject(This)
			return This

			def ThatAreMQ()
				return This.ThatAreM()

		def ThatiAreMM()
			return MainObject()

	def WhichAreBoth()
		aContent = This.Content()
		if NOT (isList(aList) and len(aList) = 2)
			return AFalseObject()
		ok

		return This

		#-- @FluentForm

		def WhichAreBothQ()
			return This.WhichAre()

		#-- @AlternativeForms

		def WhichAreBothM()
			SetMainObject(This)
			return This.WhichAreBoth()

			def WhichAreBothMQ()
				SetMainObject(This)
				return This.WhichAreBothQ()

		def WhichAreBothQM()
			return MainObject()

		def WhichAreBothMM()
			return MainObject()

		#--

		def WhichBothAre()
			return This.WhichAreBoth()

		def WhichBothAreQ()
			return This.WhichAreBoth()

		def WhichBothAreM()
			SetMainObject(This)
			return This

			def WhichBothAreMQ()
				SetMainObject(This)
				return This.WhichBothAreQ()

		def WhichBothAreMM()
			return MainObject()

		#-- @MisspelledForms

		def WichAreBoth()
			return This.WhichAreBoth()

		def WichAreBothQ()
			return This.WhichAre()

		def WichAreBothM()
			SetMainObject(This)
			return This.WichAreBoth()

			def WichAreBothMQ()
				SetMainObject(This)
				return This.WichAreBothQ()

			def WichAreBothQM()
				return MainObject()

		def WichAreBothMM()
			return MainObject()

		#--

		def WichBothAre()
			return This.WhichAreBoth()

		def WichBothAreQ()
			return This.WhichAreBoth()

		def WichBothAreM()
			SetMainObject(This)
			return This.WichBothAre()

			def WichBothAreMQ()
				SetMainObject(This)
				return This.WichBothAreQ()

			def WichBothAreQM()
				return MainObject()

		def WichBothAreMM()
			return MainObject()

		#--

		def WitchBothAre()
			return This.WhichAreBoth()

		def WitchBothAreQ()
			return This.WhichAreBoth()

		def WitchBothAreM()
			SetMainObject(This)
			return This.WitchBothAre()

			def WitchBothAreMQ()
				SetMainObject(This)
				return This.WitchBothAreQ()

			def WitchBothAreQM()
				return MainObject()

		def WitchBothAreMM()
			return MainObject()

	def FromIt()
		return This.Content()

		def FromItQ()
			return This
		
	def FromQ()
		return This

	def FromThem()
		return This.Content()

		def FromThemQ()
			return This

	def WhileQ()
		return This

	def FinallyQ()
		return This

		def FinallyMQ()
			SetMainObject(This)
			return This

		def FinallyM()
			SetMainObject(This)
			return This

	def AndFinallyQ()
		return This

		def AndFinallyMQ()
			SetMainObject(This)
			return This

		def AndFinallyM()
			SetMainObject(This)
			return This

	def ThenQ()
		return This

		def ThenMQ()
			SetMainObject(This)
			return This

		def ThenM()
			SetMainObject(This)
			return This

	def AndThen()
		return This

		def AndThenQ()
			return This

			def AndThenMQ()
				SetMainObject(This)
				return This

			def AndThenQM()
				return MainObject()

		def AndQ()
			return This

			def AndQM()
				return MainObject()

			def AndMQ()
				SetMainObject()
				return This.AndQ()

		def AndThenM()
			SetMainObject()
			return This.AndThen()

		def AndThenMM()
			return MainObject()

	def QM()
		return MainObject() # Used in chains of truth

	def Having()
		return This

		def HavingQ()
			return This

		def HavingQM()
			return MainObject()

		def HavingMQ()
			SetMainObject(This)
			return This.HavingQ()

		def HavingM()
			return MainObject()
		
		#--

		def AndHaving()
			return This

		def AndHavingQ()
			return This

		def AndHavingQM()
			return MainObject()

		def AndHavingMQ()
			SetMainObject(This)
			return This.AndHavingQ()

		def AndHavingM()
			return MainObject()

	def With()
		return This

		def WithQ()
			return This

		def WithA()
			return This

		def WithAQ()
			return This

		def WithMQ()
			SetMainObject(This)
			return This.WithQ()

		def WithM()
			return MainObject()

		def WithAMQ()
			SetMainObject(This)
			return This.WithAQ()

		def WithAM()
			return MainObject()

	def WithQM()
		return MainObject()

		def WithAQM()
			return MainObject()
	
	def Only(value)
		SetLastValue(value)
		return This

		def OnlyQ(value)
			return Only(value)

		def OnLyQM(value)
			SetLastValue(value)
			return MainObject()

		def OnlyMQ(value)
			SetMainObject(This)
			return this.OnlyQ(value)

		def OnlyM(value)
			SetMainObject(This)
			return This.OnlyM(value)

		def OnlyMM(value)
			return MainObject()

	def A()
		return This

		def AQ()
			return This

		def AQM()
			return This

		#--

		def AM()
			SetMainObject(This)
			return This

		def AMQ()
			SetMainObject(This)
			return This

		def AMM()
			return MainObject()

	def Their()
		return This

		#< @FunctionFluentForm

		def TheirQ()
			return This

		def TheirQM()
			return MainObject()
		
		#>

		def TheirM()
			SetMainObject(This)
			return This.Their()

			def TheirMQ()
				SetMainObject(This)
				return This.TheirQ()
	
		def TheirMM()
			return MainObject()


		#< @FunctionAlternativeForms

		def AllTheir()
			return This

			def AllTheirQ()
				return This

			def AllTheirQM()
				return MainObject()

			def AlltheirMQ()
				SetMainObject(This)
				return This.AlltheirQ()

		def Its()
			return This

			def ItsM()
				SetMainObject(This)
				return This.Its()

			def ItsMM()
				return MainObject()

			def ItsQ()
				return This
	
			def ItsQM()
				return MainObject()

			def ItsMQ()
				SetMainObject(This)
				return This.ItsQ()

		def His()
			return This

			def HisM()
				SetMainObject(This)
				return This

			def HisMM()
				return MainObject()

			def HisQ()
				return This
	
			def HisQM()
				return MainObject()

			def HisMQ()
				SetMainObject(This)
				return This.HisQ()

		def Her()
			return This

			def HerM()
				SetMainObject(This)
				return This

			def HerMM()
				return MainObject()

			def HerQ()
				return This
	
			def HerQM()
				return MainObject()

			def HerMQ()
				SetMainObject(This)
				return This.HerQ()

		def My()
			return This


			def MyM()
				SetMainObject(This)
				return This

			def MyMM()
				return MainObject()

			def MyQ()
				return This
	
			def MyQM()
				return MainObject()

			def MyMQ()
				SetMainObject(This)
				return This.MyQ()

		def Your()
			return This


			def YourM()
				SetMainObject(This)
				return This

			def YourMM()
				return MainObject()

			def YourQ()
				return This
	
			def YourQM()
				return MainObject()

			def YourMQ()
				SetMainObject(This)
				return This.YourQ()

		#>

	def As()
		return This

		def AsM()
			SetMainObject(This)
			return This.As()

		def AsMM()
			return MainObject()

		def AsQ()
			return This

		def AsQM()
			return MainObject()

		def AsMQ()
			SetMainObject(This)
			return This.AsM()

		#--

		def AsA()
			return This.As()

		def AsAM()
			return This.AsM()

		def AsAMM()
			return MainObject()

		def AsAQ()
			return This.AsQ()

		def AsAQM()
			return MainObject()

		def AsAMQ()
			return This.AsMQ()

		#--

		def AsThe()
			return This.As()

		def AstheM()
			return This.AsM()

		def AsTheMM()
			return MainObject()

		def AsTheQ()
			return This.AsQ()

		def AsTheQM()
			return MainObject()

		def AsTheMQ()
			return This.AsMQ()

	def The()
		return This

		def TheQ()
			return This.The()

		def The_M() # to avoid confusion with Them()
			SetMainObject(This)
			return This

			def The_MQ()
				return This.The_M()

		def The_MM()
			return MainObject()

	def Them()
		return This

		def ThemQ()
			return This.Them()

		def ThemM()
			SetMainObject(This)
			return This

			def ThemMQ()
				return This.ThemM()

		def ThemMM()
			return MainObejct()

	def Me()
		return This

		def MeM()
			SetMainObject(This)
			return This

		def MeMM()
			return MainObject()

		def MeQ()
			return This.Me()

		def MeQM()
			return MainObject()

		def MeMQ()
			SetMainObject(This)
			return This.MeQ()

	def Mine()
		return This

		def MineM()
			SetMainObject(This)
			return This

		def MineMM()
			return MainObject()

		def MineQ()
			return This.Mine()

		def MineQM()
			return MainObject()

		def MineMQ()
			SetMainObject(This)
			return This.MineQ()

	def It()
		return This

		def ItM()
			SetMainObject(This)
			return This

		def ItMM()
			return MainObject()

		def ItQ()
			return This.It()

		def ItQM()
			return MainObject()

		def ItMQ()
			SetMainObject(This)
			return This.ItQ()

	def You()
		return This

		def YouM()
			SetMainObject(This)
			return This

		def YouMM()
			return MainObject()

		def YouQ()
			return This.You()

		def YouQM()
			return MainObject()

		def YouMQ()
			SetMainObject(This)
			return This.YouQ()

	def Yours()
		return This

		def YoursM()
			SetMainObject(This)
			return This

		def YoursMM()
			return MainObject()

		def YoursQ()
			return This.Yours()

		def YoursQM()
			return MainObject()

		def YoursMQ()
			SetMainObject(This)
			return This.YoursQ()

	def Him()
		return This

		def HimM()
			SetMainObject(This)
			return This

		def HimMM()
			return MainObject()

		def HimQ()
			return This.Him()

		def HimQM()
			return MainObject()

		def HimMQ()
			SetMainObject(This)
			return This.HimQ()

	def Has()
		return This

		def HasM()
			SetMainObject(This)
			return This

		def HasMM()
			return MainObject()

		def HasQ()
			return This.Has()

		def HasQM()
			return MainObject()

		def HasMQ()
			SetMainObject(This)
			return This.HasQ()

	def HasA()
		return This

		def HasAM()
			SetMainObject(This)
			return This

		def HasAMM()
			return MainObject()

		def HasAQ()
			return This.HasA()

		def HasAQM()
			return MainObject()

		def HasaMQ()
			SetMainObject(This)
			return This.HasAQ()

	def HasN(n)
		if CheckingParams()
			if NOT isNumber(n)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		SetLastValue(n)
		return This

		def HasNM(n)
			if CheckingParams()
				if NOT isNumber(n)
					StzRaise("Incorrect param type! n must be a number.")
				ok
			ok
			SetMainObject(This)
			return This.HasN(n)

		def HasNMM()
			if CheckingParams()
				if NOT isNumber(n)
					StzRaise("Incorrect param type! n must be a number.")
				ok
			ok
			return MainObject()

		def HasNQ(n)
			return This.HasN(n)

		def HasNQM(n)
			return MainObject()

		def HasNMQ(n)
			SetMainObject(This)
			return This.HasNQ(n)

		#--

		def HasTheNumber(n)
			return This.HasN(n)

		def HasTheNumberM(n)
			SetMainObject(This)
			return This.HasTheNumber(n)

		def HasTheNumberMM(n)
			return MainObject()

		def HasTheNumberQ(n)
			return This.HasTheNumber(n)

		def HasTheNumberQM(n)
			return This.HasTheNumberM(n)

		def HasTheNumberMQ(n)
			return This.HasTheNumberM(n)

	#==

	def M()
		SetMainObject(This)
		return This

	def MM()
		return MainObject()

	def _(any)
		return LastValue()

		def _M()
			SetMainObject(This)
			return This._(any)

		def _MM()
			return MainObject()

		def _Q(any)
			return Q( This._(any) )

		def _QM(any)
			return MainObject()

		def _MQ(any)
			SetMainObject(This)
			return This._Q(any)

	#==

	def OfCS(n, pCaseSensitive)
		return This.IsEqualToCS(n, pCaseSensitive)

		def OfCSM(n, pCaseSensitive)
			SetMainObject(This)
			return This.OfCS(n, pCaseSensitive)

		def OfCSMM(n, pCaseSensitive)
			return MainObject()

		def OfCSQ(n, pCaseSensitive)
			if This.IsEqualToCS(n, pCaseSensitive)
				return This
			else
				return AFalseObject()
			ok

		def OfCSQM(n, pCaseSensitive)
			return MainObject()

		def OfCSMQ(n, pCaseSensitive)
			SetMainObject(This)
			return This.OfCSQ(n, pCaseSensitive)

	def Of(n)
		return This.OfCS(n, _TRUE_)

		def OfM(n)
			return This.OfCSM(n, _TRUE_)

		def OfMM(n)
			return This.OfCSMM(n, _TRUE_)

		def OfQ(n)
			return This.OfCSQ(n, _TRUE_)

		def OfQM(n)
			return MainObject()

		def OfMQ(n)
			return This.OfCSMQ(n, pCaseSensitive)
		
	#--

	def OfCSXT(n, cIgnored, pCaseSensitive)
		return This.OfCS(n, pCaseSensitive)

		def OfCSXTQ(n, cIgnored, pCaseSensitive)
			return This.OfCSQ(n, pCaseSensitive)

		def OfCSXTQM(n, cIgnored, pCaseSensitive)
			return This.OfCSQM(n, pCaseSensitive)

		def OfCSXTMQ(n, cIgnored, pCaseSensitive)
			return This.OfCSMQ(n, pCaseSensitive)

		def OfXTCS(n, cIgnored, pCaseSensitive)
			return This.OfCS(n, pCaseSensitive)

		def OfXTCSQ(n, cIgnored, pCaseSensitive)
			return This.OfCS(n, pCaseSensitive)

		def OfXTCSQM(n, cIgnored, pCaseSensitive)
			return This.OfCS(n, pCaseSensitive)

		def OfXTCSMQ(n, cIgnored, pCaseSensitive)
			return This.OfCS(n, pCaseSensitive)

	def OfXT(n, cIgnored)
		return This.OfCS(n, _TRUE_)

		def OfXTM(n, cIgnored)
			return This.OfCSM(n, _TRUE_)

		def OfXTMM(n, cIgnored)
			return This.OfCSMM(n, _TRUE_)

		def OfXTQ(n, cIgnored)
			return This.OfCSQ(n, _TRUE_)

		def OfXTQM(n, cIgnored)
			return This.OfCSXTQM(n, _TRUE_)

		def OfXTMQ(n, cIgnored)
			return This.OfCSXTMQ(n, _TRUE_)

	#==

	def OfCSB(n, pCaseSensitive)
		if Q(n).IsEqualToCS(LastValue(), pCaseSensitive)
			
			return _TRUE_
		else
			return _FALSE_
		ok

		def OfCSBM(n, pCaseSensitive)
			SetMainObject()
			return This.OfCSB(n, pCaseSensitive)

		def OfCSBMM(n, pCaseSensitive)
			return MainObject()

		def OfCSMB(n, pCaseSensitive)
			SetMainObject(This)
			return This.OfCSB(n, pCaseSensitive)

		def OfCSBQ(n, pCaseSensitive)
			if This.OfCSB(n, pCaseSensitive) = _TRUE_
				return This
			else
				return AFalseObject()
			ok

		def OfCSBQM(n, pCaseSensitive)
			SetMainObject(This)
			return This.OfCSBQ(n, pCaseSensitive)


		def OfCSBQMM(n, pCaseSensitive)
			return MainObject()

	def OfBM(n)
		return This.OfCSBM(n, pCaseSensitive)

		def OfBMM(n)
			return MainObject()

		def OfMB(n)
			return This.OfCSMB(n, _TRUE_)

		def OfBQ(n)
			return This.OfCSBQ(n, _TRUE_)

		def OfBQM(n)
			return This.OfCSBQM(n, _TRUE_)

		def OfBQMM(n)
			return MainObject()

	#==

	def OfXTCSB(n, cIgnored, pCaseSensitive)
		return This.OfCSB(c, pCaseSensitive)

		def OfXTCSBM(n, cIgnored, pCaseSensitive)
			return This.OfCSBM(n, pCaseSensitive)

		def OfXTCSBMM(n, cIgnored, pCaseSensitive)
			return MainObject()

		def OfXTCSMB(n, cIgnored, pCaseSensitive)
			return This.OfCSMB(n, pCaseSensitive)

		def OfXTCSBQ(n, cIgnored, pCaseSensitive)
			return This.OfCSBQ(n, pCaseSensitive)

		def OfXTCSBQM(n, cIgnored, pCaseSensitive)
			return This.OfCSBQM(n, pCaseSensitive)

		def OfXTCSBQMM(n, pCaseSensitive)
			return MainObject()

	def OfXTBM(n)
		return This.OfXTCSB(n, cIgnored, _TRUE_)

		def OfXTBMM(n)
			return MainObject()

		def OfXTMB(n)
			return This.OfXTCSMB(n, _TRUE_)

		def OfXTBQ(n)
			return This.OfXTCSBQ(n, _TRUE_)

		def OfXTBQM(n)
			return This.OfXTCSBQM(n, _TRUE_)

		def OfXTBQMM(n)
			return MainObject()

	#==

	def IsEitherA(pcType1, pcType2)
		if isList(pcType2) and Q(pcType2).IsOrNamedParam()
			pcType2 = pcType2[2]
		ok

		if NOT ( isString(pcType1) and isString(pcType2) )
			StzRaise("Incorrect param type! pcType1 and pcType2 must be strings.")
		ok

		if This.IsA(pcType1) or This.IsA(pcType2)
			return _TRUE_
		else
			return _FALSE_
		ok


		#< @functionAlternativeForms

		def IsEitherAn(pcType1, pcType2)
			return This.IsEitherA(pcType1, pcType2)

		def AreEitherA(pcType1, pcType2)
			return This.IsEitherA(pcType1, pcType2)

		def AreEitherAn(pcType1, pcType2)
			return This.IsEitherA(pcType1, pcType2)

		def AreBothEitherA(pcType1, pcType2)
			return This.IsEitherA(pcType1, pcType2)

		def AreEitherBothAn(pcType1, pcType2)
			return This.IsEitherA(pcType1, pcType2)

		#>

	def IsNeitherA(pcType1, pcType2)
		if isList(pcType2) and Q(pcType2).IsNorNamedParam()
			pcType2 = pcType2[2]
		ok

		if NOT ( isString(pcType1) and isString(pcType2) )
			StzRaise("Incorrect param type! pcType1 and pcType2 must be strings.")
		ok

		if NOT This.IsA(pcType1) and
		   NOT This.IsA(pcType2)

			return _TRUE_
		else
			return _FALSE_
		ok

		#< @functionAlternativeForms

		def IsNeitherAn(pcType1, pcType2)
			return This.IsNeitherA(pcType1, pcType2)

		def AreNeitherA(pcType1, pcType2)
			return This.IsNeitherA(pcType1, pcType2)

		def AreNeitherAn(pcType1, pcType2)
			return This.IsNeitherA(pcType1, pcType2)

		def AreBothNeitherA(pcType1, pcType2)
			return This.IsNeitherA(pcType1, pcType2)

		def AreNeitherBothAn(pcType1, pcType2)
			return This.IsNeitherA(pcType1, pcType2)

		#>

	  #-------------------------#
	 #  CHECKING OBJECT VALUE  #
	#-------------------------#

	def IsEither(pValue1, pValue2)
		if isList(pValue2) and Q(pValue2).IsOrNamedParam()
			pValue2 = pValue2[2]
		ok

		if This.IsAString()
			if BothAreStrings(pValue1, pValue2) and
			   ( This.String() = pValue1 or This.String() = pValue2 )

				return _TRUE_
			ok

		but This.IsANumber()

			if BothAreNumbers(pValue1, pValue2) and
			   ( This.Number() = pValue1 or This.Number() = pValue2 )
				return _TRUE_
			ok

		but This.IsAList()
			if isList(pValue1) and isList(pValue2) and
			   ( This.ListQ() = pValue1 or This.ListQ() = pValue2 )
				return _TRUE_
			ok

		but This.IsAnObject() #TODO
			StzRaise("Feature not implemented yet!")
		ok

		#< @FunctionAlternativeForms

		def AreEither(pValue1, pValue2)
			return This.IsEither(pValue1, pValue2)

		def BothAreEither(pValue1, pValue2)
			return This.IsEither(pValue1, pValue2)

		def AreBothEither(pValue1, pValue2)
			return This.IsEither(pValue1, pValue2)

		#>

	#--

	def IsAnObject()
		return _TRUE_

		def IsAObject()
			return _TRUE_

	def IsANumber()
		return _FALSE_

	def IsAString()
		return _FALSE_

	def IsAList()
		return _FALSE_
	
	  #======================================#
	 #  REPEATING THE OBJECT VALUE N TIMES  #
	#======================================#

	def Repeat(n)

		if isList(n) and len(n) = 2 and
		   isNumber(n[1]) and isString(n[2]) and n[2] = :Times
			n = n[1]
		ok

		return This.RepeatXT(:InList, n)

		#< @FunctionFluentForm

		def RepeatQ(n)
			return Q(This.Repeat(n))

		#>

		#< @FunctionAlternativeForms

		def RepeatNTimes(n)
			return This.Repeat(n)

			def RepeatNTimesQ(n)
				return This.RepeatQ(n)

		def Reproduce(n)
			return This.Repeat(n)

			def ReproduceQ(n)
				This.Reproduce(n)
				return This

		def ReproduceNTimes(n)
			return This.Repeat(n)

			def ReproduceNTimesQ(n)
				This.ReproduceNTimes(n)
				return This

		def CopyNTimes(n)
			return This.Repeat(n)

			def CopyNTimesQ(n)
				This.CopyNTimes(n)
				return This

		#>

	#--

	def Repeated(n)
		return This.Repeat(n)

		#< @FunctionAlternativeForms

		def RepeatedNTimes(n)
			return This.Repeated(n)

		def Reproduced(n)
			return This.Repeated(n)

		def ReproducedNTimes(n)
			return This.Repeated(n)

		def Copied(n)
			return This.Repeated(n)

		def CopiedNTimes(n)
			return This.Repeated(n)

		#>

	  #--------------------------------------#
	 #  REPEATING THE OBJECT VALUE 3 TIMES  #
	#--------------------------------------#

	def Repeat3Times()
		return This.RepeatNTimes(3)

		#< @FunctionFluentForm

		def Repeat3TimesQ()
			return Q(This.Repeat3Times())

		#>

		#< @FunctionAlternativeForms

		def Reproduce3Times()
			return This.Repeat3Times()

			def Reproduce3TimesQ()
				return This.Repeat3TimesQ()

		def Copy3Times()
			return This.Repeat3Times()

			def Copy3TimesQ()
				return This.Repeat3TimesQ()

		#>

	def Repeated3Times()
		return This.Repeat3Times()

		#< @FunctionAlternativeForms

		def Reproduced3Times()
			return This.Repeated3Times()

		def Copied3Times()
			return This.Repeated3Times()

		#>

	  #-------------------------------------------------------------------#
	 #  REPEATING THE OBJECT VALUE IN A GIVEN CONTAINER OF A GIVEN SIZE  #
	#-------------------------------------------------------------------#

	def RepeatNTimesXT(pnSize, pIn)
		return This.RepeatXT(pIn, pnSize)

		def RepeatedNTimesXT(pnSize, pIn)
			return This.RepeatNTimesXT(pnSize, pIn)
	
	def RepeatXT(pIn, pnSize)
		/* EXAMPLE
		o1 = new stzNumber(5)
		o1.RepeatXT( :InA = :List, :OfSize = 2 )
		#--> [ 5, 5 ]

		o1.RepeatXT( [ 3, :Times ], :InAList )

		*/

		# Resolving params

		# ~> Case: RepeatXT([ 3, :Times ], :InAList )
		if isList(pIn) and len(pIn) = 2 and
		   isNumber(pIn[1]) and isString(pIn[2]) and pIn[2] = :Times

			pnSize = pIn[1]

			if This.IsAString()

				pIn = :String
				
			else
				pIn = :List
			ok
		ok

		# ~> Case : RepeatXT( :NTimes = 3, :InAList )

		if isList(pIn) and len(pIn) = 2 and
		   isString(pIn[1]) and pIn[1] = :NTimes and isNumber(pIn[2])

			pnSizeTemp = pnSize
			pnSize = pIn[2]
			pIn = pnSizeTemp

		ok

		# ~> Case : RepeatXT(:In = :AList, :OfSize = 3)
		if isList(pIn) and
			( Q(pIn).IsInNamedParam() or
			  Q(pIn).IsInANamedParam() )

			pIn = pIn[2]
		ok

		if NOT ( isString(pIn) and
				Q(pIn).IsOneOfTheseCS([
					:String, :List, :Pair, :ListOfNumbers, :ListOfStrings,
					:ListOfLists, :ListOfPairs, :Grid, :Table, :StzTable,

					:AString, :AList, :APair, :AListOfNumbers, :AListOfStrings,
					:AListOfLists, :AListOfPairs, :AGrid, :ATable, :AStzTable,

					:InString, :InList, :InPair, :InListOfNumbers, :InListOfStrings,
					:InListOfLists, :InListOfPairs, :InGrid, :InTable, :InStzTable,

					:InAString, :InAList, :InAPair, :InAListOfNumbers, :InAListOfStrings,
					:InAListOfLists, :InAListOfPairs, :InAGrid, :InATable, :InAStzTable

				], _FALSE_) )

			StzRaise("Incorrect param! pIn must be a string representing one of" +
				 "these Softanza types: :String, :List, :Pair, :ListOfNumbers, :ListOfStrings, " +
				 ":ListOfLists, :ListOfPairs, :Grid, :Table, and :StzTable.")
		ok

		if isList(pnSize) and
			( Q(pnSize).IsOfSizeNamedParam() or
			  Q(pnSize).IsSizeNamedParam() )

			pnSize = pnSize[2]
		ok

		if NOT ( isNumber(pnSize) or (isList(pnSize) and Q(pnSize).IsPairOfNumbers()) )
			StzRaise("Incorrect param type! pnSize must be a number.")
		ok

		# Doing the job

		value = ""
		if This.IsANumber()
			if This.IsInteger()
				value = This.NumericValue()
			else
				value = This.StringValue()
			ok
		else
			value = This.Content()
		ok

		if ring_find([ :List, :InList, :AList, :InAList ], pIn) > 0
	
			aResult = []
			for i = 1 to pnSize
				aResult + value
			next
			return aResult

		but ring_find([ :Pair, :InPair, :APair, :InAPair ], pIn) > 0

			aResult = []
			for i = 1 to 2
				aResult + value
			next
			return aResult

		but ring_find([ :ListOfNumbers, :InListOfNumbers,
				:AListOfNumbers, :InAListOfNumbers ], pIn) > 0

			aResult = []
			for i = 1 to pnSize
				aResult + Q(value).ToNumber()
			next
			return aResult

		but ring_find([ :ListOfStrings, :InListOfStrings,
				:AListOfStrings, :InAListOfStrings ], pIn) > 0

			aResult = []
			for i = 1 to pnSize
				aResult + Q(value).Stringified()
			next
			return aResult

		but ring_find([ :ListOfLists, :InListOfLists,
				:AListOfLists, :InAListOfLists ], pIn) > 0
	
			aResult = []
			for i = 1 to pnSize
				aResult + [ value ]
			next
			return aResult

		but ring_find([ :ListOfPairs, :InListOfPairs,
				:AListOfPairs, :InAListOfNPairs ], pIn) > 0
	
			aResult = []
			for i = 1 to pnSize
				aResult + [ value, value ]
			next
			return aResult

		but ring_find([ :String, :InString, :AString, :InAString ], pIn) > 0

			cResult = ""
			for i = 1 to pnSize
				cResult += value
			next
			return cResult

		but ring_find([ :Grid, :InGrid, :AGrid, :InAGrid ], pIn) > 0

			aResult = StzGridQ([ pnSize[1], pnSize[2] ]).
					ReplaceAllQ(:With = value).
					Content()

			return aResult

		but ring_find([ :Table, :InTable, :ATable, :InATable ], pIn) > 0

			aResult = StzTableQ([ pnSize[1], pnSize[2] ]).FillQ(value).Content()
			return aResult

		but ring_find([ :StzTable, :InStzTable, :InAStzTable ], pIn) > 0

			oResult = StzTableQ([ pnSize[1], pnSize[2] ]).FillQ(value)
			return oResult

		else
			StzRaise("Unsupported type of container! Allowed containers you can repeat " +
				 "the value in are: :List, :Pair, :ListOfLists, :ListOfPairs, :String, :Grid, :Table, and :StzTable.")
		ok

		#< @FunctionFluentForm

		def RepeatXTQ(pIn, pnSize)
			if isString(pIn) and pIn = :String
				return new stzString( This.RepeatXT(pIn, pnSize) )

			else
				return new stzList( This.RepeatXT(pIn, pnSize) )
			ok

		#>

	#-- RETURNING THE OUTPUT DATA

	def RepeatedXT(pIn, pnSize)
		return This.RepeatXT(pIn, pnSize)

	  #----------------------------------------#
	 #  REPEATING THE OBJECT VALUE IN A PAIR  #
	#----------------------------------------#

	def RepeatInPair()
		return This.RepeatXT(:InA = :List, :OfSize = 2)

		#< @FunctionFluentForm

		def RepeatInAPairQ(pnSize)
			return new stzList( This.RepeatInAPair(pnSize) )

		#>

		#< @AlternativeForms

		def RepeatInAPair()
			return This.RepeatInPair()
	
			def RepeatInPairQ()
				return new stzList( This.RepeatInPair() )
	

		def RepeatedInPair()
			return This.RepeatInPair()
	
			def RepeatedInPairQ()
				return new stzList( This.RepeatInPair() )

		def RepeatedInAPair()
			return This.RepeatInPair()

			def RepeatedInAPairQ()
				return new stzList( This.RepeatInPair() )

		#>

	  #==========================================#
	 #  CASTING THE OBJECT VALUE INTO A NUMBER  #
	#==========================================#

	def ToNumber()
		if This.IsANumber()
			return This.NumericValue()

		but This.IsAString()
			if This.IsNumberInString()
				cNumber = StzStringQ(This.Content()).RemoveQ("_").Content()
				return 0+ cNumber

			else
				StzRaise("Incorrect value! The string do not contain a well formed number.")
			ok

		else
			StzRaise("Can't cast the object into a number.")
		ok

	def Numberified()
		if This.IsANumber()
			return This.NumbericValue()

		but This.IsAString()
			if This.IsNumberInString()
				cNumber = StzStringQ(This.Content()).RemoveQ("_").Content()
				return 0+ cNumber

			else
				StzRaise("Incorrect value! The string do not contain a well formed number.")
			ok

		but This.IsAList()
			return StzListQ(This.Content()).Numberified()

		else
			StzRaise("Incorrect param type! Objects can't be numberified.")
		ok

	  #------------------------------------------------------------------#
	 #  CASTING THE OBJECT VALUE INTO A NUMBER UNDER A GIVEN CONDITION  #
	#==================================================================#

	def ToNumberW(pcCode)

		if isList(pcCode) and Q(pcCode).IsUsingNamedParam()
			pcCode = pcCode[2]
		ok

		if NOT isString(pcCode)
			StzRaise("Incorrect param type! pcCode must be a string.")
		ok

		@number = 0
		if This.IsANumber()
			@number = This.Number()
		ok
		
		cCode = Q(pcCode).
			RemoveTheseBoundsQ('"').
			RemoveThisFirstCharQ("{").
			RemoveThisLastCharQ("}").
			Trimmed()
		
		if NOT Q(cCode).StartsWithOneOfTheseCS([
			"@number =", "@number +=", "@number=", "@number+=" ], _FALSE_ )

			StzRaise("Syntax error! pcCode must start with '@number =' or '@number +='.")
		ok

		if Q(cCode).StartsWithEitherCS( "@number=", :Or = "@number =", _FALSE_ )
			# EXAMPLE
			# ? Q([ "a", "b", "c" ]).ToNumberW('{ @number = len(@list) }')
			#--> 3

			@list = This.Content()
			@string = This.Content()

			eval(cCode)

		else
			# CASE += is used on a list of items or a string

			# EXAMPLE
			# ? Q([ "Me", "and", "You!" ]).ToNumberWXT('{ @number += len(@item) }')
			#--> 9
			@number = 0

			if This.IsANumber()
				eval(cCode)

			but This.IsAString()
				nLenStr = This.NumberOfChars()
				for @i = 1 to nLenStr
					@char = This.Char(@i)
					eval(cCode)
				next

			but This.IsAList()
				aList = This.List()
				nLenList = len(aList)

				for @i = 1 to nLenList 
					@item = This.Item(@i)
					eval(cCode)
				next
			ok

		ok

		if NOT isNumber(@number)
			StzRaise("Incorrect type! @number must be a number.")
		ok

		return @number

		def ToNumberWQ(pcCode)
			return new stzNumber( This.ToNumberW(pcCode) )

		def ToNumberXT(pcCode)
			return This.ToNumberW(pcCode)

			def ToNumberXTQ(pcCode)
				return new stzNumber( This.ToNumberXT(pcCode) )

	  #------------------------------------------#
	 #  CASTING THE OBJECT VALUE INTO A STRING  #
	#------------------------------------------#

	def ToString()
		return This.ObjectName()

		def Stringified()
			return This.ToString()

		def DeepStringified()
			return This.ToString()

	  #==============================#
	 #     OPERATORS OVERLOADING    #
	#==============================#

	/*
		TODO: Operators should adopt same semantics in all classes...
	*/

	#WARNING // DON'T ADD = OPERATOR
	# Because it causes semantic conflict with
	# feature in stzExtCode (see CREATE_TABLE sql function)
		

	  #============================================================#
	 #   FINDING THE FIRST N OCCURRENCES OF A SUBSTRING Or ITEM   #
	#============================================================#

	# TODO: This part is an experimentation of abastraction common features
	# between stzString and stzList in one place, here in stzObject

	#NOTE: I'm not yet decided if this should be generalised. Think about it.

	def FindFirstNOccurrencesCS(n, pStrOrItem, pCaseSensitive)

		anResult = This.FindFirstNOccurrencesSTCS(n, pStrOrItem, 1, pCaseSensitive)
		return anResult

		#< @FunctionAlternativeForms

		def FindNFirstOccurrencesCS(n, pStrOrItem, pCaseSensitive)
			return This.FindFirstNOccurrencesCS(n, pStrOrItem, pCaseSensitive)

		#--

		def PositionsOfFirstNOccurrencesCS(n, pStrOrItem, pCaseSensitive)
			return This.FindFirstNOccurrencesCS(n, pStrOrItem, pCaseSensitive)

		def PositionsOfNFirstOccurrencesCS(n, pStrOrItem, pCaseSensitive)
			return This.FindFirstNOccurrencesCS(n, pStrOrItem, pCaseSensitive)

		#--

		def FirstNCS(n, pStrOrItem, pCaseSensitive)
			return This.FindFirstNOccurrencesCS(n, pStrOrItem, pCaseSensitive)

		def NFirstCS(n, pStrOrItem, pCaseSensitive)
			return This.FindFirstNOccurrencesCS(n, pStrOrItem, pCaseSensitive)

		#--

		def FindFirstNCS(n, pStrOrItem, pCaseSensitive)
			return This.FindFirstNOccurrencesCS(n, pStrOrItem, pCaseSensitive)

		def FindNFirstCS(n, pStrOrItem, pCaseSensitive)
			return This.FindFirstNOccurrencesCS(n, pStrOrItem, pCaseSensitive)

		#--

		def FirstNOccurrencesCS(n, pStrOrItem, pCaseSensitive)
			return This.FindFirstNOccurrencesCS(n, pStrOrItem, pCaseSensitive)

		def NFirstOccurrencesCS(n, pStrOrItem, pCaseSensitive)
			return This.FindFirstNOccurrencesCS(n, pStrOrItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstNOccurrences(n, pStrOrItem)
		return This.FindFirstNOccurrencesCS(n, pStrOrItem, _TRUE_)

		#< @FunctionAlternativeForms

		def FindNFirstOccurrences(n, pStrOrItem)
			return This.FindFirstNOccurrences(n, pStrOrItem)

		#--

		def PositionsOfFirstNOccurrences(n, pStrOrItem)
			return This.FindFirstNOccurrences(n, pStrOrItem)

		def PositionsOfNFirstOccurrences(n, pStrOrItem)
			return This.FindFirstNOccurrences(n, pStrOrItem)

		#--

		def FirstN(n, pStrOrItem)
			return This.FindFirstNOccurrences(n, pStrOrItem)

		def NFirst(n, pStrOrItem)
			return This.FindFirstNOccurrences(n, pStrOrItem)

		#--

		def FindFirstN(n, pStrOrItem)
			return This.FindFirstNOccurrencesCS(n, pStrOrItem)

		def FindNFirst(n, pStrOrItem)
			return This.FindFirstNOccurrences(n, pStrOrItem)

		#--

		def FirstNOccurrences(n, pStrOrItem)
			return This.FindFirstNOccurrences(n, pStrOrItem)

		def NFirstOccurrences(n, pStrOrItem)
			return This.FindFirstNOccurrences(n, pStrOrItem)

		#>

	   #--------------------------------------------------------#
	  #  FINDING FIRST N OCCURRENCES OF A SUBSTRING OR ITEM    #
	 #  STARTING AT A GIVEN POSITION -- EXTENDTED             #
	#--------------------------------------------------------#

	def FindFirstNOccurrencesSTCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)

		if isList(pStrOrItem) and
		   Q(pStrOrItem).IsOneOfTheseNamedParams([ :Of, :OfSubString, :OfItem ])

			pStrOrItem = pStrOrItem[2]
		ok

		if isList(pnStartingAt) and Q(pnstartingAt).IsStartingAtNamedParam()
			pnStartingAt = pnStartingAt[2]
		ok

		anPos = This.SectionQ(pnStartingAt, :Last).
				FindAllCS(pStrOrItem, pCaseSensitive)

		anResult = []
		if len(anPos) > 0
			anResult = Q(anPos).FirstNItemsQRT(n, :stzListOfNumbers).AddedToEach(pnStartingAt-1)
		ok

		return anResult

		#< @FunctionAlternativeForms

		def FindNFirstOccurrencesSTCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindFirstNOccurrencesSTCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)

		#--

		def PositionsOfFirstNOccurrencesSTCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindFirstNOccurrencesSTCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)

		def PositionsOfNFirstOccurrencesSTCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindFirstNOccurrencesSTCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)

		#--

		def FirstNSTCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindFirstNOccurrencesSTCS(n, pStrOrItem, pnStartingAt,  pCaseSensitive)

		def NFirstSTCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindFirstNOccurrencesSTCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)

		#--

		def FindFirstNSTCS(n, pStrOrItem,pnStartingAt,  pCaseSensitive)
			return This.FindFirstNOccurrencesSTCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)

		def FindNFirstSTCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindFirstNOccurrencesSTCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)

		#--

		def FirstNOccurrencesSTCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindFirstNOccurrencesSTCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)

		def NFirstOccurrencesSTCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindFirstNOccurrencesSTCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstNOccurrencesST(n, pcStr, pnStartingAt)
		return This.FindFirstNOccurrencesSTCS(n, pcStr, pnStartingAt, _TRUE_)

		#< @FunctionAlternativeForms

		def FindNFirstOccurrencesST(n, pStrOrItem, pnStartingAt)
			return This.FindFirstNOccurrencesST(n, pStrOrItem, pnStartingAt)

		#--

		def PositionsOfFirstNOccurrencesST(n, pStrOrItem, pnStartingAt)
			return This.FindFirstNOccurrencesST(n, pStrOrItem, pnStartingAt)

		def PositionsOfNFirstOccurrencesST(n, pStrOrItem, pnStartingAt)
			return This.FindFirstNOccurrencesST(n, pStrOrItem, pnStartingAt)

		#--

		def FirstNST(n, pStrOrItem, pnStartingAt)
			return This.FindFirstNOccurrencesST(n, pStrOrItem, pnStartingAt)

		def NFirstST(n, pStrOrItem, pnStartingAt)
			return This.FindFirstNOccurrencesST(n, pStrOrItem, pnStartingAt)

		#--

		def FindFirstNST(n, pStrOrItem,pnStartingAt)
			return This.FindFirstNOccurrencesST(n, pStrOrItem, pnStartingAt)

		def FindNFirstST(n, pStrOrItem, pnStartingAt)
			return This.FindFirstNOccurrencesST(n, pStrOrItem, pnStartingAt)

		#--

		def FirstNOccurrencesST(n, pStrOrItem, pnStartingAt)
			return This.FindFirstNOccurrencesST(n, pStrOrItem, pnStartingAt)

		def NFirstOccurrencesST(n, pStrOrItem, pnStartingAt)
			return This.FindFirstNOccurrencesST(n, pStrOrItem, pnStartingAt)

		#>

	  #---------------------------------------------------#
	 #   FINDING THE LAST N OCCURRENCES OF A SUBSTRING   #
	#---------------------------------------------------#

	def FindLastNOccurrencesCS(n, pStrOrItem, pCaseSensitive)

		anResult = This.FindLastNOccurrencesSTCS(n, pStrOrItem, :StartingAT = 1, pCaseSensitive)
		return anResult

		#< @FunctionAlternativeForms

		def FindNLastOccurrencesCS(n, pStrOrItem, pCaseSensitive)
			return This.FindLastNOccurrencesCS(n, pStrOrItem, pCaseSensitive)

		#--

		def PositionsOfLastNOccurrencesCS(n, pStrOrItem, pCaseSensitive)
			return This.FindLastNOccurrencesCS(n, pStrOrItem, pCaseSensitive)

		def PositionsOfNLastOccurrencesCS(n, pStrOrItem, pCaseSensitive)
			return This.FindLastNOccurrencesCS(n, pStrOrItem, pCaseSensitive)

		#--

		def LastNCS(n, pStrOrItem, pCaseSensitive)
			return This.FindLastNOccurrencesCS(n, pStrOrItem, pCaseSensitive)

		def NLastCS(n, pStrOrItem, pCaseSensitive)
			return This.FindLastNOccurrencesCS(n, pStrOrItem, pCaseSensitive)

		#--

		def FindLastNCS(n, pStrOrItem, pCaseSensitive)
			return This.FindLastNOccurrencesCS(n, pStrOrItem, pCaseSensitive)

		def FindNLastCS(n, pStrOrItem, pCaseSensitive)
			return This.FindLastNOccurrencesCS(n, pStrOrItem, pCaseSensitive)

		#--

		def LastNOccurrencesCS(n, pStrOrItem, pCaseSensitive)
			return This.FindLastNOccurrencesCS(n, pStrOrItem, pCaseSensitive)

		def NLastOccurrencesCS(n, pStrOrItem, pCaseSensitive)
			return This.FindLastNOccurrencesCS(n, pStrOrItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastNOccurrences(n, pStrOrItem)
		return This.FindLastNOccurrencesCS(n, pStrOrItem, _TRUE_)

		#< @FunctionAlternativeForms

		def FindNLastOccurrences(n, pStrOrItem)
			return This.FindLastNOccurrences(n, pStrOrItem)

		#--

		def PositionsOfLastNOccurrences(n, pStrOrItem)
			return This.FindLastNOccurrences(n, pStrOrItem)

		def PositionsOfNLastOccurrences(n, pStrOrItem)
			return This.FindLastNOccurrences(n, pStrOrItem)

		#--

		def LastN(n, pStrOrItem)
			return This.FindLastNOccurrences(n, pStrOrItem)

		def NLast(n, pStrOrItem)
			return This.FindLastNOccurrences(n, pStrOrItem)

		#--

		def FindLastN(n, pStrOrItem)
			return This.FindLastNOccurrencesCS(n, pStrOrItem)

		def FindNLast(n, pStrOrItem)
			return This.FindLastNOccurrences(n, pStrOrItem)

		#--

		def LastNOccurrences(n, pStrOrItem)
			return This.FindLastNOccurrences(n, pStrOrItem)

		def NLastOccurrences(n, pStrOrItem)
			return This.FindLastNOccurrences(n, pStrOrItem)

		#>

	   #------------------------------------------------------------#
	  #  FINDING LAST N OCCURRENCES OF A SUBSTRING/ITEM STARTING   #
	 #  AT A GIVEN POSITION -- EXTENDTED                          #
	#------------------------------------------------------------#

	def FindLastNOccurrencesSTCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)
		if CheckingParams()
			if isList(pStrOrItem) and
			   Q(pStrOrItem).IsOneOfTheseNamedParams([ :Of, :OfSubString ])
	
				pStrOrItem = pStrOrItem[2]
			ok
	
			if isList(pnStartingAt) and Q(pnstartingAt).IsStartingAtNamedParam()
				pnStartingAt = pnStartingAt[2]
			ok
		ok

		anPos = This.SectionQ(pnStartingAt, :Last).
				FindAllCS(pStrOrItem, pCaseSensitive)

		anResult = Q(anPos).LastNItemsQRT(n, :stzListOfNumbers).AddedToEach(pnStartingAt-1)

		return anResult

		#< @FunctionAlternativeForms

		def FindNLastOccurrencesSTCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindLastNOccurrencesSTCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)

		#--

		def PositionsOfLastNOccurrencesSTCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindLastNOccurrencesSTCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)

		def PositionsOfNLastOccurrencesSTCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindLastNOccurrencesSTCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)

		#--

		def LastNSTCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindLastNOccurrencesSTCS(n, pStrOrItem, pnStartingAt,  pCaseSensitive)

		def NLastSTCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindLastNOccurrencesSTCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)

		#--

		def FindLastNSTCS(n, pStrOrItem,pnStartingAt,  pCaseSensitive)
			return This.FindLastNOccurrencesSTCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)

		def FindNLastSTCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindLastNOccurrencesSTCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)

		#--

		def LastNOccurrencesSTCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindLastNOccurrencesSTCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)

		def NLastOccurrencesSTCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindLastNOccurrencesSTCS(n, pStrOrItem, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastNOccurrencesST(n, pcStr, pnStartingAt)
		return This.FindLastNOccurrencesSTCS(n, pcStr, pnStartingAt, _TRUE_)

		#< @FunctionAlternativeForms

		def FindNLastOccurrencesST(n, pStrOrItem, pnStartingAt)
			return This.FindLastNOccurrencesST(n, pStrOrItem, pnStartingAt)

		#--

		def PositionsOfLastNOccurrencesST(n, pStrOrItem, pnStartingAt)
			return This.FindLastNOccurrencesST(n, pStrOrItem, pnStartingAt)

		def PositionsOfNLastOccurrencesST(n, pStrOrItem, pnStartingAt)
			return This.FindLastNOccurrencesST(n, pStrOrItem, pnStartingAt)

		#--

		def LastNST(n, pStrOrItem, pnStartingAt)
			return This.FindLastNOccurrencesST(n, pStrOrItem, pnStartingAt)

		def NLastST(n, pStrOrItem, pnStartingAt)
			return This.FindLastNOccurrencesST(n, pStrOrItem, pnStartingAt)

		#--

		def FindLastSTN(n, pStrOrItem,pnStartingAt)
			return This.FindLastNOccurrencesST(n, pStrOrItem, pnStartingAt)

		def FindNLastST(n, pStrOrItem, pnStartingAt)
			return This.FindLastNOccurrencesST(n, pStrOrItem, pnStartingAt)

		#--

		def LastNOccurrencesST(n, pStrOrItem, pnStartingAt)
			return This.FindLastNOccurrencesST(n, pStrOrItem, pnStartingAt)

		def NLastOccurrencesST(n, pStrOrItem, pnStartingAt)
			return This.FindLastNOccurrencesST(n, pStrOrItem, pnStartingAt)

		#>

	  #===========#
	 #   MISC.   #
	#===========#

	def IsOneOfThese(paList)
		return StzListQ(paList).Contains(This.Object())

		def IsNotOneOfThese(paList)
			return NOT This.IsOneOfThese(paList)

	def Methods()
		return ring_methods(This)

	def Attributes()
		return ring_attributes(This)

	def ClassName()
		return "stzobject"

		def StzClassName()
			return This.ClassName()

		def StzClass()
			return This.ClassName()

	def IsText()
		return _FALSE_

	def ToPointer()
		return object2pointer(This.Object())
		

	def Twice()
		_aResult_ = [] + This.Content() + This.Content()
		return _aResult_

		func TwiceQ()
			return This

	def TheLetterQ(c)
		return This

	def IfQ(pcCondition)
		if NOT isString(pcCondition)
			StzRaise("Incorrect param type!")
		ok

		cCode = 'bOk = (' + pcCondition + ')'
		eval(ccode)

		if bOk
			return This
		else
			# An error message is returned:
			#--> Error (R13) : Object is required 
		ok

	def IsSingle()
		if This.IsAList() and This.Size() = 1
			return _TRUE_
		else
			return _FALSE_
		ok

	# Swapping the content of the stzObject with an other stzObject

	def SwapWith(pOtherStzObject)

		if CheckingParams()

			if NOT @IsStzObject(pOtherStzObject)
				StzRaise("Incorrect param type! pOtherStzObject must be a stzObject.")
			ok
	
		ok

		oThis = This.Content()
		oOther = pOtherStzObject.Content()

		This.UpdateWith(oOther)
		pOtherStzObject.UpdateWith(oThis)

		def SwapWithQ(pOtherStzObject)
			This.SwapWith(pOtherStzObject)
			return This

		def SwapContentWith(pOtherStzObject)
			This.SwapWith(pOtherStzObject)

			def SwapContentWithQ(pOtherStzObject)
				return This.SwapWithQ(pOtherStzObject)

	def @IsNeither(pcType1, pcType2)
		if CheckingParams()
			if isList(pcType1) and Q(pcType1).IsOfTypeNamedParam()
				pcType1 = pcType1[2]
			ok

			if isList(pcType2) and Q(pcType2).IsNorNamedParam()
				pcType2 = pcType2[2]
			ok

			if NOT @BothAreStrings(pcType1, pcType2)
				StzRaise("Incorrect param type! pcType1 and pcType2 must both be strings.")
			ok
		ok

		#TODO // Add other Stz types

		bOfType1 = _FALSE_
		bOfType2 = _FALSE_

		if pcType1 = :String or pcType1 = :AString
			bOfTyep1 = This.IsStzString()

		but pcType1 = :Char or pcType1 = :AChar
			bOfType1 = This.IsStzChar()

		but pcType1 = :Number or pcType1 = :ANumber
			bOfType1 = This.IsStzNumber()

		but pcType1 = :List or pcType1 = :AList
			bOfType1 = This.IsStzList()

		but pcType1 = :Object or pcType1 = :AnObject
			bOfType1 = This.IsStzObject()
		ok

		if pcType2 = :String or pcType2 = :AString
			bOfType2 = This.IsStzString()

		but pcType2 = :Char or pcType2 = :AChar
			bOfType2 = This.IsStzChar()

		but pcType2 = :Number or pcType2 = :ANumber
			bOfType2 = This.IsStzNumber()

		but pcType2 = :List or pcType2 = :AList
			bOfType2 = This.IsStzList()

		but pcType2 = :Object or pcType2 = :AnObject
			bOfType2 = This.IsStzObject()
		ok

		if NOT bOfType1 and NOT bOfType2
			return _TRUE_
		else
			return _FALSE_
		ok

		def @IsNeitheOfType(pcType1, pcType2)
			return This.IsNeither(pcType1, pcType2)

	def LoopNTimes(n)
		for @i = 1 to n
			// Do nothing
		next

		def LoopNTimesQ(n)
			This.LoopNTimes(n)
			return This

	  #=============================================#
	 #  CASTING THE oBJECT INTO AN OTHER STZ TYPE  #
	#=============================================#

	def ToStzChar()
		return new stzChar(This.Content())

	def ToStzString()
		return new stzString(This.Content())

	def ToStzNumber()
		return new stzNumber(This.Content())

	def ToStzList()
		return new stzList(This.Content())

	   #=====================================================#
	  #   CHECKING IF OBJECT OCCURES BEFORE/AFTER A GIVEN   #
	 #   VALUE IN THE GIVEN STRING OR LIST                 #
	#=====================================================#

	def OccursCS(pcBeforeOrAfter, pIn, pCaseSensitive)

		/* EXAMPLE

		o1 = new stzString("ONE")

		? o1.Occurs( :Before = "TWO", :In = "***ONE***TWO***")	#--> _TRUE_
		? o1.Occurs( :After = "TWO", :In = "***ONE***TWO***")	#--> _FALSE_

		? o1.Occurs( :Before = "two", :In = [ "***", "ONE", "***", "TWO", "***" ])
		#--> _TRUE_
		? o1.Occurs( :After = "TWO", :In = [ "***", "ONE", "***", "TWO", "***" ])
		#--> _FALSE_

		*/
		cBeforeOrAfter = ""

		if isList(pcBeforeOrAfter) and Q(pcBeforeOrAfter).IsBeforeOrAfterNamedParam()
			cTemp = pcBeforeOrAfter[1]

			pcBeforeOrAfter = pcBeforeOrAfter[2]
		ok

		if isList(pIn) and Q(pIn).IsInNamedParam()
			pIn = pIn[2]
		ok

		if NOT ( isString(pIn) or isList(pIn) )
			StzRaise("Incorrect param type! pcIn must be a string or list.")
		ok
	
		bCaseSensitive = CaseSensitive(pCaseSensitive)

		if isString(pIn)
			oStr = new stzString(pIn)
	
			nThis  = oStr.FindFirstCS( This.Content(), bCaseSensitive )
			nOther = oStr.FindFirstCS( pcBeforeOrAfter, bCaseSensitive )

		but isList(pIn)
			if Q(pIn).IsListOfStrings()
				oListStr = new stzListOfStrings(pIn)

				nThis  = oListStr.FindFirstCS( This.Content(), bCaseSensitive )
				nOther = oListStr.FindFirstCS( pcBeforeOrAfter, bCaseSensitive )
			else

				if bCaseSensitive = _TRUE_
					oList = new stzList(pIn)
	
					nThis  = oList.FindFirst( This.Content() )
					nOther = oList.FindFirst( pcBeforeOrAfter )
						
				else
					oList = new stzList(pIn)
					oList.Lowercase()

					nThis  = oList.FindFirst( This.ContentQ().Lowercased() )
					nOther = oList.FindFirst( pcBeforeOrAfter )

				ok
			ok

		ok

		bResult = _FALSE_

		if cTemp = :After
			bResult = nThis > nOther

		but cTemp = :Before
			bResult = nThis < nOther
		ok

		return bResult

		#< @FunctionAlternativeForms

		def HappensCS(pcBeforeOrAfter, pIn, pCaseSensitive)
			return This.OccursCS(pcBeforeOrAfter, pIn, pCaseSensitive)

		def ComesCS(pcBeforeOrAfter, pIn, pCaseSensitive)
			return This.OccursCS(pcBeforeOrAfter, pIn, pCaseSensitive)

		#>


		#< @FunctionMisspelledForm

		def OccuresCS(pcBeforeOrAfter, pIn, pCaseSensitive)
			return This.OccursCS(pcBeforeOrAfter, pIn, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVTY

	def Occurs(pcBeforeOrAfter, pIn)
		return This.OccursCS(pcBeforeOrAfter, pIn, _TRUE_)

		#< @FunctionAlternativeForms

		def Happens(pcBeforeOrAfter, pIn)
			return This.Occurs(pcBeforeOrAfter, pIn)

		def Comes(pcBeforeOrAfter, pIn)
			return This.Occurs(pcBeforeOrAfter, pIn)

		#>

		#< @FunctionMisspelledForm

		def Occures(pcBeforeOrAfter, pIn)
			return This.Occurs(pcBeforeOrAfter, pIn)

		#>

	   #-----------------------------------------------#
	  #   CHECKING IF OBJECT OCCURES BEFORE A GIVEN   #
	 #   VALUE IN THE GIVEN STRING OR LIST           #
	#-----------------------------------------------#

	def OccursBeforeCS( pcSubStr, pIn, pCaseSensitive )
		return This.OccursCS( :Before = pcSubStr, pIn, pCaseSensitive)

	#-- WITHOUT CASESENSITIVTY

	def OccursBefore(pcSubStr, pIn)
		return This.OccursBeforeCS( pcSubStr, pIn, _TRUE_ )

	   #----------------------------------------------#
	  #   CHECKING IF OBJECT OCCURES َAFTER A GIVEN   #
	 #   VALUE IN THE GIVEN STRING OR LIST          #
	#----------------------------------------------#

	def OccursAfterCS( pcSubStr, pIn, pCaseSensitive )
		return This.OccursCS( :After = pcSubStr, pIn, pCaseSensitive)

	#-- WITHOUT CASESENSITIVTY

	def OccursAfter(pcSubStr, pIn)
		return This.OccursAfterCS( pcSubStr, pIn, _TRUE_ )

	   #---------------------------------------------------------#
	  #   CHECKING IF OBJECT OCCURES BETWEEN TWO GIVEN VALUES   #
	 #  IN THE GIVEN STRING OR LIST                            #
	#---------------------------------------------------------#

	def OccursBetweenCS( pValue1, pValue2, pIn, pCaseSensitive )

		if This.OccursCS( :After = pValue1, pIn, pCaseSensitive) and
		   This.OccursCS( :Before = pValue2, pIn, pCaseSensitive)

			return _TRUE_
		else
			return _FALSE_
		ok

	#-- WITHOUT CASESENSITIVTY

	def OccursBetween( pValue1, pValue2, pIn )
		return This.OccursBetweenCS( pValue1, pValue2, pIn, _TRUE_ )

	  #-------------------------------------------------------------------#
	 #   CHECKING IF OBJECT OCCURES N TIMES IN AN OTHER STRING OR LIST   #
	#-------------------------------------------------------------------#

	def OccursNTimesCS( n, pIn, pCaseSensitive )

		if isList(pIn) and Q(pIn).IsInNamedParam()
			pIn = pIn[2]
		ok

		if NOT ( isString(pIn) or isList(pIn) )
			StzRaise("Incorrect param type! pcIn must be a string or list.")
		ok
	
		bCaseSensitive = CaseSensitive(pCaseSensitive)

		nOccurrence = 0

		if isString(pIn)
			oStr = new stzString(pIn)
			nOccurrence  = oStr.NumberOfOccurrenceCS( This.Content(), bCaseSensitive )

		but isList(pIn)
			if Q(pIn).IsListOfStrings()
				oListStr = new stzListOfStrings(pIn)
				nOccurrence  = oListStr.NumberOfOccurrenceCS( This.Content(), bCaseSensitive )

			else
				if bCaseSensitive = _TRUE_
					oList = new stzList(pIn)
					nOccurrence  = oList.NumberOfOccurrence( This.Content() )
		
				else
					oList = new stzList(pIn)
					oList.Lowercase()

					nThis  = oList.FindFirst( This.ContentQ().Lowercased() )
					nOccurrence  = oList.NumberOfOccurrence( This.Content() )
		
				ok
			ok

		ok

		bResult = _FALSE_

		if nOccurrence = n
			bResult = _TRUE_
		ok

		return bResult

	#-- WITHOUT CASESENSITIVITY

	def OccursNTimes( n, pIn )
		return This.OccursNTimesCS( n, pIn, _TRUE_ )

	   #----------------------------------------------------#
	  #  CHECKING IF STRING OCCURS FOR THE NTH TIME,       #
	 #  IN AN OTHER STRING OR LIST, AT A GIVEN POSITION   #
	#----------------------------------------------------#

	def OccursForTheNthTimeCS(n, pIn, pnAt, pCaseSensitive)
		/* EXAMPLE

		? Q("*").OccursForTheNthTime( 1, :In = "a*b*c*d", :AtPosition = 2 )
		#--> _TRUE_

		? Q("*").OccursForTheNthTime( 3, :In = "a*b*c*d", :AtPosition = 6 )
		#--> _TRUE_

		*/

		if isList(pIn) and Q(pIn).IsInNamedParam()
			pIn = pIn[2]
		ok

		if NOT ( isString(pIn) or isList(pIn) )
			StzRaise("Incorrect param type! pcIn must be a string or list.")
		ok

		if isList(pnAt) and Q(pnAt).IsAtOrAtPositionNamedParam()
			pnAt = pnAt[2]
		ok
	
		if NOT isNumber(pnAt)
			StzRaise("Incorrect param type! pAt must be a number.")
		ok

		bCaseSensitive = CaseSensitive(pCaseSensitive)

		nNthOccurrence = 0

		if isString(pIn)
			oStr = new stzString(pIn)
			nNthOccurrence = oStr.NthOccurrenceCS( n, This.String(), bCaseSensitive )
	
		but isList(pIn)
			if Q(pIn).IsListOfStrings()
				oListStr = new stzListOfStrings(pIn)
				nNthOccurrence  = oListStr.NthOccurrenceCS( n, This.String(), bCaseSensitive )

			else
				if bCaseSensitive = _TRUE_
					oList = new stzList(pIn)
					nNthOccurrence  = oList.NthOccurrence( n, This.String() )
		
				else
					oList = new stzList(pIn)
					oList.Lowercase()

					nNthOccurrence  = oList.NthOccurrence( n, This.String() )
		
				ok
			ok

		ok


		if nNthOccurrence = pnAt
			return _TRUE_

		else
			return _FALSE_
		ok

		#< @FunctionAlternativeForm

		def OccursForTheNthTimeAtCS(n, pIn, pnAt, pCaseSensitive)
			return This.OccursForTheNthTimeCS(n, pIn, pnAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def OccursForTheNthTime(n, pIn, pnAt)
		return This.OccursForTheNthTimeCS(n, pIn, pnAt, _TRUE_)

		#< @FunctionAlternativeForm

		def OccursForTheNthTimeAt(n, pIn, pnAt)
			return This.OccursForTheNthTime(n, pIn, pnAt)

		#>

	   #----------------------------------------------------#
	  #  CHECKING IF STRING OCCURS FOR THE FIRST TIME,     #
	 #  IN AN OTHER STRING OR LIST, AT A GIVEN POSITION   #
	#----------------------------------------------------#

	def OccursForTheFirstTimeCS(pIn, pnAt, pCaseSensitive)
		return This.OccursForTheNthTimeCS(1, pIn, pnAt, pCaseSensitive)

		def OccursForTheFirstTimeAtCS(pIn, pnAt, pCaseSensitive)
			return This.OccursForTheFirstTimeCS(pIn, pnAt, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def OccursForTheFirstTime(pIn, pnAt)
		return This.OccursForTheFirstTimeCS(pIn, pnAt, _TRUE_)

		def OccursForTheFirstTimeAt(pIn, pnAt)
			return This.OccursForTheFirstTime(pIn, pnAt)

	   #----------------------------------------------------#
	  #  CHECKING IF STRING OCCURS FOR THE LAST TIME,      #
	 #  IN AN OTHER STRING OR LIST, AT A GIVEN POSITION   #
	#----------------------------------------------------#

	def OccursForTheLastTimeCS(pIn, pnAt, pCaseSensitive)
		if isList(pIn) and Q(pIn).IsInNamedParam()
			pIn = pIn[2]
		ok

		obj = Q(pIn)
		nPos = obj.FindLastCS(This.Content(), pCaseSensitive)
		nLast = obj.NumberOfOccurrenceCS(This.Content(), pCaseSensitive)

		return This.OccursForTheNthTimeCS(nLast, pIn, nPos, pCaseSensitive)

		def OccursForTheLastTimeAtCS(pIn, pnAt, pCaseSensitive)
			return This.OccursForTheLastTimeCS(pIn, pnAt, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def OccursForTheLastTime(pIn, pnAt)
		return This.OccursForTheLastTimeCS(pIn, pnAt, _TRUE_)

		def OccursForTheLastTimeAt(pIn, pnAt)
			return This.OccursForTheLastTime(pIn, pnAt)

	  #---------------------------------------------------------------#
	 #  GETTING THE SIZE OF THE OBJECT ~> THE SIZE OF ITS CONTENT()  #
	#---------------------------------------------------------------#

	def Size()
		aContent = This.Content()
		nResult = 0

		if isNumber(aContent)
			nResult = StzNumberQ(aContent).Size()

		but isString(aContent)
			nResult = StzStringQ(aContent).Size()

		but isList(aContent)
			nResult = StzListQ(aContent).Size()

		ok

		return nResult

	def SizeInBytes()
		aValues = []
		acAttributes = ring_attributes(This)
		nLen = len(acAttributes)

		for i = 1 to nLen
			cCode = 'value = This.' + acAttributes[i]
			eval(cCode)
			aValues + value
		next

		return @MemorySizeInBytes(aValues)		

		return nResult

		#< @FunctionAlternativeForms

		def HowManyBytes()
			return This.SizeInBytes()

		def CountBytes()
			return This.SizeInBytes()

		def NumberOfBytes()
			return This.SizeInBytes()

		#--

		def MemorySize()
			return This.SizeInBytes()

		def MSize()
			return This.SizeInBytes()

		def MemorySizeInBytes()
			return This.SizeInBytes()

		def MSizeInBytes()
			return This.SizeInBytes()

		#>

	def SizeInBytes32()
		aValues = []
		acAttributes = ring_attributes(This)
		nLen = len(acAttributes)

		for i = 1 to nLen
			cCode = 'value = This.' + acAttributes[i]
			eval(cCode)
			aValues + value
		next

		return @MemorySizeInBytes32(aValues)		

		return nResult

		#< @FunctionAlternativeForms

		def HowManyBytes32()
			return This.SizeInBytes32()

		def CountBytes32()
			return This.SizeInBytes32()

		def NumberOfBytes32()
			return This.SizeInBytes32()

		def MemorySizeInBytes32()
			return This.SizeInBytes32()

		def MSizeInBytes32()
			return This.SizeInBytes32()

		#>

	def SizeInBytes64()
		aValues = []
		acAttributes = ring_attributes(This)
		nLen = len(acAttributes)

		for i = 1 to nLen
			cCode = 'value = This.' + acAttributes[i]
			eval(cCode)
			aValues + value
		next

		return @MemorySizeInBytes64(aValues)		

		return nResult

		#< @FunctionAlternativeForms

		def HowManyBytes64()
			return This.SizeInBytes64()

		def CountBytes64()
			return This.SizeInBytes64()

		def NumberOfBytes64()
			return This.SizeInBytes64()

		#--

		def MemorySizeInBytes64()
			return This.SizeInBytes64()

		def MSizeInBytes64()
			return This.SizeInBytes64()

		#>


	def SizeInBytesXT()
		return @SizeInBytesXT(This)		

		#< @FunctionAlternativeForms

		def HowManyBytesXT()
			return This.SizeInBytesXT()

		def CountBytesXT()
			return This.SizeInBytesXT()

		def NumberOfBytesXT()
			return This.SizeInBytesXT()

		#--

		def MemorySizeXT()
			return This.SizeInBytesXT()

		def MSizeXT()
			return This.SizeInBytesXT()

		def MemorySizeInBytesXT()
			return This.SizeInBytesXT()

		def MSizeInBytesXT()
			return This.SizeInBytesXT()

		#>

	def SizeInBytesXT32()
		return @SizeInBytesXT32(This)		

		#< @FunctionAlternativeForms

		def HowManyBytesXT32()
			return This.SizeInBytesXT32()

		def CountBytesXT32()
			return This.SizeInBytesXT32()

		def NumberOfBytesXT32()
			return This.SizeInBytesXT32()

		#--

		def MemorySizeXT32()
			return This.SizeInBytesXT32()

		def MSizeXT32()
			return This.SizeInBytesXT32()

		def MemorySizeInBytesXT32()
			return This.SizeInBytesXT32()

		def MSizeInBytesXT32()
			return This.SizeInBytesXT32()

		#>

	def SizeInBytesXT64()
		return @SizeInBytesXT64(This)		

		#< @FunctionAlternativeForms

		def HowManyBytesXT64()
			return This.SizeInBytesXT64()

		def CountBytesXT64()
			return This.SizeInBytesXT64()

		def NumberOfBytesXT64()
			return This.SizeInBytesXT64()

		#--

		def MemorySizeXT64()
			return This.SizeInBytesXT64()

		def MSizeXT64()
			return This.SizeInBytesXT64()

		def MemorySizeInBytesXT64()
			return This.SizeInBytesXT64()

		def MSizeInBytesXT64()
			return This.SizeInBytesXT64()

		#>


	def ContentSize()
		aValues = []
		acAttributes = ring_attributes(This)
		nLen = len(acAttributes)

		for i = 1 to nLen
			cCode = 'value = This.' + acAttributes[i]
			eval(cCode)
			aValues + value
		next

		return @ContentSizeInBytes(aValues)

		def ContentSizeInBytes()
			return This.ContentSize()

		def CSize()
			return This.ContentSize()

		def CSizeInBytes()
			return This.ContentSize()

	  #-------------------------------------------------#
	 #  CHECKING OBJECT EQUALITY WITH AN OTHER OBJECT  #
	#-------------------------------------------------#

	#NOTE
	# In Softanza, two objects are considered equal when
	# they are both NamedObjects and have same name

	def IsEqualTo(pOtherObject)

		if NOT isObject(pOtherObject)
			return _FALSE_
		ok

		if @IsNamedObject(pOtherObject) and @IsNamedObject(pOtherObject) and
		   This.VarName() = pOtherObject.VarName()

			return _TRUE_

		else
			return _FALSE_
		ok

		#< @FunctionAlternativeForms

		def IsEqual(pOtherObject)
			return This.IsEqualTo(pOtherObject)

		def IsEqualToCS(pOtherObject, pCaseSensitive)
			return This.IsEqualTo(pOtherObject)

		def IsEqualCS(pOtherObject, pCaseSensitive)
			return This.IsEqualTo(pOtherObject)

		def EqualsCS(pOtherObject, pCaseSensitive)
			return This.IsEqualTo(pOtherObject)

		#>

	def Print()
		? This.Content()

	  #============================#
	 #  MANAGING HISTORIC VALUES  #
	#============================#

	#TODO // Review all the places in the library where softanza objects
	# are updated directly without using UpdateWith().

	#~> // UpdateWith() must be the single-update point for all objects
	# manipulations in the library, so history can be tracked.

	def AddHistoricValue(value)

		_aHisto + value

		def AddHistValue(value)
			AddHistoricValue(value)

		def AddToHistory(value)
			AddHistoricValue(value)

		def AddToHist(value)
			AddHistoricValue(value)

	def HistoricValues()
		if KeepingObjectHistoryXT() = _TRUE_
			return This.HistoricValuesXT()
		ok

		aResult = _aHisto
		_aHisto = []
		return aResult
		
		def HistValues()
			return HistoricValues()

		def History()
			return HistoricValues()

		def Histo()
			return HistoricValues()

	def CleanHistory()
		_aHisto = []


	#== XT

	def AddHistoricValueXT(value)
		_aHistoXT + value

		def AddHistValueXT(value)
			AddHistoricValueXT(value)

		def AddToHistoryXT(value)
			AddHistoricValueXT(value)

		def AddToHistXT(value)
			AddHistoricValueXT(value)

	def HistoricValuesXT()
		_aResult_ = _aHistoXT
		_aHistoXT = []
		return _aResult_

		def HistValuesXT()
			return HistoricValuesXT()

		def HistoryXT()
			return HistoricValuesXT()

		def HistoXT()
			return HistoricValuesXT()

	def CleanHistoryXT()
		_aHistoXT = []

	  #---------------------------------#
	 #  TRACING OBJECT EXECUTION TIME  #
	#---------------------------------#

	def StartTime()
		return _nStartTimeInClocks // A global variable

		def StartingTime()
			return This.StartTime()

		def StartTimeInClocks()
			return This.StartTime()

		def StartingTimeInClocks()
			return This.StartTime()


	def ExecutionTime()
		if KeepingExecutionTime() = _FALSE_
			StzRaise("Can't proceed! Keeping object execution time must be turned ON.")
		ok

		_nResult_ = ( clock() - _nStartTimeInClocks ) / clockspersecond()

		return _nResult_

		#< @FunctionAlternativeForms

		def ExecTime()
			return This.ExecutionTime()

		def ElapsedTime()
			return This.ExecutionTime()

		#--

		def ObjectExecutionTime()
			return This.ExecutionTime()

		def ObjectExecTime()
			return This.ExecutionTime()

		def ObjectElpasedTime()
			return This.ExecutionTime()

		#==

		def ExecutionTimeInSeconds()
			return This.ExecutionTime()

		def ExecTimeInSeconds()
			return This.ExecutionTime()

		def ElapsedTimeInSeconds()
			return This.ExecutionTime()

		#--

		def ObjectExecutionTimeInSeconds()
			return This.ExecutionTime()

		def ObjectExecTimeInSeconds()
			return This.ExecutionTime()

		def ObjectElpasedTimeInSeconds()
			return This.ExecutionTime()

		#>

	def AddTimeValue()
		_aTime + This.ExecutionTime()
		
		def AddExecutionTimeValue()
			This.AddTimeValue()

		def AddExecutionTime()
			This.AddTimeValue()

	def ExistsIn(paList)
		return StzListQ(paList).Contains(This.Content())

		def Inn(paList)
			return This.ExistsIn(paList)
