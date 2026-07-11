
# SOFTANZA OBJECT CLASS

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
		
			def init(_cName_)
				name = _cName_
		
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

	- we can tell it to be instanciated only once using bIsSingleton = 1

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

$bEmptyStringIsConsideredFalse = 1 # Ring's default behaviour
$acSubStringsMakingAStringFalse = []

$bEmptyListIsConsideredFalse = 1 # Ring's default behavior
$aItemsMakingAListFalse = []
$aInnerItemsMakingAListFalse = []

$bNullObjectIsFalse = 1 # A Siftanza's default, confroming to Ring default
$bObjectContentDefinesItsTruth = 0

func StzEmptyStringIsConsideredFalse()
	return $bEmptyStringIsConsideredFalse

	func EmptyStringIsConsideredFalse()
		return StzEmptyStringIsConsideredFalse()

	func EmptyStringConsideredFalse()
		return StzEmptyStringIsConsideredFalse()

	func NullStringIsConsideredFalse()
		return StzEmptyStringIsConsideredFalse()

	func NullStringConsideredFalse()
		return StzEmptyStringIsConsideredFalse()

func StzSetEmptyStringIsConsideredFalse(pnTrueFalse)

	if CheckParams() and isString(pnTrueFalse)
		_cLower_ = StzLower(pnTrueFalse)
		if _cLower_ = "yes" or _cLower_ = "on"
			pnTrueFalse = 1
		but _cLower_ = "no" or _cLower_ = "off"
			pnTrueFalse = 0
		else
			StzRaise("Incorrect param value! Possible values are 0, 1, 'yes', 'no', 'on', and 'off'.")

		ok
	ok

	if NOT (isNumber(pnTrueFalse) and (pnTrueFalse = 1 or pnTrueFalse = 0) )
		StzRaise("Incorrect param type! pnTrueFalse must be a number equal to 1 or 0.")
	ok

	$bEmptyStringIsConsideredFalse = pnTrueFalse

	func SetEmptyStringIsConsideredFalse(pnTrueFalse)
		StzSetEmptyStringIsConsideredFalse(pnTrueFalse)

func StzSubStringsMakingAStringFalse()
	return $acSubStringsMakingAStringFalse

	func SubStringsMakingAStringFalse()
		return StzSubStringsMakingAStringFalse()

	func SubStringsMakingStringFalse()
		return StzSubStringsMakingAStringFalse()

func StzSetSubStringsMakingAStringFalse(pacStr)
	if CheckParams()
		if NOT IsListOfStrings(pacStr)
			StzRaise("Incorrect param type! pacStr must be a list of strings.")
		ok
	ok

	$acSubStringsMakingAStringFalse = pacStr

	func SetSubStringsMakingAStringFalse(pacStr)
		StzSetSubStringsMakingAStringFalse(pacStr)

	func SetSubStringsMakingStringFalse(pacStr)
		StzSetSubStringsMakingAStringFalse(pacStr)

func StzEmptyListIsConsideredFalse()
	return $bEmptyListIsConsideredFalse

	func EmptyListIsConsideredFalse()
		return StzEmptyListIsConsideredFalse()

	func EmptyListConsideredFalse()
		return StzEmptyListIsConsideredFalse()

func StzSetEmptyListIsConsideredFalse(pnTrueFalse)

	if CheckParams() and isString(pnTrueFalse)
		_cLower_ = StzLower(pnTrueFalse)
		if _cLower_ = "yes" or _cLower_ = "on"
			pnTrueFalse = 1
		but _cLower_ = "no" or _cLower_ = "off"
			pnTrueFalse = 0
		else
			StzRaise("Incorrect param value! Possible values are 0, 1, 'yes', 'no', 'on', and 'off'.")

		ok
	ok

	if NOT (isNumber(pnTrueFalse) and (pnTrueFalse = 1 or pnTrueFalse = 0) )
		StzRaise("Incorrect param type! pnTrueFalse must be a number equal to 1 or 0.")
	ok

	$bEmptyListIsConsideredFalse = pnTrueFalse

	func SetEmptyListIsConsideredFalse(pnTrueFalse)
		StzSetEmptyListIsConsideredFalse(pnTrueFalse)

func StzItemsMakingAListFalse()
	return $aItemsMakingAListFalse

	func ItemsMakingAListFalse()
		return StzItemsMakingAListFalse()

	func ItemsMakingListFalse()
		return StzItemsMakingAListFalse()

func StzSetItemsMakingAListFalse(paItems)
	if CheckParams()
		if NOT IsList(paItems)
			StzRaise("Incorrect param type! paItems must be a list.")
		ok
	ok

	$aItemsMakingAListFalse = paItems

	func SetItemsMakingAListFalse(paItems)
		StzSetItemsMakingAListFalse(paItems)

	func SetItemsMakingListFalse(paItems)
		StzSetItemsMakingAListFalse(paItems)

func StzInnerItemsMakingAListFalse()
	return $aInnerItemsMakingAListFalse

	func InnerItemsMakingAListFalse()
		return StzInnerItemsMakingAListFalse()

	func InnerItemsMakingListFalse()
		return StzInnerItemsMakingAListFalse()

func StzSetInnerItemsMakingAListFalse(paItems)
	if CheckParams()
		if NOT IsList(paItems)
			StzRaise("Incorrect param type! paItems must be a list.")
		ok
	ok

	$aInnerItemsMakingAListFalse = paItems

	func SetInnerItemsMakingAListFalse(paItems)
		StzSetInnerItemsMakingAListFalse(paItems)

	func SetInnerItemsMakingListFalse(paItems)
		StzSetInnerItemsMakingAListFalse(paItems)

func StzNullObjectIsFalse()
	return $bNullObjectIsFalse

	func NullObjectIsFalse()
		return StzNullObjectIsFalse()

func StzObjectContentDefinesItsTruth()
	return $bObjectContentDefinesItsTruth

	func ObjectContentDefinesItsTruth()
		return StzObjectContentDefinesItsTruth()

  ///////////////////
 //   FUNCTIONS   //
///////////////////

func StzObjectQ(pObject)
	return new stzObject(pObject)

func StzNumberOfAttributes(pObject)
	return len(attributes(pObject))

	func NumberOfAttributes(pObject)
		return StzNumberOfAttributes(pObject)

	func HowManyAttributes(pObject)
		return StzNumberOfAttributes(pObject)

	func CountAttributes(pObject)
		return StzNumberOfAttributes(pObject)

	func @NumberOfAttributes(pObject)
		return len(attributes(pObject))

	func @HowManyAttributes(pObject)
		return len(attributes(pObject))

	func @CountAttributes(pObject)
		return len(attributes(pObject))

func StzAttributesXT(pObj)
	if NOT isObject(pObj)
		StzRaise("Incorrect param type! pObj must be an object.")
	ok

	_aResult_ = []
	_acAttr_ = attributes(pObj)
	_nLen_ = len(_acAttr_)

	for i = 1 to _nLen_
		_cCode_ = "_val_ = pObj." + _acAttr_[i]
		eval(_cCode_)
		_aResult_ + [ _acAttr_[i], _val_ ]
	next

	return _aResult_

	func AttributesXT(pObj)
		return StzAttributesXT(pObj)

	func AttributesAndValues(pObj)
		return StzAttributesXT(pObj)

	func AttributesAndTheirValues(pObj)
		return StzAttributesXT(pObj)

	func @AttributesXT(pObj)
		return StzAttributesXT(pObj)

	func @AttributesAndValues(pObj)
		return StzAttributesXT(pObj)

	func @AttributesAndTheirValues(pObj)
		return StzAttributesXT(pObj)

func StzHasAttribute(pObject, cAttr)
	if CheckParams()
		if NOT isObject(pObject)
			StzRaise("Incorrect param type! pObject must be an object.")
		ok

		if NoT isString(cAttr)
			StzRaise("Incorrect param type! cAttr must be a string.")
		ok
	ok

	_acAttr_ = attributes(pObject)
	_nPos_ = find(_acAttr_, StzLower(cAttr))
	if _nPos_ > 0
		return TRUE
	else
		return FALSE
	ok

	func HasAttribute(pObject, cAttr)
		return StzHasAttribute(pObject, cAttr)

	func ContainsAttribute(pObject, cAttr)
		return StzHasAttribute(pObject, cAttr)

	func @HasAttribute(pObject, cAttr)
		return HasAttribute(pObject, cAttr)

	func @ContainsAttribute(pObject, cAttr)
		return HasAttribute(pObject, cAttr)

#--

func StzIsTrue(p)
	if p
		return 1
	else
		return 0
	ok

	func IsTrue(p)
		return StzIsTrue(p)

func StzIsFalse(p)
	return NOT StzIsTrue(p)

	func IsFalse(p)
		return StzIsFalse(p)


func StzIsTrueXT(p)
	if isNumber(p)
		return IsTrue(p)
	
	but isString(p)

		if EmptyStringConsideredFalse() and p = ""
			return 0

		but ContainsOneOfTheseCS(p, SubStringsMakingAStringFalse(), 0)
			return 0

		else
			return IsTrue(p)
		ok

	but isList(p)
		if EmptyListIsConsideredFalse() and len(p) = 0
			return 0

		but ContainsOneOfTheseCS(p, ItemsMakingAListFalse(), 0)
			return 0

		but DeepContainsCS(p, InnerItemsMakingAListFalse(), 0)
			return 0

		else
			return IsTrue(p)
		ok

	but isObject(p)
		# NOTE: these sentinel predicates take the object as a param --
		# calling them bare raised R19 (less params), making IsTrueXT/
		# IsFalseXT crash on every object. Pass p.
		if IsTrueObject(p)
			return 1

		but IsFalseObject(p)
			return 0

		but IsNullObject(p)
			# inverted: when the null object is configured as FALSE,
			# IsTrue must be 0 (not 1).
			if NullObjectIsFalse()
				return 0
			else
				return 1
			ok

		else
			if ObjectContentDefinesItsTruth()
				return IsTrue(p.Content())
			else
				return 0
			ok
		ok

	ok

	func IsTrueXT(p)
		return StzIsTrueXT(p)

func StzIsFalseXT(p)
	return NOT StzIsTrueXT(p)

	func IsFalseXT(p)
		return StzIsFalseXT(p)

#--



#--

#TODO Abstract stzNamedObject into the MAX layer

func StzNamedObject(paNamed)
	if CheckingParams()
		if NOT (isList(paNamed) and IsPairOfStringAndObject(paNamed))
			StzRaise("Incorrect param type! paNamed must be a pair of string and object.")
		ok
	ok

	_oObject_ = Q(paNamed[2])
	_oObject_.SetName(paNamed[1])
	return _oObject_

	func StzNamedObjectQ(paNamed)
		return StzNamedObject(paNamed)

	func StzNamedObjectXTQ(paNamed)
		return StzNamedObject(paNamed)

func StzNamedObjectFrom(pcObjName)
	? @@(_avars)
	if CheckingParams()

	ok

	func NamedObject(pcObjName)
		return StzNamedObjectFrom(pcObjName)

func StzObjectMethods()
	return Stz(:Object, :Methods)

func StzObjectAttributes()
	return Stz(:Object, :Attributes)

func StzObjectClassName()
	return "stzobject"

	func StzObjectClass()
		return "stzobject"

func StzIsNotObject(p)
	return NOT isObject(p)

	func IsNotObject(p)
		return StzIsNotObject(p)

	func @IsNotObject(p)
		return IsNotObject(p)

	func IsNotAnObject(p)
		return IsNotObject(p)

	func @IsNotAnObject(p)
		return IsNotObject(p)

func StzObjectVarName(pObject)

	if NOT isObject(pObject)
		StzRaise("Incorrect param type! pObject must be an object.")
	ok

	_cResult_ = :@NoName
	if ObjectIsStzObject(pObject)
		_cResult_ = pObject.VarName()
	ok

	return _cResult_

	func ObjectVarName(pObject)
		return StzObjectVarName(pObject)

	func ObjectName(pObject)
		return StzObjectVarName(pObject)

	func @ObjectVarName(pObject)
		return StzObjectVarName(pObject)

	func @ObjectName(pObject)
		return StzObjectVarName(pObject)

func StzObjectIsNamed(pObject)
	if StzObjectVarName(pObject) != :@NoName
		return 1
	else
		return 0
	ok

	func ObjectIsNamed(pObject)
		return StzObjectIsNamed(pObject)

	func @ObjectIsNamed(pObject)
		return StzObjectIsNamed(pObject)

func StzObjectIsUnnamed(pObject)
	return NOT StzObjectIsNamed(pObject)

	func ObjectIsUnnamed(pObject)
		return StzObjectIsUnnamed(pObject)

	func @ObjectIsUnnamed(pObject)
		return StzObjectIsUnnamed(pObject)

#--

func StzPluralOfRingType(_cType_)
	if CheckingParams()
		if NOT IsString(_cPlural_)
			StzRaise("Incorrect param type! cPlural must be a string.")
		ok
	ok

	if NOT IsRingType(_cType_)
		StzRaise("Incorrect param! cType is not a valid Ring type.")
	ok

	_cType_ = StzLower(_cType_)
	_acRingTypesXT_ = RingTypesXT()
	_nLen_ = len(_acRingTypesXT_)

	_cResult_ = ""
	for i = 1 to _nLen_
		if _acRingTypesXT_[i][1] = _cType_
			_cResult_ = _acRingTypesXT_[i][2]
			exit
		ok
	next

	if _cResult_ = ""
		StzRaise("Can't get a plural of a Ring type form string!")
	else
		return _cResult_
	ok

	func PluralOfRingType(_cType_)
		return StzPluralOfRingType(_cType_)

func StzRingTypesPlurals()
	_acResult_ = []
	_aRingTypesXT_ = RingTypesXT()
	_nLen_ = len(_aRingTypesXT_)

	for i = 1 to _nLen_
		_acResult_ + _aRingTypesXT_[i][2]
	next

	return _acResult_

	func RingTypesPlurals()
		return StzRingTypesPlurals()

	func PluralsOfRingTypes()
		return StzRingTypesPlurals()

func StzIsPluralOfRingType(_cPlural_)
	if CheckingParams()
		if NOT IsString(_cPlural_)
			StzRaise("Incorrect param type! cPlural must be a string.")
		ok
	ok

	_cPlural_ = StzLower(_cPlural_)
	_acRingTypesPlurals_ = RingTypesPlurals()

	if ring_find(_acRingTypesPlurals_, _cPlural_)
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func IsPluralOfRingType(_cPlural_)
		return StzIsPluralOfRingType(_cPlural_)

	func IsRingTypePlural(_cPlural_)
		return StzIsPluralOfRingType(_cPlural_)

	func IsPluralOfARingType(_cPlural_)
		return StzIsPluralOfRingType(_cPlural_)

	func IsARingTypePlural(_cPlural_)
		return StzIsPluralOfRingType(_cPlural_)

	func IsRingTypeInPlural(_cPlural_)
		return StzIsPluralOfRingType(_cPlural_)

	func IsARingTypInePlural(_cPlural_)
		return StzIsPluralOfRingType(_cPlural_)

	func @IsPluralOfRingType(_cPlural_)
		return StzIsPluralOfRingType(_cPlural_)

	func @IsRingTypePlural(_cPlural_)
		return StzIsPluralOfRingType(_cPlural_)

	func @IsPluralOfARingType(_cPlural_)
		return StzIsPluralOfRingType(_cPlural_)

	func @IsARingTypePlural(_cPlural_)
		return StzIsPluralOfRingType(_cPlural_)

	func @IsRingTypeInPlural(_cPlural_)
		return StzIsPluralOfRingType(_cPlural_)

	func @IsARingTypInePlural(_cPlural_)
		return StzIsPluralOfRingType(_cPlural_)

	#>

func StzRingTypesXT()
	return _aRingTypesXT

	func RingTypesXT()
		return StzRingTypesXT()

func StzPluralToRingType(_cPlural_)
	if CheckingParams()
		if NOT isString(_cPlural_)
			StzRaise("Incorrect param type! cPlural must be a string.")
		ok
	ok

	_cPlural_ = StzLower(_cPlural_)
	_acRingTypesXT_ = RingTypesXT()
	_nLen_ = len(_acRingTypesXT_)

	_cResult_ = ""

	for i = 1 to _nLen_
		if _acRingTypesXT_[i][2] = _cPlural_
			_cResult_ = _acRingTypesXT_[i][1]
			exit
		ok
	next

	if _cResult_ = ""
		StzRaise("Plural does not exist or can't be be found!")
	else
		return _cResult_
	ok

	func PluralToRingType(_cPlural_)
		return StzPluralToRingType(_cPlural_)

func StzPluralOfStzClassName(cClass)

	return StzClassesXT()[cClass]

	#< @FunctionAlternativeForms

	func PluralOfStzClassName(cClass)
		return StzPluralOfStzClassName(cClass)

	func PluralOfStzType(cClass)
		return StzPluralOfStzClassName(cClass)

	func PluralOfStzClass(cClass)
		return StzPluralOfStzClassName(cClass)

	func StzTypeToPlural(cClass)
		return StzPluralOfStzClassName(cClass)

	func StzClassNameToPlural(cClass)
		return StzPluralOfStzClassName(cClass)

	func StzClassToPlural(cClass)
		return StzPluralOfStzClassName(cClass)

	func PluralOfThisStzClass(cClass)
		return StzPluralOfStzClassName(cClass)

	func PluralOfThisStzClassName(cClass)
		return StzPluralOfStzClassName(cClass)

	func PluralOfThisStzType(cClass)
		return StzPluralOfStzClassName(cClass)

	#>

func StzClassesPlurals()
	_acResult_ = []

	_acClassesXT_ = StzClassesXT()
	_nLen_ = len(_acClassesXT_)

	for i = 1 to _nLen_
		_acResult_ + _acClassesXT_[i][2]
	next

	return _acResult_

	def PluralsOfStzClasses()
		return StzClassesPlurals()

	def PluralsOfStzClassesNames()
		return StzClassesPlurals()

	def StzTypesPlurals()
		return StzClassesPlurals()

	def PluralsOfStzTypes()
		return StzClassesPlurals()

func StzIsPluralOfAStzType(_cPlural_)
	if CheckingParams()
		if NOT isString(_cPlural_)
			StzRaise("Incorrect param! cPlural must be a string.")
		ok
	ok

	_cPlural_ = StzLower(_cPlural_)
	_acPlurals_ = StzClassesPlurals()
	_nLen_ = len(_acPlurals_)

	if find(_acPlurals_, _cPlural_) > 0
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func IsPluralOfAStzType(_cPlural_)
		return StzIsPluralOfAStzType(_cPlural_)

	func IsPluralOfStzType(_cPlural_)
		return StzIsPluralOfAStzType(_cPlural_)

	func IsStzTypePlural(_cPlural_)
		return StzIsPluralOfAStzType(_cPlural_)

	func IsPluralOfAStzClass(_cPlural_)
		return StzIsPluralOfAStzType(_cPlural_)

	func IsPluralOfStzClass(_cPlural_)
		return StzIsPluralOfAStzType(_cPlural_)

	func IsStzClassPlural(_cPlural_)
		return StzIsPluralOfAStzType(_cPlural_)

	func IsPluralOfAStzClassName(_cPlural_)
		return StzIsPluralOfAStzType(_cPlural_)

	func IsPluralOfStzClassName(_cPlural_)
		return StzIsPluralOfAStzType(_cPlural_)

	func IsStzClassNamePlural(_cPlural_)
		return StzIsPluralOfAStzType(_cPlural_)

	func IsStzTypeInPlural(_cPlural_)
		return StzIsPluralOfAStzType(_cPlural_)

	func IsAStzTypeInPlural(_cPlural_)
		return StzIsPluralOfAStzType(_cPlural_)

	func @IsPluralOfAStzType(_cPlural_)
		return StzIsPluralOfAStzType(_cPlural_)

	func @IsPluralOfStzType(_cPlural_)
		return StzIsPluralOfAStzType(_cPlural_)

	func @IsStzTypePlural(_cPlural_)
		return StzIsPluralOfAStzType(_cPlural_)

	func @IsPluralOfAStzClass(_cPlural_)
		return StzIsPluralOfAStzType(_cPlural_)

	func @IsPluralOfStzClass(_cPlural_)
		return StzIsPluralOfAStzType(_cPlural_)

	func @IsStzClassPlural(_cPlural_)
		return StzIsPluralOfAStzType(_cPlural_)

	func @IsPluralOfAStzClassName(_cPlural_)
		return StzIsPluralOfAStzType(_cPlural_)

	func @IsPluralOfStzClassName(_cPlural_)
		return StzIsPluralOfAStzType(_cPlural_)

	func @IsStzClassNamePlural(_cPlural_)
		return StzIsPluralOfAStzType(_cPlural_)

	func @IsStzTypeInPlural(_cPlural_)
		return StzIsPluralOfAStzType(_cPlural_)

	func @IsAStzTypeInPlural(_cPlural_)
		return StzIsPluralOfAStzType(_cPlural_)

	#>

func StzPluralToStzType(_cPlural_)
	if CheckingParams()
		if NOT isString(_cPlural_)
			StzRaise("Incorrect param! cPlural must be a string.")
		ok
	ok

	_cPlural_ = StzLower(_cPlural_)
	
	_acTypesXT_ = StzTypesXT()

	_nLen_ = len(_acTypesXT_)

	_cResult_ = ""

	for i = 1 to _nLen_
		if _acTypesXT_[i][2] = _cPlural_
			_cResult_ = _acTypesXT_[i][1]
			exit
		ok
	next

	if _cResult_ = ""
		StzRaise("Not a plural of a stzType or can't find it!")
	ok

	return _cResult_

	#< @FunctionAlternativeForms

	func PluralToStzType(_cPlural_)
		return StzPluralToStzType(_cPlural_)

	func PluraltoStzClass(_cPlural_)
		return StzPluralToStzType(_cPlural_)

	func PluraltoStzClassName(_cPlural_)
		return StzPluralToStzType(_cPlural_)

	#>

func IsStzObject(pObject)

	if isObject(pObject) and Q(classname(pObject)).ExistsIn( StzTypes() )
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func ObjectIsStzObject(pObject)
		return IsStzObject(pObject)

	#--

	func IsAStzObject(pObject)
		return IsStzObject(pObject)

	func @IsAStzObject(pObject)
		return IsStzObject(pObject)

	func ObjectIsAStzObject(pObject)
		return IsStzObject(pObject)

	#>

func StzIsNamedObject(pObject)
	if isObject(pObject) and @IsStzObject(pObject) and pObject.IsNamed()
		return 1

	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func IsNamedObject(pObject)
		return StzIsNamedObject(pObject)

	func ObjectIsNamedObject(pObject)
		return StzIsNamedObject(pObject)

	func @IsNamedObject(pObject)
		return StzIsNamedObject(pObject)

	func IsANamedObject(pObject)
		return StzIsNamedObject(pObject)

	func @IsANamedObject(pObject)
		return StzIsNamedObject(pObject)

	#>

func StzIsUnnamedObject(pObject)
	return NOT StzIsNamedObject(pObject)

	#< @FunctionAlternativeForms

	func IsUnnamedObject(pObject)
		return StzIsUnnamedObject(pObject)

	func ObjectIsUnnamedObject(pObject)
		return StzIsUnnamedObject(pObject)

	func @IsUnnamedObject(pObject)
		return StzIsUnnamedObject(pObject)

	func IsAUnnamedObject(pObject)
		return StzIsUnnamedObject(pObject)

	func @IsAnUnnamedObject(pObject)
		return StzIsUnnamedObject(pObject)

	#>

func StzAreEqualObjects(paObjects)
	if NOT AreNamedObjects(paObjects)
		StzRaise("Incorrect param type! paObjects must be a list of named objects.")
	ok

	_acNames_ = ObjectsNames(paObjects)
	if len(U(_acNames_)) = 1
		return 1
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func AreEqualObjects(paObjects)
		return StzAreEqualObjects(paObjects)

	func AreEqualNamedObjects(paObjects)
		return StzAreEqualObjects(paObjects)

	func @AreEqualObjects(paObjects)
		return StzAreEqualObjects(paObjects)

	func @AreEqualNamedObjects(paObjects)
		return StzAreEqualObjects(paObjects)

	#>

func StzAreNamedObjects(paObjects)
	if isList(paObjects) and IsListOfObjects(paObjects)
		_bResult_ = 1

		_nLen_ = len(paObjects)
		for i = 1 to _nLen_
			if NOT IsNamedObject(paObjects[i])
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_
	else
		return 0
	ok

	#< @FunctionAlternativeForms

	func AreNamedObjects(paObjects)
		return StzAreNamedObjects(paObjects)

	func @AreNamedObjects(paObjects)
		return StzAreNamedObjects(paObjects)

	#>

func StzAreUnnamedObjects(paObjects)
	return NOT StzAreNamedObjects(paObjects)

	func AreUnnamedObjects(paObjects)
		return StzAreUnnamedObjects(paObjects)

	func @AreUnnamedObjects(paObjects)
		return StzAreUnnamedObjects(paObjects)

func StzObjectsNames(paObjects)
	if CheckingParams()
		if NOT isList(paObjects)
			StzRaise("Incorrect param type! paObjects must be a list.")
		ok
	ok

	_acResult_ = []
	_nLen_ = len(paObjects)

	for i = 1 to _nLen_
		if isObject(paObjects[i])
			_acResult_ + @@(paObjects[i])
		ok
	next

	return _acResult_

	#< @FunctionAlternativeForms

	func ObjectsNames(paObjects)
		return StzObjectsNames(paObjects)

	func ObjectsVarNames(paObjects)
		return StzObjectsNames(paObjects)

	func ObjectsVarsNames(paObjects)
		return StzObjectsNames(paObjects)

	func @ObjectsNames(paObjects)
		return StzObjectsNames(paObjects)

	func @ObjectsVarNames(paObjects)
		return StzObjectsNames(paObjects)

	func @ObjectsVarsNames(paObjects)
		return StzObjectsNames(paObjects)

	#>

/* NOTE: The following section of code is generated with
	 stzCodeGenerators and then pasted here
*/

#< @StartOfGenCode >

func IsStzNaturalCode(pObject)
	if isObject(pObject) and classname(pObject) = "stznaturalcode"
		return 1
	else
		return 0
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
		return 1
	else
		return 0
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
		return 1
	else
		return 0
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

func IsStzTransform(pObject)
	if isObject(pObject) and classname(pObject) = "stztransform"
		return 1
	else
		return 0
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
		return 1
	else
		return 0
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
		return 1
	else
		return 0
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
		return 1
	else
		return 0
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
		return 1
	else
		return 0
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
		return 1
	else
		return 0
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
		return 1
	else
		return 0
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
		return 1
	else
		return 0
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
		return 1
	else
		return 0
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
		return 1
	else
		return 0
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
		return 1
	else
		return 0
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
		return 1
	else
		return 0
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
		return 1
	else
		return 0
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
		return 1
	else
		return 0
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
	if isObject(pObject)
		_cName_ = classname(pObject)
		if _cName_ = "stzlist" or _cName_ = "stzlistnamedparams"
			return 1
		ok
	ok
	return 0

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
		return 1
	else
		return 0
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
		return 1
	else
		return 0
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
		return 1
	else
		return 0
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
		return 1
	else
		return 0
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
		return 1
	else
		return 0
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
		return 1
	else
		return 0
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
		return 1
	else
		return 0
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
		return 1
	else
		return 0
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
		return 1
	else
		return 0
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
		return 1
	else
		return 0
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
		return 1
	else
		return 0
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
		return 1
	else
		return 0
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
		return 1
	else
		return 0
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
	# was checking "stzfalseobject" (copy-paste bug) -- so IsTrueObject
	# answered TRUE for a FalseObject and FALSE for a TrueObject.
	if isObject(pObject) and classname(pObject) = "stztrueobject"
		return 1
	else
		return 0
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

func StzObjectValues(cObjectVarName)
	return StzObjectQ(cObjectVarName).ObjectValues()

	func ObjectValues(cObjectVarName)
		return StzObjectValues(cObjectVarName)

func StzObjectAttributesAndValues(cObjectVarName)
	return StzObjectQ(cObjectVarName).ObjectAttributesAndValues()

	func ObjectAttributesAndValues(cObjectVarName)
		return StzObjectAttributesAndValues(cObjectVarName)

func StzObjectToList(cObjectVarName)
	return StzObjectQ(cObjectVarName).ObjectToList()

	func ObjectToList(cObjectVarName)
		return StzObjectToList(cObjectVarName)


  ///////////////
 //   CLASS   //
///////////////

class stzObject
	@content

	@cNNLWhy = ""

	# P2 -- CHAIN-SCOPED CONTEXT (NNL_REVIEW): the expectation register and
	# the main referent travel ON the chain; the process globals survive
	# only as fallback shims. Mode "" = no chain-local expectation set.
	@cNNLExpectMode = ""
	@pNNLExpect = 0
	@nNNLExpectTol = 0
	@oNNLMain = 0

	@cVarName = :@NoName
	@cUuid = ""
	@cHashedUuid = ""

	_These_
	_Those_

	def init(pObject)

		# Creating an object from an existing object
		if isObject(pObject)
			@content = pObject

		# Creating an object from the name of an existing object
		but IsNonNullString(pObject)

			_cCode_ = '_bOk_ = isObject(' + pObject + ')'
			eval(_cCode_)
			if NOT _bOk_
				StzRaise("Can't create a stzObject from the provided string! The string must be a valid object name.")
			ok

			@cVarName = pObject

			_cCode_ = "@content = " + pObject
			eval(_cCode_)

		but IsNullString(pObject)
			StzRaise("Can't create a stzObject from an empty string!")
		
		else
			StzRaise("Type error: you must provide an object or an object varname inside a string!")
		ok

		if ObjectKeepingTime() = 1
			StartObjectTime()
		ok

		_These_ = This
		_Those_ = This

	  #==========================================================#
	 #   SELF-DESCRIPTION (ask/explain this object's methods)   #
	#==========================================================#
	# Doc()/Ask()/ExplainMethod() let the object describe ITSELF -- harvest its
	# class's methods + doc-comments from source and answer plain-English
	# questions (natural programming, no LLM; see base/reflect/stzSelfDoc).
	def Doc()
		return new stzSelfDoc(_StzClassNameOf(This))

	def Ask(pcQuestion)
		_oSd_ = new stzSelfDoc(_StzClassNameOf(This))
		return _oSd_.Ask(pcQuestion)

	def AskFor(pcQuestion, _n_)
		_oSd_ = new stzSelfDoc(_StzClassNameOf(This))
		return _oSd_.AskFor(pcQuestion, _n_)

	def ExplainMethod(pcName)
		_oSd_ = new stzSelfDoc(_StzClassNameOf(This))
		return _oSd_.ExplainMethod(pcName)

	# HowTo(intent) -- natural programming: resolve a plain-English intent to a
	# runnable method call on THIS object's class (grammar-composed then retrieved).
	def HowTo(pcIntent)
		_oSd_ = new stzSelfDoc(_StzClassNameOf(This))
		return _oSd_.HowTo(pcIntent)

	def MethodForIntent(pcIntent)
		_oSd_ = new stzSelfDoc(_StzClassNameOf(This))
		return _oSd_.MethodForIntent(pcIntent)

	# PlanForIntent(intent) -- the intent as EXECUTABLE NATURAL CODE over
	# this object's current content: a Create line + the intent's steps.
	# DoIntent(intent) lint-verifies the plan (raising with suggestions
	# when a word is not understood -- a plan must be fully understood,
	# unlike permissive free narration), runs it, returns the result.

	def PlanForIntent(pcIntent)
		_cT_ = This.NaturalTypeWord()
		if _cT_ = ""
			StzRaise("PlanForIntent is supported on stzString, stzList and stzNumber objects.")
		ok
		return StzNaturalPlanFor(pcIntent, _cT_, This.Content())

	def DoIntent(pcIntent)
		_cPlan_ = This.PlanForIntent(pcIntent)
		_aLint_ = StzNaturalLint(_cPlan_)
		if NOT _aLint_[:understood]
			_cMsg_ = "The intent was not fully understood:"
			_aU_ = _aLint_[:unresolved]
			_nU_ = len(_aU_)
			for _i_ = 1 to _nU_
				_cMsg_ += " '" + _aU_[_i_][1] + "'"
				if _aU_[_i_][2] != ""
					_cMsg_ += " (did you mean '" + _aU_[_i_][2] + "'?)"
				ok
			next
			StzRaise(_cMsg_)
		ok
		_oRun_ = Naturally(_cPlan_)
		return _oRun_.Result()

	def NaturalTypeWord()
		_c_ = lower(_StzClassNameOf(This))
		if _c_ = "stzstring"
			return "string"
		but _c_ = "stzlist"
			return "list"
		but _c_ = "stznumber"
			return "number"
		ok
		return ""

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
			return 1
		else
			return 0
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
			return 1
		else
			return 0
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
		if isList(pcVarName) and len(pcVarName) = 2 and isString(pcVarName[1]) and (pcVarName[1] = "to" or pcVarName[1] = "as")
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

	def HasUuid()
		if @cUuid != ""
			return TRUE
		else
			return FALSE
		ok

	def SetUuid()
		_oUuid_ = new stzUuid()
		@cUuid = _oUuid_.Content()
		@cHashedUuid = ""+ _oUuid_.Hashed()
		
	def Uuid()
		return @cUuid

	def HashedUuid()
		return @cHashedUuid

	def Copy()
		return new stzObject(@content)

	def Values()
		_aResult_ = []
		_acAttributes_ = This.Attributes()
		_nLen_ = len(_acAttributes_)

		for i = 1 to _nLen_ 
			_cCode_ = "aResult + This." + _acAttributes_[i]
			eval(_cCode_)
		next
		return _aResult_

		def AttributesValues()
			return This.Values()

		def ObjectValues()
			return This.Values()

	def AttributesAndValues()
		_aResult_ = Association([
				This.Attributes(),
				This.Values()
		])

		return _aResult_

		def AttributesXT()
			return This.AttributesAndValues()

		def AttributesAndTheirValues()
			return This.AttributesAndValues()

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
			return 1
		else
			return 0
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
			return 1
		else
			return 0
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
			return 1
		else
			return 0
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
			return 1
		else
			return 0
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
		return 1

		#< @FunctionAlternativeForm

		def IsAStzObject()
			return 1

		#>

		#< @FunctionNegativeForm

		def IsNotStzObject()
			return 0
	
		def IsNotAStzObject()
			return This.IsNotAnObject()

		#>

	def HasSameTypeAs(p)
		return isObject(p)

	def HasSameStzTypeAs(p)
		if isObject(p) and Q(p).IsStzType() and
		   Q(p).StzType() = This.StzType()

			return 1
		else
			return 0
		ok

	def IsOneOfTheseTypes(paTypes)

		/* EXAMPLE

		? Q("2").IsOneOfTheseTypes([ :Number, :String, :List ])
		#--> TRUE

		# can also be written use :Or = ...
		? Q("2").IsOneOfTheseTypes([ :Number, :Or = :String, :Or = :List ])
		#--> TRUE
		*/

		if NOT isList(paTypes)
			StzRaise("Incorrect param type! paTypes must be a list.")
		ok

		_aTypes_ = paTypes
		_nLen_ = len(paTypes)

		for @i = 1 to _nLen_
			if isList(_aTypes_[@i]) and IsOrNamedParamList(_aTypes_[@i])
				_aTypes_[@i] = _aTypes_[@i][2]
			ok
		next

		_bResult_ = 0

		for @i = 1 to _nLen_

			_cType_ = _aTypes_[@i]

			if _cType_ = "number" or _cType_ = "string" or _cType_ = "list"
				_cType_ = "A" + _cType_

			but _cType_ = "object"
				_cType_ = "anobject"
			ok

			if (This.IsA(_cType_) or This.Is(_cType_))
				_bResult_ = 1
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
			if isList(_aTypes_[@i]) and IsOrOrAndNamedParamList(_aTypes_[@i])
				_aTypes_[@i] = _aTypes_[@i][2]
			ok
		next

		_bResult_ = 1

		for @i = 1 to _nLen_

			if NOT (This.IsA(_aTypes_[@i]) or This.Is(_aTypes_[@i]))
				_bResult_ = 0
				exit
			ok
		next

		return _bResult_

	def IsNumberOrString()
		content = This.Content()
		if isNumber(content) or isString(content)
			return 1
		else
			return 0
		ok

		def IsStringOrNumber()
			return This.IsNumberOrString()

	def IsStringOrList()
		content = This.Content()

		if isString(content) or isList(content)
			return 1
		else
			return 0
		ok

		def IsListOrString()
			return This.IsListOrString()

	#==

	def IsFalseObject()
		if This.StzType() = :stzFlaseObject
			return 1
		else
			return 0
		ok

		#-- @Misspelled

		def IsFalseObejct()
			return This.IsFalseObject()

	def IsTrueObject()
		if This.StzType() = :stzFlaseObject
			return 1
		else
			return 0
		ok

	def IsNullObject()
		if This.StzType() = :stzNullObject
			return 1
		else
			return 0
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

		_nLen_ = len(pacStr)
		if _nLen_ = 0
			return 0
		ok

		_bResult_ = 1

		for i = 1 to _nLen_
			_cCode_ = '_bResult_ = @is' + pacStr[i] + '(' + @@(this.Content()) + ')'

			eval(_cCode_)
			if _bResult_ = 0
				exit
			ok
		next

		return _bResult_

		#-- @FunctionluentForm

		def IsAXTQ(pcType)
			if this.IsAXT(pcType) = 1

				content = This.Content()
		
				if isNumber(content)
					return This._NNLCarry(new stzNumber(content))
		
				but isString(content)
					return This._NNLCarry(new stzString(content))
		
				but isList(content)
					return This._NNLCarry(new stzList(content))
		
				but isObject(content)
					return This._NNLCarry(new stzObject(content))
		
				ok
			else
				return AFalseObjectXT(This)
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
		--> 1

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

			if This.IsA(pcType) = 1

				if pcType = "number" or pcType = "stznumber"
					return This._NNLCarry(This.ToStzNumber())

				but pcType = "string" or pcType = "stzstring"
					return This._NNLCarry(This.ToStzString())

				but pcType = "char" or pcType = "stzchar"
					return This._NNLCarry(This.ToStzChar())

				but pcType = "list" or pcType = "stzlist"
					return This._NNLCarry(This.ToStzList())

				but pctype = "object" or pcType = "stzobject"
					return This
				else
					# a NON-core descriptor that held (:Word, :Char,
					# :Email...): continue on the typed object, context
					# carried -- this is what lets the grammatical form
					# TheWordQ("ring").IsAQ(:Word).WhichQ().HasQ()...
					# run as written (it used to fall through and
					# return NOTHING)
					content = This.Content()
					if isNumber(content)
						return This._NNLCarry(new stzNumber(content))
					but isString(content)
						return This._NNLCarry(new stzString(content))
					but isList(content)
						return This._NNLCarry(new stzList(content))
					ok
					return This
				ok

			else
				return AFalseObjectXT(This)
			ok

		def IsAQM(pcType)
			SetMainObject(This)
			return This.IsAQ(pcType)

		def IsAQMM(pcType)
			return This._NNLMain()

		def IsAM(pcType)
			SetMainObject(This)
			return This.IsA(pcType)

			def IsAMQ(pcType)
				SetMainObject(This)
				return This.IsAQ(pcType)

		def IsAMM(pcType)
			return This._NNLMain()

		#>

		#< @FunctionAlternativeForms

		def IsAn(pcType)
			return This.IsA(pcType)

			def IsAnQ(pcType)
				return This.IsAQ(pcType)

			def IsAnQM(pcType)
				return This._NNLMain()

		def IsAnM(pcType)
			SetMainObject(This)
			return THis.IsAn(pcType)

			def IsAnMQ(pcType)
				SetMainObject(This)
				return This.IsAnQ(pcType)

		def IsAnMM(pctype)
			return This._NNLMain()

		#--

		def AreA(pcType)
			return This.IsA(pcType)

			def AreAQ(pcType)
				return This.IsAQ(pcType)

			def AreAQM(pcType)
				return This._NNLMain()

		def AreAM(pcType)
			SetMainObject(This)
			return This.AreA(pcType)

			def AreAMQ(pcType)
				SetMainObject(This)
				return This.AreAQ(pcType)

		def AreAMM(pcType)
			return This._NNLMain()

		#--

		def AreAn(pcType)
			return This.IsA(pcType)

			def AreAnQ(pcType)
				return This.IsAQ(pcType)

			def AreAnQM(pcType)
				return This._NNLMain()

		def AreAnM(pcType)
			SetMainObject(This)
			return This.AreAn(pcType)

			def AreAnMQ(pcType)
				SetMainObject(This)
				return This.AreAnQ(pcType)

		def AreAnMM(pcType)
			return This._NNLMain()

		#--

		def IsThe(pcType)
			return This.IsA(pcType)

			def IsTheQ(pcType)
				return This.IsAQ(pcType)

			def IsTheQM(pcType)
				return This._NNLMain()

		def IsTheM(pcType)
			SetMainObject(This)
			return This.IsThe(pcType)

			def IsTheMQ(pcType)
				SetMainObject(This)
				return This.IsTheQ(pcType)

		def IsTheMM(pcType)
			return This._NNLMain()

		#--

		def AreThe(pcType)
			return This.IsA(pcType)

			def AreTheQ(pcType)
				return This.IsAQ(pcType)

			def AreTheQM(pcType)
				return This._NNLMain()

		def AreTheM(pcType)
			SetMainObject(This)
			return This.AreThe(pcType)

			def AreTheMQ(pcType)
				SetMainObject(This)
				return This.AreTheQ(pcType)

		def AreTheMM(pcType)
			return This._NNLMain()

		#>

	def Is(pcType)
		# Is(:StzString) et al: match the StzType directly (with or
		# without the stz prefix), then fall back to IsA.
		if isString(pcType)
			_kwIs_ = lower(pcType)
			if ring_left(_kwIs_, 1) = ":"
				_kwIs_ = StzMidToEnd(_kwIs_, 2)
			ok
			_tIs_ = lower(This.StzType())
			if _tIs_ = _kwIs_ return TRUE ok
			if _tIs_ = "stz" + _kwIs_ return TRUE ok
		ok
		return This.IsA(pcType)

		def IsQ(pcType)
			if This.Is(pcType) = 1

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
				return AFalseObjectXT(This)
			ok

		def IsQM(pcType)
			return This._NNLMain()

		def IsM(pcType)
			SetMainObject(This)
			return This.IsM(pcType)

			def IsMQ(pcType)
				SetMainObject(This)
				return This.IsQ(pcType)

		def IsMM(pcType)
			return This._NNLMain()

	def Are(pcType)

		/* Example

		? Q([ 10, 20, 30 ]).Are(:Numbers)

		--> 1
		*/
 
		if NOT This.IsAList()
			return 0
		ok

		if NOT ( @IsRingTypeInPlural(pcType) or @IsStzTypeInPlural(pcType) )
			StzRaise("Incorrect param type! pcType must be a Ring type or Softanza type in plural.")
		ok

		_cCode_ = '_bResult_ = This.IsListOf'+ pcType + '()'

		eval(_cCode_)
		return _bResult_

		#< @FunctionAlternativeForms

		def AreQ(pcType)

			if This.Are(pcType) = 1

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
				return AFalseObjectXT(This)
			ok

		def AreQM(pcType)
			return This._NNLMain()
			
		def AreM(pcType)
			SetMainObject(This)
			return This.Are(pcType)

			def AreMQ(pcType)
				SetMainObject(This)
				return This.AreQ(pcType)

		def AreMM(pcType)
			return This._NNLMain()

		#>

		def AreAll(pcType)
			return This.Are(pcType)

			def AreAllQ(pcType)
				return This.AreQ(pcType)

			def AreAllQM(pcType)
				return This._NNLMain()

		def AreAllM(pcType)
			SetMainObject(This)
			return this.AreAll(pcType)

			def AreAllMQ(pcType)
				SetMainObject(pcType)
				return This.AreAllQ(pcType)

		def AreAllMM(pcType)
			return This._NNLMain()

	def AreBothA(pcType)

		if NOT (This.StzType() = "stzlist" and This.NumberOfItems() = 2)
			return AFalseObjectXT(This)
		ok

		_item1_ = This.Content()[1]
		_item2_ = This.Content()[2]
		if isList(_item2_) and IsAndNamedParamList(_item2_)

			_item2_ = _item2_[2]
		ok

		This.UpdateWith([ _item1_, _item2_ ])

		return This.IsA(pcType)

		#< @FunctionFluentForm

		def AreBothAQ(pcType)

			if NOT (This.StzType() = "stzlist" and This.NumberOfItems() = 2)
				return AFalseObjectXT(This)
			ok
	
			_item1_ = This.Content()[1]
			_item2_ = This.Content()[2]
			if isList(_item2_) and IsAndNamedParamList(_item2_)
	
				_item2_ = _item2_[2]
			ok
	
			This.UpdateWith([ _item1_, _item2_ ])

			return This.AreQ(pcType)

		def AreBothAQM(pcType)
			return This._NNLMain()

		#>

		#< @FunctionAlternativeForms

		def AreBothAn(pcType)
			return This.AreBothA(pcType)

			def AreBothAnQ(pcType)
				return This.AreBothAQ(pcType)

			def AreBothAnQM(pcType)
				return This._NNLMain()

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
			return This._NNLMain()

		#--

		def BothAreA(pcType)
			return This.AreBothA(pcType)

			def BothAreAQ(pcType)
				return This.AreBothAQ(pcType)

			def BothAreAQM(pcType)
				return This._NNLMain()

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
			return This._NNLMain()

		#--

		def BothAreAn(pcType)
			return This.AreBothA(pcType)

			def BothAreAnQ(pcType)
				return This.AreBothAQ(pcType)

			def BothAreAnQM(pcType)
				return This._NNLMain()

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
			return This._NNLMain()

		#--

		def BothAre(pcType)
			return This.AreBoth(pcType)

			def BothAreQ(pcType)
				return This.AreBothQ(pcType)

			def BothAreQM(pcType)
				return This._NNLMain()

		def BothAreM(pcType)
			return this.AreBothM(pcType)

			def BothAreMQ(pcType)
				return This.AreBothMQ(pcType)

		def BothAreMM(pcType)
			return This._NNLMain()

		#--

		def AreTwo(pcType)
			return AreBothA(pcType)

			def AreTwoQ(pcType)
				return AreBothAQ(pcType)

			def AreTwoQM(pcType)
				return This._NNLMain()

		def AreTwoM(pcType)
			SetMainObject(This)
			return This.AreTwo(pcType)

			def AreTwoMQ(pcType)
				SetMainObject(This)
				return This.AreTwoM(pcType)

		def AreTwoMM(pcType)
			return This._NNLMain()

		#>

	def Which()
		return This

		def WichM()
			SetMainObject(This)
			return This

			def WichMQ()
				return This.WichM()
	
		def WichMM()
			return This._NNLMain()

		def WhichQ()
			return This.Which()

		def WhichQM()
			return This._NNLMain()

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
			return This._NNLMain()

		def ThatQ()
			return This

		def ThatQM()
			return This._NNLMain()

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
			return This._NNLMain()

		def WhichIsMM()
			return This._NNLMain()

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
			return This._NNLMain()

	def WhichAre()
		return This

		def WhichAreQ()
			return This.WhichAre()

		def WhichAreM()
			SetMainObject(This)
			return This

		def WhichAreMQ()
			return This._NNLMain()

		def WhichAreMM()
			return This._NNLMain()

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
			return This._NNLMain()

	def WhichAreBoth()
		_aContent_ = This.Content()
		if NOT (isList(_aList_) and len(_aList_) = 2)
			return AFalseObjectXT(This)
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
			return This._NNLMain()

		def WhichAreBothMM()
			return This._NNLMain()

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
			return This._NNLMain()

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
				return This._NNLMain()

		def WichAreBothMM()
			return This._NNLMain()

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
				return This._NNLMain()

		def WichBothAreMM()
			return This._NNLMain()

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
				return This._NNLMain()

		def WitchBothAreMM()
			return This._NNLMain()

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
				return This._NNLMain()

		def AndQ()
			return This

			def AndQM()
				return This._NNLMain()

			def AndMQ()
				SetMainObject()
				return This.AndQ()

		def AndThenM()
			SetMainObject()
			return This.AndThen()

		def AndThenMM()
			return This._NNLMain()

	def QM()
		return This._NNLMain() # Used in chains of truth

	def Having()
		return This

		def HavingQ()
			return This

		def HavingQM()
			return This._NNLMain()

		def HavingMQ()
			SetMainObject(This)
			return This.HavingQ()

		def HavingM()
			return This._NNLMain()
		
		#--

		def AndHaving()
			return This

		def AndHavingQ()
			return This

		def AndHavingQM()
			return This._NNLMain()

		def AndHavingMQ()
			SetMainObject(This)
			return This.AndHavingQ()

		def AndHavingM()
			return This._NNLMain()

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
			return This._NNLMain()

		def WithAMQ()
			SetMainObject(This)
			return This.WithAQ()

		def WithAM()
			return This._NNLMain()

	def WithQM()
		return This._NNLMain()

		def WithAQM()
			return This._NNLMain()
	
	def Only(value)
		This._NNLSetExpect(value, :Exactly, 0)
		return This

		def OnlyQ(value)
			return Only(value)

		def OnLyQM(value)
			_oM_ = This._NNLMain()
			_oM_._NNLSetExpect(value, :Exactly, 0)
			return _oM_

		def OnlyMQ(value)
			SetMainObject(This)
			return this.OnlyQ(value)

		def OnlyM(value)
			SetMainObject(This)
			return This.OnlyM(value)

		def OnlyMM(value)
			return This._NNLMain()

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
			return This._NNLMain()

	def Their()
		return This

		#< @FunctionFluentForm

		def TheirQ()
			return This

		def TheirQM()
			return This._NNLMain()
		
		#>

		def TheirM()
			SetMainObject(This)
			return This.Their()

			def TheirMQ()
				SetMainObject(This)
				return This.TheirQ()
	
		def TheirMM()
			return This._NNLMain()


		#< @FunctionAlternativeForms

		def AllTheir()
			return This

			def AllTheirQ()
				return This

			def AllTheirQM()
				return This._NNLMain()

			def AlltheirMQ()
				SetMainObject(This)
				return This.AlltheirQ()

		def Its()
			return This

			def ItsM()
				SetMainObject(This)
				return This.Its()

			def ItsMM()
				return This._NNLMain()

			def ItsQ()
				return This
	
			def ItsQM()
				return This._NNLMain()

			def ItsMQ()
				SetMainObject(This)
				return This.ItsQ()

		def His()
			return This

			def HisM()
				SetMainObject(This)
				return This

			def HisMM()
				return This._NNLMain()

			def HisQ()
				return This
	
			def HisQM()
				return This._NNLMain()

			def HisMQ()
				SetMainObject(This)
				return This.HisQ()

		def Her()
			return This

			def HerM()
				SetMainObject(This)
				return This

			def HerMM()
				return This._NNLMain()

			def HerQ()
				return This
	
			def HerQM()
				return This._NNLMain()

			def HerMQ()
				SetMainObject(This)
				return This.HerQ()

		def My()
			return This


			def MyM()
				SetMainObject(This)
				return This

			def MyMM()
				return This._NNLMain()

			def MyQ()
				return This
	
			def MyQM()
				return This._NNLMain()

			def MyMQ()
				SetMainObject(This)
				return This.MyQ()

		def Your()
			return This


			def YourM()
				SetMainObject(This)
				return This

			def YourMM()
				return This._NNLMain()

			def YourQ()
				return This
	
			def YourQM()
				return This._NNLMain()

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
			return This._NNLMain()

		def AsQ()
			return This

		def AsQM()
			return This._NNLMain()

		def AsMQ()
			SetMainObject(This)
			return This.AsM()

		#--

		def AsA()
			return This.As()

		def AsAM()
			return This.AsM()

		def AsAMM()
			return This._NNLMain()

		def AsAQ()
			return This.AsQ()

		def AsAQM()
			return This._NNLMain()

		def AsAMQ()
			return This.AsMQ()

		#--

		def AsThe()
			return This.As()

		def AstheM()
			return This.AsM()

		def AsTheMM()
			return This._NNLMain()

		def AsTheQ()
			return This.AsQ()

		def AsTheQM()
			return This._NNLMain()

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
			return This._NNLMain()

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
			return This._NNLMain()

		def MeQ()
			return This.Me()

		def MeQM()
			return This._NNLMain()

		def MeMQ()
			SetMainObject(This)
			return This.MeQ()

	def Mine()
		return This

		def MineM()
			SetMainObject(This)
			return This

		def MineMM()
			return This._NNLMain()

		def MineQ()
			return This.Mine()

		def MineQM()
			return This._NNLMain()

		def MineMQ()
			SetMainObject(This)
			return This.MineQ()

	def It()
		return This

		def ItM()
			SetMainObject(This)
			return This

		def ItMM()
			return This._NNLMain()

		def ItQ()
			return This.It()

		def ItQM()
			return This._NNLMain()

		def ItMQ()
			SetMainObject(This)
			return This.ItQ()

	def You()
		return This

		def YouM()
			SetMainObject(This)
			return This

		def YouMM()
			return This._NNLMain()

		def YouQ()
			return This.You()

		def YouQM()
			return This._NNLMain()

		def YouMQ()
			SetMainObject(This)
			return This.YouQ()

	def Yours()
		return This

		def YoursM()
			SetMainObject(This)
			return This

		def YoursMM()
			return This._NNLMain()

		def YoursQ()
			return This.Yours()

		def YoursQM()
			return This._NNLMain()

		def YoursMQ()
			SetMainObject(This)
			return This.YoursQ()

	def Him()
		return This

		def HimM()
			SetMainObject(This)
			return This

		def HimMM()
			return This._NNLMain()

		def HimQ()
			return This.Him()

		def HimQM()
			return This._NNLMain()

		def HimMQ()
			SetMainObject(This)
			return This.HimQ()

	def Has()
		return This

		def HasM()
			SetMainObject(This)
			return This

		def HasMM()
			return This._NNLMain()

		def HasQ()
			return This.Has()

		def HasQM()
			return This._NNLMain()

		def HasMQ()
			SetMainObject(This)
			return This.HasQ()

	def HasA()
		return This

		def HasAM()
			SetMainObject(This)
			return This

		def HasAMM()
			return This._NNLMain()

		def HasAQ()
			return This.HasA()

		def HasAQM()
			return This._NNLMain()

		def HasaMQ()
			SetMainObject(This)
			return This.HasAQ()

	def HasN(_n_)
		if CheckingParams()
			if NOT isNumber(_n_)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		This._NNLSetExpect(_n_, :Exactly, 0)
		return This

		def HasNM(_n_)
			if CheckingParams()
				if NOT isNumber(_n_)
					StzRaise("Incorrect param type! n must be a number.")
				ok
			ok
			SetMainObject(This)
			return This.HasN(_n_)

		def HasNMM()
			if CheckingParams()
				if NOT isNumber(_n_)
					StzRaise("Incorrect param type! n must be a number.")
				ok
			ok
			return This._NNLMain()

		def HasNQ(_n_)
			return This.HasN(_n_)

		def HasNQM(_n_)
			return This._NNLMain()

		def HasNMQ(_n_)
			SetMainObject(This)
			return This.HasNQ(_n_)

		#--

		def HasTheNumber(_n_)
			return This.HasN(_n_)

		def HasTheNumberM(_n_)
			SetMainObject(This)
			return This.HasTheNumber(_n_)

		def HasTheNumberMM(_n_)
			return This._NNLMain()

		def HasTheNumberQ(_n_)
			return This.HasTheNumber(_n_)

		def HasTheNumberQM(_n_)
			return This.HasTheNumberM(_n_)

		def HasTheNumberMQ(_n_)
			return This.HasTheNumberM(_n_)

	#==

	def M()
		SetMainObject(This)
		return This

	def MM()
		return This._NNLMain()

	def _(any)
		return LastValue()

		def _M()
			SetMainObject(This)
			return This._(any)

		def _MM()
			return This._NNLMain()

		def _Q(any)
			return Q( This._(any) )

		def _QM(any)
			return This._NNLMain()

		def _MQ(any)
			SetMainObject(This)
			return This._Q(any)

	#==

	def OfCS(_n_, pCaseSensitive)
		return This.IsEqualToCS(_n_, pCaseSensitive)

		def OfCSM(_n_, pCaseSensitive)
			SetMainObject(This)
			return This.OfCS(_n_, pCaseSensitive)

		def OfCSMM(_n_, pCaseSensitive)
			return This._NNLMain()

		def OfCSQ(_n_, pCaseSensitive)
			if This.IsEqualToCS(_n_, pCaseSensitive)
				return This
			else
				return AFalseObjectXT(This)
			ok

		def OfCSQM(_n_, pCaseSensitive)
			return This._NNLMain()

		def OfCSMQ(_n_, pCaseSensitive)
			SetMainObject(This)
			return This.OfCSQ(_n_, pCaseSensitive)

	def Of(_n_)
		return This.OfCS(_n_, 1)

		def OfM(_n_)
			return This.OfCSM(_n_, 1)

		def OfMM(_n_)
			return This.OfCSMM(_n_, 1)

		def OfQ(_n_)
			return This.OfCSQ(_n_, 1)

		def OfQM(_n_)
			return This._NNLMain()

		def OfMQ(_n_)
			return This.OfCSMQ(_n_, pCaseSensitive)
		
	#--

	def OfCSXT(_n_, cIgnored, pCaseSensitive)
		return This.OfCS(_n_, pCaseSensitive)

		def OfCSXTQ(_n_, cIgnored, pCaseSensitive)
			return This.OfCSQ(_n_, pCaseSensitive)

		def OfCSXTQM(_n_, cIgnored, pCaseSensitive)
			return This.OfCSQM(_n_, pCaseSensitive)

		def OfCSXTMQ(_n_, cIgnored, pCaseSensitive)
			return This.OfCSMQ(_n_, pCaseSensitive)

		def OfXTCS(_n_, cIgnored, pCaseSensitive)
			return This.OfCS(_n_, pCaseSensitive)

		def OfXTCSQ(_n_, cIgnored, pCaseSensitive)
			return This.OfCS(_n_, pCaseSensitive)

		def OfXTCSQM(_n_, cIgnored, pCaseSensitive)
			return This.OfCS(_n_, pCaseSensitive)

		def OfXTCSMQ(_n_, cIgnored, pCaseSensitive)
			return This.OfCS(_n_, pCaseSensitive)

	def OfXT(_n_, cIgnored)
		return This.OfCS(_n_, 1)

		def OfXTM(_n_, cIgnored)
			return This.OfCSM(_n_, 1)

		def OfXTMM(_n_, cIgnored)
			return This.OfCSMM(_n_, 1)

		def OfXTQ(_n_, cIgnored)
			return This.OfCSQ(_n_, 1)

		def OfXTQM(_n_, cIgnored)
			return This.OfCSXTQM(_n_, 1)

		def OfXTMQ(_n_, cIgnored)
			return This.OfCSXTMQ(_n_, 1)

	#==

	def OfCSB(_n_, pCaseSensitive)
		if Q(_n_).IsEqualToCS(LastValue(), pCaseSensitive)
			
			return 1
		else
			return 0
		ok

		def OfCSBM(_n_, pCaseSensitive)
			SetMainObject()
			return This.OfCSB(_n_, pCaseSensitive)

		def OfCSBMM(_n_, pCaseSensitive)
			return This._NNLMain()

		def OfCSMB(_n_, pCaseSensitive)
			SetMainObject(This)
			return This.OfCSB(_n_, pCaseSensitive)

		def OfCSBQ(_n_, pCaseSensitive)
			if This.OfCSB(_n_, pCaseSensitive) = 1
				return This
			else
				return AFalseObjectXT(This)
			ok

		def OfCSBQM(_n_, pCaseSensitive)
			SetMainObject(This)
			return This.OfCSBQ(_n_, pCaseSensitive)


		def OfCSBQMM(_n_, pCaseSensitive)
			return This._NNLMain()

	def OfBM(_n_)
		return This.OfCSBM(_n_, pCaseSensitive)

		def OfBMM(_n_)
			return This._NNLMain()

		def OfMB(_n_)
			return This.OfCSMB(_n_, 1)

		def OfBQ(_n_)
			return This.OfCSBQ(_n_, 1)

		def OfBQM(_n_)
			return This.OfCSBQM(_n_, 1)

		def OfBQMM(_n_)
			return This._NNLMain()

	#==

	def OfXTCSB(_n_, cIgnored, pCaseSensitive)
		return This.OfCSB(c, pCaseSensitive)

		def OfXTCSBM(_n_, cIgnored, pCaseSensitive)
			return This.OfCSBM(_n_, pCaseSensitive)

		def OfXTCSBMM(_n_, cIgnored, pCaseSensitive)
			return This._NNLMain()

		def OfXTCSMB(_n_, cIgnored, pCaseSensitive)
			return This.OfCSMB(_n_, pCaseSensitive)

		def OfXTCSBQ(_n_, cIgnored, pCaseSensitive)
			return This.OfCSBQ(_n_, pCaseSensitive)

		def OfXTCSBQM(_n_, cIgnored, pCaseSensitive)
			return This.OfCSBQM(_n_, pCaseSensitive)

		def OfXTCSBQMM(_n_, pCaseSensitive)
			return This._NNLMain()

	def OfXTBM(_n_)
		return This.OfXTCSB(_n_, cIgnored, 1)

		def OfXTBMM(_n_)
			return This._NNLMain()

		def OfXTMB(_n_)
			return This.OfXTCSMB(_n_, 1)

		def OfXTBQ(_n_)
			return This.OfXTCSBQ(_n_, 1)

		def OfXTBQM(_n_)
			return This.OfXTCSBQM(_n_, 1)

		def OfXTBQMM(_n_)
			return This._NNLMain()

	#==

	def IsEitherA(pcType1, pcType2)
		if isList(pcType2) and IsOrNamedParamList(pcType2)
			pcType2 = pcType2[2]
		ok

		if NOT ( isString(pcType1) and isString(pcType2) )
			StzRaise("Incorrect param type! pcType1 and pcType2 must be strings.")
		ok

		if This.IsA(pcType1) or This.IsA(pcType2)
			return 1
		else
			return 0
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
		if isList(pcType2) and IsNorNamedParamList(pcType2)
			pcType2 = pcType2[2]
		ok

		if NOT ( isString(pcType1) and isString(pcType2) )
			StzRaise("Incorrect param type! pcType1 and pcType2 must be strings.")
		ok

		if NOT This.IsA(pcType1) and
		   NOT This.IsA(pcType2)

			return 1
		else
			return 0
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
		if isList(pValue2) and IsOrNamedParamList(pValue2)
			pValue2 = pValue2[2]
		ok

		if This.IsAString()
			if BothAreStrings(pValue1, pValue2) and
			   ( This.String() = pValue1 or This.String() = pValue2 )

				return 1
			ok

		but This.IsANumber()

			if BothAreNumbers(pValue1, pValue2) and
			   ( This.Number() = pValue1 or This.Number() = pValue2 )
				return 1
			ok

		but This.IsAList()
			if isList(pValue1) and isList(pValue2) and
			   ( This.ListQ() = pValue1 or This.ListQ() = pValue2 )
				return 1
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
		return 1

		def IsAObject()
			return 1

	def IsANumber()
		return 0

	def IsAString()
		return 0

	def IsAList()
		return 0

	# IsStzType: when Content() is a string, answer "is this string the
	# name of a registered Softanza class?". Used by the return-type
	# routing in stzNumber.MultiplesUntilQRT etc. -- the user passes
	# :stzList / :stzListOfNumbers as the return type and the dispatch
	# validates it via Q(name).IsStzType().
	#
	# The recognised set covers every public Stz... class the library
	# ships. Names are matched case-insensitively to spare callers
	# the exact-casing burden.
	def IsStzType()
		_cIstContent_ = This.Content()
		if NOT isString(_cIstContent_)
			return 0
		ok
		_cIstName_ = lower(_cIstContent_)
		_acIstTypes_ = [
			"stzobject", "stznumber", "stzstring", "stzlist",
			"stzlistofnumbers", "stzlistofstrings", "stzlistofchars",
			"stzlistofbytes", "stzlistoflists", "stzlistofpairs",
			"stzlistofhashlists", "stzlistoftimelines",
			"stzlistofentities", "stzlist2d", "stzlistex",
			"stzhashlist", "stzpair", "stzpairofnumbers",
			"stzchar", "stzbyte", "stzdate", "stztime",
			"stzdatetime", "stzcalendar", "stzduration",
			"stztimeline", "stzcounter", "stzintseq",
			"stzregex", "stzhtml", "stzfile", "stzfolder",
			"stztable", "stztablex", "stzpivottable",
			"stzmatrex", "stzgrid", "stzgraph", "stzgraphquery",
			"stzgraphplanner", "stzknowledgegraph", "stzorgchart",
			"stzdiagram", "stztree", "stztext", "stzentity",
			"stzdataset", "stzdatawrangler", "stzcurrency",
			"stzlocale", "stzcountry", "stzuuid", "stzhexnumber",
			"stzbinarynumber", "stzoctalnumber"
		]
		if ring_find(_acIstTypes_, _cIstName_) > 0
			return 1
		ok
		return 0

		# Alias: IsStzClassName -- same predicate, narrative-friendly
		# spelling used by stzNaturalCode.QRT and stzHashList.ItemsZ.
		def IsStzClassName()
			return This.IsStzType()
	
	  #======================================#
	 #  REPEATING THE OBJECT VALUE N TIMES  #
	#======================================#

	def Repeat(_n_)

		if isList(_n_) and len(_n_) = 2 and
		   isNumber(_n_[1]) and isString(_n_[2]) and _n_[2] = :Times
			_n_ = _n_[1]
		ok

		return This.RepeatXT(:InList, _n_)

		#< @FunctionFluentForm

		def RepeatQ(_n_)
			return Q(This.Repeat(_n_))

		#>

		#< @FunctionAlternativeForms

		def RepeatNTimes(_n_)
			return This.Repeat(_n_)

			def RepeatNTimesQ(_n_)
				return This.RepeatQ(_n_)

		def Reproduce(_n_)
			return This.Repeat(_n_)

			def ReproduceQ(_n_)
				This.Reproduce(_n_)
				return This

		def ReproduceNTimes(_n_)
			return This.Repeat(_n_)

			def ReproduceNTimesQ(_n_)
				This.ReproduceNTimes(_n_)
				return This

		def CopyNTimes(_n_)
			return This.Repeat(_n_)

			def CopyNTimesQ(_n_)
				This.CopyNTimes(_n_)
				return This

		#>

	#--

	def Repeated(_n_)
		return This.Repeat(_n_)

		#< @FunctionAlternativeForms

		def RepeatedNTimes(_n_)
			return This.Repeated(_n_)

		def Reproduced(_n_)
			return This.Repeated(_n_)

		def ReproducedNTimes(_n_)
			return This.Repeated(_n_)

		def Copied(_n_)
			return This.Repeated(_n_)

		def CopiedNTimes(_n_)
			return This.Repeated(_n_)

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

				], 0) )

			StzRaise("Incorrect param! pIn must be a string representing one of" +
				 "these Softanza types: :String, :List, :Pair, :ListOfNumbers, :ListOfStrings, " +
				 ":ListOfLists, :ListOfPairs, :Grid, :Table, and :StzTable.")
		ok

		if isList(pnSize) and
			( Q(pnSize).IsOfSizeNamedParam() or
			  Q(pnSize).IsSizeNamedParam() )

			pnSize = pnSize[2]
		ok

		if NOT ( isNumber(pnSize) or (isList(pnSize) and IsPairOfNumbers(pnSize)) )
			StzRaise("Incorrect param type! pnSize must be a number.")
		ok

		# Doing the job

		# Only a real stzNumber repeats its numeric _value_; a stzString
		# holding "5" keeps the STRING "5" (the :ListOfNumbers /
		# :ListOfStrings kinds do the explicit coercion below).
		_value_ = ""
		if This.StzType() = :stzNumber
			if This.IsInteger()
				_value_ = This.NumericValue()
			else
				_value_ = This.StringValue()
			ok
		else
			_value_ = This.Content()
		ok

		if StzFindFirst([ :List, :InList, :AList, :InAList ], pIn) > 0
	
			_aResult_ = []
			for i = 1 to pnSize
				_aResult_ + _value_
			next
			return _aResult_

		but StzFindFirst([ :Pair, :InPair, :APair, :InAPair ], pIn) > 0

			_aResult_ = []
			for i = 1 to 2
				_aResult_ + _value_
			next
			return _aResult_

		but StzFindFirst([ :ListOfNumbers, :InListOfNumbers,
				:AListOfNumbers, :InAListOfNumbers ], pIn) > 0

			_aResult_ = []
			for i = 1 to pnSize
				_aResult_ + Q(_value_).ToNumber()
			next
			return _aResult_

		but StzFindFirst([ :ListOfStrings, :InListOfStrings,
				:AListOfStrings, :InAListOfStrings ], pIn) > 0

			_aResult_ = []
			for i = 1 to pnSize
				_aResult_ + Q(_value_).Stringified()
			next
			return _aResult_

		but StzFindFirst([ :ListOfLists, :InListOfLists,
				:AListOfLists, :InAListOfLists ], pIn) > 0
	
			_aResult_ = []
			for i = 1 to pnSize
				_aResult_ + [ _value_ ]
			next
			return _aResult_

		but StzFindFirst([ :ListOfPairs, :InListOfPairs,
				:AListOfPairs, :InAListOfNPairs ], pIn) > 0
	
			_aResult_ = []
			for i = 1 to pnSize
				_aResult_ + [ _value_, _value_ ]
			next
			return _aResult_

		but StzFindFirst([ :String, :InString, :AString, :InAString ], pIn) > 0

			_cResult_ = ""
			for i = 1 to pnSize
				_cResult_ += _value_
			next
			return _cResult_

		but StzFindFirst([ :Grid, :InGrid, :AGrid, :InAGrid ], pIn) > 0

			_aResult_ = StzGridQ([ pnSize[1], pnSize[2] ]).
					ReplaceAllQ(:With = _value_).
					Content()

			return _aResult_

		but StzFindFirst([ :Table, :InTable, :ATable, :InATable ], pIn) > 0

			_aResult_ = StzTableQ([ pnSize[1], pnSize[2] ]).FillQ(_value_).Content()
			return _aResult_

		but StzFindFirst([ :StzTable, :InStzTable, :InAStzTable ], pIn) > 0

			_oResult_ = StzTableQ([ pnSize[1], pnSize[2] ]).FillQ(_value_)
			return _oResult_

		else
			StzRaise("Unsupported type of container! Allowed containers you can repeat " +
				 "the _value_ in are: :List, :Pair, :ListOfLists, :ListOfPairs, :String, :Grid, :Table, and :StzTable.")
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
				_cNumber_ = StzReplace(This.Content(), "_", "")
				return 0+ _cNumber_

			else
				StzRaise("Incorrect value! The string do not contain a well formed number.")
			ok

		else
			StzRaise("Can't cast the object into a number.")
		ok

	def Numberified()
		# Detect actual underlying content type rather than relying on
		# the IsA{Number,String,List} dispatch -- those return 0 in the
		# bare stzObject ancestor for subclasses (e.g. stzList) that
		# don't override them, which would route a real list value to
		# the catch-all "can't be numberified" error.

		_cNfContent_ = This.Content()

		if isNumber(_cNfContent_)
			return _cNfContent_

		but isString(_cNfContent_)
			if This.IsNumberInString()
				_cNfNumber_ = StzReplace(_cNfContent_, "_", "")
				return 0+ _cNfNumber_

			else
				StzRaise("Incorrect value! The string do not contain a well formed number.")
			ok

		but isList(_cNfContent_)
			_anNfResult_ = []
			_nNfLen_ = len(_cNfContent_)
			for _i_ = 1 to _nNfLen_
				_xNfItem_ = _cNfContent_[_i_]
				if isNumber(_xNfItem_)
					_anNfResult_ + _xNfItem_
				but isString(_xNfItem_)
					_anNfResult_ + (0+ StzReplace(_xNfItem_, "_", ""))
				else
					StzRaise("Incorrect value! List element is neither number nor numeric string.")
				ok
			next
			return _anNfResult_

		else
			StzRaise("Incorrect param type! Objects can't be numberified.")
		ok

		# Aliases used by narrative tests. Numberify == Numberified
		# semantically (we're already returning a fresh value, not
		# mutating). NumberifyQ wraps in stzList for chains.
		def Numberify()
			return This.Numberified()

		def NumberifyQ()
			return new stzList( This.Numberified() )

		def NumberifiedQ()
			return new stzList( This.Numberified() )

		def Numbrify()
			return This.Numberified()

	  #------------------------------------------------------------------#
	 #  CASTING THE OBJECT VALUE INTO A NUMBER UNDER A GIVEN CONDITION  #
	#==================================================================#

	def ToNumberW(pcCode)

		if isList(pcCode) and IsUsingNamedParamList(pcCode)
			pcCode = pcCode[2]
		ok

		if NOT isString(pcCode)
			StzRaise("Incorrect param type! pcCode must be a string.")
		ok

		@number = 0
		if This.IsANumber()
			@number = This.Number()
		ok
		
		_cCode_ = Q(pcCode).
			RemoveBoundsQ('"').
			RemoveThisFirstCharQ("{").
			RemoveThisLastCharQ("}").
			Trimmed()
		
		if NOT Q(_cCode_).StartsWithOneOfTheseCS([
			"@number =", "@number +=", "@number=", "@number+=" ], 0 )

			StzRaise("Syntax error! pcCode must start with '@number =' or '@number +='.")
		ok

		if Q(_cCode_).StartsWithEitherCS( "@number=", :Or = "@number =", 0 )
			# EXAMPLE
			# ? Q([ "a", "b", "c" ]).ToNumberW('{ @number = len(@list) }')
			#--> 3

			@list = This.Content()
			@string = This.Content()

			eval(_cCode_)

		else
			# CASE += is used on a list of items or a string

			# EXAMPLE
			# ? Q([ "Me", "and", "You!" ]).ToNumberWXT('{ @number += len(@item) }')
			#--> 9
			@number = 0

			if This.IsANumber()
				eval(_cCode_)

			but This.IsAString()
				_nLenStr_ = This.NumberOfChars()
				for @i = 1 to _nLenStr_
					@char = This.Char(@i)
					eval(_cCode_)
				next

			but This.IsAList()
				_aList_ = This.List()
				_nLenList_ = len(_aList_)

				for @i = 1 to _nLenList_ 
					@item = This.Item(@i)
					eval(_cCode_)
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

	def FindFirstNOccurrencesCS(_n_, pStrOrItem, pCaseSensitive)

		_anResult_ = This.FindFirstNOccurrencesSTCS(_n_, pStrOrItem, 1, pCaseSensitive)
		return _anResult_

		#< @FunctionAlternativeForms

		def FindNFirstOccurrencesCS(_n_, pStrOrItem, pCaseSensitive)
			return This.FindFirstNOccurrencesCS(_n_, pStrOrItem, pCaseSensitive)

		#--

		def PositionsOfFirstNOccurrencesCS(_n_, pStrOrItem, pCaseSensitive)
			return This.FindFirstNOccurrencesCS(_n_, pStrOrItem, pCaseSensitive)

		def PositionsOfNFirstOccurrencesCS(_n_, pStrOrItem, pCaseSensitive)
			return This.FindFirstNOccurrencesCS(_n_, pStrOrItem, pCaseSensitive)

		#--

		def FirstNCS(_n_, pStrOrItem, pCaseSensitive)
			return This.FindFirstNOccurrencesCS(_n_, pStrOrItem, pCaseSensitive)

		def NFirstCS(_n_, pStrOrItem, pCaseSensitive)
			return This.FindFirstNOccurrencesCS(_n_, pStrOrItem, pCaseSensitive)

		#--

		def FindFirstNCS(_n_, pStrOrItem, pCaseSensitive)
			return This.FindFirstNOccurrencesCS(_n_, pStrOrItem, pCaseSensitive)

		def FindNFirstCS(_n_, pStrOrItem, pCaseSensitive)
			return This.FindFirstNOccurrencesCS(_n_, pStrOrItem, pCaseSensitive)

		#--

		def FirstNOccurrencesCS(_n_, pStrOrItem, pCaseSensitive)
			return This.FindFirstNOccurrencesCS(_n_, pStrOrItem, pCaseSensitive)

		def NFirstOccurrencesCS(_n_, pStrOrItem, pCaseSensitive)
			return This.FindFirstNOccurrencesCS(_n_, pStrOrItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstNOccurrences(_n_, pStrOrItem)
		return This.FindFirstNOccurrencesCS(_n_, pStrOrItem, 1)

		#< @FunctionAlternativeForms

		def FindNFirstOccurrences(_n_, pStrOrItem)
			return This.FindFirstNOccurrences(_n_, pStrOrItem)

		#--

		def PositionsOfFirstNOccurrences(_n_, pStrOrItem)
			return This.FindFirstNOccurrences(_n_, pStrOrItem)

		def PositionsOfNFirstOccurrences(_n_, pStrOrItem)
			return This.FindFirstNOccurrences(_n_, pStrOrItem)

		#--

		def FirstN(_n_, pStrOrItem)
			return This.FindFirstNOccurrences(_n_, pStrOrItem)

		def NFirst(_n_, pStrOrItem)
			return This.FindFirstNOccurrences(_n_, pStrOrItem)

		#--

		def FindFirstN(_n_, pStrOrItem)
			return This.FindFirstNOccurrencesCS(_n_, pStrOrItem)

		def FindNFirst(_n_, pStrOrItem)
			return This.FindFirstNOccurrences(_n_, pStrOrItem)

		#--

		def FirstNOccurrences(_n_, pStrOrItem)
			return This.FindFirstNOccurrences(_n_, pStrOrItem)

		def NFirstOccurrences(_n_, pStrOrItem)
			return This.FindFirstNOccurrences(_n_, pStrOrItem)

		#>

	   #--------------------------------------------------------#
	  #  FINDING FIRST N OCCURRENCES OF A SUBSTRING OR ITEM    #
	 #  STARTING AT A GIVEN POSITION -- EXTENDTED             #
	#--------------------------------------------------------#

	def FindFirstNOccurrencesSTCS(_n_, pStrOrItem, pnStartingAt, pCaseSensitive)

		if isList(pStrOrItem) and
		   IsOneOfTheseNamedParamsList(pStrOrItem, [ :Of, :OfSubString, :OfItem ])

			pStrOrItem = pStrOrItem[2]
		ok

		if isList(pnStartingAt) and IsStartingAtNamedParamList(pnstartingAt)
			pnStartingAt = pnStartingAt[2]
		ok

		_anPos_ = This.SectionQ(pnStartingAt, :Last).
				FindAllCS(pStrOrItem, pCaseSensitive)

		_anResult_ = []
		if len(_anPos_) > 0
			_anResult_ = Q(_anPos_).FirstNItemsQRT(_n_, :stzListOfNumbers).AddedToEach(pnStartingAt-1)
		ok

		return _anResult_

		#< @FunctionAlternativeForms

		def FindNFirstOccurrencesSTCS(_n_, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindFirstNOccurrencesSTCS(_n_, pStrOrItem, pnStartingAt, pCaseSensitive)

		#--

		def PositionsOfFirstNOccurrencesSTCS(_n_, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindFirstNOccurrencesSTCS(_n_, pStrOrItem, pnStartingAt, pCaseSensitive)

		def PositionsOfNFirstOccurrencesSTCS(_n_, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindFirstNOccurrencesSTCS(_n_, pStrOrItem, pnStartingAt, pCaseSensitive)

		#--

		def FirstNSTCS(_n_, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindFirstNOccurrencesSTCS(_n_, pStrOrItem, pnStartingAt,  pCaseSensitive)

		def NFirstSTCS(_n_, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindFirstNOccurrencesSTCS(_n_, pStrOrItem, pnStartingAt, pCaseSensitive)

		#--

		def FindFirstNSTCS(_n_, pStrOrItem,pnStartingAt,  pCaseSensitive)
			return This.FindFirstNOccurrencesSTCS(_n_, pStrOrItem, pnStartingAt, pCaseSensitive)

		def FindNFirstSTCS(_n_, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindFirstNOccurrencesSTCS(_n_, pStrOrItem, pnStartingAt, pCaseSensitive)

		#--

		def FirstNOccurrencesSTCS(_n_, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindFirstNOccurrencesSTCS(_n_, pStrOrItem, pnStartingAt, pCaseSensitive)

		def NFirstOccurrencesSTCS(_n_, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindFirstNOccurrencesSTCS(_n_, pStrOrItem, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindFirstNOccurrencesST(_n_, pcStr, pnStartingAt)
		return This.FindFirstNOccurrencesSTCS(_n_, pcStr, pnStartingAt, 1)

		#< @FunctionAlternativeForms

		def FindNFirstOccurrencesST(_n_, pStrOrItem, pnStartingAt)
			return This.FindFirstNOccurrencesST(_n_, pStrOrItem, pnStartingAt)

		#--

		def PositionsOfFirstNOccurrencesST(_n_, pStrOrItem, pnStartingAt)
			return This.FindFirstNOccurrencesST(_n_, pStrOrItem, pnStartingAt)

		def PositionsOfNFirstOccurrencesST(_n_, pStrOrItem, pnStartingAt)
			return This.FindFirstNOccurrencesST(_n_, pStrOrItem, pnStartingAt)

		#--

		def FirstNST(_n_, pStrOrItem, pnStartingAt)
			return This.FindFirstNOccurrencesST(_n_, pStrOrItem, pnStartingAt)

		def NFirstST(_n_, pStrOrItem, pnStartingAt)
			return This.FindFirstNOccurrencesST(_n_, pStrOrItem, pnStartingAt)

		#--

		def FindFirstNST(_n_, pStrOrItem,pnStartingAt)
			return This.FindFirstNOccurrencesST(_n_, pStrOrItem, pnStartingAt)

		def FindNFirstST(_n_, pStrOrItem, pnStartingAt)
			return This.FindFirstNOccurrencesST(_n_, pStrOrItem, pnStartingAt)

		#--

		def FirstNOccurrencesST(_n_, pStrOrItem, pnStartingAt)
			return This.FindFirstNOccurrencesST(_n_, pStrOrItem, pnStartingAt)

		def NFirstOccurrencesST(_n_, pStrOrItem, pnStartingAt)
			return This.FindFirstNOccurrencesST(_n_, pStrOrItem, pnStartingAt)

		#>

	  #---------------------------------------------------#
	 #   FINDING THE LAST N OCCURRENCES OF A SUBSTRING   #
	#---------------------------------------------------#

	def FindLastNOccurrencesCS(_n_, pStrOrItem, pCaseSensitive)

		_anResult_ = This.FindLastNOccurrencesSTCS(_n_, pStrOrItem, :StartingAT = 1, pCaseSensitive)
		return _anResult_

		#< @FunctionAlternativeForms

		def FindNLastOccurrencesCS(_n_, pStrOrItem, pCaseSensitive)
			return This.FindLastNOccurrencesCS(_n_, pStrOrItem, pCaseSensitive)

		#--

		def PositionsOfLastNOccurrencesCS(_n_, pStrOrItem, pCaseSensitive)
			return This.FindLastNOccurrencesCS(_n_, pStrOrItem, pCaseSensitive)

		def PositionsOfNLastOccurrencesCS(_n_, pStrOrItem, pCaseSensitive)
			return This.FindLastNOccurrencesCS(_n_, pStrOrItem, pCaseSensitive)

		#--

		def LastNCS(_n_, pStrOrItem, pCaseSensitive)
			return This.FindLastNOccurrencesCS(_n_, pStrOrItem, pCaseSensitive)

		def NLastCS(_n_, pStrOrItem, pCaseSensitive)
			return This.FindLastNOccurrencesCS(_n_, pStrOrItem, pCaseSensitive)

		#--

		def FindLastNCS(_n_, pStrOrItem, pCaseSensitive)
			return This.FindLastNOccurrencesCS(_n_, pStrOrItem, pCaseSensitive)

		def FindNLastCS(_n_, pStrOrItem, pCaseSensitive)
			return This.FindLastNOccurrencesCS(_n_, pStrOrItem, pCaseSensitive)

		#--

		def LastNOccurrencesCS(_n_, pStrOrItem, pCaseSensitive)
			return This.FindLastNOccurrencesCS(_n_, pStrOrItem, pCaseSensitive)

		def NLastOccurrencesCS(_n_, pStrOrItem, pCaseSensitive)
			return This.FindLastNOccurrencesCS(_n_, pStrOrItem, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastNOccurrences(_n_, pStrOrItem)
		return This.FindLastNOccurrencesCS(_n_, pStrOrItem, 1)

		#< @FunctionAlternativeForms

		def FindNLastOccurrences(_n_, pStrOrItem)
			return This.FindLastNOccurrences(_n_, pStrOrItem)

		#--

		def PositionsOfLastNOccurrences(_n_, pStrOrItem)
			return This.FindLastNOccurrences(_n_, pStrOrItem)

		def PositionsOfNLastOccurrences(_n_, pStrOrItem)
			return This.FindLastNOccurrences(_n_, pStrOrItem)

		#--

		def LastN(_n_, pStrOrItem)
			return This.FindLastNOccurrences(_n_, pStrOrItem)

		def NLast(_n_, pStrOrItem)
			return This.FindLastNOccurrences(_n_, pStrOrItem)

		#--

		def FindLastN(_n_, pStrOrItem)
			return This.FindLastNOccurrencesCS(_n_, pStrOrItem)

		def FindNLast(_n_, pStrOrItem)
			return This.FindLastNOccurrences(_n_, pStrOrItem)

		#--

		def LastNOccurrences(_n_, pStrOrItem)
			return This.FindLastNOccurrences(_n_, pStrOrItem)

		def NLastOccurrences(_n_, pStrOrItem)
			return This.FindLastNOccurrences(_n_, pStrOrItem)

		#>

	   #------------------------------------------------------------#
	  #  FINDING LAST N OCCURRENCES OF A SUBSTRING/ITEM STARTING   #
	 #  AT A GIVEN POSITION -- EXTENDTED                          #
	#------------------------------------------------------------#

	def FindLastNOccurrencesSTCS(_n_, pStrOrItem, pnStartingAt, pCaseSensitive)
		if CheckingParams()
			if isList(pStrOrItem) and
			   IsOneOfTheseNamedParamsList(pStrOrItem, [ :Of, :OfSubString ])
	
				pStrOrItem = pStrOrItem[2]
			ok
	
			if isList(pnStartingAt) and IsStartingAtNamedParamList(pnstartingAt)
				pnStartingAt = pnStartingAt[2]
			ok
		ok

		_anPos_ = This.SectionQ(pnStartingAt, :Last).
				FindAllCS(pStrOrItem, pCaseSensitive)

		_anResult_ = Q(_anPos_).LastNItemsQRT(_n_, :stzListOfNumbers).AddedToEach(pnStartingAt-1)

		return _anResult_

		#< @FunctionAlternativeForms

		def FindNLastOccurrencesSTCS(_n_, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindLastNOccurrencesSTCS(_n_, pStrOrItem, pnStartingAt, pCaseSensitive)

		#--

		def PositionsOfLastNOccurrencesSTCS(_n_, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindLastNOccurrencesSTCS(_n_, pStrOrItem, pnStartingAt, pCaseSensitive)

		def PositionsOfNLastOccurrencesSTCS(_n_, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindLastNOccurrencesSTCS(_n_, pStrOrItem, pnStartingAt, pCaseSensitive)

		#--

		def LastNSTCS(_n_, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindLastNOccurrencesSTCS(_n_, pStrOrItem, pnStartingAt,  pCaseSensitive)

		def NLastSTCS(_n_, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindLastNOccurrencesSTCS(_n_, pStrOrItem, pnStartingAt, pCaseSensitive)

		#--

		def FindLastNSTCS(_n_, pStrOrItem,pnStartingAt,  pCaseSensitive)
			return This.FindLastNOccurrencesSTCS(_n_, pStrOrItem, pnStartingAt, pCaseSensitive)

		def FindNLastSTCS(_n_, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindLastNOccurrencesSTCS(_n_, pStrOrItem, pnStartingAt, pCaseSensitive)

		#--

		def LastNOccurrencesSTCS(_n_, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindLastNOccurrencesSTCS(_n_, pStrOrItem, pnStartingAt, pCaseSensitive)

		def NLastOccurrencesSTCS(_n_, pStrOrItem, pnStartingAt, pCaseSensitive)
			return This.FindLastNOccurrencesSTCS(_n_, pStrOrItem, pnStartingAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def FindLastNOccurrencesST(_n_, pcStr, pnStartingAt)
		return This.FindLastNOccurrencesSTCS(_n_, pcStr, pnStartingAt, 1)

		#< @FunctionAlternativeForms

		def FindNLastOccurrencesST(_n_, pStrOrItem, pnStartingAt)
			return This.FindLastNOccurrencesST(_n_, pStrOrItem, pnStartingAt)

		#--

		def PositionsOfLastNOccurrencesST(_n_, pStrOrItem, pnStartingAt)
			return This.FindLastNOccurrencesST(_n_, pStrOrItem, pnStartingAt)

		def PositionsOfNLastOccurrencesST(_n_, pStrOrItem, pnStartingAt)
			return This.FindLastNOccurrencesST(_n_, pStrOrItem, pnStartingAt)

		#--

		def LastNST(_n_, pStrOrItem, pnStartingAt)
			return This.FindLastNOccurrencesST(_n_, pStrOrItem, pnStartingAt)

		def NLastST(_n_, pStrOrItem, pnStartingAt)
			return This.FindLastNOccurrencesST(_n_, pStrOrItem, pnStartingAt)

		#--

		def FindLastSTN(_n_, pStrOrItem,pnStartingAt)
			return This.FindLastNOccurrencesST(_n_, pStrOrItem, pnStartingAt)

		def FindNLastST(_n_, pStrOrItem, pnStartingAt)
			return This.FindLastNOccurrencesST(_n_, pStrOrItem, pnStartingAt)

		#--

		def LastNOccurrencesST(_n_, pStrOrItem, pnStartingAt)
			return This.FindLastNOccurrencesST(_n_, pStrOrItem, pnStartingAt)

		def NLastOccurrencesST(_n_, pStrOrItem, pnStartingAt)
			return This.FindLastNOccurrencesST(_n_, pStrOrItem, pnStartingAt)

		#>

	  #===========#
	 #   MISC.   #
	#===========#

	def IsOneOfThese(paList)
		return ListContains(paList, This.Object())

		def IsNotOneOfThese(paList)
			return NOT This.IsOneOfThese(paList)

	def Methods()
		return ring_methods(This)

	def NumberOfMethods()
		return len(ring_methods(This))

		def CountMethods()
			return len(ring_methods(This))

		def HowManyMethods()
			return len(ring_methods(This))

	def Attributes()
		return ring_attributes(This)

	def NumberOfAttribytes()
		return len(ring_attributes(This))

		def CountAttributes()
			return len(ring_attributes(This))

		def HowManyAttributes()
			return len(ring_attributes(This))

	def ClassName()
		return "stzobject"

		def StzClassName()
			return This.ClassName()

		def StzClass()
			return This.ClassName()

	def IsText()
		return 0

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

		_cCode_ = '_bOk_ = (' + pcCondition + ')'
		eval(_cCode_)

		if _bOk_
			return This
		else
			# An error message is returned:
			#--> Error (R13) : Object is required 
		ok

	def IsSingle()
		if This.IsAList() and This.Size() = 1
			return 1
		else
			return 0
		ok

	# Swapping the content of the stzObject with an other stzObject

	def SwapWith(pOtherStzObject)

		if CheckingParams()

			if NOT @IsStzObject(pOtherStzObject)
				StzRaise("Incorrect param type! pOtherStzObject must be a stzObject.")
			ok
	
		ok

		_oThis_ = This.Content()
		_oOther_ = pOtherStzObject.Content()

		This.UpdateWith(_oOther_)
		pOtherStzObject.UpdateWith(_oThis_)

		def SwapWithQ(pOtherStzObject)
			This.SwapWith(pOtherStzObject)
			return This

		def SwapContentWith(pOtherStzObject)
			This.SwapWith(pOtherStzObject)

			def SwapContentWithQ(pOtherStzObject)
				return This.SwapWithQ(pOtherStzObject)

	def @IsNeither(pcType1, pcType2)
		if CheckingParams()
			if isList(pcType1) and IsOfTypeNamedParamList(pcType1)
				pcType1 = pcType1[2]
			ok

			if isList(pcType2) and IsNorNamedParamList(pcType2)
				pcType2 = pcType2[2]
			ok

			if NOT @BothAreStrings(pcType1, pcType2)
				StzRaise("Incorrect param type! pcType1 and pcType2 must both be strings.")
			ok
		ok

		#TODO // Add other Stz types

		_bOfType1_ = 0
		_bOfType2_ = 0

		if pcType1 = :String or pcType1 = :AString
			_bOfType1_ = This.IsStzString()

		but pcType1 = :Char or pcType1 = :AChar
			_bOfType1_ = This.IsStzChar()

		but pcType1 = :Number or pcType1 = :ANumber
			_bOfType1_ = This.IsStzNumber()

		but pcType1 = :List or pcType1 = :AList
			_bOfType1_ = This.IsStzList()

		but pcType1 = :Object or pcType1 = :AnObject
			_bOfType1_ = This.IsStzObject()
		ok

		if pcType2 = :String or pcType2 = :AString
			_bOfType2_ = This.IsStzString()

		but pcType2 = :Char or pcType2 = :AChar
			_bOfType2_ = This.IsStzChar()

		but pcType2 = :Number or pcType2 = :ANumber
			_bOfType2_ = This.IsStzNumber()

		but pcType2 = :List or pcType2 = :AList
			_bOfType2_ = This.IsStzList()

		but pcType2 = :Object or pcType2 = :AnObject
			_bOfType2_ = This.IsStzObject()
		ok

		if NOT _bOfType1_ and NOT _bOfType2_
			return 1
		else
			return 0
		ok

		def @IsNeitheOfType(pcType1, pcType2)
			return This.IsNeither(pcType1, pcType2)

	def LoopNTimes(_n_)
		for @i = 1 to _n_
			// Do nothing
		next

		def LoopNTimesQ(_n_)
			This.LoopNTimes(_n_)
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

		? o1.Occurs( :Before = "TWO", :In = "***ONE***TWO***")	#--> TRUE
		? o1.Occurs( :After = "TWO", :In = "***ONE***TWO***")	#--> FALSE

		? o1.Occurs( :Before = "two", :In = [ "***", "ONE", "***", "TWO", "***" ])
		#--> TRUE
		? o1.Occurs( :After = "TWO", :In = [ "***", "ONE", "***", "TWO", "***" ])
		#--> FALSE

		*/
		_cBeforeOrAfter_ = ""

		if isList(pcBeforeOrAfter) and IsBeforeOrAfterNamedParamList(pcBeforeOrAfter)
			_cTemp_ = pcBeforeOrAfter[1]

			pcBeforeOrAfter = pcBeforeOrAfter[2]
		ok

		if isList(pIn) and IsInNamedParamList(pIn)
			pIn = pIn[2]
		ok

		if NOT ( isString(pIn) or isList(pIn) )
			StzRaise("Incorrect param type! pcIn must be a string or list.")
		ok
	
		_bCaseSensitive_ = CaseSensitive(pCaseSensitive)

		if isString(pIn)
			_oStr_ = new stzString(pIn)
	
			_nThis_  = _oStr_.FindFirstCS( This.Content(), _bCaseSensitive_ )
			_nOther_ = _oStr_.FindFirstCS( pcBeforeOrAfter, _bCaseSensitive_ )

		but isList(pIn)
			if Q(pIn).IsListOfStrings()
				_oListStr_ = new stzListOfStrings(pIn)

				_nThis_  = _oListStr_.FindFirstCS( This.Content(), _bCaseSensitive_ )
				_nOther_ = _oListStr_.FindFirstCS( pcBeforeOrAfter, _bCaseSensitive_ )
			else

				if _bCaseSensitive_ = 1
					_oList_ = new stzList(pIn)
	
					_nThis_  = _oList_.FindFirst( This.Content() )
					_nOther_ = _oList_.FindFirst( pcBeforeOrAfter )
						
				else
					_oList_ = new stzList(pIn)
					_oList_.Lowercase()

					_nThis_  = _oList_.FindFirst( This.ContentQ().Lowercased() )
					_nOther_ = _oList_.FindFirst( pcBeforeOrAfter )

				ok
			ok

		ok

		_bResult_ = 0

		if _cTemp_ = :After
			_bResult_ = _nThis_ > _nOther_

		but _cTemp_ = :Before
			_bResult_ = _nThis_ < _nOther_
		ok

		return _bResult_

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
		return This.OccursCS(pcBeforeOrAfter, pIn, 1)

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
		return This.OccursBeforeCS( pcSubStr, pIn, 1 )

	   #----------------------------------------------#
	  #   CHECKING IF OBJECT OCCURES ÙŽAFTER A GIVEN   #
	 #   VALUE IN THE GIVEN STRING OR LIST          #
	#----------------------------------------------#

	def OccursAfterCS( pcSubStr, pIn, pCaseSensitive )
		return This.OccursCS( :After = pcSubStr, pIn, pCaseSensitive)

	#-- WITHOUT CASESENSITIVTY

	def OccursAfter(pcSubStr, pIn)
		return This.OccursAfterCS( pcSubStr, pIn, 1 )

	   #---------------------------------------------------------#
	  #   CHECKING IF OBJECT OCCURES BETWEEN TWO GIVEN VALUES   #
	 #  IN THE GIVEN STRING OR LIST                            #
	#---------------------------------------------------------#

	def OccursBetweenCS( pValue1, pValue2, pIn, pCaseSensitive )

		if This.OccursCS( :After = pValue1, pIn, pCaseSensitive) and
		   This.OccursCS( :Before = pValue2, pIn, pCaseSensitive)

			return 1
		else
			return 0
		ok

	#-- WITHOUT CASESENSITIVTY

	def OccursBetween( pValue1, pValue2, pIn )
		return This.OccursBetweenCS( pValue1, pValue2, pIn, 1 )

	  #-------------------------------------------------------------------#
	 #   CHECKING IF OBJECT OCCURES N TIMES IN AN OTHER STRING OR LIST   #
	#-------------------------------------------------------------------#

	def OccursNTimesCS( _n_, pIn, pCaseSensitive )

		if isList(pIn) and IsInNamedParamList(pIn)
			pIn = pIn[2]
		ok

		if NOT ( isString(pIn) or isList(pIn) )
			StzRaise("Incorrect param type! pcIn must be a string or list.")
		ok
	
		_bCaseSensitive_ = CaseSensitive(pCaseSensitive)

		_nOccurrence_ = 0

		if isString(pIn)
			_oStr_ = new stzString(pIn)
			_nOccurrence_  = _oStr_.NumberOfOccurrenceCS( This.Content(), _bCaseSensitive_ )

		but isList(pIn)
			if Q(pIn).IsListOfStrings()
				_oListStr_ = new stzListOfStrings(pIn)
				_nOccurrence_  = _oListStr_.NumberOfOccurrenceCS( This.Content(), _bCaseSensitive_ )

			else
				if _bCaseSensitive_ = 1
					_oList_ = new stzList(pIn)
					_nOccurrence_  = _oList_.NumberOfOccurrence( This.Content() )
		
				else
					_oList_ = new stzList(pIn)
					_oList_.Lowercase()

					_nThis_  = _oList_.FindFirst( This.ContentQ().Lowercased() )
					_nOccurrence_  = _oList_.NumberOfOccurrence( This.Content() )
		
				ok
			ok

		ok

		_bResult_ = 0

		if _nOccurrence_ = _n_
			_bResult_ = 1
		ok

		return _bResult_

	#-- WITHOUT CASESENSITIVITY

	def OccursNTimes( _n_, pIn )
		return This.OccursNTimesCS( _n_, pIn, 1 )

	   #----------------------------------------------------#
	  #  CHECKING IF STRING OCCURS FOR THE NTH TIME,       #
	 #  IN AN OTHER STRING OR LIST, AT A GIVEN POSITION   #
	#----------------------------------------------------#

	def OccursForTheNthTimeCS(_n_, pIn, pnAt, pCaseSensitive)
		/* EXAMPLE

		? Q("*").OccursForTheNthTime( 1, :In = "a*b*c*d", :AtPosition = 2 )
		#--> TRUE

		? Q("*").OccursForTheNthTime( 3, :In = "a*b*c*d", :AtPosition = 6 )
		#--> TRUE

		*/

		if isList(pIn) and IsInNamedParamList(pIn)
			pIn = pIn[2]
		ok

		if NOT ( isString(pIn) or isList(pIn) )
			StzRaise("Incorrect param type! pcIn must be a string or list.")
		ok

		if isList(pnAt) and IsAtOrAtPositionNamedParamList(pnAt)
			pnAt = pnAt[2]
		ok
	
		if NOT isNumber(pnAt)
			StzRaise("Incorrect param type! pAt must be a number.")
		ok

		_bCaseSensitive_ = CaseSensitive(pCaseSensitive)

		_nNthOccurrence_ = 0

		if isString(pIn)
			_oStr_ = new stzString(pIn)
			_nNthOccurrence_ = _oStr_.NthOccurrenceCS( _n_, This.String(), _bCaseSensitive_ )
	
		but isList(pIn)
			if Q(pIn).IsListOfStrings()
				_oListStr_ = new stzListOfStrings(pIn)
				_nNthOccurrence_  = _oListStr_.NthOccurrenceCS( _n_, This.String(), _bCaseSensitive_ )

			else
				if _bCaseSensitive_ = 1
					_oList_ = new stzList(pIn)
					_nNthOccurrence_  = _oList_.NthOccurrence( _n_, This.String() )
		
				else
					_oList_ = new stzList(pIn)
					_oList_.Lowercase()

					_nNthOccurrence_  = _oList_.NthOccurrence( _n_, This.String() )
		
				ok
			ok

		ok


		if _nNthOccurrence_ = pnAt
			return 1

		else
			return 0
		ok

		#< @FunctionAlternativeForm

		def OccursForTheNthTimeAtCS(_n_, pIn, pnAt, pCaseSensitive)
			return This.OccursForTheNthTimeCS(_n_, pIn, pnAt, pCaseSensitive)

		#>

	#-- WITHOUT CASESENSITIVITY

	def OccursForTheNthTime(_n_, pIn, pnAt)
		return This.OccursForTheNthTimeCS(_n_, pIn, pnAt, 1)

		#< @FunctionAlternativeForm

		def OccursForTheNthTimeAt(_n_, pIn, pnAt)
			return This.OccursForTheNthTime(_n_, pIn, pnAt)

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
		return This.OccursForTheFirstTimeCS(pIn, pnAt, 1)

		def OccursForTheFirstTimeAt(pIn, pnAt)
			return This.OccursForTheFirstTime(pIn, pnAt)

	   #----------------------------------------------------#
	  #  CHECKING IF STRING OCCURS FOR THE LAST TIME,      #
	 #  IN AN OTHER STRING OR LIST, AT A GIVEN POSITION   #
	#----------------------------------------------------#

	def OccursForTheLastTimeCS(pIn, pnAt, pCaseSensitive)
		if isList(pIn) and IsInNamedParamList(pIn)
			pIn = pIn[2]
		ok

		_obj_ = Q(pIn)
		_nPos_ = _obj_.FindLastCS(This.Content(), pCaseSensitive)
		nLast = _obj_.NumberOfOccurrenceCS(This.Content(), pCaseSensitive)

		return This.OccursForTheNthTimeCS(nLast, pIn, _nPos_, pCaseSensitive)

		def OccursForTheLastTimeAtCS(pIn, pnAt, pCaseSensitive)
			return This.OccursForTheLastTimeCS(pIn, pnAt, pCaseSensitive)

	#-- WITHOUT CASESENSITIVITY

	def OccursForTheLastTime(pIn, pnAt)
		return This.OccursForTheLastTimeCS(pIn, pnAt, 1)

		def OccursForTheLastTimeAt(pIn, pnAt)
			return This.OccursForTheLastTime(pIn, pnAt)

	  #---------------------------------------------------------------#
	 #  GETTING THE SIZE OF THE OBJECT ~> THE SIZE OF ITS CONTENT()  #
	#---------------------------------------------------------------#

	def Size()
		_aContent_ = This.Content()
		_nResult_ = 0

		if isNumber(_aContent_)
			_nResult_ = StzNumberQ(_aContent_).Size()

		but isString(_aContent_)
			_nResult_ = len(_aContent_)

		but isList(_aContent_)
			_nResult_ = len(_aContent_)

		ok

		return _nResult_

	def SizeInBytes()
		_aValues_ = []
		_acAttributes_ = ring_attributes(This)
		_nLen_ = len(_acAttributes_)

		for i = 1 to _nLen_
			_cCode_ = '_value_ = This.' + _acAttributes_[i]
			eval(_cCode_)
			_aValues_ + _value_
		next

		return @MemorySizeInBytes(_aValues_)		

		return _nResult_

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
		_aValues_ = []
		_acAttributes_ = ring_attributes(This)
		_nLen_ = len(_acAttributes_)

		for i = 1 to _nLen_
			_cCode_ = '_value_ = This.' + _acAttributes_[i]
			eval(_cCode_)
			_aValues_ + _value_
		next

		return @MemorySizeInBytes32(_aValues_)		

		return _nResult_

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
		_aValues_ = []
		_acAttributes_ = ring_attributes(This)
		_nLen_ = len(_acAttributes_)

		for i = 1 to _nLen_
			_cCode_ = '_value_ = This.' + _acAttributes_[i]
			eval(_cCode_)
			_aValues_ + _value_
		next

		return @MemorySizeInBytes64(_aValues_)		

		return _nResult_

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
		_aValues_ = []
		_acAttributes_ = ring_attributes(This)
		_nLen_ = len(_acAttributes_)

		for i = 1 to _nLen_
			_cCode_ = '_value_ = This.' + _acAttributes_[i]
			eval(_cCode_)
			_aValues_ + _value_
		next

		return @ContentSizeInBytes(_aValues_)

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
			return 0
		ok

		if @IsNamedObject(pOtherObject) and @IsNamedObject(pOtherObject) and
		   This.VarName() = pOtherObject.VarName()

			return 1

		else
			return 0
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
		if KeepingObjectHistoryXT() = 1
			return This.HistoricValuesXT()
		ok

		_aResult_ = _aHisto
		_aHisto = []
		return _aResult_
		
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
		if KeepingExecutionTime() = 0
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
		return ListContains(paList, This.Content())

		def Inn(paList)
			return This.ExistsIn(paList)


	  #================================================================#
	 #  NNL 2.0 -- THE NEAR-NATURAL LANGUAGE DEVICE LAYER (RENOVATED)  #
	#================================================================#
	# doc/design/NNL_REVIEW.md is the contract. Hand-written here: the
	# accountable mini-dispatcher, the expectation comparator, the grammar
	# particles that were missing, the COMPARATIVE determiners, the
	# CONDITIONAL MOOD, and ORDINAL REFERENCE. The noun surface
	# (VowelN / VowelNB / VowelsB / ...) is GENERATED from the semantic
	# lexicon between the <nnl-generated-surface> markers further down.

	# --- the accountable dynamic call (the seed of the P3 dispatcher):
	# exact method -> call; else resolve the stem through the ONE lexicon
	# (morphology included); else REFUSE with a suggestion. Silent
	# absorb-anything typo tolerance is gone by design.

	def _NNLCall(pcMethod, paParams)
		_cM_ = StzLower(ring_trim(pcMethod))
		if StzFindFirst(ring_methods(This), _cM_) = 0
			_cId_ = StzResolveSemantic(_cM_)
			_bGot_ = FALSE
			if _cId_ != ""
				_nOps_ = ring_len($aSemanticOperations)
				for _i_ = 1 to _nOps_
					if $aSemanticOperations[_i_][:semantic_id] = _cId_ and
					   HasKey($aSemanticOperations[_i_], :stz_method)
						_cCand_ = lower($aSemanticOperations[_i_][:stz_method])
						if StzFindFirst(ring_methods(This), _cCand_) > 0
							_cM_ = _cCand_
							_bGot_ = TRUE
						ok
						exit
					ok
				next
			ok
			if NOT _bGot_
				_cSugg_ = StzSuggestWord("en", pcMethod)
				_cMsg_ = "NNL: this " + This.StzType() + " does not understand '" + pcMethod + "'."
				if _cSugg_ != ""
					_cMsg_ += " Did you mean '" + _cSugg_ + "'?"
				ok
				StzRaise(_cMsg_)
			ok
		ok
		_cCode_ = "_vNNL_ = This." + _cM_ + "("
		_nP_ = ring_len(paParams)
		for _i_ = 1 to _nP_
			_cCode_ += @@(paParams[_i_])
			if _i_ < _nP_
				_cCode_ += ", "
			ok
		next
		_cCode_ += ")"
		eval(_cCode_)
		return _vNNL_

	# run one ACTION given naturally: :Uppercase, "remove duplicates",
	# or [ :Replace, "a", "b" ] -- the conditional mood's executor
	def _NNLDo(pAction)
		if isString(pAction)
			return This._NNLCall(pAction, [])
		but isList(pAction) and ring_len(pAction) > 0 and isString(pAction[1])
			_aPrm_ = []
			_nA_ = ring_len(pAction)
			for _i_ = 2 to _nA_
				_aPrm_ + pAction[_i_]
			next
			return This._NNLCall(pAction[1], _aPrm_)
		ok
		StzRaise("NNL: an action must be a name or [ name, params... ].")

	# --- P2: the chain-scoped context machinery -----------------------
	# A determiner sets the expectation ON the object it returns; a device
	# that returns a NEW object carries the context over (_NNLCarry); the
	# *QM recalls read the chain-local main first. Globals stay mirrored
	# so legacy code and the detached console surface keep working.

	def SetNNLMain(poObj)
		@oNNLMain = poObj

	def NNLMainRaw()
		return @oNNLMain

	def _NNLMain()
		if isObject(@oNNLMain)
			return @oNNLMain
		ok
		return This._NNLMain()

	def _NNLSetExpect(pVal, pcMode, pnTol)
		@pNNLExpect = pVal
		@cNNLExpectMode = pcMode
		@nNNLExpectTol = pnTol
		# mirror the globals (SetLastValue resets the global mode, so the
		# mode is written AFTER it)
		SetLastValue(pVal)
		$cStzExpectMode = pcMode
		$nStzExpectTol = pnTol

	def _NNLExpectValue()
		if @cNNLExpectMode != ""
			return @pNNLExpect
		ok
		return LastValue()

	def _NNLCarry(poNew)
		if isObject(poNew)
			if isObject(@oNNLMain)
				poNew.SetNNLMain(@oNNLMain)
			ok
			if @cNNLExpectMode != ""
				poNew._NNLSetExpect(@pNNLExpect, @cNNLExpectMode, @nNNLExpectTol)
			ok
		ok
		return poNew

	# --- counting through a noun (guarded, accountable)

	def _NNLNounCount(pcMethod)
		if StzFindFirst(ring_methods(This), StzLower(pcMethod)) > 0
			eval("_nNNL_ = This." + StzLower(pcMethod) + "()")
			return _nNNL_
		ok
		# SELECTIONAL ATTACHMENT (anaphora without markers): the current
		# object cannot answer this noun -- if the chain's SUBJECT can,
		# attach there, exactly as a listener resolves "...a length of 4
		# and only 1 vowel" (lengths have no vowels, so the vowel belongs
		# to the word). Deterministic order: nearest referent first (the
		# branch above), the subject second, refusal third.
		if isObject(@oNNLMain)
			if StzFindFirst(ring_methods(@oNNLMain), StzLower(pcMethod)) > 0
				eval("_nNNL_ = @oNNLMain." + StzLower(pcMethod) + "()")
				return _nNNL_
			ok
		ok
		StzRaise("NNL: a " + This.StzType() + " cannot count '" +
			StzLower(pcMethod) + "' -- and neither can the chain subject.")

	# --- the expectation comparator: compares an actual count to the
	# expectation register per the active COMPARATIVE MODE, and records
	# its explanation (WhyB) -- the ellipsis device, generalized

	def _NNLExpectCompare(nActual)
		_pExp_ = LastValue()
		_cMode_ = $cStzExpectMode
		_nTolR_ = $nStzExpectTol
		if @cNNLExpectMode != ""
			_pExp_ = @pNNLExpect
			_cMode_ = @cNNLExpectMode
			_nTolR_ = @nNNLExpectTol
		ok
		_bYes_ = FALSE
		_cExp_ = @@(_pExp_)
		if _cMode_ = :Exactly
			_bYes_ = ( nActual = _pExp_ )
		but _cMode_ = :AtLeast
			_bYes_ = ( nActual >= _pExp_ )
		but _cMode_ = :AtMost
			_bYes_ = ( nActual <= _pExp_ )
		but _cMode_ = :MoreThan
			_bYes_ = ( nActual > _pExp_ )
		but _cMode_ = :LessThan
			_bYes_ = ( nActual < _pExp_ )
		but _cMode_ = :About
			_nTol_ = _nTolR_
			if _nTol_ < 1
				_nTol_ = _pExp_ * _nTol_
			ok
			_bYes_ = ( nActual >= (_pExp_ - _nTol_) and nActual <= (_pExp_ + _nTol_) )
		but _cMode_ = :Between
			_bYes_ = ( nActual >= _pExp_[1] and nActual <= _pExp_[2] )
			_cExp_ = "between " + _pExp_[1] + " and " + _pExp_[2]
		ok
		if _bYes_
			@cNNLWhy = "yes: expected " + lower("" + _cMode_) + " " +
				_cExp_ + ", found " + nActual
			$cStzLastWhyB = @cNNLWhy
			return 1
		ok
		@cNNLWhy = "no: expected " + lower("" + _cMode_) + " " +
			_cExp_ + ", found " + nActual
		$cStzLastWhyB = @cNNLWhy
		return 0

	def _NNLCountIs(pcMethod)
		return This._NNLExpectCompare(This._NNLNounCount(pcMethod))

	# --- value agreement: the RESULT of a noun equals the remembered value
	def _NNLValueIs(pcMethod)
		_vNNL_ = This._NNLCall(pcMethod, [])
		if Q(_vNNL_).IsEqualTo(This._NNLExpectValue())
			@cNNLWhy = "yes: " + StzLower(pcMethod) + " equals the expected value"
			$cStzLastWhyB = @cNNLWhy
			return 1
		ok
		@cNNLWhy = "no: " + StzLower(pcMethod) + " is " + @@(_vNNL_) +
			", expected " + @@(This._NNLExpectValue())
		$cStzLastWhyB = @cNNLWhy
		return 0

	# CHAIN-LOCAL explanations, in the stzChainOfValue naming grammar
	# (WhyChainStopped / WhyCodeNotYetExecuted): Why + subject + past
	# verb, always about something NOT proceeding; the reason lives ON
	# the object -- never on a process global (two interleaved chains
	# would lie to each other). Successes are not explained -- the
	# archive never explained them either.

	def WhyCheckFailed()
		if @cNNLWhy = ""
			return "no check has been made on this object yet"
		ok
		if StzLeft(@cNNLWhy, 4) = "yes:"
			return "the last check did not fail"
		ok
		return @cNNLWhy

	def WhyStopped()
		# a live object means the chain did NOT stop -- answer politely,
		# exactly like the archived "Chain is not stopped!"
		return "the chain is not stopped"

	# --- grammar particles that were missing (pure pass-throughs)

	def AnQ()
		return This

	def AlsoQ()
		return This

	def UnitQ(pUnit)
		# unit annotation: ...ALengthQ().OfQ(4).UnitQ(:Letters) -- says
		# WHAT the 4 counts; semantically inert, linguistically load-
		# bearing. (A method named Q() would shadow the global Q() for
		# every child class -- the documented ring_len() trap -- hence UnitQ.)
		return This

	# --- the article device, generic: "a length" of ANY object

	def ALengthN()
		if StzFindFirst(ring_methods(This), "numberofchars") > 0
			return This.NumberOfChars()
		but StzFindFirst(ring_methods(This), "numberofitems") > 0
			return This.NumberOfItems()
		but StzFindFirst(ring_methods(This), "numberofdigits") > 0
			return This.NumberOfDigits()
		ok
		StzRaise("NNL: a " + This.StzType() + " has no length to speak of.")

		def ALength()
			return This.ALengthN()

		def ALengthQ()
			return This._NNLCarry(new stzNumber(This.ALengthN()))

		def ALengthNB()
			return This._NNLExpectCompare(This.ALengthN())

	# --- COMPARATIVE DETERMINERS (new devices): degree words for the
	# expectation register. Only() said "exactly"; language also says
	# "at least", "at most", "more than", "about" (vagueness!), and
	# "between". Each returns This (chain on) or MainObject (QM recall).

	def Exactly(n)
		This._NNLSetExpect(n, :Exactly, 0)
		return This

		def ExactlyQ(n)
			return This.Exactly(n)

		def ExactlyQM(n)
			_oM_ = This._NNLMain()
			_oM_._NNLSetExpect(n, :Exactly, 0)
			return _oM_

	def AtLeast(n)
		This._NNLSetExpect(n, :AtLeast, 0)
		return This

		def AtLeastQ(n)
			return This.AtLeast(n)

		def AtLeastQM(n)
			_oM_ = This._NNLMain()
			_oM_._NNLSetExpect(n, :AtLeast, 0)
			return _oM_

	def AtMost(n)
		This._NNLSetExpect(n, :AtMost, 0)
		return This

		def AtMostQ(n)
			return This.AtMost(n)

		def AtMostQM(n)
			_oM_ = This._NNLMain()
			_oM_._NNLSetExpect(n, :AtMost, 0)
			return _oM_

	def MoreThan(n)
		This._NNLSetExpect(n, :MoreThan, 0)
		return This

		def MoreThanQ(n)
			return This.MoreThan(n)

		def MoreThanQM(n)
			_oM_ = This._NNLMain()
			_oM_._NNLSetExpect(n, :MoreThan, 0)
			return _oM_

	def LessThan(n)
		This._NNLSetExpect(n, :LessThan, 0)
		return This

		def LessThanQ(n)
			return This.LessThan(n)

		def LessThanQM(n)
			_oM_ = This._NNLMain()
			_oM_._NNLSetExpect(n, :LessThan, 0)
			return _oM_

	def About(n)
		This._NNLSetExpect(n, :About, 0.1)
		return This

		def AboutQ(n)
			return This.About(n)

		def AboutQM(n)
			_oM_ = This._NNLMain()
			_oM_._NNLSetExpect(n, :About, 0.1)
			return _oM_

		def AboutXT(n, nTol)
			This._NNLSetExpect(n, :About, nTol)
			return This

	# named BetweenN (not Between) -- stzString owns Between(sub1, sub2)
	# for text extraction; the N marks the NUMBER expectation
	def BetweenN(n1, n2)
		This._NNLSetExpect([ n1, n2 ], :Between, 0)
		return This

		def BetweenNQ(n1, n2)
			return This.BetweenN(n1, n2)

		def BetweenNQM(n1, n2)
			_oM_ = This._NNLMain()
			_oM_._NNLSetExpect([ n1, n2 ], :Between, 0)
			return _oM_

	# --- CONDITIONAL MOOD (new device): the chain branches on its own
	# truth. On a live object the premise held: IfSo RUNS, Otherwise
	# skips. On a false premise (stzFalseObject) IfSo skips and
	# Otherwise recovers the origin object and runs on it.
	#   Q("ring").IsAQ(:String).IfSo(:Uppercase).Otherwise(:Trim)

	def IfSo(pAction)
		This._NNLDo(pAction)
		return This

		def IfSoQ(pAction)
			return This.IfSo(pAction)

	def Otherwise(pAction)
		return This

		def OtherwiseQ(pAction)
			return This

	# --- ORDINAL REFERENCE (new device): "the second word", "the last
	# vowel" -- definite reference into a plural noun, stzOrdinal wired.

	def TheNth(n, pcNoun)
		_aNNL_ = This._NNLCall(pcNoun, [])
		if isList(_aNNL_) and n >= 1 and n <= ring_len(_aNNL_)
			return _aNNL_[n]
		ok
		StzRaise("NNL: there is no " + Ordinal(n) + " " +
			StzLower("" + pcNoun) + " here.")

		def TheNthQ(n, pcNoun)
			return This._NNLCarry(Q(This.TheNth(n, pcNoun)))

	def TheFirst(pcNoun)
		return This.TheNth(1, pcNoun)

		def TheFirstQ(pcNoun)
			return This._NNLCarry(Q(This.TheFirst(pcNoun)))

	def TheLast(pcNoun)
		_aNNL_ = This._NNLCall(pcNoun, [])
		if isList(_aNNL_) and ring_len(_aNNL_) > 0
			return _aNNL_[ring_len(_aNNL_)]
		ok
		StzRaise("NNL: there is no last " + StzLower("" + pcNoun) + " here.")

		def TheLastQ(pcNoun)
			return This._NNLCarry(Q(This.TheLast(pcNoun)))

	# <nnl-generated-surface>
	# GENERATED from the semantic lexicon (scripts: scratchpad gen_nnl_surface.py;
	# see doc/design/NNL_REVIEW.md). One entry per countable noun the library
	# knows: <Noun>N (count), <Noun>NQ, <Noun>NB (count vs the expectation
	# register), <Noun>NBQ (monadic), and where the plural op exists <Nouns>B /
	# <Nouns>BQ (value agreement). All delegate to the hand-written engine
	# above; a child class overriding any name wins automatically. Do not
	# edit by hand -- regenerate.

	def ByteN()
		return This._NNLNounCount("numberofbytes")
	def ByteNQ()
		return This._NNLCarry(new stzNumber(This._NNLNounCount("numberofbytes")))
	def ByteNB()
		return This._NNLCountIs("numberofbytes")
	def ByteNBQ()
		if This._NNLCountIs("numberofbytes") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_
	def BytesB()
		return This._NNLValueIs("bytes")
	def BytesBQ()
		if This._NNLValueIs("bytes") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def CharN()
		return This._NNLNounCount("numberofchars")
	def CharNQ()
		return This._NNLCarry(new stzNumber(This._NNLNounCount("numberofchars")))
	def CharNB()
		return This._NNLCountIs("numberofchars")
	def CharNBQ()
		if This._NNLCountIs("numberofchars") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_
	def CharsB()
		return This._NNLValueIs("chars")
	def CharsBQ()
		if This._NNLValueIs("chars") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ClassN()
		return This._NNLNounCount("numberofclasses")
	def ClassNQ()
		return This._NNLCarry(new stzNumber(This._NNLNounCount("numberofclasses")))
	def ClassNB()
		return This._NNLCountIs("numberofclasses")
	def ClassNBQ()
		if This._NNLCountIs("numberofclasses") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_
	def ClassesB()
		return This._NNLValueIs("classes")
	def ClassesBQ()
		if This._NNLValueIs("classes") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def DecimalN()
		return This._NNLNounCount("numberofdecimals")
	def DecimalNQ()
		return This._NNLCarry(new stzNumber(This._NNLNounCount("numberofdecimals")))
	def DecimalNB()
		return This._NNLCountIs("numberofdecimals")
	def DecimalNBQ()
		if This._NNLCountIs("numberofdecimals") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_
	def DecimalsB()
		return This._NNLValueIs("decimals")
	def DecimalsBQ()
		if This._NNLValueIs("decimals") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def DigitN()
		return This._NNLNounCount("numberofdigits")
	def DigitNQ()
		return This._NNLCarry(new stzNumber(This._NNLNounCount("numberofdigits")))
	def DigitNB()
		return This._NNLCountIs("numberofdigits")
	def DigitNBQ()
		if This._NNLCountIs("numberofdigits") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_
	def DigitsB()
		return This._NNLValueIs("digits")
	def DigitsBQ()
		if This._NNLValueIs("digits") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def DuplicatedItemN()
		return This._NNLNounCount("numberofduplicateditems")
	def DuplicatedItemNQ()
		return This._NNLCarry(new stzNumber(This._NNLNounCount("numberofduplicateditems")))
	def DuplicatedItemNB()
		return This._NNLCountIs("numberofduplicateditems")
	def DuplicatedItemNBQ()
		if This._NNLCountIs("numberofduplicateditems") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_
	def DuplicatedItemsB()
		return This._NNLValueIs("duplicateditems")
	def DuplicatedItemsBQ()
		if This._NNLValueIs("duplicateditems") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def DuplicateN()
		return This._NNLNounCount("numberofduplicates")
	def DuplicateNQ()
		return This._NNLCarry(new stzNumber(This._NNLNounCount("numberofduplicates")))
	def DuplicateNB()
		return This._NNLCountIs("numberofduplicates")
	def DuplicateNBQ()
		if This._NNLCountIs("numberofduplicates") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_
	def DuplicatesB()
		return This._NNLValueIs("duplicates")
	def DuplicatesBQ()
		if This._NNLValueIs("duplicates") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def DuplicationN()
		return This._NNLNounCount("numberofduplications")
	def DuplicationNQ()
		return This._NNLCarry(new stzNumber(This._NNLNounCount("numberofduplications")))
	def DuplicationNB()
		return This._NNLCountIs("numberofduplications")
	def DuplicationNBQ()
		if This._NNLCountIs("numberofduplications") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_
	def DuplicationsB()
		return This._NNLValueIs("duplications")
	def DuplicationsBQ()
		if This._NNLValueIs("duplications") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def EmptyLineN()
		return This._NNLNounCount("numberofemptylines")
	def EmptyLineNQ()
		return This._NNLCarry(new stzNumber(This._NNLNounCount("numberofemptylines")))
	def EmptyLineNB()
		return This._NNLCountIs("numberofemptylines")
	def EmptyLineNBQ()
		if This._NNLCountIs("numberofemptylines") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IntegerN()
		return This._NNLNounCount("numberofintegers")
	def IntegerNQ()
		return This._NNLCarry(new stzNumber(This._NNLNounCount("numberofintegers")))
	def IntegerNB()
		return This._NNLCountIs("numberofintegers")
	def IntegerNBQ()
		if This._NNLCountIs("numberofintegers") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_
	def IntegersB()
		return This._NNLValueIs("integers")
	def IntegersBQ()
		if This._NNLValueIs("integers") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ItemN()
		return This._NNLNounCount("numberofitems")
	def ItemNQ()
		return This._NNLCarry(new stzNumber(This._NNLNounCount("numberofitems")))
	def ItemNB()
		return This._NNLCountIs("numberofitems")
	def ItemNBQ()
		if This._NNLCountIs("numberofitems") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_
	def ItemsB()
		return This._NNLValueIs("items")
	def ItemsBQ()
		if This._NNLValueIs("items") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ItemsUN()
		return This._NNLNounCount("numberofitemsu")
	def ItemsUNQ()
		return This._NNLCarry(new stzNumber(This._NNLNounCount("numberofitemsu")))
	def ItemsUNB()
		return This._NNLCountIs("numberofitemsu")
	def ItemsUNBQ()
		if This._NNLCountIs("numberofitemsu") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def LargestN()
		return This._NNLNounCount("numberoflargest")
	def LargestNQ()
		return This._NNLCarry(new stzNumber(This._NNLNounCount("numberoflargest")))
	def LargestNB()
		return This._NNLCountIs("numberoflargest")
	def LargestNBQ()
		if This._NNLCountIs("numberoflargest") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_
	def LargestB()
		return This._NNLValueIs("largest")
	def LargestBQ()
		if This._NNLValueIs("largest") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def LeadingCharN()
		return This._NNLNounCount("numberofleadingchars")
	def LeadingCharNQ()
		return This._NNLCarry(new stzNumber(This._NNLNounCount("numberofleadingchars")))
	def LeadingCharNB()
		return This._NNLCountIs("numberofleadingchars")
	def LeadingCharNBQ()
		if This._NNLCountIs("numberofleadingchars") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_
	def LeadingCharsB()
		return This._NNLValueIs("leadingchars")
	def LeadingCharsBQ()
		if This._NNLValueIs("leadingchars") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def LeadingItemN()
		return This._NNLNounCount("numberofleadingitems")
	def LeadingItemNQ()
		return This._NNLCarry(new stzNumber(This._NNLNounCount("numberofleadingitems")))
	def LeadingItemNB()
		return This._NNLCountIs("numberofleadingitems")
	def LeadingItemNBQ()
		if This._NNLCountIs("numberofleadingitems") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_
	def LeadingItemsB()
		return This._NNLValueIs("leadingitems")
	def LeadingItemsBQ()
		if This._NNLValueIs("leadingitems") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def LetterN()
		return This._NNLNounCount("numberofletters")
	def LetterNQ()
		return This._NNLCarry(new stzNumber(This._NNLNounCount("numberofletters")))
	def LetterNB()
		return This._NNLCountIs("numberofletters")
	def LetterNBQ()
		if This._NNLCountIs("numberofletters") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_
	def LettersB()
		return This._NNLValueIs("letters")
	def LettersBQ()
		if This._NNLValueIs("letters") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def LevelN()
		return This._NNLNounCount("numberoflevels")
	def LevelNQ()
		return This._NNLCarry(new stzNumber(This._NNLNounCount("numberoflevels")))
	def LevelNB()
		return This._NNLCountIs("numberoflevels")
	def LevelNBQ()
		if This._NNLCountIs("numberoflevels") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def LineN()
		return This._NNLNounCount("numberoflines")
	def LineNQ()
		return This._NNLCarry(new stzNumber(This._NNLNounCount("numberoflines")))
	def LineNB()
		return This._NNLCountIs("numberoflines")
	def LineNBQ()
		if This._NNLCountIs("numberoflines") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_
	def LinesB()
		return This._NNLValueIs("lines")
	def LinesBQ()
		if This._NNLValueIs("lines") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ListN()
		return This._NNLNounCount("numberoflists")
	def ListNQ()
		return This._NNLCarry(new stzNumber(This._NNLNounCount("numberoflists")))
	def ListNB()
		return This._NNLCountIs("numberoflists")
	def ListNBQ()
		if This._NNLCountIs("numberoflists") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_
	def ListsB()
		return This._NNLValueIs("lists")
	def ListsBQ()
		if This._NNLValueIs("lists") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def MarkerN()
		return This._NNLNounCount("numberofmarkers")
	def MarkerNQ()
		return This._NNLCarry(new stzNumber(This._NNLNounCount("numberofmarkers")))
	def MarkerNB()
		return This._NNLCountIs("numberofmarkers")
	def MarkerNBQ()
		if This._NNLCountIs("numberofmarkers") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_
	def MarkersB()
		return This._NNLValueIs("markers")
	def MarkersBQ()
		if This._NNLValueIs("markers") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def MarquerN()
		return This._NNLNounCount("numberofmarquers")
	def MarquerNQ()
		return This._NNLCarry(new stzNumber(This._NNLNounCount("numberofmarquers")))
	def MarquerNB()
		return This._NNLCountIs("numberofmarquers")
	def MarquerNBQ()
		if This._NNLCountIs("numberofmarquers") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_
	def MarquersB()
		return This._NNLValueIs("marquers")
	def MarquersBQ()
		if This._NNLValueIs("marquers") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def NamedObjectN()
		return This._NNLNounCount("numberofnamedobjects")
	def NamedObjectNQ()
		return This._NNLCarry(new stzNumber(This._NNLNounCount("numberofnamedobjects")))
	def NamedObjectNB()
		return This._NNLCountIs("numberofnamedobjects")
	def NamedObjectNBQ()
		if This._NNLCountIs("numberofnamedobjects") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_
	def NamedObjectsB()
		return This._NNLValueIs("namedobjects")
	def NamedObjectsBQ()
		if This._NNLValueIs("namedobjects") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def NonEmptyLineN()
		return This._NNLNounCount("numberofnonemptylines")
	def NonEmptyLineNQ()
		return This._NNLCarry(new stzNumber(This._NNLNounCount("numberofnonemptylines")))
	def NonEmptyLineNB()
		return This._NNLCountIs("numberofnonemptylines")
	def NonEmptyLineNBQ()
		if This._NNLCountIs("numberofnonemptylines") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def NonStzObjectN()
		return This._NNLNounCount("numberofnonstzobjects")
	def NonStzObjectNQ()
		return This._NNLCarry(new stzNumber(This._NNLNounCount("numberofnonstzobjects")))
	def NonStzObjectNB()
		return This._NNLCountIs("numberofnonstzobjects")
	def NonStzObjectNBQ()
		if This._NNLCountIs("numberofnonstzobjects") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def NumberN()
		return This._NNLNounCount("numberofnumbers")
	def NumberNQ()
		return This._NNLCarry(new stzNumber(This._NNLNounCount("numberofnumbers")))
	def NumberNB()
		return This._NNLCountIs("numberofnumbers")
	def NumberNBQ()
		if This._NNLCountIs("numberofnumbers") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_
	def NumbersB()
		return This._NNLValueIs("numbers")
	def NumbersBQ()
		if This._NNLValueIs("numbers") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ObjectN()
		return This._NNLNounCount("numberofobjects")
	def ObjectNQ()
		return This._NNLCarry(new stzNumber(This._NNLNounCount("numberofobjects")))
	def ObjectNB()
		return This._NNLCountIs("numberofobjects")
	def ObjectNBQ()
		if This._NNLCountIs("numberofobjects") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_
	def ObjectsB()
		return This._NNLValueIs("objects")
	def ObjectsBQ()
		if This._NNLValueIs("objects") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def PairN()
		return This._NNLNounCount("numberofpairs")
	def PairNQ()
		return This._NNLCarry(new stzNumber(This._NNLNounCount("numberofpairs")))
	def PairNB()
		return This._NNLCountIs("numberofpairs")
	def PairNBQ()
		if This._NNLCountIs("numberofpairs") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_
	def PairsB()
		return This._NNLValueIs("pairs")
	def PairsBQ()
		if This._NNLValueIs("pairs") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ParagraphN()
		return This._NNLNounCount("numberofparagraphs")
	def ParagraphNQ()
		return This._NNLCarry(new stzNumber(This._NNLNounCount("numberofparagraphs")))
	def ParagraphNB()
		return This._NNLCountIs("numberofparagraphs")
	def ParagraphNBQ()
		if This._NNLCountIs("numberofparagraphs") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_
	def ParagraphsB()
		return This._NNLValueIs("paragraphs")
	def ParagraphsBQ()
		if This._NNLValueIs("paragraphs") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ScriptN()
		return This._NNLNounCount("numberofscripts")
	def ScriptNQ()
		return This._NNLCarry(new stzNumber(This._NNLNounCount("numberofscripts")))
	def ScriptNB()
		return This._NNLCountIs("numberofscripts")
	def ScriptNBQ()
		if This._NNLCountIs("numberofscripts") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_
	def ScriptsB()
		return This._NNLValueIs("scripts")
	def ScriptsBQ()
		if This._NNLValueIs("scripts") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def SentenceN()
		return This._NNLNounCount("numberofsentences")
	def SentenceNQ()
		return This._NNLCarry(new stzNumber(This._NNLNounCount("numberofsentences")))
	def SentenceNB()
		return This._NNLCountIs("numberofsentences")
	def SentenceNBQ()
		if This._NNLCountIs("numberofsentences") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_
	def SentencesB()
		return This._NNLValueIs("sentences")
	def SentencesBQ()
		if This._NNLValueIs("sentences") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def SmallestN()
		return This._NNLNounCount("numberofsmallest")
	def SmallestNQ()
		return This._NNLCarry(new stzNumber(This._NNLNounCount("numberofsmallest")))
	def SmallestNB()
		return This._NNLCountIs("numberofsmallest")
	def SmallestNBQ()
		if This._NNLCountIs("numberofsmallest") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_
	def SmallestB()
		return This._NNLValueIs("smallest")
	def SmallestBQ()
		if This._NNLValueIs("smallest") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def StringN()
		return This._NNLNounCount("numberofstrings")
	def StringNQ()
		return This._NNLCarry(new stzNumber(This._NNLNounCount("numberofstrings")))
	def StringNB()
		return This._NNLCountIs("numberofstrings")
	def StringNBQ()
		if This._NNLCountIs("numberofstrings") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_
	def StringsB()
		return This._NNLValueIs("strings")
	def StringsBQ()
		if This._NNLValueIs("strings") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def StzObjectN()
		return This._NNLNounCount("numberofstzobjects")
	def StzObjectNQ()
		return This._NNLCarry(new stzNumber(This._NNLNounCount("numberofstzobjects")))
	def StzObjectNB()
		return This._NNLCountIs("numberofstzobjects")
	def StzObjectNBQ()
		if This._NNLCountIs("numberofstzobjects") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def SubStringN()
		return This._NNLNounCount("numberofsubstrings")
	def SubStringNQ()
		return This._NNLCarry(new stzNumber(This._NNLNounCount("numberofsubstrings")))
	def SubStringNB()
		return This._NNLCountIs("numberofsubstrings")
	def SubStringNBQ()
		if This._NNLCountIs("numberofsubstrings") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_
	def SubStringsB()
		return This._NNLValueIs("substrings")
	def SubStringsBQ()
		if This._NNLValueIs("substrings") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def SubStringsUN()
		return This._NNLNounCount("numberofsubstringsu")
	def SubStringsUNQ()
		return This._NNLCarry(new stzNumber(This._NNLNounCount("numberofsubstringsu")))
	def SubStringsUNB()
		return This._NNLCountIs("numberofsubstringsu")
	def SubStringsUNBQ()
		if This._NNLCountIs("numberofsubstringsu") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_
	def SubStringsUB()
		return This._NNLValueIs("substringsu")
	def SubStringsUBQ()
		if This._NNLValueIs("substringsu") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def TrailingCharN()
		return This._NNLNounCount("numberoftrailingchars")
	def TrailingCharNQ()
		return This._NNLCarry(new stzNumber(This._NNLNounCount("numberoftrailingchars")))
	def TrailingCharNB()
		return This._NNLCountIs("numberoftrailingchars")
	def TrailingCharNBQ()
		if This._NNLCountIs("numberoftrailingchars") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_
	def TrailingCharsB()
		return This._NNLValueIs("trailingchars")
	def TrailingCharsBQ()
		if This._NNLValueIs("trailingchars") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def TrailingItemN()
		return This._NNLNounCount("numberoftrailingitems")
	def TrailingItemNQ()
		return This._NNLCarry(new stzNumber(This._NNLNounCount("numberoftrailingitems")))
	def TrailingItemNB()
		return This._NNLCountIs("numberoftrailingitems")
	def TrailingItemNBQ()
		if This._NNLCountIs("numberoftrailingitems") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_
	def TrailingItemsB()
		return This._NNLValueIs("trailingitems")
	def TrailingItemsBQ()
		if This._NNLValueIs("trailingitems") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def UniqueSubStringN()
		return This._NNLNounCount("numberofuniquesubstrings")
	def UniqueSubStringNQ()
		return This._NNLCarry(new stzNumber(This._NNLNounCount("numberofuniquesubstrings")))
	def UniqueSubStringNB()
		return This._NNLCountIs("numberofuniquesubstrings")
	def UniqueSubStringNBQ()
		if This._NNLCountIs("numberofuniquesubstrings") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_
	def UniqueSubStringsB()
		return This._NNLValueIs("uniquesubstrings")
	def UniqueSubStringsBQ()
		if This._NNLValueIs("uniquesubstrings") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def UnnamedObjectN()
		return This._NNLNounCount("numberofunnamedobjects")
	def UnnamedObjectNQ()
		return This._NNLCarry(new stzNumber(This._NNLNounCount("numberofunnamedobjects")))
	def UnnamedObjectNB()
		return This._NNLCountIs("numberofunnamedobjects")
	def UnnamedObjectNBQ()
		if This._NNLCountIs("numberofunnamedobjects") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_
	def UnnamedObjectsB()
		return This._NNLValueIs("unnamedobjects")
	def UnnamedObjectsBQ()
		if This._NNLValueIs("unnamedobjects") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def VowelN()
		return This._NNLNounCount("numberofvowels")
	def VowelNQ()
		return This._NNLCarry(new stzNumber(This._NNLNounCount("numberofvowels")))
	def VowelNB()
		return This._NNLCountIs("numberofvowels")
	def VowelNBQ()
		if This._NNLCountIs("numberofvowels") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_
	def VowelsB()
		return This._NNLValueIs("vowels")
	def VowelsBQ()
		if This._NNLValueIs("vowels") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def WordN()
		return This._NNLNounCount("numberofwords")
	def WordNQ()
		return This._NNLCarry(new stzNumber(This._NNLNounCount("numberofwords")))
	def WordNB()
		return This._NNLCountIs("numberofwords")
	def WordNBQ()
		if This._NNLCountIs("numberofwords") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_
	def WordsB()
		return This._NNLValueIs("words")
	def WordsBQ()
		if This._NNLValueIs("words") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_
	# </nnl-generated-surface>
