
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

	# Q3 -- truth-functional coordination (one-shot flags). NO NotQ:
	# English negates with negative FORMS (IsNot*/DoesNot*), antonym
	# comparators (DifferentFromQ) and the OrNot tag (author's ruling).
	@bNNLSkip = 0      # OrQ() on a TRUE branch: skip the next disjunct
	@bNNLNeither = 0   # neither...nor: every disjunct must be false
	@bNNLEither = 0    # is either...or: first disjunct may fail WITHOUT
	@bNNLSat = 0       # falsifying; or-recovery/skip close the figure
	@cNNLQuant = ""    # each|any|none: the NEXT predicate distributes
	@aNNLConstraints = []   # per-object constraints: [ [name, rule], ... ]
	@bNNLEnforce = 0        # 1 = the update points refuse violating values

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

		# the DESCRIPTOR must test the TYPED value: stzNumber stores its
		# content as a STRING (big-number precision), so @@(Content())
		# rendered numbers as string literals and @isString(123) answered
		# 1 while @isNumber(123) answered 0 -- every type descriptor on
		# numbers was silently inverted (pre-existing, exposed by the Q3
		# disjunction tests)
		_vIsaxt_ = this.Content()
		if This.StzType() = :stzNumber
			_vIsaxt_ = This.NumericValue()
		ok

		for i = 1 to _nLen_
			_cCode_ = '_bResult_ = @is' + pacStr[i] + '(' + @@(_vIsaxt_) + ')'

			eval(_cCode_)
			if _bResult_ = 0
				exit
			ok
		next

		return _bResult_

		#-- @FunctionluentForm

		def IsAXTQ(pcType)
			if @bNNLSkip = 1
				@bNNLSkip = 0
				return This
			ok
			if @cNNLQuant != ""
				return This._NNLDistIsA(pcType)
			ok
			if @bNNLNeither = 1
				# under neither...nor a HOLDING predicate falsifies;
				# a failing one keeps the chain alive (mode persists
				# across the nor-continuation)
				if this.IsAXT(pcType) = 1
					@bNNLNeither = 0
					_oFo_ = AFalseObjectXT(This)
					_oFo_.SetWhyStopped("no: the predicate held, but neither/nor required it false")
					return _oFo_
				ok
				return This
			ok
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

			if @bNNLSkip = 1
				@bNNLSkip = 0
				return This
			ok
			if @cNNLQuant != ""
				return This._NNLDistIsA(pcType)
			ok
			if isList(pcType)
				return This.IsAXTQ(pcType)
			ok
			if @bNNLNeither = 1
				if This.IsA(pcType) = 1
					@bNNLNeither = 0
					_oFo_ = AFalseObjectXT(This)
					_oFo_.SetWhyStopped("no: the predicate held, but neither/nor required it false")
					return _oFo_
				ok
				return This
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






		#>

		#< @FunctionAlternativeForms

		def IsAn(pcType)
			return This.IsA(pcType)

			def IsAnQ(pcType)
				return This.IsAQ(pcType)





		#--

		def AreA(pcType)
			return This.IsA(pcType)

			def AreAQ(pcType)
				return This.IsAQ(pcType)





		#--

		def AreAn(pcType)
			return This.IsA(pcType)

			def AreAnQ(pcType)
				return This.IsAQ(pcType)





		#--

		def IsThe(pcType)
			return This.IsA(pcType)

			def IsTheQ(pcType)
				return This.IsAQ(pcType)





		#--

		def AreThe(pcType)
			return This.IsA(pcType)

			def AreTheQ(pcType)
				return This.IsAQ(pcType)





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

			



		#>

		def AreAll(pcType)
			return This.Are(pcType)

			def AreAllQ(pcType)
				return This.AreQ(pcType)





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


		#>

		#< @FunctionAlternativeForms

		def AreBothAn(pcType)
			return This.AreBothA(pcType)

			def AreBothAnQ(pcType)
				return This.AreBothAQ(pcType)


		#--

		def AreBoth(pcType)
			return This.AreBothA(pcType)

			def AreBothQ(pcType)
				return This.AreBothAQ(pcType)

		#--

		def BothAreA(pcType)
			return This.AreBothA(pcType)

			def BothAreAQ(pcType)
				return This.AreBothAQ(pcType)






		#--

		def BothAreAn(pcType)
			return This.AreBothA(pcType)

			def BothAreAnQ(pcType)
				return This.AreBothAQ(pcType)






		#--

		def BothAre(pcType)
			return This.AreBoth(pcType)

			def BothAreQ(pcType)
				return This.AreBothQ(pcType)


		def BothAreM(pcType)
			return this.AreBothM(pcType)



		#--

		def AreTwo(pcType)
			return AreBothA(pcType)

			def AreTwoQ(pcType)
				return AreBothAQ(pcType)





		#>

	def Which()
		return This


	

		def WhichQ()
			return This.Which()


		#--
	
		def That()
			return This



		def ThatQ()
			return This



	def WhichIs()
		return This

		def WhichIsQ()
			return This.WhichIs()





		#--

		def ThatIs()
			return This

		def ThatIsQ()
			return This.ThatIs()




	def WhichAre()
		return This

		def WhichAreQ()
			return This.WhichAre()




		#--

		def ThatAre()
			return This

		def ThatAreQ()
			return This.ThatAre()




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





		#--

		def WhichBothAre()
			return This.WhichAreBoth()

		def WhichBothAreQ()
			return This.WhichAreBoth()




		#-- @MisspelledForms

		def WichAreBoth()
			return This.WhichAreBoth()

		def WichAreBothQ()
			return This.WhichAre()





		#--

		def WichBothAre()
			return This.WhichAreBoth()

		def WichBothAreQ()
			return This.WhichAreBoth()





		#--

		def WitchBothAre()
			return This.WhichAreBoth()

		def WitchBothAreQ()
			return This.WhichAreBoth()





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



	def AndFinallyQ()
		return This



	def ThenQ()
		return This



	def AndThen()
		return This

		def AndThenQ()
			return This



		def AndQ()
			return This






	def Having()
		return This

		def HavingQ()
			return This



		
		#--

		def AndHaving()
			return This

		def AndHavingQ()
			return This




	def With()
		return This

		def WithQ()
			return This

		def WithA()
			return This

		def WithAQ()
			return This






	
	def Only(value)
		This._NNLSetExpect(value, :Exactly, 0)
		return This

		def OnlyQ(value)
			return Only(value)





	def A()
		return This

		def AQ()
			return This


		#--




	def Their()
		return This

		#< @FunctionFluentForm

		def TheirQ()
		# the PRONOUN: returns the chain SUBJECT -- on an uninterrupted
		# chain @oNNLMain is unset (lazy stamping) and the subject IS
		# This; after an interruption the stored subject is an
		# assignment-copy, so the live logical figure is re-stamped
		# onto what is handed back.
		if isObject(@oNNLMain)
			_oIt_ = @oNNLMain
			_oIt_._NNLSetFigure(@bNNLNeither, @bNNLEither, @bNNLSat, @bNNLSkip)
			return _oIt_
		ok
		return This

		
		#>


	


		#< @FunctionAlternativeForms

		def AllTheir()
			return This

			def AllTheirQ()
				return This



		def Its()
			return This



			def ItsQ()
		# the PRONOUN: returns the chain SUBJECT -- on an uninterrupted
		# chain @oNNLMain is unset (lazy stamping) and the subject IS
		# This; after an interruption the stored subject is an
		# assignment-copy, so the live logical figure is re-stamped
		# onto what is handed back.
		if isObject(@oNNLMain)
			_oIt_ = @oNNLMain
			_oIt_._NNLSetFigure(@bNNLNeither, @bNNLEither, @bNNLSat, @bNNLSkip)
			return _oIt_
		ok
		return This
	


		def His()
			return This



			def HisQ()
				return This
	


		def Her()
			return This



			def HerQ()
				return This
	


		def My()
			return This




			def MyQ()
				return This
	


		def Your()
			return This




			def YourQ()
				return This
	


		#>

	def As()
		return This



		def AsQ()
			return This



		#--

		def AsA()
			return This.As()

		def AsAM()
			return This.AsM()


		def AsAQ()
			return This.AsQ()



		#--

		def AsThe()
			return This.As()

		def AstheM()
			return This.AsM()


		def AsTheQ()
			return This.AsQ()



	def The()
		return This

		def TheQ()
			return This.The()




	def Them()
		return This





		def ThemQ()
			return This.Them()

	def Me()
		return This



		def MeQ()
			return This.Me()



	def Mine()
		return This



		def MineQ()
			return This.Mine()



	def It()
		return This



		def ItQ()
		# the PRONOUN: returns the chain SUBJECT -- on an uninterrupted
		# chain @oNNLMain is unset (lazy stamping) and the subject IS
		# This; after an interruption the stored subject is an
		# assignment-copy, so the live logical figure is re-stamped
		# onto what is handed back.
		if isObject(@oNNLMain)
			_oIt_ = @oNNLMain
			_oIt_._NNLSetFigure(@bNNLNeither, @bNNLEither, @bNNLSat, @bNNLSkip)
			return _oIt_
		ok
		return This



	def You()
		return This



		def YouQ()
			return This.You()



	def Yours()
		return This



		def YoursQ()
			return This.Yours()



	def Him()
		return This






		def HimQ()
			return This.Him()

	def Has()
		return This



		def HasQ()
			return This.Has()



	def HasA()
		return This



		def HasAQ()
			return This.HasA()



	def HasN(_n_)
		if CheckingParams()
			if NOT isNumber(_n_)
				StzRaise("Incorrect param type! n must be a number.")
			ok
		ok

		This._NNLSetExpect(_n_, :Exactly, 0)
		return This



		def HasNQ(_n_)
			return This.HasN(_n_)



		#--

		def HasTheNumber(_n_)
			return This.HasN(_n_)



		def HasTheNumberQ(_n_)
			return This.HasTheNumber(_n_)



	#==



	def _(any)
		return LastValue()



		def _Q(any)
			return Q( This._(any) )



	#==

	def OfCS(_n_, pCaseSensitive)
		return This.IsEqualToCS(_n_, pCaseSensitive)



		def OfCSQ(_n_, pCaseSensitive)
			if This.IsEqualToCS(_n_, pCaseSensitive)
				return This
			else
				return AFalseObjectXT(This)
			ok



	def Of(_n_)
		return This.OfCS(_n_, 1)

		def OfM(_n_)
			return This.OfCSM(_n_, 1)


		def OfQ(_n_)
			return This.OfCSQ(_n_, 1)


		
	#--

	def OfCSXT(_n_, cIgnored, pCaseSensitive)
		return This.OfCS(_n_, pCaseSensitive)

		def OfCSXTQ(_n_, cIgnored, pCaseSensitive)
			return This.OfCSQ(_n_, pCaseSensitive)



		def OfXTCS(_n_, cIgnored, pCaseSensitive)
			return This.OfCS(_n_, pCaseSensitive)

		def OfXTCSQ(_n_, cIgnored, pCaseSensitive)
			return This.OfCS(_n_, pCaseSensitive)



	def OfXT(_n_, cIgnored)
		return This.OfCS(_n_, 1)

		def OfXTM(_n_, cIgnored)
			return This.OfCSM(_n_, 1)


		def OfXTQ(_n_, cIgnored)
			return This.OfCSQ(_n_, 1)



	#==

	def OfCSB(_n_, pCaseSensitive)
		if Q(_n_).IsEqualToCS(LastValue(), pCaseSensitive)
			
			return 1
		else
			return 0
		ok




		def OfCSBQ(_n_, pCaseSensitive)
			if This.OfCSB(_n_, pCaseSensitive) = 1
				return This
			else
				return AFalseObjectXT(This)
			ok




	def OfBM(_n_)
		return This.OfCSBM(_n_, pCaseSensitive)


		def OfMB(_n_)
			return This.OfCSMB(_n_, 1)

		def OfBQ(_n_)
			return This.OfCSBQ(_n_, 1)



	#==

	def OfXTCSB(_n_, cIgnored, pCaseSensitive)
		return This.OfCSB(c, pCaseSensitive)

		def OfXTCSBM(_n_, cIgnored, pCaseSensitive)
			return This.OfCSBM(_n_, pCaseSensitive)


		def OfXTCSMB(_n_, cIgnored, pCaseSensitive)
			return This.OfCSMB(_n_, pCaseSensitive)

		def OfXTCSBQ(_n_, cIgnored, pCaseSensitive)
			return This.OfCSBQ(_n_, pCaseSensitive)



	def OfXTBM(_n_)
		return This.OfXTCSB(_n_, cIgnored, 1)


		def OfXTMB(_n_)
			return This.OfXTCSMB(_n_, 1)

		def OfXTBQ(_n_)
			return This.OfXTCSBQ(_n_, 1)



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
			if _cId_ = ""
				# MULTILINGUAL stems: the pack languages speak here too
				# ("majuscule" -> METHOD_UPPERCASE) -- same accountable
				# route, any registered language
				_aLangs_ = StzNaturalLanguages()
				_nLg_ = len(_aLangs_)
				for _iLg_ = 1 to _nLg_
					if _aLangs_[_iLg_] != "en"
						_cId_ = StzResolveSemanticInLang(_aLangs_[_iLg_], _cM_)
						if _cId_ != ""
							exit
						ok
					ok
				next
			ok
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
			# LAZY subject stamping (no birth snapshot): the subject is
			# recorded at the moment of INTERRUPTION, from the live
			# object being left behind. A birth-time snapshot would
			# dangle once the original mutates (stz copies share the
			# engine handle -- see the aliasing doctrine).
			if isObject(@oNNLMain)
				poNew.SetNNLMain(@oNNLMain)
			else
				poNew.SetNNLMain(This)
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
		_cModeTxt_ = lower("" + _cMode_)
		if _bYes_
			@cNNLWhy = "yes: expected " + _cModeTxt_ + " " +
				_cExp_ + ", found " + nActual
			$cStzLastWhyB = @cNNLWhy
			return 1
		ok
		@cNNLWhy = "no: expected " + _cModeTxt_ + " " +
			_cExp_ + ", found " + nActual
		$cStzLastWhyB = @cNNLWhy
		return 0

	# the IMMUTABLE form executor: act on a CLONE (QC), return the
	# clone chainable, the original untouched -- the ...QC suffix the
	# reflect layer already tags, generated below for every action
	def _NNLImmutable(pcMethod, paParams)
		_oQc_ = QC(This)
		_oQc_._NNLCall(pcMethod, paParams)
		return _oQc_

	def _NNLCountIs(pcMethod)
		if @bNNLSkip = 1
			@bNNLSkip = 0
			@cNNLWhy = "skipped: the disjunction was already satisfied"
			$cStzLastWhyB = @cNNLWhy
			return 1
		ok
		if @cNNLQuant != ""
			# distribute: every/any/no item's count must satisfy the
			# expectation ("each has at least 2 vowels")
			_cQ_ = @cNNLQuant
			@cNNLQuant = ""
			_aItems_ = This._NNLQuantItems()
			_nQc_ = len(_aItems_)
			for _i_ = 1 to _nQc_
				_bOk_ = ( This._NNLExpectCompare(
					Q(_aItems_[_i_])._NNLNounCount(pcMethod) ) = 1 )
				if _cQ_ = "each" and NOT _bOk_
					@cNNLWhy = "no: item " + _i_ + " (" + @@(_aItems_[_i_]) +
						") fails -- " + @cNNLWhy
					$cStzLastWhyB = @cNNLWhy
					return 0
				ok
				if _cQ_ = "any" and _bOk_
					@cNNLWhy = "yes: item " + _i_ + " satisfies -- " + @cNNLWhy
					$cStzLastWhyB = @cNNLWhy
					return 1
				ok
				if _cQ_ = "none" and _bOk_
					@cNNLWhy = "no: item " + _i_ + " (" + @@(_aItems_[_i_]) +
						") satisfies, and none may"
					$cStzLastWhyB = @cNNLWhy
					return 0
				ok
			next
			if _cQ_ = "any"
				@cNNLWhy = "no: no item satisfies the expectation"
				$cStzLastWhyB = @cNNLWhy
				return 0
			ok
			@cNNLWhy = "yes: " + _cQ_ + " over " + _nQc_ + " items"
			$cStzLastWhyB = @cNNLWhy
			return 1
		ok
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


	def AtLeast(n)
		This._NNLSetExpect(n, :AtLeast, 0)
		return This

		def AtLeastQ(n)
			return This.AtLeast(n)


	def AtMost(n)
		This._NNLSetExpect(n, :AtMost, 0)
		return This

		def AtMostQ(n)
			return This.AtMost(n)


	def MoreThan(n)
		This._NNLSetExpect(n, :MoreThan, 0)
		return This

		def MoreThanQ(n)
			return This.MoreThan(n)


	def LessThan(n)
		This._NNLSetExpect(n, :LessThan, 0)
		return This

		def LessThanQ(n)
			return This.LessThan(n)


	def About(n)
		This._NNLSetExpect(n, :About, 0.1)
		return This

		def AboutQ(n)
			return This.About(n)


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

	# --- Q3: NEGATION + TRUTH-FUNCTIONAL COORDINATION ------------------
	# NotQ() flips the NEXT comparison ("has not at most 2 vowels").
	# EitherQ()/BothQ() are readable openers (pass-throughs). OrQ() on a
	# LIVE object short-circuits: the disjunction is already satisfied,
	# so the next disjunct is SKIPPED (one-shot flag honored by the
	# device layer); on a FALSE premise OrQ() recovers the origin and
	# the second disjunct gets its chance -- real disjunction, enabled
	# by the carried origin. NeitherQ()...NorQ() demands every disjunct
	# FALSE: a passing predicate turns the chain false, a failing one
	# keeps it alive.

	def BothQ()
		return This

	# RING SEMANTICS (author's rule, mutation-probed): numbers/strings
	# copy; lists and objects pass BY REFERENCE into functions, but the
	# `=` ASSIGNMENT (incl. attribute store) COPIES -- and a copied stz
	# object SHARES its engine handle, so the elder's view dangles after
	# the younger mutates. Therefore the chain's semantics belong to
	# Softanza's returning code alone: never alias stz objects with `=`
	# (use QC()/Copy()), and stored subjects are copies whose live
	# figure must be re-stamped when handed back:
	def _NNLSetFigure(pbNeither, pbEither, pbSat, pbSkip)
		@bNNLNeither = pbNeither
		@bNNLEither = pbEither
		@bNNLSat = pbSat
		@bNNLSkip = pbSkip

	# "It IS EITHER a number or a string" -- the fused copula opens the
	# disjunctive figure: the FIRST disjunct may fail without falsifying
	def IsEitherQ()
		@bNNLEither = 1
		@bNNLSat = 0
		return This

	# "It IS NEITHER a number nor a list" -- every disjunct must be
	# false; a holding predicate falsifies the chain
	def IsNeitherQ()
		@bNNLNeither = 1
		return This

		def NeitherQ()
			@bNNLNeither = 1
			return This

	def OrQ()
		if @bNNLEither = 1
			# inside either...or: skip the next disjunct ONLY when one
			# already held; otherwise the next disjunct decides
			@bNNLEither = 0
			if @bNNLSat = 1
				@bNNLSkip = 1
				@bNNLSat = 0
			ok
			return This
		ok
		# outside the figure: a live object means the premise held --
		# the disjunction is satisfied, skip the next disjunct
		@bNNLSkip = 1
		return This

	def NorQ()
		return This

	# --- Q3b: DISTRIBUTIVE QUANTIFIERS ---------------------------------
	# The quantifier opens a figure; the NEXT predicate applies to every
	# item and the figure folds the answers: EACH demands all hold, ANY
	# demands one, NONE demands zero. Singular agreement by design
	# ("each IS a number", "none IS a number"); the collective plural
	# lives in AreQ(:Numbers). The fold explains itself per item.

	def EachQ()
		@cNNLQuant = "each"
		return This

	def AnyQ()
		@cNNLQuant = "any"
		return This

	def NoneQ()
		@cNNLQuant = "none"
		return This

	# the quantifier-NOUN units (author's formulations): "each item is",
	# "any item is", "no item is" -- same figures, the noun spoken.
	def EachItemQ()
		@cNNLQuant = "each"
		return This

	def AnyItemQ()
		@cNNLQuant = "any"
		return This

	def NoItemQ()
		@cNNLQuant = "none"
		return This

	# "ALL ITEMS ARE numbers" -- the COLLECTIVE side: all takes plural
	# agreement, so AllItemsQ is the topic particle and AreQ (the
	# existing collective check) does the work, answering with the
	# TYPED list. The distributive per-item story belongs to EACH.
	def AllItemsQ()
		return This

	# --- MODALITY gate: "the value QUALIFIES AS a score" -- validates
	# the content against the kind's declared constraints; monadic
	# (AsAQ was unavailable: the As-family owns it)

	def QualifiesAs(pcKind)
		_cQk_ = StzLower(ring_trim(pcKind))
		_aQc_ = ConstraintsOn(_cQk_)
		_nQc_ = len(_aQc_)
		if _nQc_ = 0
			@cNNLWhy = "no: nothing is known about being a '" + _cQk_ + "'"
			$cStzLastWhyB = @cNNLWhy
			return 0
		ok
		_vQv_ = This.Content()
		if This.StzType() = :stzNumber
			_vQv_ = This.NumericValue()
		ok
		for _i_ = 1 to _nQc_
			if NOT _StzKindHolds(_vQv_, _aQc_[_i_])
				@cNNLWhy = "no: " + @@(_vQv_) + " is not " + _aQc_[_i_] +
					" (constraint " + _i_ + " of '" + _cQk_ + "')"
				$cStzLastWhyB = @cNNLWhy
				return 0
			ok
		next
		@cNNLWhy = "yes: it qualifies as a '" + _cQk_ + "'"
		$cStzLastWhyB = @cNNLWhy
		return 1

		def QualifiesAsQ(pcKind)
			if This.QualifiesAs(pcKind) = 1
				return This
			ok
			_oFo_ = AFalseObjectXT(This)
			_oFo_.SetWhyStopped(@cNNLWhy)
			return _oFo_

	# --- PER-OBJECT CONSTRAINTS (the archived stzString design, finally
	# generalized -- the author's own TODO said "Generalize this feature
	# to other classes"). A constraint is NAMED and its rule is either a
	# DESCRIPTOR symbol (:Lowercase -- the @is<X> dispatch) or a
	# CONDITION in the archived placeholder style:
	#     o.AddConstraint("stay-small", '{ len(@string) < 10 }')
	# VerifyConstraint answers 1/0 with Why; ApplyConstraints ENFORCES:
	# the archived structured raise ("Execution is cancelled by
	# Softanza") on the first violation, This when all hold.

	def AddConstraint(pcName, pRule)
		if NOT isString(pcName) or ring_trim(pcName) = ""
			StzRaise("A constraint needs a name.")
		ok
		_cCn_ = StzLower(ring_trim(pcName))
		_nCn_ = len(@aNNLConstraints)
		for _i_ = 1 to _nCn_
			if @aNNLConstraints[_i_][1] = _cCn_
				@aNNLConstraints[_i_][2] = pRule
				return
			ok
		next
		@aNNLConstraints + [ _cCn_, pRule ]

		def AddConstraintQ(pcName, pRule)
			This.AddConstraint(pcName, pRule)
			return This

	def Constraints()
		return @aNNLConstraints

	def RemoveConstraint(pcName)
		_cCn_ = StzLower(ring_trim(pcName))
		_aKeep_ = []
		_nCn_ = len(@aNNLConstraints)
		for _i_ = 1 to _nCn_
			if @aNNLConstraints[_i_][1] != _cCn_
				_aKeep_ + @aNNLConstraints[_i_]
			ok
		next
		@aNNLConstraints = _aKeep_

	# does one rule hold against the TYPED content?
	def _NNLConstraintHolds(pRule)
		_vCh_ = This.Content()
		if This.StzType() = :stzNumber
			_vCh_ = This.NumericValue()
		ok
		return This._NNLRuleHoldsFor(pRule, _vCh_)

	# ...and against a CANDIDATE value -- the enforcement guard asks
	# about the FUTURE state, before it is applied
	def _NNLRuleHoldsFor(pRule, pValue)
		_vCv_ = pValue
		if isString(pRule) and StzFindFirst(pRule, "{") > 0
			# the archived placeholder style: @string/@number/@list/
			# @item/@object/@ all mean THE VALUE (longest name first)
			_cCc_ = pRule
			_cCc_ = StzReplace(_cCc_, "{", " ")
			_cCc_ = StzReplace(_cCc_, "}", " ")
			_cCc_ = StzReplace(_cCc_, "@string", "_vCv_")
			_cCc_ = StzReplace(_cCc_, "@number", "_vCv_")
			_cCc_ = StzReplace(_cCc_, "@object", "_vCv_")
			_cCc_ = StzReplace(_cCc_, "@list", "_vCv_")
			_cCc_ = StzReplace(_cCc_, "@item", "_vCv_")
			_cCc_ = StzReplace(_cCc_, "@", "_vCv_")
			_bCh_ = 0
			try
				eval("_bCh_ = ( " + _cCc_ + " )")
			catch
				StzRaise("Invalid constraint condition: " + pRule)
			done
			return _bCh_
		ok
		return _StzKindHolds(_vCv_, StzLower(ring_trim("" + pRule)))

	def VerifyConstraint(pcName)
		_cCn_ = StzLower(ring_trim(pcName))
		_nCn_ = len(@aNNLConstraints)
		for _i_ = 1 to _nCn_
			if @aNNLConstraints[_i_][1] = _cCn_
				if This._NNLConstraintHolds(@aNNLConstraints[_i_][2])
					@cNNLWhy = "yes: constraint '" + _cCn_ + "' holds"
					$cStzLastWhyB = @cNNLWhy
					return 1
				ok
				@cNNLWhy = "no: constraint '" + _cCn_ + "' is violated by " +
					@@(This.Content())
				$cStzLastWhyB = @cNNLWhy
				return 0
			ok
		next
		StzRaise("Inexistant constraint! No constraint named '" + _cCn_ +
			"' on this object.")

	def VerifyConstraints()
		_nCn_ = len(@aNNLConstraints)
		for _i_ = 1 to _nCn_
			if NOT This._NNLConstraintHolds(@aNNLConstraints[_i_][2])
				@cNNLWhy = "no: constraint '" + @aNNLConstraints[_i_][1] +
					"' is violated by " + @@(This.Content())
				$cStzLastWhyB = @cNNLWhy
				return 0
			ok
		next
		@cNNLWhy = "yes: all " + _nCn_ + " constraints hold"
		$cStzLastWhyB = @cNNLWhy
		return 1

	# ENFORCEMENT -- the archived semantics: execution is cancelled on a
	# violation, with the structured explanation; chainable when clean
	def ApplyConstraints()
		_nCn_ = len(@aNNLConstraints)
		for _i_ = 1 to _nCn_
			if NOT This._NNLConstraintHolds(@aNNLConstraints[_i_][2])
				StzRaise([
					:Where = "stzObject > ApplyConstraints()",
					:What  = "Execution is cancelled by Softanza",
					:Why   = "The constraint '" + @aNNLConstraints[_i_][1] +
						"' on this object is not verified by " +
						@@(This.Content()),
					:Todo  = "Check that constraint and adjust your logic accordingly ;)"
				])
			ok
		next
		return This

		def ApplyConstraintsQ()
			return This.ApplyConstraints()

	# ENFORCEMENT-ON-UPDATE -- the archived dream, live: a constrained
	# object REFUSES a violating update at the SINGLE UPDATE POINT
	# (stzString/stzNumber Update(), stzList _SetContent()).
	# EnforceConstraint() declares AND arms; RelaxConstraints() disarms
	# (on-demand verification stays available). Most mutators compute
	# their result THEN Update, so a refusal leaves the object
	# untouched; the few in-place engine mutators journal their
	# pre-state first, so Undo() recovers.

	def EnforceConstraint(pcName, pRule)
		This.AddConstraint(pcName, pRule)
		@bNNLEnforce = 1

		def EnforceConstraintQ(pcName, pRule)
			This.EnforceConstraint(pcName, pRule)
			return This

	def EnforceConstraints()
		@bNNLEnforce = 1

		def EnforceConstraintsQ()
			This.EnforceConstraints()
			return This

	def RelaxConstraints()
		@bNNLEnforce = 0

		def RelaxConstraintsQ()
			This.RelaxConstraints()
			return This

	def ConstraintsAreEnforced()
		return @bNNLEnforce

	# the guard the update points call BEFORE applying a new value
	def _NNLGuardUpdate(pNewValue)
		if @bNNLEnforce = 0 or len(@aNNLConstraints) = 0
			return
		ok
		_nGc_ = len(@aNNLConstraints)
		for _iGc_ = 1 to _nGc_
			if NOT This._NNLRuleHoldsFor(@aNNLConstraints[_iGc_][2], pNewValue)
				StzRaise([
					:Where = This.StzType() + " > Update()",
					:What  = "Execution is cancelled by Softanza",
					:Why   = "Updating this object to " + @@(pNewValue) +
						" would violate the enforced constraint " + "'" +
						@aNNLConstraints[_iGc_][1] + "'",
					:Todo  = "Fix the new value or relax the constraint (RelaxConstraints())"
				])
			ok
		next

	# --- Q4: DISCOURSE TENSE over the QH history ----------------------
	# Open the chain with QH() and the object remembers its states; the
	# tense devices then answer about TIME, plain-form (they are data):
	#   WasEver(:Uppercase)   -- some state satisfied the descriptor
	#   WasNever(:Number)     -- no state ever did (the negative FORM)
	#   UsedToBe(:Lowercase)  -- held in the PAST, does not hold NOW
	#   IsStill(:Uppercase)   -- held before and still holds
	# Descriptors dispatch like IsAXT (@is<X> over the typed state).
	# The devices PEEK the stream (History() consumes; these do not).

	def _NNLPastStates()
		# the QH stream is PROCESS-global (History() consumes it to end
		# a stream); a tense device must not read another chain's
		# leftovers -- the stream belongs to THIS object only if its
		# latest state IS this object's current content
		_aTense_ = _aHisto
		_nTe_ = len(_aTense_)
		if _nTe_ = 0
			return []
		ok
		if NOT Q(_aTense_[_nTe_]).IsEqualTo(This.Content())
			return []
		ok
		return _aTense_

	def _NNLStateHolds(pState, pcDesc)
		_vTense_ = pState
		eval("_bTh_ = @is" + pcDesc + "(_vTense_)")
		return _bTh_

	def WasEver(pcDesc)
		_aPast_ = This._NNLPastStates()
		_nTe_ = len(_aPast_)
		if _nTe_ = 0
			@cNNLWhy = "no: no history was kept (open the chain with QH)"
			$cStzLastWhyB = @cNNLWhy
			return 0
		ok
		for _i_ = 1 to _nTe_
			if This._NNLStateHolds(_aPast_[_i_], pcDesc)
				@cNNLWhy = "yes: state " + _i_ + " (" + @@(_aPast_[_i_]) +
					") was " + StzLower(pcDesc)
				$cStzLastWhyB = @cNNLWhy
				return 1
			ok
		next
		if This._NNLStateHolds(This.Content(), pcDesc)
			@cNNLWhy = "yes: it is " + StzLower(pcDesc) + " right now"
			$cStzLastWhyB = @cNNLWhy
			return 1
		ok
		@cNNLWhy = "no: none of the " + _nTe_ + " states was " + StzLower(pcDesc)
		$cStzLastWhyB = @cNNLWhy
		return 0

	def WasNever(pcDesc)
		if This.WasEver(pcDesc) = 1
			@cNNLWhy = "no: " + @cNNLWhy
			$cStzLastWhyB = @cNNLWhy
			return 0
		ok
		@cNNLWhy = "yes: " + StzLower("" + pcDesc) + " never held"
		$cStzLastWhyB = @cNNLWhy
		return 1

	def UsedToBe(pcDesc)
		_aPast_ = This._NNLPastStates()
		_nTe_ = len(_aPast_)
		if _nTe_ = 0
			@cNNLWhy = "no: no history was kept (open the chain with QH)"
			$cStzLastWhyB = @cNNLWhy
			return 0
		ok
		_bPast_ = FALSE
		for _i_ = 1 to _nTe_ - 1
			if This._NNLStateHolds(_aPast_[_i_], pcDesc)
				_bPast_ = TRUE
				exit
			ok
		next
		_bNow_ = This._NNLStateHolds(This.Content(), pcDesc)
		if _bPast_ and NOT _bNow_
			@cNNLWhy = "yes: it was " + StzLower(pcDesc) + " before, not anymore"
			$cStzLastWhyB = @cNNLWhy
			return 1
		ok
		if NOT _bPast_
			@cNNLWhy = "no: it never was " + StzLower(pcDesc) + " before now"
		else
			@cNNLWhy = "no: it is STILL " + StzLower(pcDesc)
		ok
		$cStzLastWhyB = @cNNLWhy
		return 0

	def IsStill(pcDesc)
		_aPast_ = This._NNLPastStates()
		_nTe_ = len(_aPast_)
		if _nTe_ = 0
			@cNNLWhy = "no: no history was kept (open the chain with QH)"
			$cStzLastWhyB = @cNNLWhy
			return 0
		ok
		_bPast_ = FALSE
		for _i_ = 1 to _nTe_ - 1
			if This._NNLStateHolds(_aPast_[_i_], pcDesc)
				_bPast_ = TRUE
				exit
			ok
		next
		_bNow_ = This._NNLStateHolds(This.Content(), pcDesc)
		if _bPast_ and _bNow_
			@cNNLWhy = "yes: it was and still is " + StzLower(pcDesc)
			$cStzLastWhyB = @cNNLWhy
			return 1
		ok
		if NOT _bPast_
			@cNNLWhy = "no: it was not " + StzLower(pcDesc) + " before"
		else
			@cNNLWhy = "no: it stopped being " + StzLower(pcDesc)
		ok
		$cStzLastWhyB = @cNNLWhy
		return 0

	# the typed-list converters AreQ answers with (decayed remnants --
	# AreQ referenced them but modularization had dropped them; strings
	# map to stzStringList, the plural-strings class)
	def ToStzListOfNumbers()
		return This._NNLCarry(new stzListOfNumbers(This.Content()))

	def ToStzListOfStrings()
		return This._NNLCarry(new stzStringList(This.Content()))

	def ToStzListOfChars()
		return This._NNLCarry(new stzListOfChars(This.Content()))

	def ToStzListOfLists()
		return This._NNLCarry(new stzListOfLists(This.Content()))

	def ToStzListOfObjects()
		return This._NNLCarry(new stzListOfObjects(This.Content()))

	# the items a quantifier ranges over: a list's items, a string's chars
	def _NNLQuantItems()
		_vQi_ = This.Content()
		if isList(_vQi_)
			return _vQi_
		ok
		if isString(_vQi_)
			return This.Chars()
		ok
		StzRaise("NNL: '" + @cNNLQuant + "' needs a plural subject (a list or a string).")

	# distribute a TYPE test (IsAQ symbol or IsAXT descriptor list)
	def _NNLDistIsA(pType)
		_cQ_ = @cNNLQuant
		@cNNLQuant = ""
		_aItems_ = This._NNLQuantItems()
		_nQi_ = len(_aItems_)
		for _i_ = 1 to _nQi_
			_bHold_ = ( Q(_aItems_[_i_]).IsA(pType) = 1 )
			if _cQ_ = "each" and NOT _bHold_
				_oFo_ = AFalseObjectXT(This)
				_oFo_.SetWhyStopped("no: item " + _i_ + " (" + @@(_aItems_[_i_]) +
					") does not hold, and each must")
				return _oFo_
			ok
			if _cQ_ = "any" and _bHold_
				@cNNLWhy = "yes: item " + _i_ + " holds"
				$cStzLastWhyB = @cNNLWhy
				return This
			ok
			if _cQ_ = "none" and _bHold_
				_oFo_ = AFalseObjectXT(This)
				_oFo_.SetWhyStopped("no: item " + _i_ + " (" + @@(_aItems_[_i_]) +
					") holds, and none may")
				return _oFo_
			ok
		next
		if _cQ_ = "any"
			_oFo_ = AFalseObjectXT(This)
			_oFo_.SetWhyStopped("no: no item holds, and any needs one")
			return _oFo_
		ok
		@cNNLWhy = "yes: " + _cQ_ + " over " + _nQi_ + " items holds"
		$cStzLastWhyB = @cNNLWhy
		return This

	# --- the TYPE-NOUN predicates: "a number", "a string"... the words
	# the disjunctive figures coordinate ("is either A NUMBER or A
	# STRING"). Outside a figure they behave like IsAQ(type).

	def _NNLTypeNoun(pcType)
		if @bNNLSkip = 1
			@bNNLSkip = 0
			return This
		ok
		if @cNNLQuant != ""
			return This._NNLDistIsA(pcType)
		ok
		if @bNNLEither = 1
			# first disjunct: record, never falsify
			if This.IsA(pcType) = 1
				@bNNLSat = 1
			ok
			return This
		ok
		if @bNNLNeither = 1
			if This.IsA(pcType) = 1
				@bNNLNeither = 0
				_oFo_ = AFalseObjectXT(This)
				_oFo_.SetWhyStopped("no: the predicate held, but neither/nor required it false")
				return _oFo_
			ok
			return This
		ok
		return This.IsAQ(pcType)

	def ANumberQ()
		return This._NNLTypeNoun(:Number)

	def AStringQ()
		return This._NNLTypeNoun(:String)

	def AListQ()
		return This._NNLTypeNoun(:List)

	def AnObjectQ()
		return This._NNLTypeNoun(:Object)

	def ACharQ()
		return This._NNLTypeNoun(:Char)

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
	# GENERATED from the semantic lexicon (scratchpad gen_widen.py; see
	# doc/design/NNL_REVIEW.md). Three device families:
	#   - countable nouns: <Noun>N/NQ/NB/NBQ (+<Nouns>B/BQ value agreement)
	#   - Q2 predicate B-forms: <Query>B/BQ -- the query's VALUE equals the
	#     remembered expectation (the ellipsis device over any query)
	#   - Q2 immutable forms: <Action>QC -- act on a CLONE via QC(), the
	#     original untouched (the suffix the reflect layer tags immutable)
	# All delegate to the hand-written engine; child overrides win; the
	# FalseObject absorbs via the engine overrides. Do not edit; regenerate.

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

	def AbsB()
		return This._NNLValueIs("abs")

	def AbsBQ()
		if This._NNLValueIs("abs") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def AbsoluteB()
		return This._NNLValueIs("absolute")

	def AbsoluteBQ()
		if This._NNLValueIs("absolute") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ACharB()
		return This._NNLValueIs("achar")

	def ACharBQ()
		if This._NNLValueIs("achar") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def AllAreEqualB()
		return This._NNLValueIs("allareequal")

	def AllAreEqualBQ()
		if This._NNLValueIs("allareequal") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def AllCharsAreEvenB()
		return This._NNLValueIs("allcharsareeven")

	def AllCharsAreEvenBQ()
		if This._NNLValueIs("allcharsareeven") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def AllCharsAreOddB()
		return This._NNLValueIs("allcharsareodd")

	def AllCharsAreOddBQ()
		if This._NNLValueIs("allcharsareodd") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def AllCharsArePositiveB()
		return This._NNLValueIs("allcharsarepositive")

	def AllCharsArePositiveBQ()
		if This._NNLValueIs("allcharsarepositive") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def AllDozensB()
		return This._NNLValueIs("alldozens")

	def AllDozensBQ()
		if This._NNLValueIs("alldozens") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def AllHundredsB()
		return This._NNLValueIs("allhundreds")

	def AllHundredsBQ()
		if This._NNLValueIs("allhundreds") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def AllItemsAreEmptyListsB()
		return This._NNLValueIs("allitemsareemptylists")

	def AllItemsAreEmptyListsBQ()
		if This._NNLValueIs("allitemsareemptylists") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def AllItemsAreEqualB()
		return This._NNLValueIs("allitemsareequal")

	def AllItemsAreEqualBQ()
		if This._NNLValueIs("allitemsareequal") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def AllItemsAreListsB()
		return This._NNLValueIs("allitemsarelists")

	def AllItemsAreListsBQ()
		if This._NNLValueIs("allitemsarelists") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def AllItemsHaveSameTypeB()
		return This._NNLValueIs("allitemshavesametype")

	def AllItemsHaveSameTypeBQ()
		if This._NNLValueIs("allitemshavesametype") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def AllPathsB()
		return This._NNLValueIs("allpaths")

	def AllPathsBQ()
		if This._NNLValueIs("allpaths") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def AllUnitsB()
		return This._NNLValueIs("allunits")

	def AllUnitsBQ()
		if This._NNLValueIs("allunits") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def AnyCharB()
		return This._NNLValueIs("anychar")

	def AnyCharBQ()
		if This._NNLValueIs("anychar") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def AnyPositionB()
		return This._NNLValueIs("anyposition")

	def AnyPositionBQ()
		if This._NNLValueIs("anyposition") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def AnySectionB()
		return This._NNLValueIs("anysection")

	def AnySectionBQ()
		if This._NNLValueIs("anysection") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def APositionB()
		return This._NNLValueIs("aposition")

	def APositionBQ()
		if This._NNLValueIs("aposition") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ARandomCharB()
		return This._NNLValueIs("arandomchar")

	def ARandomCharBQ()
		if This._NNLValueIs("arandomchar") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ARandomPositionB()
		return This._NNLValueIs("arandomposition")

	def ARandomPositionBQ()
		if This._NNLValueIs("arandomposition") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ARandomSectionB()
		return This._NNLValueIs("arandomsection")

	def ARandomSectionBQ()
		if This._NNLValueIs("arandomsection") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def AreContiguousB()
		return This._NNLValueIs("arecontiguous")

	def AreContiguousBQ()
		if This._NNLValueIs("arecontiguous") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ASectionB()
		return This._NNLValueIs("asection")

	def ASectionBQ()
		if This._NNLValueIs("asection") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def AsWellB()
		return This._NNLValueIs("aswell")

	def AsWellBQ()
		if This._NNLValueIs("aswell") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def AttributesB()
		return This._NNLValueIs("attributes")

	def AttributesBQ()
		if This._NNLValueIs("attributes") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def AutoLemmatizedB()
		return This._NNLValueIs("autolemmatized")

	def AutoLemmatizedBQ()
		if This._NNLValueIs("autolemmatized") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def AutoStemmedB()
		return This._NNLValueIs("autostemmed")

	def AutoStemmedBQ()
		if This._NNLValueIs("autostemmed") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def AverageB()
		return This._NNLValueIs("average")

	def AverageBQ()
		if This._NNLValueIs("average") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def BisectB()
		return This._NNLValueIs("bisect")

	def BisectBQ()
		if This._NNLValueIs("bisect") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def BothAreListsB()
		return This._NNLValueIs("botharelists")

	def BothAreListsBQ()
		if This._NNLValueIs("botharelists") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def BothAreNumbersB()
		return This._NNLValueIs("botharenumbers")

	def BothAreNumbersBQ()
		if This._NNLValueIs("botharenumbers") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def BothAreObjectsB()
		return This._NNLValueIs("bothareobjects")

	def BothAreObjectsBQ()
		if This._NNLValueIs("bothareobjects") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def BothAreStringsB()
		return This._NNLValueIs("botharestrings")

	def BothAreStringsBQ()
		if This._NNLValueIs("botharestrings") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def BoundsB()
		return This._NNLValueIs("bounds")

	def BoundsBQ()
		if This._NNLValueIs("bounds") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def BoundsRemovedB()
		return This._NNLValueIs("boundsremoved")

	def BoundsRemovedBQ()
		if This._NNLValueIs("boundsremoved") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def BoxedB()
		return This._NNLValueIs("boxed")

	def BoxedBQ()
		if This._NNLValueIs("boxed") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def BoxedDashedB()
		return This._NNLValueIs("boxeddashed")

	def BoxedDashedBQ()
		if This._NNLValueIs("boxeddashed") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def BoxedRoundB()
		return This._NNLValueIs("boxedround")

	def BoxedRoundBQ()
		if This._NNLValueIs("boxedround") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def BoxedRoundDashedB()
		return This._NNLValueIs("boxedrounddashed")

	def BoxedRoundDashedBQ()
		if This._NNLValueIs("boxedrounddashed") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def BoxedRoundedB()
		return This._NNLValueIs("boxedrounded")

	def BoxedRoundedBQ()
		if This._NNLValueIs("boxedrounded") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def BoxedRoundedDashedB()
		return This._NNLValueIs("boxedroundeddashed")

	def BoxedRoundedDashedBQ()
		if This._NNLValueIs("boxedroundeddashed") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def BoxifyB()
		return This._NNLValueIs("boxify")

	def BoxifyBQ()
		if This._NNLValueIs("boxify") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def BytecodesB()
		return This._NNLValueIs("bytecodes")

	def BytecodesBQ()
		if This._NNLValueIs("bytecodes") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def CapitalCasedB()
		return This._NNLValueIs("capitalcased")

	def CapitalCasedBQ()
		if This._NNLValueIs("capitalcased") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def CapitalizedB()
		return This._NNLValueIs("capitalized")

	def CapitalizedBQ()
		if This._NNLValueIs("capitalized") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def CaseFoldedB()
		return This._NNLValueIs("casefolded")

	def CaseFoldedBQ()
		if This._NNLValueIs("casefolded") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def CentralCharB()
		return This._NNLValueIs("centralchar")

	def CentralCharBQ()
		if This._NNLValueIs("centralchar") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def CentralItemB()
		return This._NNLValueIs("centralitem")

	def CentralItemBQ()
		if This._NNLValueIs("centralitem") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def CentralItemPositionB()
		return This._NNLValueIs("centralitemposition")

	def CentralItemPositionBQ()
		if This._NNLValueIs("centralitemposition") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def CentralPositionB()
		return This._NNLValueIs("centralposition")

	def CentralPositionBQ()
		if This._NNLValueIs("centralposition") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def CharCaseB()
		return This._NNLValueIs("charcase")

	def CharCaseBQ()
		if This._NNLValueIs("charcase") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def CharsAndTheirCountsB()
		return This._NNLValueIs("charsandtheircounts")

	def CharsAndTheirCountsBQ()
		if This._NNLValueIs("charsandtheircounts") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def CharsAndTheirUnicodesB()
		return This._NNLValueIs("charsandtheirunicodes")

	def CharsAndTheirUnicodesBQ()
		if This._NNLValueIs("charsandtheirunicodes") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def CharsAndUnicodesB()
		return This._NNLValueIs("charsandunicodes")

	def CharsAndUnicodesBQ()
		if This._NNLValueIs("charsandunicodes") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def CharsAndUnicodesUB()
		return This._NNLValueIs("charsandunicodesu")

	def CharsAndUnicodesUBQ()
		if This._NNLValueIs("charsandunicodesu") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def CharsBoxedB()
		return This._NNLValueIs("charsboxed")

	def CharsBoxedBQ()
		if This._NNLValueIs("charsboxed") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def CharsInvertedB()
		return This._NNLValueIs("charsinverted")

	def CharsInvertedBQ()
		if This._NNLValueIs("charsinverted") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def CharsNamesB()
		return This._NNLValueIs("charsnames")

	def CharsNamesBQ()
		if This._NNLValueIs("charsnames") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def CharsReversedB()
		return This._NNLValueIs("charsreversed")

	def CharsReversedBQ()
		if This._NNLValueIs("charsreversed") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def CharsUB()
		return This._NNLValueIs("charsu")

	def CharsUBQ()
		if This._NNLValueIs("charsu") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ClassifiedB()
		return This._NNLValueIs("classified")

	def ClassifiedBQ()
		if This._NNLValueIs("classified") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ClassNameB()
		return This._NNLValueIs("classname")

	def ClassNameBQ()
		if This._NNLValueIs("classname") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def CommonLogarithmB()
		return This._NNLValueIs("commonlogarithm")

	def CommonLogarithmBQ()
		if This._NNLValueIs("commonlogarithm") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def CompactedB()
		return This._NNLValueIs("compacted")

	def CompactedBQ()
		if This._NNLValueIs("compacted") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ConsecutiveSubStringsB()
		return This._NNLValueIs("consecutivesubstrings")

	def ConsecutiveSubStringsBQ()
		if This._NNLValueIs("consecutivesubstrings") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ConsecutiveSubStringsZB()
		return This._NNLValueIs("consecutivesubstringsz")

	def ConsecutiveSubStringsZBQ()
		if This._NNLValueIs("consecutivesubstringsz") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsADecimalPartB()
		return This._NNLValueIs("containsadecimalpart")

	def ContainsADecimalPartBQ()
		if This._NNLValueIs("containsadecimalpart") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsAFinalNumberB()
		return This._NNLValueIs("containsafinalnumber")

	def ContainsAFinalNumberBQ()
		if This._NNLValueIs("containsafinalnumber") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsAnEndingNumberB()
		return This._NNLValueIs("containsanendingnumber")

	def ContainsAnEndingNumberBQ()
		if This._NNLValueIs("containsanendingnumber") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsArabicB()
		return This._NNLValueIs("containsarabic")

	def ContainsArabicBQ()
		if This._NNLValueIs("containsarabic") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsASignB()
		return This._NNLValueIs("containsasign")

	def ContainsASignBQ()
		if This._NNLValueIs("containsasign") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsBillionsB()
		return This._NNLValueIs("containsbillions")

	def ContainsBillionsBQ()
		if This._NNLValueIs("containsbillions") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsCentralItemB()
		return This._NNLValueIs("containscentralitem")

	def ContainsCentralItemBQ()
		if This._NNLValueIs("containscentralitem") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsDecimalPartB()
		return This._NNLValueIs("containsdecimalpart")

	def ContainsDecimalPartBQ()
		if This._NNLValueIs("containsdecimalpart") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsDiacriticsB()
		return This._NNLValueIs("containsdiacritics")

	def ContainsDiacriticsBQ()
		if This._NNLValueIs("containsdiacritics") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsDigitsB()
		return This._NNLValueIs("containsdigits")

	def ContainsDigitsBQ()
		if This._NNLValueIs("containsdigits") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsDozensB()
		return This._NNLValueIs("containsdozens")

	def ContainsDozensBQ()
		if This._NNLValueIs("containsdozens") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsDuplicatesB()
		return This._NNLValueIs("containsduplicates")

	def ContainsDuplicatesBQ()
		if This._NNLValueIs("containsduplicates") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsEmptyStringsB()
		return This._NNLValueIs("containsemptystrings")

	def ContainsEmptyStringsBQ()
		if This._NNLValueIs("containsemptystrings") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsFractionalPartB()
		return This._NNLValueIs("containsfractionalpart")

	def ContainsFractionalPartBQ()
		if This._NNLValueIs("containsfractionalpart") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsHundredsB()
		return This._NNLValueIs("containshundreds")

	def ContainsHundredsBQ()
		if This._NNLValueIs("containshundreds") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsInvisibleCharsB()
		return This._NNLValueIs("containsinvisiblechars")

	def ContainsInvisibleCharsBQ()
		if This._NNLValueIs("containsinvisiblechars") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsLatinB()
		return This._NNLValueIs("containslatin")

	def ContainsLatinBQ()
		if This._NNLValueIs("containslatin") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsLettersB()
		return This._NNLValueIs("containsletters")

	def ContainsLettersBQ()
		if This._NNLValueIs("containsletters") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsListsB()
		return This._NNLValueIs("containslists")

	def ContainsListsBQ()
		if This._NNLValueIs("containslists") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsManyBillionsB()
		return This._NNLValueIs("containsmanybillions")

	def ContainsManyBillionsBQ()
		if This._NNLValueIs("containsmanybillions") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsManyDozensB()
		return This._NNLValueIs("containsmanydozens")

	def ContainsManyDozensBQ()
		if This._NNLValueIs("containsmanydozens") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsManyHundredsB()
		return This._NNLValueIs("containsmanyhundreds")

	def ContainsManyHundredsBQ()
		if This._NNLValueIs("containsmanyhundreds") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsManyMillionsB()
		return This._NNLValueIs("containsmanymillions")

	def ContainsManyMillionsBQ()
		if This._NNLValueIs("containsmanymillions") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsManyOnesB()
		return This._NNLValueIs("containsmanyones")

	def ContainsManyOnesBQ()
		if This._NNLValueIs("containsmanyones") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsManyThousandsB()
		return This._NNLValueIs("containsmanythousands")

	def ContainsManyThousandsBQ()
		if This._NNLValueIs("containsmanythousands") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsManyTrillionsB()
		return This._NNLValueIs("containsmanytrillions")

	def ContainsManyTrillionsBQ()
		if This._NNLValueIs("containsmanytrillions") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsManyZerosB()
		return This._NNLValueIs("containsmanyzeros")

	def ContainsManyZerosBQ()
		if This._NNLValueIs("containsmanyzeros") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsMarkersB()
		return This._NNLValueIs("containsmarkers")

	def ContainsMarkersBQ()
		if This._NNLValueIs("containsmarkers") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsMarquersB()
		return This._NNLValueIs("containsmarquers")

	def ContainsMarquersBQ()
		if This._NNLValueIs("containsmarquers") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsMillionsB()
		return This._NNLValueIs("containsmillions")

	def ContainsMillionsBQ()
		if This._NNLValueIs("containsmillions") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsNoDuplicatesB()
		return This._NNLValueIs("containsnoduplicates")

	def ContainsNoDuplicatesBQ()
		if This._NNLValueIs("containsnoduplicates") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsNoDuplicationsB()
		return This._NNLValueIs("containsnoduplications")

	def ContainsNoDuplicationsBQ()
		if This._NNLValueIs("containsnoduplications") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsNoNumbersB()
		return This._NNLValueIs("containsnonumbers")

	def ContainsNoNumbersBQ()
		if This._NNLValueIs("containsnonumbers") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsNoObjectsB()
		return This._NNLValueIs("containsnoobjects")

	def ContainsNoObjectsBQ()
		if This._NNLValueIs("containsnoobjects") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsNoStringsB()
		return This._NNLValueIs("containsnostrings")

	def ContainsNoStringsBQ()
		if This._NNLValueIs("containsnostrings") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsObjectsB()
		return This._NNLValueIs("containsobjects")

	def ContainsObjectsBQ()
		if This._NNLValueIs("containsobjects") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsOneOrMoreListsB()
		return This._NNLValueIs("containsoneormorelists")

	def ContainsOneOrMoreListsBQ()
		if This._NNLValueIs("containsoneormorelists") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsOnesB()
		return This._NNLValueIs("containsones")

	def ContainsOnesBQ()
		if This._NNLValueIs("containsones") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsOnlyDigitsB()
		return This._NNLValueIs("containsonlydigits")

	def ContainsOnlyDigitsBQ()
		if This._NNLValueIs("containsonlydigits") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsOnlyEmptyListsB()
		return This._NNLValueIs("containsonlyemptylists")

	def ContainsOnlyEmptyListsBQ()
		if This._NNLValueIs("containsonlyemptylists") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsOnlyLettersB()
		return This._NNLValueIs("containsonlyletters")

	def ContainsOnlyLettersBQ()
		if This._NNLValueIs("containsonlyletters") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsOnlyListsB()
		return This._NNLValueIs("containsonlylists")

	def ContainsOnlyListsBQ()
		if This._NNLValueIs("containsonlylists") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsOnlyNumbersB()
		return This._NNLValueIs("containsonlynumbers")

	def ContainsOnlyNumbersBQ()
		if This._NNLValueIs("containsonlynumbers") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsOnlySpacesB()
		return This._NNLValueIs("containsonlyspaces")

	def ContainsOnlySpacesBQ()
		if This._NNLValueIs("containsonlyspaces") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsPairsB()
		return This._NNLValueIs("containspairs")

	def ContainsPairsBQ()
		if This._NNLValueIs("containspairs") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsSeveralDozensB()
		return This._NNLValueIs("containsseveraldozens")

	def ContainsSeveralDozensBQ()
		if This._NNLValueIs("containsseveraldozens") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsSeveralOnesB()
		return This._NNLValueIs("containsseveralones")

	def ContainsSeveralOnesBQ()
		if This._NNLValueIs("containsseveralones") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsSeveralZerosB()
		return This._NNLValueIs("containsseveralzeros")

	def ContainsSeveralZerosBQ()
		if This._NNLValueIs("containsseveralzeros") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsSignB()
		return This._NNLValueIs("containssign")

	def ContainsSignBQ()
		if This._NNLValueIs("containssign") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsSinglesB()
		return This._NNLValueIs("containssingles")

	def ContainsSinglesBQ()
		if This._NNLValueIs("containssingles") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsThousandsB()
		return This._NNLValueIs("containsthousands")

	def ContainsThousandsBQ()
		if This._NNLValueIs("containsthousands") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsTrillionsB()
		return This._NNLValueIs("containstrillions")

	def ContainsTrillionsBQ()
		if This._NNLValueIs("containstrillions") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsTwoListsB()
		return This._NNLValueIs("containstwolists")

	def ContainsTwoListsBQ()
		if This._NNLValueIs("containstwolists") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsTwoNumbersB()
		return This._NNLValueIs("containstwonumbers")

	def ContainsTwoNumbersBQ()
		if This._NNLValueIs("containstwonumbers") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsTwoObjectsB()
		return This._NNLValueIs("containstwoobjects")

	def ContainsTwoObjectsBQ()
		if This._NNLValueIs("containstwoobjects") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsTwoStringsB()
		return This._NNLValueIs("containstwostrings")

	def ContainsTwoStringsBQ()
		if This._NNLValueIs("containstwostrings") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsVowelsB()
		return This._NNLValueIs("containsvowels")

	def ContainsVowelsBQ()
		if This._NNLValueIs("containsvowels") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContainsZerosB()
		return This._NNLValueIs("containszeros")

	def ContainsZerosBQ()
		if This._NNLValueIs("containszeros") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContentB()
		return This._NNLValueIs("content")

	def ContentBQ()
		if This._NNLValueIs("content") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContentUB()
		return This._NNLValueIs("contentu")

	def ContentUBQ()
		if This._NNLValueIs("contentu") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ContentWordsB()
		return This._NNLValueIs("contentwords")

	def ContentWordsBQ()
		if This._NNLValueIs("contentwords") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def CosineB()
		return This._NNLValueIs("cosine")

	def CosineBQ()
		if This._NNLValueIs("cosine") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def CotangentB()
		return This._NNLValueIs("cotangent")

	def CotangentBQ()
		if This._NNLValueIs("cotangent") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def DecimalPartValueB()
		return This._NNLValueIs("decimalpartvalue")

	def DecimalPartValueBQ()
		if This._NNLValueIs("decimalpartvalue") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def DecrementedB()
		return This._NNLValueIs("decremented")

	def DecrementedBQ()
		if This._NNLValueIs("decremented") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def DeepStringifiedB()
		return This._NNLValueIs("deepstringified")

	def DeepStringifiedBQ()
		if This._NNLValueIs("deepstringified") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def DerivativeSigmoidB()
		return This._NNLValueIs("derivativesigmoid")

	def DerivativeSigmoidBQ()
		if This._NNLValueIs("derivativesigmoid") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def DetectedLanguageB()
		return This._NNLValueIs("detectedlanguage")

	def DetectedLanguageBQ()
		if This._NNLValueIs("detectedlanguage") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def DiacriticsRemovedB()
		return This._NNLValueIs("diacriticsremoved")

	def DiacriticsRemovedBQ()
		if This._NNLValueIs("diacriticsremoved") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def DigitCountB()
		return This._NNLValueIs("digitcount")

	def DigitCountBQ()
		if This._NNLValueIs("digitcount") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def DigitSumB()
		return This._NNLValueIs("digitsum")

	def DigitSumBQ()
		if This._NNLValueIs("digitsum") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def DividorsB()
		return This._NNLValueIs("dividors")

	def DividorsBQ()
		if This._NNLValueIs("dividors") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def DivirdosB()
		return This._NNLValueIs("divirdos")

	def DivirdosBQ()
		if This._NNLValueIs("divirdos") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def DivisorsB()
		return This._NNLValueIs("divisors")

	def DivisorsBQ()
		if This._NNLValueIs("divisors") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def DotlessB()
		return This._NNLValueIs("dotless")

	def DotlessBQ()
		if This._NNLValueIs("dotless") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def DotsOnLettersRemovedB()
		return This._NNLValueIs("dotsonlettersremoved")

	def DotsOnLettersRemovedBQ()
		if This._NNLValueIs("dotsonlettersremoved") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def DotsRemovedB()
		return This._NNLValueIs("dotsremoved")

	def DotsRemovedBQ()
		if This._NNLValueIs("dotsremoved") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def DozensB()
		return This._NNLValueIs("dozens")

	def DozensBQ()
		if This._NNLValueIs("dozens") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def DuplicateCharsZB()
		return This._NNLValueIs("duplicatecharsz")

	def DuplicateCharsZBQ()
		if This._NNLValueIs("duplicatecharsz") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def DuplicatedCharsRemovedB()
		return This._NNLValueIs("duplicatedcharsremoved")

	def DuplicatedCharsRemovedBQ()
		if This._NNLValueIs("duplicatedcharsremoved") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def DuplicatedItemsZB()
		return This._NNLValueIs("duplicateditemsz")

	def DuplicatedItemsZBQ()
		if This._NNLValueIs("duplicateditemsz") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def DuplicatedStringsB()
		return This._NNLValueIs("duplicatedstrings")

	def DuplicatedStringsBQ()
		if This._NNLValueIs("duplicatedstrings") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def DuplicatedSubStringsB()
		return This._NNLValueIs("duplicatedsubstrings")

	def DuplicatedSubStringsBQ()
		if This._NNLValueIs("duplicatedsubstrings") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def DuplicateItemsZB()
		return This._NNLValueIs("duplicateitemsz")

	def DuplicateItemsZBQ()
		if This._NNLValueIs("duplicateitemsz") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def DuplicatesRemovedB()
		return This._NNLValueIs("duplicatesremoved")

	def DuplicatesRemovedBQ()
		if This._NNLValueIs("duplicatesremoved") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def DuplicatesXTZB()
		return This._NNLValueIs("duplicatesxtz")

	def DuplicatesXTZBQ()
		if This._NNLValueIs("duplicatesxtz") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def DuplicatesZB()
		return This._NNLValueIs("duplicatesz")

	def DuplicatesZBQ()
		if This._NNLValueIs("duplicatesz") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def DuplicationsZB()
		return This._NNLValueIs("duplicationsz")

	def DuplicationsZBQ()
		if This._NNLValueIs("duplicationsz") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def DupOriginsB()
		return This._NNLValueIs("duporigins")

	def DupOriginsBQ()
		if This._NNLValueIs("duporigins") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def EachCharBoxedB()
		return This._NNLValueIs("eachcharboxed")

	def EachCharBoxedBQ()
		if This._NNLValueIs("eachcharboxed") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def EachCharBoxedDashedB()
		return This._NNLValueIs("eachcharboxeddashed")

	def EachCharBoxedDashedBQ()
		if This._NNLValueIs("eachcharboxeddashed") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def EachCharBoxedRoundedB()
		return This._NNLValueIs("eachcharboxedrounded")

	def EachCharBoxedRoundedBQ()
		if This._NNLValueIs("eachcharboxedrounded") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def EachCharBoxRoundedB()
		return This._NNLValueIs("eachcharboxrounded")

	def EachCharBoxRoundedBQ()
		if This._NNLValueIs("eachcharboxrounded") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def EndsWithAFinalNumberB()
		return This._NNLValueIs("endswithafinalnumber")

	def EndsWithAFinalNumberBQ()
		if This._NNLValueIs("endswithafinalnumber") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def EndsWithANumberB()
		return This._NNLValueIs("endswithanumber")

	def EndsWithANumberBQ()
		if This._NNLValueIs("endswithanumber") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def EndsWithNumberB()
		return This._NNLValueIs("endswithnumber")

	def EndsWithNumberBQ()
		if This._NNLValueIs("endswithnumber") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def EngineB()
		return This._NNLValueIs("engine")

	def EngineBQ()
		if This._NNLValueIs("engine") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def EscapedForRegexB()
		return This._NNLValueIs("escapedforregex")

	def EscapedForRegexBQ()
		if This._NNLValueIs("escapedforregex") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def EscapedHtmlB()
		return This._NNLValueIs("escapedhtml")

	def EscapedHtmlBQ()
		if This._NNLValueIs("escapedhtml") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ExponentialB()
		return This._NNLValueIs("exponential")

	def ExponentialBQ()
		if This._NNLValueIs("exponential") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def FactorialB()
		return This._NNLValueIs("factorial")

	def FactorialBQ()
		if This._NNLValueIs("factorial") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def FactorsB()
		return This._NNLValueIs("factors")

	def FactorsBQ()
		if This._NNLValueIs("factors") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def FibonacciB()
		return This._NNLValueIs("fibonacci")

	def FibonacciBQ()
		if This._NNLValueIs("fibonacci") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def FirstAndLastItemsB()
		return This._NNLValueIs("firstandlastitems")

	def FirstAndLastItemsBQ()
		if This._NNLValueIs("firstandlastitems") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def FirstCharB()
		return This._NNLValueIs("firstchar")

	def FirstCharBQ()
		if This._NNLValueIs("firstchar") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def FirstCharRemovedB()
		return This._NNLValueIs("firstcharremoved")

	def FirstCharRemovedBQ()
		if This._NNLValueIs("firstcharremoved") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def FirstHalfB()
		return This._NNLValueIs("firsthalf")

	def FirstHalfBQ()
		if This._NNLValueIs("firsthalf") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def FirstHalfAndItsSectionB()
		return This._NNLValueIs("firsthalfanditssection")

	def FirstHalfAndItsSectionBQ()
		if This._NNLValueIs("firsthalfanditssection") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def FirstHalfAndPositionB()
		return This._NNLValueIs("firsthalfandposition")

	def FirstHalfAndPositionBQ()
		if This._NNLValueIs("firsthalfandposition") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def FirstHalfAndSectionB()
		return This._NNLValueIs("firsthalfandsection")

	def FirstHalfAndSectionBQ()
		if This._NNLValueIs("firsthalfandsection") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def FirstHalfXTZB()
		return This._NNLValueIs("firsthalfxtz")

	def FirstHalfXTZBQ()
		if This._NNLValueIs("firsthalfxtz") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def FirstHalfXTZZB()
		return This._NNLValueIs("firsthalfxtzz")

	def FirstHalfXTZZBQ()
		if This._NNLValueIs("firsthalfxtzz") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def FirstHalfZB()
		return This._NNLValueIs("firsthalfz")

	def FirstHalfZBQ()
		if This._NNLValueIs("firsthalfz") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def FirstHalfZZB()
		return This._NNLValueIs("firsthalfzz")

	def FirstHalfZZBQ()
		if This._NNLValueIs("firsthalfzz") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def FirstItemB()
		return This._NNLValueIs("firstitem")

	def FirstItemBQ()
		if This._NNLValueIs("firstitem") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def FirstLineB()
		return This._NNLValueIs("firstline")

	def FirstLineBQ()
		if This._NNLValueIs("firstline") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def FirstNonSpaceCharB()
		return This._NNLValueIs("firstnonspacechar")

	def FirstNonSpaceCharBQ()
		if This._NNLValueIs("firstnonspacechar") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def FirstSentenceB()
		return This._NNLValueIs("firstsentence")

	def FirstSentenceBQ()
		if This._NNLValueIs("firstsentence") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def FirstWordB()
		return This._NNLValueIs("firstword")

	def FirstWordBQ()
		if This._NNLValueIs("firstword") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def FlattenedB()
		return This._NNLValueIs("flattened")

	def FlattenedBQ()
		if This._NNLValueIs("flattened") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def FleschKincaidGradeB()
		return This._NNLValueIs("fleschkincaidgrade")

	def FleschKincaidGradeBQ()
		if This._NNLValueIs("fleschkincaidgrade") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def FleschReadingEaseB()
		return This._NNLValueIs("fleschreadingease")

	def FleschReadingEaseBQ()
		if This._NNLValueIs("fleschreadingease") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def FractionalPartValueB()
		return This._NNLValueIs("fractionalpartvalue")

	def FractionalPartValueBQ()
		if This._NNLValueIs("fractionalpartvalue") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def FrequenciesB()
		return This._NNLValueIs("frequencies")

	def FrequenciesBQ()
		if This._NNLValueIs("frequencies") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def GetRoundB()
		return This._NNLValueIs("getround")

	def GetRoundBQ()
		if This._NNLValueIs("getround") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def GreatestB()
		return This._NNLValueIs("greatest")

	def GreatestBQ()
		if This._NNLValueIs("greatest") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HalvesB()
		return This._NNLValueIs("halves")

	def HalvesBQ()
		if This._NNLValueIs("halves") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HalvesAndPositionsB()
		return This._NNLValueIs("halvesandpositions")

	def HalvesAndPositionsBQ()
		if This._NNLValueIs("halvesandpositions") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HalvesAndSectionsB()
		return This._NNLValueIs("halvesandsections")

	def HalvesAndSectionsBQ()
		if This._NNLValueIs("halvesandsections") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HalvesXTZB()
		return This._NNLValueIs("halvesxtz")

	def HalvesXTZBQ()
		if This._NNLValueIs("halvesxtz") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HalvesXTZZB()
		return This._NNLValueIs("halvesxtzz")

	def HalvesXTZZBQ()
		if This._NNLValueIs("halvesxtzz") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HalvesZB()
		return This._NNLValueIs("halvesz")

	def HalvesZBQ()
		if This._NNLValueIs("halvesz") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HalvesZZB()
		return This._NNLValueIs("halveszz")

	def HalvesZZBQ()
		if This._NNLValueIs("halveszz") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HasADecimalPartB()
		return This._NNLValueIs("hasadecimalpart")

	def HasADecimalPartBQ()
		if This._NNLValueIs("hasadecimalpart") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HasAFractionalPartB()
		return This._NNLValueIs("hasafractionalpart")

	def HasAFractionalPartBQ()
		if This._NNLValueIs("hasafractionalpart") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HasASignB()
		return This._NNLValueIs("hasasign")

	def HasASignBQ()
		if This._NNLValueIs("hasasign") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HasBillionsB()
		return This._NNLValueIs("hasbillions")

	def HasBillionsBQ()
		if This._NNLValueIs("hasbillions") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HasCentralCharB()
		return This._NNLValueIs("hascentralchar")

	def HasCentralCharBQ()
		if This._NNLValueIs("hascentralchar") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HasCentralItemB()
		return This._NNLValueIs("hascentralitem")

	def HasCentralItemBQ()
		if This._NNLValueIs("hascentralitem") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HasDecimalPartB()
		return This._NNLValueIs("hasdecimalpart")

	def HasDecimalPartBQ()
		if This._NNLValueIs("hasdecimalpart") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HasDiacriticsB()
		return This._NNLValueIs("hasdiacritics")

	def HasDiacriticsBQ()
		if This._NNLValueIs("hasdiacritics") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HasDuplicatedCharsB()
		return This._NNLValueIs("hasduplicatedchars")

	def HasDuplicatedCharsBQ()
		if This._NNLValueIs("hasduplicatedchars") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HasDuplicatesB()
		return This._NNLValueIs("hasduplicates")

	def HasDuplicatesBQ()
		if This._NNLValueIs("hasduplicates") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HasFractionalPartB()
		return This._NNLValueIs("hasfractionalpart")

	def HasFractionalPartBQ()
		if This._NNLValueIs("hasfractionalpart") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HasHundredsB()
		return This._NNLValueIs("hashundreds")

	def HasHundredsBQ()
		if This._NNLValueIs("hashundreds") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HasLeadingCharsB()
		return This._NNLValueIs("hasleadingchars")

	def HasLeadingCharsBQ()
		if This._NNLValueIs("hasleadingchars") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HasLeadingItemsB()
		return This._NNLValueIs("hasleadingitems")

	def HasLeadingItemsBQ()
		if This._NNLValueIs("hasleadingitems") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HasLeadingSubStringB()
		return This._NNLValueIs("hasleadingsubstring")

	def HasLeadingSubStringBQ()
		if This._NNLValueIs("hasleadingsubstring") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HasManyBillionsB()
		return This._NNLValueIs("hasmanybillions")

	def HasManyBillionsBQ()
		if This._NNLValueIs("hasmanybillions") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HasManyHundredsB()
		return This._NNLValueIs("hasmanyhundreds")

	def HasManyHundredsBQ()
		if This._NNLValueIs("hasmanyhundreds") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HasManyOnesB()
		return This._NNLValueIs("hasmanyones")

	def HasManyOnesBQ()
		if This._NNLValueIs("hasmanyones") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HasManyThousandsB()
		return This._NNLValueIs("hasmanythousands")

	def HasManyThousandsBQ()
		if This._NNLValueIs("hasmanythousands") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HasManyTrillionsB()
		return This._NNLValueIs("hasmanytrillions")

	def HasManyTrillionsBQ()
		if This._NNLValueIs("hasmanytrillions") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HasManyZerosB()
		return This._NNLValueIs("hasmanyzeros")

	def HasManyZerosBQ()
		if This._NNLValueIs("hasmanyzeros") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HasMarkB()
		return This._NNLValueIs("hasmark")

	def HasMarkBQ()
		if This._NNLValueIs("hasmark") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HasMillionsB()
		return This._NNLValueIs("hasmillions")

	def HasMillionsBQ()
		if This._NNLValueIs("hasmillions") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HasOnesB()
		return This._NNLValueIs("hasones")

	def HasOnesBQ()
		if This._NNLValueIs("hasones") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HasSeveralBillionsB()
		return This._NNLValueIs("hasseveralbillions")

	def HasSeveralBillionsBQ()
		if This._NNLValueIs("hasseveralbillions") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HasSeveralHundredsB()
		return This._NNLValueIs("hasseveralhundreds")

	def HasSeveralHundredsBQ()
		if This._NNLValueIs("hasseveralhundreds") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HasSeveralMilllionsB()
		return This._NNLValueIs("hasseveralmilllions")

	def HasSeveralMilllionsBQ()
		if This._NNLValueIs("hasseveralmilllions") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HasSeveralOnesB()
		return This._NNLValueIs("hasseveralones")

	def HasSeveralOnesBQ()
		if This._NNLValueIs("hasseveralones") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HasSeveralThousandsB()
		return This._NNLValueIs("hasseveralthousands")

	def HasSeveralThousandsBQ()
		if This._NNLValueIs("hasseveralthousands") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HasSeveralTrillionsB()
		return This._NNLValueIs("hasseveraltrillions")

	def HasSeveralTrillionsBQ()
		if This._NNLValueIs("hasseveraltrillions") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HasSeveralZerosB()
		return This._NNLValueIs("hasseveralzeros")

	def HasSeveralZerosBQ()
		if This._NNLValueIs("hasseveralzeros") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HasSignB()
		return This._NNLValueIs("hassign")

	def HasSignBQ()
		if This._NNLValueIs("hassign") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HasSynonymsB()
		return This._NNLValueIs("hassynonyms")

	def HasSynonymsBQ()
		if This._NNLValueIs("hassynonyms") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HasThousandsB()
		return This._NNLValueIs("hasthousands")

	def HasThousandsBQ()
		if This._NNLValueIs("hasthousands") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HasTrailingCharsB()
		return This._NNLValueIs("hastrailingchars")

	def HasTrailingCharsBQ()
		if This._NNLValueIs("hastrailingchars") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HasTrailingItemsB()
		return This._NNLValueIs("hastrailingitems")

	def HasTrailingItemsBQ()
		if This._NNLValueIs("hastrailingitems") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HasTrailingSubStringB()
		return This._NNLValueIs("hastrailingsubstring")

	def HasTrailingSubStringBQ()
		if This._NNLValueIs("hastrailingsubstring") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HasTrillionsB()
		return This._NNLValueIs("hastrillions")

	def HasTrillionsBQ()
		if This._NNLValueIs("hastrillions") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HasVowelsB()
		return This._NNLValueIs("hasvowels")

	def HasVowelsBQ()
		if This._NNLValueIs("hasvowels") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HasZerosB()
		return This._NNLValueIs("haszeros")

	def HasZerosBQ()
		if This._NNLValueIs("haszeros") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HexUnicodeB()
		return This._NNLValueIs("hexunicode")

	def HexUnicodeBQ()
		if This._NNLValueIs("hexunicode") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HexUnicodesB()
		return This._NNLValueIs("hexunicodes")

	def HexUnicodesBQ()
		if This._NNLValueIs("hexunicodes") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HighestB()
		return This._NNLValueIs("highest")

	def HighestBQ()
		if This._NNLValueIs("highest") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HistogramB()
		return This._NNLValueIs("histogram")

	def HistogramBQ()
		if This._NNLValueIs("histogram") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HowManyDigitsB()
		return This._NNLValueIs("howmanydigits")

	def HowManyDigitsBQ()
		if This._NNLValueIs("howmanydigits") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HowManyDuplicatesB()
		return This._NNLValueIs("howmanyduplicates")

	def HowManyDuplicatesBQ()
		if This._NNLValueIs("howmanyduplicates") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HowManyItemsB()
		return This._NNLValueIs("howmanyitems")

	def HowManyItemsBQ()
		if This._NNLValueIs("howmanyitems") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HowManyLeadingCharB()
		return This._NNLValueIs("howmanyleadingchar")

	def HowManyLeadingCharBQ()
		if This._NNLValueIs("howmanyleadingchar") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HowManySubStringsB()
		return This._NNLValueIs("howmanysubstrings")

	def HowManySubStringsBQ()
		if This._NNLValueIs("howmanysubstrings") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HowManyTrailingCharB()
		return This._NNLValueIs("howmanytrailingchar")

	def HowManyTrailingCharBQ()
		if This._NNLValueIs("howmanytrailingchar") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HowManyWordsB()
		return This._NNLValueIs("howmanywords")

	def HowManyWordsBQ()
		if This._NNLValueIs("howmanywords") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HsManyMillionsB()
		return This._NNLValueIs("hsmanymillions")

	def HsManyMillionsBQ()
		if This._NNLValueIs("hsmanymillions") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HtmlDecodedB()
		return This._NNLValueIs("htmldecoded")

	def HtmlDecodedBQ()
		if This._NNLValueIs("htmldecoded") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HtmlEncodedB()
		return This._NNLValueIs("htmlencoded")

	def HtmlEncodedBQ()
		if This._NNLValueIs("htmlencoded") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HTMLEscapeB()
		return This._NNLValueIs("htmlescape")

	def HTMLEscapeBQ()
		if This._NNLValueIs("htmlescape") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HtmlEscapedB()
		return This._NNLValueIs("htmlescaped")

	def HtmlEscapedBQ()
		if This._NNLValueIs("htmlescaped") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HyperbolicCosineB()
		return This._NNLValueIs("hyperboliccosine")

	def HyperbolicCosineBQ()
		if This._NNLValueIs("hyperboliccosine") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def HyperbolicSineB()
		return This._NNLValueIs("hyperbolicsine")

	def HyperbolicSineBQ()
		if This._NNLValueIs("hyperbolicsine") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IncrementedB()
		return This._NNLValueIs("incremented")

	def IncrementedBQ()
		if This._NNLValueIs("incremented") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IndexB()
		return This._NNLValueIs("index")

	def IndexBQ()
		if This._NNLValueIs("index") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def InfereTypeB()
		return This._NNLValueIs("inferetype")

	def InfereTypeBQ()
		if This._NNLValueIs("inferetype") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def InitialsB()
		return This._NNLValueIs("initials")

	def InitialsBQ()
		if This._NNLValueIs("initials") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IntegerPartB()
		return This._NNLValueIs("integerpart")

	def IntegerPartBQ()
		if This._NNLValueIs("integerpart") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IntegerPartStringValueB()
		return This._NNLValueIs("integerpartstringvalue")

	def IntegerPartStringValueBQ()
		if This._NNLValueIs("integerpartstringvalue") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IntegerPartToHexFormB()
		return This._NNLValueIs("integerparttohexform")

	def IntegerPartToHexFormBQ()
		if This._NNLValueIs("integerparttohexform") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IntegerPartToOctalFormB()
		return This._NNLValueIs("integerparttooctalform")

	def IntegerPartToOctalFormBQ()
		if This._NNLValueIs("integerparttooctalform") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IntegerPartValueB()
		return This._NNLValueIs("integerpartvalue")

	def IntegerPartValueBQ()
		if This._NNLValueIs("integerpartvalue") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IntegerPartWithoutSignB()
		return This._NNLValueIs("integerpartwithoutsign")

	def IntegerPartWithoutSignBQ()
		if This._NNLValueIs("integerpartwithoutsign") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IntergerPartB()
		return This._NNLValueIs("intergerpart")

	def IntergerPartBQ()
		if This._NNLValueIs("intergerpart") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IntergersB()
		return This._NNLValueIs("intergers")

	def IntergersBQ()
		if This._NNLValueIs("intergers") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def InverseB()
		return This._NNLValueIs("inverse")

	def InverseBQ()
		if This._NNLValueIs("inverse") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def InversedB()
		return This._NNLValueIs("inversed")

	def InversedBQ()
		if This._NNLValueIs("inversed") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsACharB()
		return This._NNLValueIs("isachar")

	def IsACharBQ()
		if This._NNLValueIs("isachar") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsACharNameB()
		return This._NNLValueIs("isacharname")

	def IsACharNameBQ()
		if This._NNLValueIs("isacharname") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsAClassB()
		return This._NNLValueIs("isaclass")

	def IsAClassBQ()
		if This._NNLValueIs("isaclass") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsADigitB()
		return This._NNLValueIs("isadigit")

	def IsADigitBQ()
		if This._NNLValueIs("isadigit") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsAFunctionB()
		return This._NNLValueIs("isafunction")

	def IsAFunctionBQ()
		if This._NNLValueIs("isafunction") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsAFunctionNameB()
		return This._NNLValueIs("isafunctionname")

	def IsAFunctionNameBQ()
		if This._NNLValueIs("isafunctionname") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsAHashListB()
		return This._NNLValueIs("isahashlist")

	def IsAHashListBQ()
		if This._NNLValueIs("isahashlist") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsAHexUnicodeB()
		return This._NNLValueIs("isahexunicode")

	def IsAHexUnicodeBQ()
		if This._NNLValueIs("isahexunicode") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsALetterB()
		return This._NNLValueIs("isaletter")

	def IsALetterBQ()
		if This._NNLValueIs("isaletter") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsAListB()
		return This._NNLValueIs("isalist")

	def IsAListBQ()
		if This._NNLValueIs("isalist") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsAllLettersB()
		return This._NNLValueIs("isallletters")

	def IsAllLettersBQ()
		if This._NNLValueIs("isallletters") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsAlmostAFunctionCallB()
		return This._NNLValueIs("isalmostafunctioncall")

	def IsAlmostAFunctionCallBQ()
		if This._NNLValueIs("isalmostafunctioncall") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsAlphaStringB()
		return This._NNLValueIs("isalphastring")

	def IsAlphaStringBQ()
		if This._NNLValueIs("isalphastring") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsAndcColNamedParamB()
		return This._NNLValueIs("isandccolnamedparam")

	def IsAndcColNamedParamBQ()
		if This._NNLValueIs("isandccolnamedparam") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsAndColAtNamedParamB()
		return This._NNLValueIs("isandcolatnamedparam")

	def IsAndColAtNamedParamBQ()
		if This._NNLValueIs("isandcolatnamedparam") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsAndColumnNamedParamB()
		return This._NNLValueIs("isandcolumnnamedparam")

	def IsAndColumnNamedParamBQ()
		if This._NNLValueIs("isandcolumnnamedparam") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsAndNamedParamB()
		return This._NNLValueIs("isandnamedparam")

	def IsAndNamedParamBQ()
		if This._NNLValueIs("isandnamedparam") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsAndReturnNamedParamB()
		return This._NNLValueIs("isandreturnnamedparam")

	def IsAndReturnNamedParamBQ()
		if This._NNLValueIs("isandreturnnamedparam") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsAndRowAtNamedParamB()
		return This._NNLValueIs("isandrowatnamedparam")

	def IsAndRowAtNamedParamBQ()
		if This._NNLValueIs("isandrowatnamedparam") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsAndRowNamedParamB()
		return This._NNLValueIs("isandrownamedparam")

	def IsAndRowNamedParamBQ()
		if This._NNLValueIs("isandrownamedparam") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsAnIntegerB()
		return This._NNLValueIs("isaninteger")

	def IsAnIntegerBQ()
		if This._NNLValueIs("isaninteger") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsAnObjectB()
		return This._NNLValueIs("isanobject")

	def IsAnObjectBQ()
		if This._NNLValueIs("isanobject") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsANumberB()
		return This._NNLValueIs("isanumber")

	def IsANumberBQ()
		if This._NNLValueIs("isanumber") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsAObjectB()
		return This._NNLValueIs("isaobject")

	def IsAObjectBQ()
		if This._NNLValueIs("isaobject") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsAPairB()
		return This._NNLValueIs("isapair")

	def IsAPairBQ()
		if This._NNLValueIs("isapair") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsAPrimeB()
		return This._NNLValueIs("isaprime")

	def IsAPrimeBQ()
		if This._NNLValueIs("isaprime") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsAPrimeNumberB()
		return This._NNLValueIs("isaprimenumber")

	def IsAPrimeNumberBQ()
		if This._NNLValueIs("isaprimenumber") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsArabicB()
		return This._NNLValueIs("isarabic")

	def IsArabicBQ()
		if This._NNLValueIs("isarabic") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsArabicScriptB()
		return This._NNLValueIs("isarabicscript")

	def IsArabicScriptBQ()
		if This._NNLValueIs("isarabicscript") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsASetB()
		return This._NNLValueIs("isaset")

	def IsASetBQ()
		if This._NNLValueIs("isaset") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsAStringB()
		return This._NNLValueIs("isastring")

	def IsAStringBQ()
		if This._NNLValueIs("isastring") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsAtCharsNamedParamB()
		return This._NNLValueIs("isatcharsnamedparam")

	def IsAtCharsNamedParamBQ()
		if This._NNLValueIs("isatcharsnamedparam") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsAtNamedParamB()
		return This._NNLValueIs("isatnamedparam")

	def IsAtNamedParamBQ()
		if This._NNLValueIs("isatnamedparam") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsAtPositionNamedParamB()
		return This._NNLValueIs("isatpositionnamedparam")

	def IsAtPositionNamedParamBQ()
		if This._NNLValueIs("isatpositionnamedparam") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsBalancedB()
		return This._NNLValueIs("isbalanced")

	def IsBalancedBQ()
		if This._NNLValueIs("isbalanced") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsBetweenNamedParamB()
		return This._NNLValueIs("isbetweennamedparam")

	def IsBetweenNamedParamBQ()
		if This._NNLValueIs("isbetweennamedparam") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsBetweenRowNamedParamB()
		return This._NNLValueIs("isbetweenrownamedparam")

	def IsBetweenRowNamedParamBQ()
		if This._NNLValueIs("isbetweenrownamedparam") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsBigNumberB()
		return This._NNLValueIs("isbignumber")

	def IsBigNumberBQ()
		if This._NNLValueIs("isbignumber") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsBlankB()
		return This._NNLValueIs("isblank")

	def IsBlankBQ()
		if This._NNLValueIs("isblank") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsBooleanB()
		return This._NNLValueIs("isboolean")

	def IsBooleanBQ()
		if This._NNLValueIs("isboolean") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsByNamedParamB()
		return This._NNLValueIs("isbynamedparam")

	def IsByNamedParamBQ()
		if This._NNLValueIs("isbynamedparam") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsByRowNamedParamB()
		return This._NNLValueIs("isbyrownamedparam")

	def IsByRowNamedParamBQ()
		if This._NNLValueIs("isbyrownamedparam") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsCamelCaseB()
		return This._NNLValueIs("iscamelcase")

	def IsCamelCaseBQ()
		if This._NNLValueIs("iscamelcase") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsCapitalcaseB()
		return This._NNLValueIs("iscapitalcase")

	def IsCapitalcaseBQ()
		if This._NNLValueIs("iscapitalcase") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsCharB()
		return This._NNLValueIs("ischar")

	def IsCharBQ()
		if This._NNLValueIs("ischar") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsCharNameB()
		return This._NNLValueIs("ischarname")

	def IsCharNameBQ()
		if This._NNLValueIs("ischarname") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsCharsSortedAscB()
		return This._NNLValueIs("ischarssortedasc")

	def IsCharsSortedAscBQ()
		if This._NNLValueIs("ischarssortedasc") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsCharsSortedAscendingB()
		return This._NNLValueIs("ischarssortedascending")

	def IsCharsSortedAscendingBQ()
		if This._NNLValueIs("ischarssortedascending") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsCharsSortedDescB()
		return This._NNLValueIs("ischarssorteddesc")

	def IsCharsSortedDescBQ()
		if This._NNLValueIs("ischarssorteddesc") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsCircledDigitB()
		return This._NNLValueIs("iscircleddigit")

	def IsCircledDigitBQ()
		if This._NNLValueIs("iscircleddigit") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsCircledNumberB()
		return This._NNLValueIs("iscirclednumber")

	def IsCircledNumberBQ()
		if This._NNLValueIs("iscirclednumber") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsComingNamedParamB()
		return This._NNLValueIs("iscomingnamedparam")

	def IsComingNamedParamBQ()
		if This._NNLValueIs("iscomingnamedparam") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsCommonScriptB()
		return This._NNLValueIs("iscommonscript")

	def IsCommonScriptBQ()
		if This._NNLValueIs("iscommonscript") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsContiguousB()
		return This._NNLValueIs("iscontiguous")

	def IsContiguousBQ()
		if This._NNLValueIs("iscontiguous") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsControlB()
		return This._NNLValueIs("iscontrol")

	def IsControlBQ()
		if This._NNLValueIs("iscontrol") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsCountryAbbreviationB()
		return This._NNLValueIs("iscountryabbreviation")

	def IsCountryAbbreviationBQ()
		if This._NNLValueIs("iscountryabbreviation") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsCountryCodeB()
		return This._NNLValueIs("iscountrycode")

	def IsCountryCodeBQ()
		if This._NNLValueIs("iscountrycode") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsCountryIdentifierB()
		return This._NNLValueIs("iscountryidentifier")

	def IsCountryIdentifierBQ()
		if This._NNLValueIs("iscountryidentifier") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsCountryNameB()
		return This._NNLValueIs("iscountryname")

	def IsCountryNameBQ()
		if This._NNLValueIs("iscountryname") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsCountryNumberB()
		return This._NNLValueIs("iscountrynumber")

	def IsCountryNumberBQ()
		if This._NNLValueIs("iscountrynumber") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsCountryPhoneCodeB()
		return This._NNLValueIs("iscountryphonecode")

	def IsCountryPhoneCodeBQ()
		if This._NNLValueIs("iscountryphonecode") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsCurrencyNameB()
		return This._NNLValueIs("iscurrencyname")

	def IsCurrencyNameBQ()
		if This._NNLValueIs("iscurrencyname") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsCurrencySymbolB()
		return This._NNLValueIs("iscurrencysymbol")

	def IsCurrencySymbolBQ()
		if This._NNLValueIs("iscurrencysymbol") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsDigitB()
		return This._NNLValueIs("isdigit")

	def IsDigitBQ()
		if This._NNLValueIs("isdigit") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsDigitPalindromeB()
		return This._NNLValueIs("isdigitpalindrome")

	def IsDigitPalindromeBQ()
		if This._NNLValueIs("isdigitpalindrome") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsEmailLikeB()
		return This._NNLValueIs("isemaillike")

	def IsEmailLikeBQ()
		if This._NNLValueIs("isemaillike") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsEmptyB()
		return This._NNLValueIs("isempty")

	def IsEmptyBQ()
		if This._NNLValueIs("isempty") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsEqualToNamedParamB()
		return This._NNLValueIs("isequaltonamedparam")

	def IsEqualToNamedParamBQ()
		if This._NNLValueIs("isequaltonamedparam") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsEvenB()
		return This._NNLValueIs("iseven")

	def IsEvenBQ()
		if This._NNLValueIs("iseven") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsEvenOrOddB()
		return This._NNLValueIs("isevenorodd")

	def IsEvenOrOddBQ()
		if This._NNLValueIs("isevenorodd") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsFalseB()
		return This._NNLValueIs("isfalse")

	def IsFalseBQ()
		if This._NNLValueIs("isfalse") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsFardiOrZawjiB()
		return This._NNLValueIs("isfardiorzawji")

	def IsFardiOrZawjiBQ()
		if This._NNLValueIs("isfardiorzawji") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsFromNamedParamB()
		return This._NNLValueIs("isfromnamedparam")

	def IsFromNamedParamBQ()
		if This._NNLValueIs("isfromnamedparam") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsFuncB()
		return This._NNLValueIs("isfunc")

	def IsFuncBQ()
		if This._NNLValueIs("isfunc") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsHanScriptB()
		return This._NNLValueIs("ishanscript")

	def IsHanScriptBQ()
		if This._NNLValueIs("ishanscript") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsHashListB()
		return This._NNLValueIs("ishashlist")

	def IsHashListBQ()
		if This._NNLValueIs("ishashlist") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsHexUnicodeB()
		return This._NNLValueIs("ishexunicode")

	def IsHexUnicodeBQ()
		if This._NNLValueIs("ishexunicode") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsHybridcaseB()
		return This._NNLValueIs("ishybridcase")

	def IsHybridcaseBQ()
		if This._NNLValueIs("ishybridcase") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsHybridScriptB()
		return This._NNLValueIs("ishybridscript")

	def IsHybridScriptBQ()
		if This._NNLValueIs("ishybridscript") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsIdentifierB()
		return This._NNLValueIs("isidentifier")

	def IsIdentifierBQ()
		if This._NNLValueIs("isidentifier") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsInheritedScriptB()
		return This._NNLValueIs("isinheritedscript")

	def IsInheritedScriptBQ()
		if This._NNLValueIs("isinheritedscript") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsIntegerB()
		return This._NNLValueIs("isinteger")

	def IsIntegerBQ()
		if This._NNLValueIs("isinteger") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsIntegerOrRealB()
		return This._NNLValueIs("isintegerorreal")

	def IsIntegerOrRealBQ()
		if This._NNLValueIs("isintegerorreal") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsIntergerOrRealB()
		return This._NNLValueIs("isintergerorreal")

	def IsIntergerOrRealBQ()
		if This._NNLValueIs("isintergerorreal") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsIsogramB()
		return This._NNLValueIs("isisogram")

	def IsIsogramBQ()
		if This._NNLValueIs("isisogram") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsItemB()
		return This._NNLValueIs("isitem")

	def IsItemBQ()
		if This._NNLValueIs("isitem") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsKebabCaseB()
		return This._NNLValueIs("iskebabcase")

	def IsKebabCaseBQ()
		if This._NNLValueIs("iskebabcase") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsLanguageAbbreviationB()
		return This._NNLValueIs("islanguageabbreviation")

	def IsLanguageAbbreviationBQ()
		if This._NNLValueIs("islanguageabbreviation") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsLanguageCodeB()
		return This._NNLValueIs("islanguagecode")

	def IsLanguageCodeBQ()
		if This._NNLValueIs("islanguagecode") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsLanguageIdentifierB()
		return This._NNLValueIs("islanguageidentifier")

	def IsLanguageIdentifierBQ()
		if This._NNLValueIs("islanguageidentifier") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsLanguageNameB()
		return This._NNLValueIs("islanguagename")

	def IsLanguageNameBQ()
		if This._NNLValueIs("islanguagename") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsLanguageNumberB()
		return This._NNLValueIs("islanguagenumber")

	def IsLanguageNumberBQ()
		if This._NNLValueIs("islanguagenumber") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsLatinB()
		return This._NNLValueIs("islatin")

	def IsLatinBQ()
		if This._NNLValueIs("islatin") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsLatinScriptB()
		return This._NNLValueIs("islatinscript")

	def IsLatinScriptBQ()
		if This._NNLValueIs("islatinscript") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsLeftToRightB()
		return This._NNLValueIs("islefttoright")

	def IsLeftToRightBQ()
		if This._NNLValueIs("islefttoright") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsLetterB()
		return This._NNLValueIs("isletter")

	def IsLetterBQ()
		if This._NNLValueIs("isletter") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsLocaleAbbreviationB()
		return This._NNLValueIs("islocaleabbreviation")

	def IsLocaleAbbreviationBQ()
		if This._NNLValueIs("islocaleabbreviation") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsLocaleListB()
		return This._NNLValueIs("islocalelist")

	def IsLocaleListBQ()
		if This._NNLValueIs("islocalelist") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsLowercaseB()
		return This._NNLValueIs("islowercase")

	def IsLowercaseBQ()
		if This._NNLValueIs("islowercase") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsLowercasedB()
		return This._NNLValueIs("islowercased")

	def IsLowercasedBQ()
		if This._NNLValueIs("islowercased") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsMarkerB()
		return This._NNLValueIs("ismarker")

	def IsMarkerBQ()
		if This._NNLValueIs("ismarker") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsMarquerB()
		return This._NNLValueIs("ismarquer")

	def IsMarquerBQ()
		if This._NNLValueIs("ismarquer") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsMemberB()
		return This._NNLValueIs("ismember")

	def IsMemberBQ()
		if This._NNLValueIs("ismember") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsMultilingualStringB()
		return This._NNLValueIs("ismultilingualstring")

	def IsMultilingualStringBQ()
		if This._NNLValueIs("ismultilingualstring") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsNamedObjectB()
		return This._NNLValueIs("isnamedobject")

	def IsNamedObjectBQ()
		if This._NNLValueIs("isnamedobject") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsNamedParamB()
		return This._NNLValueIs("isnamedparam")

	def IsNamedParamBQ()
		if This._NNLValueIs("isnamedparam") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsNegativeB()
		return This._NNLValueIs("isnegative")

	def IsNegativeBQ()
		if This._NNLValueIs("isnegative") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsNegativeIntegerB()
		return This._NNLValueIs("isnegativeinteger")

	def IsNegativeIntegerBQ()
		if This._NNLValueIs("isnegativeinteger") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsNestedB()
		return This._NNLValueIs("isnested")

	def IsNestedBQ()
		if This._NNLValueIs("isnested") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsNorNamedParamB()
		return This._NNLValueIs("isnornamedparam")

	def IsNorNamedParamBQ()
		if This._NNLValueIs("isnornamedparam") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsNotAListB()
		return This._NNLValueIs("isnotalist")

	def IsNotAListBQ()
		if This._NNLValueIs("isnotalist") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsNotAnObjectB()
		return This._NNLValueIs("isnotanobject")

	def IsNotAnObjectBQ()
		if This._NNLValueIs("isnotanobject") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsNotANumberB()
		return This._NNLValueIs("isnotanumber")

	def IsNotANumberBQ()
		if This._NNLValueIs("isnotanumber") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsNotAStringB()
		return This._NNLValueIs("isnotastring")

	def IsNotAStringBQ()
		if This._NNLValueIs("isnotastring") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsNotEmptyB()
		return This._NNLValueIs("isnotempty")

	def IsNotEmptyBQ()
		if This._NNLValueIs("isnotempty") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsNotEvenB()
		return This._NNLValueIs("isnoteven")

	def IsNotEvenBQ()
		if This._NNLValueIs("isnoteven") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsNotHashListB()
		return This._NNLValueIs("isnothashlist")

	def IsNotHashListBQ()
		if This._NNLValueIs("isnothashlist") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsNotLetterB()
		return This._NNLValueIs("isnotletter")

	def IsNotLetterBQ()
		if This._NNLValueIs("isnotletter") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsNotOddB()
		return This._NNLValueIs("isnotodd")

	def IsNotOddBQ()
		if This._NNLValueIs("isnotodd") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsNotSignedB()
		return This._NNLValueIs("isnotsigned")

	def IsNotSignedBQ()
		if This._NNLValueIs("isnotsigned") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsNumericStringB()
		return This._NNLValueIs("isnumericstring")

	def IsNumericStringBQ()
		if This._NNLValueIs("isnumericstring") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsOddB()
		return This._NNLValueIs("isodd")

	def IsOddBQ()
		if This._NNLValueIs("isodd") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsOddOrEvenB()
		return This._NNLValueIs("isoddoreven")

	def IsOddOrEvenBQ()
		if This._NNLValueIs("isoddoreven") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsOneDigitB()
		return This._NNLValueIs("isonedigit")

	def IsOneDigitBQ()
		if This._NNLValueIs("isonedigit") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsPairB()
		return This._NNLValueIs("ispair")

	def IsPairBQ()
		if This._NNLValueIs("ispair") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsPalindromeB()
		return This._NNLValueIs("ispalindrome")

	def IsPalindromeBQ()
		if This._NNLValueIs("ispalindrome") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsPalindromeNumberB()
		return This._NNLValueIs("ispalindromenumber")

	def IsPalindromeNumberBQ()
		if This._NNLValueIs("ispalindromenumber") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsPalindromeWordsB()
		return This._NNLValueIs("ispalindromewords")

	def IsPalindromeWordsBQ()
		if This._NNLValueIs("ispalindromewords") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsPangramB()
		return This._NNLValueIs("ispangram")

	def IsPangramBQ()
		if This._NNLValueIs("ispangram") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsPerfectB()
		return This._NNLValueIs("isperfect")

	def IsPerfectBQ()
		if This._NNLValueIs("isperfect") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsPerfectNumberB()
		return This._NNLValueIs("isperfectnumber")

	def IsPerfectNumberBQ()
		if This._NNLValueIs("isperfectnumber") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsPositionNamedParamB()
		return This._NNLValueIs("ispositionnamedparam")

	def IsPositionNamedParamBQ()
		if This._NNLValueIs("ispositionnamedparam") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsPositiveB()
		return This._NNLValueIs("ispositive")

	def IsPositiveBQ()
		if This._NNLValueIs("ispositive") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsPositiveIntegerB()
		return This._NNLValueIs("ispositiveinteger")

	def IsPositiveIntegerBQ()
		if This._NNLValueIs("ispositiveinteger") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsPrimeB()
		return This._NNLValueIs("isprime")

	def IsPrimeBQ()
		if This._NNLValueIs("isprime") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsPrimeNumberB()
		return This._NNLValueIs("isprimenumber")

	def IsPrimeNumberBQ()
		if This._NNLValueIs("isprimenumber") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsRealB()
		return This._NNLValueIs("isreal")

	def IsRealBQ()
		if This._NNLValueIs("isreal") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsRealNumberB()
		return This._NNLValueIs("isrealnumber")

	def IsRealNumberBQ()
		if This._NNLValueIs("isrealnumber") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsReturnedAsNamedParamB()
		return This._NNLValueIs("isreturnedasnamedparam")

	def IsReturnedAsNamedParamBQ()
		if This._NNLValueIs("isreturnedasnamedparam") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsReturningNamedParamB()
		return This._NNLValueIs("isreturningnamedparam")

	def IsReturningNamedParamBQ()
		if This._NNLValueIs("isreturningnamedparam") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsReturnNamedParamB()
		return This._NNLValueIs("isreturnnamedparam")

	def IsReturnNamedParamBQ()
		if This._NNLValueIs("isreturnnamedparam") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsReturnNthNamedParamB()
		return This._NNLValueIs("isreturnnthnamedparam")

	def IsReturnNthNamedParamBQ()
		if This._NNLValueIs("isreturnnthnamedparam") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsRightToLeftB()
		return This._NNLValueIs("isrighttoleft")

	def IsRightToLeftBQ()
		if This._NNLValueIs("isrighttoleft") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsScriptB()
		return This._NNLValueIs("isscript")

	def IsScriptBQ()
		if This._NNLValueIs("isscript") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsScriptAbbreviationB()
		return This._NNLValueIs("isscriptabbreviation")

	def IsScriptAbbreviationBQ()
		if This._NNLValueIs("isscriptabbreviation") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsScriptCodeB()
		return This._NNLValueIs("isscriptcode")

	def IsScriptCodeBQ()
		if This._NNLValueIs("isscriptcode") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsScriptIdentifierB()
		return This._NNLValueIs("isscriptidentifier")

	def IsScriptIdentifierBQ()
		if This._NNLValueIs("isscriptidentifier") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsScriptNameB()
		return This._NNLValueIs("isscriptname")

	def IsScriptNameBQ()
		if This._NNLValueIs("isscriptname") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsScriptNumberB()
		return This._NNLValueIs("isscriptnumber")

	def IsScriptNumberBQ()
		if This._NNLValueIs("isscriptnumber") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsSeedNamedParamB()
		return This._NNLValueIs("isseednamedparam")

	def IsSeedNamedParamBQ()
		if This._NNLValueIs("isseednamedparam") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsSetB()
		return This._NNLValueIs("isset")

	def IsSetBQ()
		if This._NNLValueIs("isset") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsSignedB()
		return This._NNLValueIs("issigned")

	def IsSignedBQ()
		if This._NNLValueIs("issigned") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsSingleB()
		return This._NNLValueIs("issingle")

	def IsSingleBQ()
		if This._NNLValueIs("issingle") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsSizeNamedParamB()
		return This._NNLValueIs("issizenamedparam")

	def IsSizeNamedParamBQ()
		if This._NNLValueIs("issizenamedparam") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsSnakeCaseB()
		return This._NNLValueIs("issnakecase")

	def IsSnakeCaseBQ()
		if This._NNLValueIs("issnakecase") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsSortedB()
		return This._NNLValueIs("issorted")

	def IsSortedBQ()
		if This._NNLValueIs("issorted") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsStartingAtNamedParamB()
		return This._NNLValueIs("isstartingatnamedparam")

	def IsStartingAtNamedParamBQ()
		if This._NNLValueIs("isstartingatnamedparam") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsStepNamedParamB()
		return This._NNLValueIs("isstepnamedparam")

	def IsStepNamedParamBQ()
		if This._NNLValueIs("isstepnamedparam") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsStoppingAtNamedParamB()
		return This._NNLValueIs("isstoppingatnamedparam")

	def IsStoppingAtNamedParamBQ()
		if This._NNLValueIs("isstoppingatnamedparam") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsStopwordB()
		return This._NNLValueIs("isstopword")

	def IsStopwordBQ()
		if This._NNLValueIs("isstopword") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsStrictlyNegativeB()
		return This._NNLValueIs("isstrictlynegative")

	def IsStrictlyNegativeBQ()
		if This._NNLValueIs("isstrictlynegative") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsStrictlyPositiveB()
		return This._NNLValueIs("isstrictlypositive")

	def IsStrictlyPositiveBQ()
		if This._NNLValueIs("isstrictlypositive") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsStzNumberB()
		return This._NNLValueIs("isstznumber")

	def IsStzNumberBQ()
		if This._NNLValueIs("isstznumber") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsTitlecaseB()
		return This._NNLValueIs("istitlecase")

	def IsTitlecaseBQ()
		if This._NNLValueIs("istitlecase") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsTitleCasedB()
		return This._NNLValueIs("istitlecased")

	def IsTitleCasedBQ()
		if This._NNLValueIs("istitlecased") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsToNamedParamB()
		return This._NNLValueIs("istonamedparam")

	def IsToNamedParamBQ()
		if This._NNLValueIs("istonamedparam") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsToOrToPositionB()
		return This._NNLValueIs("istoortoposition")

	def IsToOrToPositionBQ()
		if This._NNLValueIs("istoortoposition") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsToPositionNamedParamB()
		return This._NNLValueIs("istopositionnamedparam")

	def IsToPositionNamedParamBQ()
		if This._NNLValueIs("istopositionnamedparam") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsToPositionOrToB()
		return This._NNLValueIs("istopositionorto")

	def IsToPositionOrToBQ()
		if This._NNLValueIs("istopositionorto") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsTrueB()
		return This._NNLValueIs("istrue")

	def IsTrueBQ()
		if This._NNLValueIs("istrue") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsUnsignedB()
		return This._NNLValueIs("isunsigned")

	def IsUnsignedBQ()
		if This._NNLValueIs("isunsigned") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsUppercaseB()
		return This._NNLValueIs("isuppercase")

	def IsUppercaseBQ()
		if This._NNLValueIs("isuppercase") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsUppercasedB()
		return This._NNLValueIs("isuppercased")

	def IsUppercasedBQ()
		if This._NNLValueIs("isuppercased") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsUrlLikeB()
		return This._NNLValueIs("isurllike")

	def IsUrlLikeBQ()
		if This._NNLValueIs("isurllike") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsVowelB()
		return This._NNLValueIs("isvowel")

	def IsVowelBQ()
		if This._NNLValueIs("isvowel") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsWithNamedParamB()
		return This._NNLValueIs("iswithnamedparam")

	def IsWithNamedParamBQ()
		if This._NNLValueIs("iswithnamedparam") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsWithOrByNamedParamB()
		return This._NNLValueIs("iswithorbynamedparam")

	def IsWithOrByNamedParamBQ()
		if This._NNLValueIs("iswithorbynamedparam") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsWithRowNamedParamB()
		return This._NNLValueIs("iswithrownamedparam")

	def IsWithRowNamedParamBQ()
		if This._NNLValueIs("iswithrownamedparam") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsWordB()
		return This._NNLValueIs("isword")

	def IsWordBQ()
		if This._NNLValueIs("isword") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsZawjiOrFardiB()
		return This._NNLValueIs("iszawjiorfardi")

	def IsZawjiOrFardiBQ()
		if This._NNLValueIs("iszawjiorfardi") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def IsZeroB()
		return This._NNLValueIs("iszero")

	def IsZeroBQ()
		if This._NNLValueIs("iszero") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ItemsAndTheirPositionsB()
		return This._NNLValueIs("itemsandtheirpositions")

	def ItemsAndTheirPositionsBQ()
		if This._NNLValueIs("itemsandtheirpositions") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ItemsAndTheirTypesB()
		return This._NNLValueIs("itemsandtheirtypes")

	def ItemsAndTheirTypesBQ()
		if This._NNLValueIs("itemsandtheirtypes") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ItemsAreEmptyListsB()
		return This._NNLValueIs("itemsareemptylists")

	def ItemsAreEmptyListsBQ()
		if This._NNLValueIs("itemsareemptylists") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ItemsCountB()
		return This._NNLValueIs("itemscount")

	def ItemsCountBQ()
		if This._NNLValueIs("itemscount") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ItemsHaveSameTypeB()
		return This._NNLValueIs("itemshavesametype")

	def ItemsHaveSameTypeBQ()
		if This._NNLValueIs("itemshavesametype") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ItemsReversedB()
		return This._NNLValueIs("itemsreversed")

	def ItemsReversedBQ()
		if This._NNLValueIs("itemsreversed") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ItemsZB()
		return This._NNLValueIs("itemsz")

	def ItemsZBQ()
		if This._NNLValueIs("itemsz") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def KeywordsB()
		return This._NNLValueIs("keywords")

	def KeywordsBQ()
		if This._NNLValueIs("keywords") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def KFormB()
		return This._NNLValueIs("kform")

	def KFormBQ()
		if This._NNLValueIs("kform") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def LanguageB()
		return This._NNLValueIs("language")

	def LanguageBQ()
		if This._NNLValueIs("language") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def LastAndFirstItemsB()
		return This._NNLValueIs("lastandfirstitems")

	def LastAndFirstItemsBQ()
		if This._NNLValueIs("lastandfirstitems") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def LastCharB()
		return This._NNLValueIs("lastchar")

	def LastCharBQ()
		if This._NNLValueIs("lastchar") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def LastCharRemovedB()
		return This._NNLValueIs("lastcharremoved")

	def LastCharRemovedBQ()
		if This._NNLValueIs("lastcharremoved") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def LastItemB()
		return This._NNLValueIs("lastitem")

	def LastItemBQ()
		if This._NNLValueIs("lastitem") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def LastLineB()
		return This._NNLValueIs("lastline")

	def LastLineBQ()
		if This._NNLValueIs("lastline") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def LastNonSpaceCharB()
		return This._NNLValueIs("lastnonspacechar")

	def LastNonSpaceCharBQ()
		if This._NNLValueIs("lastnonspacechar") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def LastSentenceB()
		return This._NNLValueIs("lastsentence")

	def LastSentenceBQ()
		if This._NNLValueIs("lastsentence") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def LastWordB()
		return This._NNLValueIs("lastword")

	def LastWordBQ()
		if This._NNLValueIs("lastword") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def LastZB()
		return This._NNLValueIs("lastz")

	def LastZBQ()
		if This._NNLValueIs("lastz") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def LeadingCharsRemovedB()
		return This._NNLValueIs("leadingcharsremoved")

	def LeadingCharsRemovedBQ()
		if This._NNLValueIs("leadingcharsremoved") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def LeadingSpacesRemovedB()
		return This._NNLValueIs("leadingspacesremoved")

	def LeadingSpacesRemovedBQ()
		if This._NNLValueIs("leadingspacesremoved") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def LeastFrequentB()
		return This._NNLValueIs("leastfrequent")

	def LeastFrequentBQ()
		if This._NNLValueIs("leastfrequent") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def LeftBoundB()
		return This._NNLValueIs("leftbound")

	def LeftBoundBQ()
		if This._NNLValueIs("leftbound") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def LeftCharB()
		return This._NNLValueIs("leftchar")

	def LeftCharBQ()
		if This._NNLValueIs("leftchar") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def LeftCharRemovedB()
		return This._NNLValueIs("leftcharremoved")

	def LeftCharRemovedBQ()
		if This._NNLValueIs("leftcharremoved") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def LemmaB()
		return This._NNLValueIs("lemma")

	def LemmaBQ()
		if This._NNLValueIs("lemma") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def LemmatizedB()
		return This._NNLValueIs("lemmatized")

	def LemmatizedBQ()
		if This._NNLValueIs("lemmatized") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def LemmatizedWordsB()
		return This._NNLValueIs("lemmatizedwords")

	def LemmatizedWordsBQ()
		if This._NNLValueIs("lemmatizedwords") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def LengthB()
		return This._NNLValueIs("length")

	def LengthBQ()
		if This._NNLValueIs("length") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def LexicalDiversityB()
		return This._NNLValueIs("lexicaldiversity")

	def LexicalDiversityBQ()
		if This._NNLValueIs("lexicaldiversity") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ListB()
		return This._NNLValueIs("list")

	def ListBQ()
		if This._NNLValueIs("list") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def LowercasedB()
		return This._NNLValueIs("lowercased")

	def LowercasedBQ()
		if This._NNLValueIs("lowercased") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def LowestB()
		return This._NNLValueIs("lowest")

	def LowestBQ()
		if This._NNLValueIs("lowest") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def MarkerB()
		return This._NNLValueIs("marker")

	def MarkerBQ()
		if This._NNLValueIs("marker") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def MarkersAreSortedB()
		return This._NNLValueIs("markersaresorted")

	def MarkersAreSortedBQ()
		if This._NNLValueIs("markersaresorted") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def MarkersAreUnsortedB()
		return This._NNLValueIs("markersareunsorted")

	def MarkersAreUnsortedBQ()
		if This._NNLValueIs("markersareunsorted") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def MarkersSortingOrderB()
		return This._NNLValueIs("markerssortingorder")

	def MarkersSortingOrderBQ()
		if This._NNLValueIs("markerssortingorder") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def MarquerB()
		return This._NNLValueIs("marquer")

	def MarquerBQ()
		if This._NNLValueIs("marquer") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def MarquersAreSortedB()
		return This._NNLValueIs("marquersaresorted")

	def MarquersAreSortedBQ()
		if This._NNLValueIs("marquersaresorted") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def MarquersAreUnsortedB()
		return This._NNLValueIs("marquersareunsorted")

	def MarquersAreUnsortedBQ()
		if This._NNLValueIs("marquersareunsorted") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def MarquersSortingOrderB()
		return This._NNLValueIs("marquerssortingorder")

	def MarquersSortingOrderBQ()
		if This._NNLValueIs("marquerssortingorder") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def MaxB()
		return This._NNLValueIs("max")

	def MaxBQ()
		if This._NNLValueIs("max") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def MaxNumberB()
		return This._NNLValueIs("maxnumber")

	def MaxNumberBQ()
		if This._NNLValueIs("maxnumber") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def MaxRoundB()
		return This._NNLValueIs("maxround")

	def MaxRoundBQ()
		if This._NNLValueIs("maxround") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def MeanB()
		return This._NNLValueIs("mean")

	def MeanBQ()
		if This._NNLValueIs("mean") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def MedianB()
		return This._NNLValueIs("median")

	def MedianBQ()
		if This._NNLValueIs("median") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def MergedB()
		return This._NNLValueIs("merged")

	def MergedBQ()
		if This._NNLValueIs("merged") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def MetaphoneB()
		return This._NNLValueIs("metaphone")

	def MetaphoneBQ()
		if This._NNLValueIs("metaphone") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def MethodsB()
		return This._NNLValueIs("methods")

	def MethodsBQ()
		if This._NNLValueIs("methods") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def MFormB()
		return This._NNLValueIs("mform")

	def MFormBQ()
		if This._NNLValueIs("mform") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def MiddleB()
		return This._NNLValueIs("middle")

	def MiddleBQ()
		if This._NNLValueIs("middle") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def MinB()
		return This._NNLValueIs("min")

	def MinBQ()
		if This._NNLValueIs("min") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def MinNumberB()
		return This._NNLValueIs("minnumber")

	def MinNumberBQ()
		if This._NNLValueIs("minnumber") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ModeB()
		return This._NNLValueIs("mode")

	def ModeBQ()
		if This._NNLValueIs("mode") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def MostFrequentB()
		return This._NNLValueIs("mostfrequent")

	def MostFrequentBQ()
		if This._NNLValueIs("mostfrequent") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def MostFrequentCharB()
		return This._NNLValueIs("mostfrequentchar")

	def MostFrequentCharBQ()
		if This._NNLValueIs("mostfrequentchar") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def MostFrequentWordB()
		return This._NNLValueIs("mostfrequentword")

	def MostFrequentWordBQ()
		if This._NNLValueIs("mostfrequentword") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def MostNegativeSentenceB()
		return This._NNLValueIs("mostnegativesentence")

	def MostNegativeSentenceBQ()
		if This._NNLValueIs("mostnegativesentence") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def MostPositiveSentenceB()
		return This._NNLValueIs("mostpositivesentence")

	def MostPositiveSentenceBQ()
		if This._NNLValueIs("mostpositivesentence") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def NamesB()
		return This._NNLValueIs("names")

	def NamesBQ()
		if This._NNLValueIs("names") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def NaturalLogarithmB()
		return This._NNLValueIs("naturallogarithm")

	def NaturalLogarithmBQ()
		if This._NNLValueIs("naturallogarithm") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def NegativeScoreB()
		return This._NNLValueIs("negativescore")

	def NegativeScoreBQ()
		if This._NNLValueIs("negativescore") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def NestingDepthB()
		return This._NNLValueIs("nestingdepth")

	def NestingDepthBQ()
		if This._NNLValueIs("nestingdepth") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def NeutralScoreB()
		return This._NNLValueIs("neutralscore")

	def NeutralScoreBQ()
		if This._NNLValueIs("neutralscore") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def NoItemsAreDuplicatedB()
		return This._NNLValueIs("noitemsareduplicated")

	def NoItemsAreDuplicatedBQ()
		if This._NNLValueIs("noitemsareduplicated") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def NonDuplicatedItemsB()
		return This._NNLValueIs("nonduplicateditems")

	def NonDuplicatedItemsBQ()
		if This._NNLValueIs("nonduplicateditems") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def NonDuplicatedItemsZB()
		return This._NNLValueIs("nonduplicateditemsz")

	def NonDuplicatedItemsZBQ()
		if This._NNLValueIs("nonduplicateditemsz") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def NounsB()
		return This._NNLValueIs("nouns")

	def NounsBQ()
		if This._NNLValueIs("nouns") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def NullsStrippedB()
		return This._NNLValueIs("nullsstripped")

	def NullsStrippedBQ()
		if This._NNLValueIs("nullsstripped") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def NumberB()
		return This._NNLValueIs("number")

	def NumberBQ()
		if This._NNLValueIs("number") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def NumberFormB()
		return This._NNLValueIs("numberform")

	def NumberFormBQ()
		if This._NNLValueIs("numberform") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def NumbericValueB()
		return This._NNLValueIs("numbericvalue")

	def NumbericValueBQ()
		if This._NNLValueIs("numbericvalue") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def NumberRoundB()
		return This._NNLValueIs("numberround")

	def NumberRoundBQ()
		if This._NNLValueIs("numberround") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def NumbersAndStringsB()
		return This._NNLValueIs("numbersandstrings")

	def NumbersAndStringsBQ()
		if This._NNLValueIs("numbersandstrings") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def NumbersAndStringsZB()
		return This._NNLValueIs("numbersandstringsz")

	def NumbersAndStringsZBQ()
		if This._NNLValueIs("numbersandstringsz") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def NumbersAsSectionsB()
		return This._NNLValueIs("numbersassections")

	def NumbersAsSectionsBQ()
		if This._NNLValueIs("numbersassections") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def NumberWithSignB()
		return This._NNLValueIs("numberwithsign")

	def NumberWithSignBQ()
		if This._NNLValueIs("numberwithsign") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ObjectifiedB()
		return This._NNLValueIs("objectified")

	def ObjectifiedBQ()
		if This._NNLValueIs("objectified") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def OnlyLatinLettersB()
		return This._NNLValueIs("onlylatinletters")

	def OnlyLatinLettersBQ()
		if This._NNLValueIs("onlylatinletters") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def OrientationB()
		return This._NNLValueIs("orientation")

	def OrientationBQ()
		if This._NNLValueIs("orientation") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def PairifiedB()
		return This._NNLValueIs("pairified")

	def PairifiedBQ()
		if This._NNLValueIs("pairified") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def PairifyB()
		return This._NNLValueIs("pairify")

	def PairifyBQ()
		if This._NNLValueIs("pairify") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def PathsB()
		return This._NNLValueIs("paths")

	def PathsBQ()
		if This._NNLValueIs("paths") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def PercentB()
		return This._NNLValueIs("percent")

	def PercentBQ()
		if This._NNLValueIs("percent") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def PositiveScoreB()
		return This._NNLValueIs("positivescore")

	def PositiveScoreBQ()
		if This._NNLValueIs("positivescore") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def POSTagsB()
		return This._NNLValueIs("postags")

	def POSTagsBQ()
		if This._NNLValueIs("postags") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def PrimeDividorsB()
		return This._NNLValueIs("primedividors")

	def PrimeDividorsBQ()
		if This._NNLValueIs("primedividors") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def PrimeDivirdosB()
		return This._NNLValueIs("primedivirdos")

	def PrimeDivirdosBQ()
		if This._NNLValueIs("primedivirdos") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def PrimeDivisorsB()
		return This._NNLValueIs("primedivisors")

	def PrimeDivisorsBQ()
		if This._NNLValueIs("primedivisors") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def PrimeFactorsB()
		return This._NNLValueIs("primefactors")

	def PrimeFactorsBQ()
		if This._NNLValueIs("primefactors") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ProductB()
		return This._NNLValueIs("product")

	def ProductBQ()
		if This._NNLValueIs("product") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ProfileB()
		return This._NNLValueIs("profile")

	def ProfileBQ()
		if This._NNLValueIs("profile") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def RandomCharB()
		return This._NNLValueIs("randomchar")

	def RandomCharBQ()
		if This._NNLValueIs("randomchar") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def RandomItemB()
		return This._NNLValueIs("randomitem")

	def RandomItemBQ()
		if This._NNLValueIs("randomitem") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def RandomItemsB()
		return This._NNLValueIs("randomitems")

	def RandomItemsBQ()
		if This._NNLValueIs("randomitems") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def RandomizedB()
		return This._NNLValueIs("randomized")

	def RandomizedBQ()
		if This._NNLValueIs("randomized") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def RandomPositionB()
		return This._NNLValueIs("randomposition")

	def RandomPositionBQ()
		if This._NNLValueIs("randomposition") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def RandomSectionB()
		return This._NNLValueIs("randomsection")

	def RandomSectionBQ()
		if This._NNLValueIs("randomsection") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def RankedB()
		return This._NNLValueIs("ranked")

	def RankedBQ()
		if This._NNLValueIs("ranked") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ReadabilityExplainedB()
		return This._NNLValueIs("readabilityexplained")

	def ReadabilityExplainedBQ()
		if This._NNLValueIs("readabilityexplained") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ReadabilityGradeB()
		return This._NNLValueIs("readabilitygrade")

	def ReadabilityGradeBQ()
		if This._NNLValueIs("readabilitygrade") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ReadingEaseB()
		return This._NNLValueIs("readingease")

	def ReadingEaseBQ()
		if This._NNLValueIs("readingease") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ReduceB()
		return This._NNLValueIs("reduce")

	def ReduceBQ()
		if This._NNLValueIs("reduce") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def RepresentsAHexUnicodeB()
		return This._NNLValueIs("representsahexunicode")

	def RepresentsAHexUnicodeBQ()
		if This._NNLValueIs("representsahexunicode") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def RepresentsBinaryNumberB()
		return This._NNLValueIs("representsbinarynumber")

	def RepresentsBinaryNumberBQ()
		if This._NNLValueIs("representsbinarynumber") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def RepresentsHexNumberB()
		return This._NNLValueIs("representshexnumber")

	def RepresentsHexNumberBQ()
		if This._NNLValueIs("representshexnumber") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def RepresentsIntegerB()
		return This._NNLValueIs("representsinteger")

	def RepresentsIntegerBQ()
		if This._NNLValueIs("representsinteger") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def RepresentsNumberB()
		return This._NNLValueIs("representsnumber")

	def RepresentsNumberBQ()
		if This._NNLValueIs("representsnumber") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def RepresentsOctalNumberB()
		return This._NNLValueIs("representsoctalnumber")

	def RepresentsOctalNumberBQ()
		if This._NNLValueIs("representsoctalnumber") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def RepresentsRealNumberB()
		return This._NNLValueIs("representsrealnumber")

	def RepresentsRealNumberBQ()
		if This._NNLValueIs("representsrealnumber") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def RepresentsSignedNumberB()
		return This._NNLValueIs("representssignednumber")

	def RepresentsSignedNumberBQ()
		if This._NNLValueIs("representssignednumber") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ReturnTypeB()
		return This._NNLValueIs("returntype")

	def ReturnTypeBQ()
		if This._NNLValueIs("returntype") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ReversedB()
		return This._NNLValueIs("reversed")

	def ReversedBQ()
		if This._NNLValueIs("reversed") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def RightBoundB()
		return This._NNLValueIs("rightbound")

	def RightBoundBQ()
		if This._NNLValueIs("rightbound") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def RightCharB()
		return This._NNLValueIs("rightchar")

	def RightCharBQ()
		if This._NNLValueIs("rightchar") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def RightCharRemovedB()
		return This._NNLValueIs("rightcharremoved")

	def RightCharRemovedBQ()
		if This._NNLValueIs("rightcharremoved") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def rndItemsB()
		return This._NNLValueIs("rnditems")

	def rndItemsBQ()
		if This._NNLValueIs("rnditems") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def RoundB()
		return This._NNLValueIs("round")

	def RoundBQ()
		if This._NNLValueIs("round") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def RoundedToMaxB()
		return This._NNLValueIs("roundedtomax")

	def RoundedToMaxBQ()
		if This._NNLValueIs("roundedtomax") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ScriptB()
		return This._NNLValueIs("script")

	def ScriptBQ()
		if This._NNLValueIs("script") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def SecondHalfB()
		return This._NNLValueIs("secondhalf")

	def SecondHalfBQ()
		if This._NNLValueIs("secondhalf") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def SecondHalfAndPositionB()
		return This._NNLValueIs("secondhalfandposition")

	def SecondHalfAndPositionBQ()
		if This._NNLValueIs("secondhalfandposition") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def SecondHalfAndSectionB()
		return This._NNLValueIs("secondhalfandsection")

	def SecondHalfAndSectionBQ()
		if This._NNLValueIs("secondhalfandsection") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def SecondHalfXTZB()
		return This._NNLValueIs("secondhalfxtz")

	def SecondHalfXTZBQ()
		if This._NNLValueIs("secondhalfxtz") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def SecondHalfXTZZB()
		return This._NNLValueIs("secondhalfxtzz")

	def SecondHalfXTZZBQ()
		if This._NNLValueIs("secondhalfxtzz") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def SecondHalfZB()
		return This._NNLValueIs("secondhalfz")

	def SecondHalfZBQ()
		if This._NNLValueIs("secondhalfz") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def SecondHalfZZB()
		return This._NNLValueIs("secondhalfzz")

	def SecondHalfZZBQ()
		if This._NNLValueIs("secondhalfzz") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def SentimentB()
		return This._NNLValueIs("sentiment")

	def SentimentBQ()
		if This._NNLValueIs("sentiment") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def SentimentCompoundB()
		return This._NNLValueIs("sentimentcompound")

	def SentimentCompoundBQ()
		if This._NNLValueIs("sentimentcompound") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def SentimentExplainedB()
		return This._NNLValueIs("sentimentexplained")

	def SentimentExplainedBQ()
		if This._NNLValueIs("sentimentexplained") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def SentimentScoreB()
		return This._NNLValueIs("sentimentscore")

	def SentimentScoreBQ()
		if This._NNLValueIs("sentimentscore") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ShortenedB()
		return This._NNLValueIs("shortened")

	def ShortenedBQ()
		if This._NNLValueIs("shortened") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ShowTaggedB()
		return This._NNLValueIs("showtagged")

	def ShowTaggedBQ()
		if This._NNLValueIs("showtagged") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ShuffledB()
		return This._NNLValueIs("shuffled")

	def ShuffledBQ()
		if This._NNLValueIs("shuffled") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def SigmoidB()
		return This._NNLValueIs("sigmoid")

	def SigmoidBQ()
		if This._NNLValueIs("sigmoid") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def SignRemovedB()
		return This._NNLValueIs("signremoved")

	def SignRemovedBQ()
		if This._NNLValueIs("signremoved") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def SimplifiedB()
		return This._NNLValueIs("simplified")

	def SimplifiedBQ()
		if This._NNLValueIs("simplified") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def SineB()
		return This._NNLValueIs("sine")

	def SineBQ()
		if This._NNLValueIs("sine") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def SinglifiedB()
		return This._NNLValueIs("singlified")

	def SinglifiedBQ()
		if This._NNLValueIs("singlified") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def SortedB()
		return This._NNLValueIs("sorted")

	def SortedBQ()
		if This._NNLValueIs("sorted") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def SoundexB()
		return This._NNLValueIs("soundex")

	def SoundexBQ()
		if This._NNLValueIs("soundex") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def SpacesRemovedB()
		return This._NNLValueIs("spacesremoved")

	def SpacesRemovedBQ()
		if This._NNLValueIs("spacesremoved") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def SpacifiedB()
		return This._NNLValueIs("spacified")

	def SpacifiedBQ()
		if This._NNLValueIs("spacified") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def SquareRootB()
		return This._NNLValueIs("squareroot")

	def SquareRootBQ()
		if This._NNLValueIs("squareroot") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def SqueezedB()
		return This._NNLValueIs("squeezed")

	def SqueezedBQ()
		if This._NNLValueIs("squeezed") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def StandardDeviationB()
		return This._NNLValueIs("standarddeviation")

	def StandardDeviationBQ()
		if This._NNLValueIs("standarddeviation") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def StartsWithANumberB()
		return This._NNLValueIs("startswithanumber")

	def StartsWithANumberBQ()
		if This._NNLValueIs("startswithanumber") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def StartsWithNumberB()
		return This._NNLValueIs("startswithnumber")

	def StartsWithNumberBQ()
		if This._NNLValueIs("startswithnumber") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def StddevB()
		return This._NNLValueIs("stddev")

	def StddevBQ()
		if This._NNLValueIs("stddev") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def StemB()
		return This._NNLValueIs("stem")

	def StemBQ()
		if This._NNLValueIs("stem") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def StemmedB()
		return This._NNLValueIs("stemmed")

	def StemmedBQ()
		if This._NNLValueIs("stemmed") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def StemmedWordsB()
		return This._NNLValueIs("stemmedwords")

	def StemmedWordsBQ()
		if This._NNLValueIs("stemmedwords") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def StringB()
		return This._NNLValueIs("string")

	def StringBQ()
		if This._NNLValueIs("string") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def StringCaseB()
		return This._NNLValueIs("stringcase")

	def StringCaseBQ()
		if This._NNLValueIs("stringcase") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def StringifiedB()
		return This._NNLValueIs("stringified")

	def StringifiedBQ()
		if This._NNLValueIs("stringified") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def StringsAndNumbersB()
		return This._NNLValueIs("stringsandnumbers")

	def StringsAndNumbersBQ()
		if This._NNLValueIs("stringsandnumbers") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def StringsAndNumbersZB()
		return This._NNLValueIs("stringsandnumbersz")

	def StringsAndNumbersZBQ()
		if This._NNLValueIs("stringsandnumbersz") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def StringsLowercasedB()
		return This._NNLValueIs("stringslowercased")

	def StringsLowercasedBQ()
		if This._NNLValueIs("stringslowercased") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def StringsUppercasedB()
		return This._NNLValueIs("stringsuppercased")

	def StringsUppercasedBQ()
		if This._NNLValueIs("stringsuppercased") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def StringValueB()
		return This._NNLValueIs("stringvalue")

	def StringValueBQ()
		if This._NNLValueIs("stringvalue") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def StyleProfileB()
		return This._NNLValueIs("styleprofile")

	def StyleProfileBQ()
		if This._NNLValueIs("styleprofile") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def StzClassB()
		return This._NNLValueIs("stzclass")

	def StzClassBQ()
		if This._NNLValueIs("stzclass") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def StzClassNameB()
		return This._NNLValueIs("stzclassname")

	def StzClassNameBQ()
		if This._NNLValueIs("stzclassname") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def StzTypeB()
		return This._NNLValueIs("stztype")

	def StzTypeBQ()
		if This._NNLValueIs("stztype") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def SubStringsZB()
		return This._NNLValueIs("substringsz")

	def SubStringsZBQ()
		if This._NNLValueIs("substringsz") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def SubStringsZZB()
		return This._NNLValueIs("substringszz")

	def SubStringsZZBQ()
		if This._NNLValueIs("substringszz") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def SubstrinksB()
		return This._NNLValueIs("substrinks")

	def SubstrinksBQ()
		if This._NNLValueIs("substrinks") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def SubstrongsB()
		return This._NNLValueIs("substrongs")

	def SubstrongsBQ()
		if This._NNLValueIs("substrongs") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def SumB()
		return This._NNLValueIs("sum")

	def SumBQ()
		if This._NNLValueIs("sum") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def TaggedWordsB()
		return This._NNLValueIs("taggedwords")

	def TaggedWordsBQ()
		if This._NNLValueIs("taggedwords") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def TangentB()
		return This._NNLValueIs("tangent")

	def TangentBQ()
		if This._NNLValueIs("tangent") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def TextB()
		return This._NNLValueIs("text")

	def TextBQ()
		if This._NNLValueIs("text") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def TitlecasedB()
		return This._NNLValueIs("titlecased")

	def TitlecasedBQ()
		if This._NNLValueIs("titlecased") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ToBinaryB()
		return This._NNLValueIs("tobinary")

	def ToBinaryBQ()
		if This._NNLValueIs("tobinary") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ToBinaryFormB()
		return This._NNLValueIs("tobinaryform")

	def ToBinaryFormBQ()
		if This._NNLValueIs("tobinaryform") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ToBinaryFormNoPrefixB()
		return This._NNLValueIs("tobinaryformnoprefix")

	def ToBinaryFormNoPrefixBQ()
		if This._NNLValueIs("tobinaryformnoprefix") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ToBinaryNoPrefixB()
		return This._NNLValueIs("tobinarynoprefix")

	def ToBinaryNoPrefixBQ()
		if This._NNLValueIs("tobinarynoprefix") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ToBinaryWithoutPrefixB()
		return This._NNLValueIs("tobinarywithoutprefix")

	def ToBinaryWithoutPrefixBQ()
		if This._NNLValueIs("tobinarywithoutprefix") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ToCodeB()
		return This._NNLValueIs("tocode")

	def ToCodeBQ()
		if This._NNLValueIs("tocode") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ToHexB()
		return This._NNLValueIs("tohex")

	def ToHexBQ()
		if This._NNLValueIs("tohex") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ToHexFormB()
		return This._NNLValueIs("tohexform")

	def ToHexFormBQ()
		if This._NNLValueIs("tohexform") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ToHexFormWithoutPrefixB()
		return This._NNLValueIs("tohexformwithoutprefix")

	def ToHexFormWithoutPrefixBQ()
		if This._NNLValueIs("tohexformwithoutprefix") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ToHexUnicodeB()
		return This._NNLValueIs("tohexunicode")

	def ToHexUnicodeBQ()
		if This._NNLValueIs("tohexunicode") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ToHexWithoutPrefixB()
		return This._NNLValueIs("tohexwithoutprefix")

	def ToHexWithoutPrefixBQ()
		if This._NNLValueIs("tohexwithoutprefix") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ToKFormB()
		return This._NNLValueIs("tokform")

	def ToKFormBQ()
		if This._NNLValueIs("tokform") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ToListB()
		return This._NNLValueIs("tolist")

	def ToListBQ()
		if This._NNLValueIs("tolist") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ToMFormB()
		return This._NNLValueIs("tomform")

	def ToMFormBQ()
		if This._NNLValueIs("tomform") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ToOctalB()
		return This._NNLValueIs("tooctal")

	def ToOctalBQ()
		if This._NNLValueIs("tooctal") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ToOctalFormB()
		return This._NNLValueIs("tooctalform")

	def ToOctalFormBQ()
		if This._NNLValueIs("tooctalform") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ToPairsB()
		return This._NNLValueIs("topairs")

	def ToPairsBQ()
		if This._NNLValueIs("topairs") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def TopKeyPhraseB()
		return This._NNLValueIs("topkeyphrase")

	def TopKeyPhraseBQ()
		if This._NNLValueIs("topkeyphrase") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ToSetB()
		return This._NNLValueIs("toset")

	def ToSetBQ()
		if This._NNLValueIs("toset") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ToSlugB()
		return This._NNLValueIs("toslug")

	def ToSlugBQ()
		if This._NNLValueIs("toslug") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ToStringB()
		return This._NNLValueIs("tostring")

	def ToStringBQ()
		if This._NNLValueIs("tostring") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ToUnicodeHexB()
		return This._NNLValueIs("tounicodehex")

	def ToUnicodeHexBQ()
		if This._NNLValueIs("tounicodehex") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ToUnicodeHexFormB()
		return This._NNLValueIs("tounicodehexform")

	def ToUnicodeHexFormBQ()
		if This._NNLValueIs("tounicodehexform") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def TrailingCharsRemovedB()
		return This._NNLValueIs("trailingcharsremoved")

	def TrailingCharsRemovedBQ()
		if This._NNLValueIs("trailingcharsremoved") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def TrailingSpacesRemovedB()
		return This._NNLValueIs("trailingspacesremoved")

	def TrailingSpacesRemovedBQ()
		if This._NNLValueIs("trailingspacesremoved") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def TrimmedB()
		return This._NNLValueIs("trimmed")

	def TrimmedBQ()
		if This._NNLValueIs("trimmed") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def TrimmedLeftB()
		return This._NNLValueIs("trimmedleft")

	def TrimmedLeftBQ()
		if This._NNLValueIs("trimmedleft") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def TrimmedRightB()
		return This._NNLValueIs("trimmedright")

	def TrimmedRightBQ()
		if This._NNLValueIs("trimmedright") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def TripletsB()
		return This._NNLValueIs("triplets")

	def TripletsBQ()
		if This._NNLValueIs("triplets") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def TypesB()
		return This._NNLValueIs("types")

	def TypesBQ()
		if This._NNLValueIs("types") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def TypesAndTheirSectionsB()
		return This._NNLValueIs("typesandtheirsections")

	def TypesAndTheirSectionsBQ()
		if This._NNLValueIs("typesandtheirsections") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def TypesUB()
		return This._NNLValueIs("typesu")

	def TypesUBQ()
		if This._NNLValueIs("typesu") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def TypesZZB()
		return This._NNLValueIs("typeszz")

	def TypesZZBQ()
		if This._NNLValueIs("typeszz") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def TypeTokenRatioB()
		return This._NNLValueIs("typetokenratio")

	def TypeTokenRatioBQ()
		if This._NNLValueIs("typetokenratio") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def UnicodeB()
		return This._NNLValueIs("unicode")

	def UnicodeBQ()
		if This._NNLValueIs("unicode") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def UnicodesB()
		return This._NNLValueIs("unicodes")

	def UnicodesBQ()
		if This._NNLValueIs("unicodes") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def UniqueB()
		return This._NNLValueIs("unique")

	def UniqueBQ()
		if This._NNLValueIs("unique") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def UniqueCharsB()
		return This._NNLValueIs("uniquechars")

	def UniqueCharsBQ()
		if This._NNLValueIs("uniquechars") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def UniqueCharsAndUnicodesB()
		return This._NNLValueIs("uniquecharsandunicodes")

	def UniqueCharsAndUnicodesBQ()
		if This._NNLValueIs("uniquecharsandunicodes") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def UniqueItemsB()
		return This._NNLValueIs("uniqueitems")

	def UniqueItemsBQ()
		if This._NNLValueIs("uniqueitems") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def UniqueTypesB()
		return This._NNLValueIs("uniquetypes")

	def UniqueTypesBQ()
		if This._NNLValueIs("uniquetypes") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def UniqueWordsB()
		return This._NNLValueIs("uniquewords")

	def UniqueWordsBQ()
		if This._NNLValueIs("uniquewords") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def UnitsB()
		return This._NNLValueIs("units")

	def UnitsBQ()
		if This._NNLValueIs("units") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def UnspacifiedB()
		return This._NNLValueIs("unspacified")

	def UnspacifiedBQ()
		if This._NNLValueIs("unspacified") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def UnzipB()
		return This._NNLValueIs("unzip")

	def UnzipBQ()
		if This._NNLValueIs("unzip") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def UnzippedB()
		return This._NNLValueIs("unzipped")

	def UnzippedBQ()
		if This._NNLValueIs("unzipped") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def UppercasedB()
		return This._NNLValueIs("uppercased")

	def UppercasedBQ()
		if This._NNLValueIs("uppercased") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def UrlDecodedB()
		return This._NNLValueIs("urldecoded")

	def UrlDecodedBQ()
		if This._NNLValueIs("urldecoded") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def UrlEncodedB()
		return This._NNLValueIs("urlencoded")

	def UrlEncodedBQ()
		if This._NNLValueIs("urlencoded") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ValueB()
		return This._NNLValueIs("value")

	def ValueBQ()
		if This._NNLValueIs("value") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def VarianceB()
		return This._NNLValueIs("variance")

	def VarianceBQ()
		if This._NNLValueIs("variance") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def VowelB()
		return This._NNLValueIs("vowel")

	def VowelBQ()
		if This._NNLValueIs("vowel") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def WalkBackAndForthB()
		return This._NNLValueIs("walkbackandforth")

	def WalkBackAndForthBQ()
		if This._NNLValueIs("walkbackandforth") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def WalkForthAndBackB()
		return This._NNLValueIs("walkforthandback")

	def WalkForthAndBackBQ()
		if This._NNLValueIs("walkforthandback") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def WithoutDiacriticsB()
		return This._NNLValueIs("withoutdiacritics")

	def WithoutDiacriticsBQ()
		if This._NNLValueIs("withoutdiacritics") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def WithoutDotsB()
		return This._NNLValueIs("withoutdots")

	def WithoutDotsBQ()
		if This._NNLValueIs("withoutdots") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def WithoutDotsOnLettersB()
		return This._NNLValueIs("withoutdotsonletters")

	def WithoutDotsOnLettersBQ()
		if This._NNLValueIs("withoutdotsonletters") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def WithoutDuplicationB()
		return This._NNLValueIs("withoutduplication")

	def WithoutDuplicationBQ()
		if This._NNLValueIs("withoutduplication") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def WithoutSapcesB()
		return This._NNLValueIs("withoutsapces")

	def WithoutSapcesBQ()
		if This._NNLValueIs("withoutsapces") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def WithoutSpacesB()
		return This._NNLValueIs("withoutspaces")

	def WithoutSpacesBQ()
		if This._NNLValueIs("withoutspaces") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def WithoutStopwordsB()
		return This._NNLValueIs("withoutstopwords")

	def WithoutStopwordsBQ()
		if This._NNLValueIs("withoutstopwords") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def WordsAndTheirCountsB()
		return This._NNLValueIs("wordsandtheircounts")

	def WordsAndTheirCountsBQ()
		if This._NNLValueIs("wordsandtheircounts") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def WordsForSearchB()
		return This._NNLValueIs("wordsforsearch")

	def WordsForSearchBQ()
		if This._NNLValueIs("wordsforsearch") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def WordsLemmatizedB()
		return This._NNLValueIs("wordslemmatized")

	def WordsLemmatizedBQ()
		if This._NNLValueIs("wordslemmatized") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def WordsStemmedB()
		return This._NNLValueIs("wordsstemmed")

	def WordsStemmedBQ()
		if This._NNLValueIs("wordsstemmed") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def WordsWithPOSB()
		return This._NNLValueIs("wordswithpos")

	def WordsWithPOSBQ()
		if This._NNLValueIs("wordswithpos") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def ZerosRemovedB()
		return This._NNLValueIs("zerosremoved")

	def ZerosRemovedBQ()
		if This._NNLValueIs("zerosremoved") = 1
			return This
		ok
		_oFo_ = AFalseObjectXT(This)
		_oFo_.SetWhyStopped(@cNNLWhy)
		return _oFo_

	def AddQC(p1)
		return This._NNLImmutable("add", [ p1 ])

	def AddBoundsQC(p1)
		return This._NNLImmutable("addbounds", [ p1 ])

	def AddedManyQC(p1)
		return This._NNLImmutable("addedmany", [ p1 ])

	def AddedToEachQC(p1)
		return This._NNLImmutable("addedtoeach", [ p1 ])

	def AddItemQC(p1)
		return This._NNLImmutable("additem", [ p1 ])

	def AddItemsQC(p1)
		return This._NNLImmutable("additems", [ p1 ])

	def AddManyQC(p1)
		return This._NNLImmutable("addmany", [ p1 ])

	def AddTheseQC(p1)
		return This._NNLImmutable("addthese", [ p1 ])

	def AddToEachQC(p1)
		return This._NNLImmutable("addtoeach", [ p1 ])

	def AdjectivesQC()
		return This._NNLImmutable("adjectives", [])

	def AdverbsQC()
		return This._NNLImmutable("adverbs", [])

	def AllAreEqualCSQC(p1)
		return This._NNLImmutable("allareequalcs", [ p1 ])

	def AllCharsAreQC(p1)
		return This._NNLImmutable("allcharsare", [ p1 ])

	def AllItemsAreQC(p1)
		return This._NNLImmutable("allitemsare", [ p1 ])

	def AllItemsAreEqualCSQC(p1)
		return This._NNLImmutable("allitemsareequalcs", [ p1 ])

	def AllItemsAreEqualToQC(p1)
		return This._NNLImmutable("allitemsareequalto", [ p1 ])

	def AllItemsExceptQC(p1)
		return This._NNLImmutable("allitemsexcept", [ p1 ])

	def AllItemsVerifyQC(p1)
		return This._NNLImmutable("allitemsverify", [ p1 ])

	def AntiFindQC(p1)
		return This._NNLImmutable("antifind", [ p1 ])

	def AntiFindAsSectionQC(p1)
		return This._NNLImmutable("antifindassection", [ p1 ])

	def AntiFindAsSectionsQC(p1)
		return This._NNLImmutable("antifindassections", [ p1 ])

	def AntiFindAsSectionsZQC(p1)
		return This._NNLImmutable("antifindassectionsz", [ p1 ])

	def AntiFindAsSectionsZZQC(p1)
		return This._NNLImmutable("antifindassectionszz", [ p1 ])

	def AntiFindZZQC(p1)
		return This._NNLImmutable("antifindzz", [ p1 ])

	def AntiPositionsQC(p1)
		return This._NNLImmutable("antipositions", [ p1 ])

	def AntiPositionsZZQC(p1)
		return This._NNLImmutable("antipositionszz", [ p1 ])

	def AntiRangesQC(p1)
		return This._NNLImmutable("antiranges", [ p1 ])

	def AntiSectionsQC(p1)
		return This._NNLImmutable("antisections", [ p1 ])

	def AntiSectionsZQC(p1)
		return This._NNLImmutable("antisectionsz", [ p1 ])

	def AntiSectionsZZQC(p1)
		return This._NNLImmutable("antisectionszz", [ p1 ])

	def AnyBoundedByQC(p1)
		return This._NNLImmutable("anyboundedby", [ p1 ])

	def AnyBoundedByZZQC(p1)
		return This._NNLImmutable("anyboundedbyzz", [ p1 ])

	def AnySubStringsBoundedByQC(p1)
		return This._NNLImmutable("anysubstringsboundedby", [ p1 ])

	def AppendQC(p1)
		return This._NNLImmutable("append", [ p1 ])

	def ApplyFormatQC()
		return This._NNLImmutable("applyformat", [])

	def ApplyLocaleQC(p1)
		return This._NNLImmutable("applylocale", [ p1 ])

	def ApplyTitlecaseQC()
		return This._NNLImmutable("applytitlecase", [])

	def ArcCosineQC()
		return This._NNLImmutable("arccosine", [])

	def ArcSineQC()
		return This._NNLImmutable("arcsine", [])

	def ArcTangentQC()
		return This._NNLImmutable("arctangent", [])

	def AsDeepListQC()
		return This._NNLImmutable("asdeeplist", [])

	def AssociatedWithQC(p1)
		return This._NNLImmutable("associatedwith", [ p1 ])

	def AssociateWithQC(p1)
		return This._NNLImmutable("associatewith", [ p1 ])

	def BeginsWithQC(p1)
		return This._NNLImmutable("beginswith", [ p1 ])

	def BillionsQC()
		return This._NNLImmutable("billions", [])

	def BoundedByQC(p1)
		return This._NNLImmutable("boundedby", [ p1 ])

	def BoundedByUQC(p1)
		return This._NNLImmutable("boundedbyu", [ p1 ])

	def BoundedByUZQC(p1)
		return This._NNLImmutable("boundedbyuz", [ p1 ])

	def BoundedByUZZQC(p1)
		return This._NNLImmutable("boundedbyuzz", [ p1 ])

	def BoundedByZQC(p1)
		return This._NNLImmutable("boundedbyz", [ p1 ])

	def BoundedByZZQC(p1)
		return This._NNLImmutable("boundedbyzz", [ p1 ])

	def BoundWithQC(p1)
		return This._NNLImmutable("boundwith", [ p1 ])

	def BoxQC()
		return This._NNLImmutable("box", [])

	def BoxEachCharQC()
		return This._NNLImmutable("boxeachchar", [])

	def BoxifyCharsQC()
		return This._NNLImmutable("boxifychars", [])

	def BoxifyRoundQC()
		return This._NNLImmutable("boxifyround", [])

	def BoxRoundQC()
		return This._NNLImmutable("boxround", [])

	def BoxRoundEachCharQC()
		return This._NNLImmutable("boxroundeachchar", [])

	def CanBeDividedByQC(p1)
		return This._NNLImmutable("canbedividedby", [ p1 ])

	def CapitalCaseQC()
		return This._NNLImmutable("capitalcase", [])

	def CapitalizeQC()
		return This._NNLImmutable("capitalize", [])

	def CharacterNameQC()
		return This._NNLImmutable("charactername", [])

	def CharAtQC(p1)
		return This._NNLImmutable("charat", [ p1 ])

	def CharIsControlAtQC(p1)
		return This._NNLImmutable("chariscontrolat", [ p1 ])

	def CharIsMarkAtQC(p1)
		return This._NNLImmutable("charismarkat", [ p1 ])

	def CharIsSpaceAtQC(p1)
		return This._NNLImmutable("charisspaceat", [ p1 ])

	def CharNameQC()
		return This._NNLImmutable("charname", [])

	def CharRemovedFromLeftQC(p1)
		return This._NNLImmutable("charremovedfromleft", [ p1 ])

	def CharRemovedFromRightQC(p1)
		return This._NNLImmutable("charremovedfromright", [ p1 ])

	def CharsAndTheirCountsCSQC(p1)
		return This._NNLImmutable("charsandtheircountscs", [ p1 ])

	def CharsZQC()
		return This._NNLImmutable("charsz", [])

	def CharTrimmedFromLeftQC(p1)
		return This._NNLImmutable("chartrimmedfromleft", [ p1 ])

	def CharTrimmedFromRightQC(p1)
		return This._NNLImmutable("chartrimmedfromright", [ p1 ])

	def CheckQC(p1)
		return This._NNLImmutable("check", [ p1 ])

	def ChunksQC(p1)
		return This._NNLImmutable("chunks", [ p1 ])

	def ClassesQC()
		return This._NNLImmutable("classes", [])

	def ClassesSFQC()
		return This._NNLImmutable("classessf", [])

	def ClassifiedSFQC()
		return This._NNLImmutable("classifiedsf", [])

	def ClassifyQC()
		return This._NNLImmutable("classify", [])

	def ClassifyByQC(p1)
		return This._NNLImmutable("classifyby", [ p1 ])

	def ClassifySFQC()
		return This._NNLImmutable("classifysf", [])

	def CombinationsQC(p1)
		return This._NNLImmutable("combinations", [ p1 ])

	def ComesAfterPositionQC(p1)
		return This._NNLImmutable("comesafterposition", [ p1 ])

	def ComesAfterSubStringQC(p1)
		return This._NNLImmutable("comesaftersubstring", [ p1 ])

	def ComesBeforePositionQC(p1)
		return This._NNLImmutable("comesbeforeposition", [ p1 ])

	def ComesBeforeSubStringQC(p1)
		return This._NNLImmutable("comesbeforesubstring", [ p1 ])

	def CommonQC(p1)
		return This._NNLImmutable("common", [ p1 ])

	def CommonGreatestDividorQC(p1)
		return This._NNLImmutable("commongreatestdividor", [ p1 ])

	def CommonItemsQC(p1)
		return This._NNLImmutable("commonitems", [ p1 ])

	def CommonItemsWithQC(p1)
		return This._NNLImmutable("commonitemswith", [ p1 ])

	def CommonPrefixWithQC(p1)
		return This._NNLImmutable("commonprefixwith", [ p1 ])

	def CommonSubStringsQC(p1)
		return This._NNLImmutable("commonsubstrings", [ p1 ])

	def CommonSuffixWithQC(p1)
		return This._NNLImmutable("commonsuffixwith", [ p1 ])

	def CompactQC()
		return This._NNLImmutable("compact", [])

	def CompactFormQC()
		return This._NNLImmutable("compactform", [])

	def ComparedToQC(p1)
		return This._NNLImmutable("comparedto", [ p1 ])

	def CompareRoundsWithQC(p1)
		return This._NNLImmutable("compareroundswith", [ p1 ])

	def CompressUsingBinaryQC(p1)
		return This._NNLImmutable("compressusingbinary", [ p1 ])

	def ConcatenateQC(p1)
		return This._NNLImmutable("concatenate", [ p1 ])

	def ConcordanceQC(p1)
		return This._NNLImmutable("concordance", [ p1 ])

	def ContentCSQC(p1)
		return This._NNLImmutable("contentcs", [ p1 ])

	def ContentCSUQC(p1)
		return This._NNLImmutable("contentcsu", [ p1 ])

	def CopyQC()
		return This._NNLImmutable("copy", [])

	def CosineSimilarityWithQC(p1)
		return This._NNLImmutable("cosinesimilaritywith", [ p1 ])

	def CountQC(p1)
		return This._NNLImmutable("count", [ p1 ])

	def CountEmptyStringsQC()
		return This._NNLImmutable("countemptystrings", [])

	def CountLeadingCharQC(p1)
		return This._NNLImmutable("countleadingchar", [ p1 ])

	def CountNumbersQC()
		return This._NNLImmutable("countnumbers", [])

	def CountOverlappingQC(p1)
		return This._NNLImmutable("countoverlapping", [ p1 ])

	def CountRegexQC(p1)
		return This._NNLImmutable("countregex", [ p1 ])

	def CountSubStringsQC(p1)
		return This._NNLImmutable("countsubstrings", [ p1 ])

	def CountTrailingCharQC(p1)
		return This._NNLImmutable("counttrailingchar", [ p1 ])

	def CountVowelsQC()
		return This._NNLImmutable("countvowels", [])

	def CountWordsQC()
		return This._NNLImmutable("countwords", [])

	def DecimalPartQC()
		return This._NNLImmutable("decimalpart", [])

	def DecimalPartStringValueQC()
		return This._NNLImmutable("decimalpartstringvalue", [])

	def DecimalPartToHexFormQC()
		return This._NNLImmutable("decimalparttohexform", [])

	def DecimalPartwihtoutDotQC()
		return This._NNLImmutable("decimalpartwihtoutdot", [])

	def DecimalPartWithoutDotQC()
		return This._NNLImmutable("decimalpartwithoutdot", [])

	def DecimalsQC()
		return This._NNLImmutable("decimals", [])

	def DecrementQC()
		return This._NNLImmutable("decrement", [])

	def DeepBoundedByQC(p1)
		return This._NNLImmutable("deepboundedby", [ p1 ])

	def DeepContainsQC(p1)
		return This._NNLImmutable("deepcontains", [ p1 ])

	def DeepContainsManyQC(p1)
		return This._NNLImmutable("deepcontainsmany", [ p1 ])

	def DeepContainsTheseQC(p1)
		return This._NNLImmutable("deepcontainsthese", [ p1 ])

	def DeepFindQC(p1)
		return This._NNLImmutable("deepfind", [ p1 ])

	def DeepFindAllQC(p1)
		return This._NNLImmutable("deepfindall", [ p1 ])

	def DeepFindBoundedByZZQC(p1)
		return This._NNLImmutable("deepfindboundedbyzz", [ p1 ])

	def DeepFindSubStringsZZQC(p1)
		return This._NNLImmutable("deepfindsubstringszz", [ p1 ])

	def DeepListQC()
		return This._NNLImmutable("deeplist", [])

	def DeepListsQC()
		return This._NNLImmutable("deeplists", [])

	def DeeplyContainsQC(p1)
		return This._NNLImmutable("deeplycontains", [ p1 ])

	def DeepRemoveQC(p1)
		return This._NNLImmutable("deepremove", [ p1 ])

	def DeepRemovedQC(p1)
		return This._NNLImmutable("deepremoved", [ p1 ])

	def DeepRemoveManyQC(p1)
		return This._NNLImmutable("deepremovemany", [ p1 ])

	def DeepStringifiyQC()
		return This._NNLImmutable("deepstringifiy", [])

	def DeepSubStringsZZQC(p1)
		return This._NNLImmutable("deepsubstringszz", [ p1 ])

	def DerivativeQC(p1)
		return This._NNLImmutable("derivative", [ p1 ])

	def DiffQC(p1)
		return This._NNLImmutable("diff", [ p1 ])

	def DifferenceWithQC(p1)
		return This._NNLImmutable("differencewith", [ p1 ])

	def DifferentItemsWithQC(p1)
		return This._NNLImmutable("differentitemswith", [ p1 ])

	def DifferentItemsWithXTTQC(p1)
		return This._NNLImmutable("differentitemswithxtt", [ p1 ])

	def DiffWithQC(p1)
		return This._NNLImmutable("diffwith", [ p1 ])

	def DiffXTTQC(p1)
		return This._NNLImmutable("diffxtt", [ p1 ])

	def DisplayQC()
		return This._NNLImmutable("display", [])

	def DistributeOverQC(p1)
		return This._NNLImmutable("distributeover", [ p1 ])

	def DivideByQC(p1)
		return This._NNLImmutable("divideby", [ p1 ])

	def DivideByManyQC(p1)
		return This._NNLImmutable("dividebymany", [ p1 ])

	def DividedByQC(p1)
		return This._NNLImmutable("dividedby", [ p1 ])

	def DividedByManyQC(p1)
		return This._NNLImmutable("dividedbymany", [ p1 ])

	def DoesNotContainQC(p1)
		return This._NNLImmutable("doesnotcontain", [ p1 ])

	def DownToQC(p1)
		return This._NNLImmutable("downto", [ p1 ])

	def DuplicatedItemsCSQC(p1)
		return This._NNLImmutable("duplicateditemscs", [ p1 ])

	def DuplicatedStringsCSQC(p1)
		return This._NNLImmutable("duplicatedstringscs", [ p1 ])

	def DuplicatedSubStringsCSQC(p1)
		return This._NNLImmutable("duplicatedsubstringscs", [ p1 ])

	def DuplicatesCSQC(p1)
		return This._NNLImmutable("duplicatescs", [ p1 ])

	def DuplicatesCSXTZQC(p1)
		return This._NNLImmutable("duplicatescsxtz", [ p1 ])

	def DuplicatesCSZQC(p1)
		return This._NNLImmutable("duplicatescsz", [ p1 ])

	def DuplicatesRemovedCSQC(p1)
		return This._NNLImmutable("duplicatesremovedcs", [ p1 ])

	def DupSecutiveCharsZQC()
		return This._NNLImmutable("dupsecutivecharsz", [])

	def DupSecutiveCharsZZQC()
		return This._NNLImmutable("dupsecutivecharszz", [])

	def DupSecutiveItemsQC()
		return This._NNLImmutable("dupsecutiveitems", [])

	def DupSecutiveItemsCSQC(p1)
		return This._NNLImmutable("dupsecutiveitemscs", [ p1 ])

	def DupSecutiveItemsCSZQC(p1)
		return This._NNLImmutable("dupsecutiveitemscsz", [ p1 ])

	def DupSecutiveItemsZQC()
		return This._NNLImmutable("dupsecutiveitemsz", [])

	def DupSecutiveItemZQC(p1)
		return This._NNLImmutable("dupsecutiveitemz", [ p1 ])

	def DupSecutiveSubStringsQC()
		return This._NNLImmutable("dupsecutivesubstrings", [])

	def DupSecutiveSubStringsZQC()
		return This._NNLImmutable("dupsecutivesubstringsz", [])

	def DupSecutiveSubStringZQC(p1)
		return This._NNLImmutable("dupsecutivesubstringz", [ p1 ])

	def DupSecutiveSubStringZZQC(p1)
		return This._NNLImmutable("dupsecutivesubstringzz", [ p1 ])

	def EachContainsQC(p1)
		return This._NNLImmutable("eachcontains", [ p1 ])

	def EachContainsTheseQC(p1)
		return This._NNLImmutable("eachcontainsthese", [ p1 ])

	def EachItemContainsQC(p1)
		return This._NNLImmutable("eachitemcontains", [ p1 ])

	def EachItemIsQC(p1)
		return This._NNLImmutable("eachitemis", [ p1 ])

	def EachItemIsAQC(p1)
		return This._NNLImmutable("eachitemisa", [ p1 ])

	def EditDistanceWithQC(p1)
		return This._NNLImmutable("editdistancewith", [ p1 ])

	def EndingNumberQC()
		return This._NNLImmutable("endingnumber", [])

	def EnsurePrefixQC(p1)
		return This._NNLImmutable("ensureprefix", [ p1 ])

	def EnsureSuffixQC(p1)
		return This._NNLImmutable("ensuresuffix", [ p1 ])

	def EntitiesQC()
		return This._NNLImmutable("entities", [])

	def EqualToQC(p1)
		return This._NNLImmutable("equalto", [ p1 ])

	def EscapeForRegexQC()
		return This._NNLImmutable("escapeforregex", [])

	def EveryNthItemQC(p1)
		return This._NNLImmutable("everynthitem", [ p1 ])

	def ExceptQC(p1)
		return This._NNLImmutable("except", [ p1 ])

	def ExtendQC(p1)
		return This._NNLImmutable("extend", [ p1 ])

	def ExtendToQC(p1)
		return This._NNLImmutable("extendto", [ p1 ])

	def ExtendToPositionQC(p1)
		return This._NNLImmutable("extendtoposition", [ p1 ])

	def ExtendWithQC(p1)
		return This._NNLImmutable("extendwith", [ p1 ])

	def ExtractQC(p1)
		return This._NNLImmutable("extract", [ p1 ])

	def ExtractAllQC()
		return This._NNLImmutable("extractall", [])

	def ExtractAtQC(p1)
		return This._NNLImmutable("extractat", [ p1 ])

	def ExtractDatesQC()
		return This._NNLImmutable("extractdates", [])

	def ExtractDuplicatesQC()
		return This._NNLImmutable("extractduplicates", [])

	def ExtractDuplicatesCSQC(p1)
		return This._NNLImmutable("extractduplicatescs", [ p1 ])

	def ExtractEmailsQC()
		return This._NNLImmutable("extractemails", [])

	def ExtractFirstQC(p1)
		return This._NNLImmutable("extractfirst", [ p1 ])

	def ExtractFirstOccurrenceQC(p1)
		return This._NNLImmutable("extractfirstoccurrence", [ p1 ])

	def ExtractHashtagsQC()
		return This._NNLImmutable("extracthashtags", [])

	def ExtractIPAddressesQC()
		return This._NNLImmutable("extractipaddresses", [])

	def ExtractLastQC(p1)
		return This._NNLImmutable("extractlast", [ p1 ])

	def ExtractLastOccurrenceQC(p1)
		return This._NNLImmutable("extractlastoccurrence", [ p1 ])

	def ExtractListsQC()
		return This._NNLImmutable("extractlists", [])

	def ExtractManyQC(p1)
		return This._NNLImmutable("extractmany", [ p1 ])

	def ExtractMatchesQC(p1)
		return This._NNLImmutable("extractmatches", [ p1 ])

	def ExtractMentionsQC()
		return This._NNLImmutable("extractmentions", [])

	def ExtractNthQC(p1)
		return This._NNLImmutable("extractnth", [ p1 ])

	def ExtractNumbersQC()
		return This._NNLImmutable("extractnumbers", [])

	def ExtractPatternQC(p1)
		return This._NNLImmutable("extractpattern", [ p1 ])

	def ExtractPhoneNumbersQC()
		return This._NNLImmutable("extractphonenumbers", [])

	def ExtractPhonesQC()
		return This._NNLImmutable("extractphones", [])

	def ExtractPricesQC()
		return This._NNLImmutable("extractprices", [])

	def ExtractStringsQC()
		return This._NNLImmutable("extractstrings", [])

	def ExtractTimesQC()
		return This._NNLImmutable("extracttimes", [])

	def ExtractURLsQC()
		return This._NNLImmutable("extracturls", [])

	def FilledWithQC(p1)
		return This._NNLImmutable("filledwith", [ p1 ])

	def FilterQC(p1)
		return This._NNLImmutable("filter", [ p1 ])

	def FindQC(p1)
		return This._NNLImmutable("find", [ p1 ])

	def FindAllQC(p1)
		return This._NNLImmutable("findall", [ p1 ])

	def FindAllAsSectionsQC(p1)
		return This._NNLImmutable("findallassections", [ p1 ])

	def FindAllCharQC(p1)
		return This._NNLImmutable("findallchar", [ p1 ])

	def FindAllExceptQC(p1)
		return This._NNLImmutable("findallexcept", [ p1 ])

	def FindAllExceptFirstQC(p1)
		return This._NNLImmutable("findallexceptfirst", [ p1 ])

	def FindAllExceptLastQC(p1)
		return This._NNLImmutable("findallexceptlast", [ p1 ])

	def FindAllRegexQC(p1)
		return This._NNLImmutable("findallregex", [ p1 ])

	def FindAllRegexMatchesQC(p1)
		return This._NNLImmutable("findallregexmatches", [ p1 ])

	def FindAllZZQC(p1)
		return This._NNLImmutable("findallzz", [ p1 ])

	def FindAntiSectionsQC(p1)
		return This._NNLImmutable("findantisections", [ p1 ])

	def FindAntiSectionsZQC(p1)
		return This._NNLImmutable("findantisectionsz", [ p1 ])

	def FindAntiSectionsZZQC(p1)
		return This._NNLImmutable("findantisectionszz", [ p1 ])

	def FindAnyBoundedByQC(p1)
		return This._NNLImmutable("findanyboundedby", [ p1 ])

	def FindAnyBoundedByZZQC(p1)
		return This._NNLImmutable("findanyboundedbyzz", [ p1 ])

	def FindAsAntiSectionsQC(p1)
		return This._NNLImmutable("findasantisections", [ p1 ])

	def FindAsSectionQC(p1)
		return This._NNLImmutable("findassection", [ p1 ])

	def FindAsSectionsQC(p1)
		return This._NNLImmutable("findassections", [ p1 ])

	def FindBoundedByQC(p1)
		return This._NNLImmutable("findboundedby", [ p1 ])

	def FindBoundedByZZQC(p1)
		return This._NNLImmutable("findboundedbyzz", [ p1 ])

	def FindBoundedSubStringQC(p1)
		return This._NNLImmutable("findboundedsubstring", [ p1 ])

	def FindBoundedSubStringsQC(p1)
		return This._NNLImmutable("findboundedsubstrings", [ p1 ])

	def FindBoundedSubStringZQC(p1)
		return This._NNLImmutable("findboundedsubstringz", [ p1 ])

	def FindBoundedSubStringZZQC(p1)
		return This._NNLImmutable("findboundedsubstringzz", [ p1 ])

	def FindDuplicatedItemQC(p1)
		return This._NNLImmutable("findduplicateditem", [ p1 ])

	def FindDuplicatedItemsQC()
		return This._NNLImmutable("findduplicateditems", [])

	def FindDuplicatedStringQC(p1)
		return This._NNLImmutable("findduplicatedstring", [ p1 ])

	def FindDuplicatesQC()
		return This._NNLImmutable("findduplicates", [])

	def FindDuplicatesCSQC(p1)
		return This._NNLImmutable("findduplicatescs", [ p1 ])

	def FindDuplicatesOriginsQC()
		return This._NNLImmutable("findduplicatesorigins", [])

	def FindDuplicatesZZQC()
		return This._NNLImmutable("findduplicateszz", [])

	def FindDuplicationsQC()
		return This._NNLImmutable("findduplications", [])

	def FindDupOriginsQC()
		return This._NNLImmutable("findduporigins", [])

	def FindDupSecutiveCharsQC()
		return This._NNLImmutable("finddupsecutivechars", [])

	def FindDupSecutiveCharsCSQC(p1)
		return This._NNLImmutable("finddupsecutivecharscs", [ p1 ])

	def FindDupSecutiveCharsZZQC()
		return This._NNLImmutable("finddupsecutivecharszz", [])

	def FindDupSecutiveItemsQC()
		return This._NNLImmutable("finddupsecutiveitems", [])

	def FindDupSecutiveItemsCSQC(p1)
		return This._NNLImmutable("finddupsecutiveitemscs", [ p1 ])

	def FindEmptyStringsQC()
		return This._NNLImmutable("findemptystrings", [])

	def FindExceptZZQC(p1)
		return This._NNLImmutable("findexceptzz", [ p1 ])

	def FindFirstQC(p1)
		return This._NNLImmutable("findfirst", [ p1 ])

	def FindFirstAsSectionQC(p1)
		return This._NNLImmutable("findfirstassection", [ p1 ])

	def FindFirstDuplicatesQC()
		return This._NNLImmutable("findfirstduplicates", [])

	def FindFirstDuplicatesCSQC(p1)
		return This._NNLImmutable("findfirstduplicatescs", [ p1 ])

	def FindFirstListQC()
		return This._NNLImmutable("findfirstlist", [])

	def FindFirstMarquerQC()
		return This._NNLImmutable("findfirstmarquer", [])

	def FindFirstNonSpaceCharQC()
		return This._NNLImmutable("findfirstnonspacechar", [])

	def FindFirstOccurrenceQC(p1)
		return This._NNLImmutable("findfirstoccurrence", [ p1 ])

	def FindFirstRegexQC(p1)
		return This._NNLImmutable("findfirstregex", [ p1 ])

	def FindFirstSubStringQC(p1)
		return This._NNLImmutable("findfirstsubstring", [ p1 ])

	def FindFirstZQC(p1)
		return This._NNLImmutable("findfirstz", [ p1 ])

	def FindFirstZZQC(p1)
		return This._NNLImmutable("findfirstzz", [ p1 ])

	def FindInvisibleCharsQC()
		return This._NNLImmutable("findinvisiblechars", [])

	def FindItemQC(p1)
		return This._NNLImmutable("finditem", [ p1 ])

	def FindItemsQC()
		return This._NNLImmutable("finditems", [])

	def FindItemsCSQC(p1)
		return This._NNLImmutable("finditemscs", [ p1 ])

	def FindItemsOtherThanQC(p1)
		return This._NNLImmutable("finditemsotherthan", [ p1 ])

	def FindLargestQC()
		return This._NNLImmutable("findlargest", [])

	def FindLastQC(p1)
		return This._NNLImmutable("findlast", [ p1 ])

	def FindLastAsSectionQC(p1)
		return This._NNLImmutable("findlastassection", [ p1 ])

	def FindLasteAsSectionQC(p1)
		return This._NNLImmutable("findlasteassection", [ p1 ])

	def FindLastMarquerQC()
		return This._NNLImmutable("findlastmarquer", [])

	def FindLastNonSpaceCharQC()
		return This._NNLImmutable("findlastnonspacechar", [])

	def FindLastZQC(p1)
		return This._NNLImmutable("findlastz", [ p1 ])

	def FindLastZZQC(p1)
		return This._NNLImmutable("findlastzz", [ p1 ])

	def FindLeadingCharsQC()
		return This._NNLImmutable("findleadingchars", [])

	def FindLeadingCharsZZQC()
		return This._NNLImmutable("findleadingcharszz", [])

	def FindListsAsSectionsQC()
		return This._NNLImmutable("findlistsassections", [])

	def FindListsZZQC()
		return This._NNLImmutable("findlistszz", [])

	def FindManyQC(p1)
		return This._NNLImmutable("findmany", [ p1 ])

	def FindManyAsSectionsQC(p1)
		return This._NNLImmutable("findmanyassections", [ p1 ])

	def FindManyZZQC(p1)
		return This._NNLImmutable("findmanyzz", [ p1 ])

	def FindMarkerQC(p1)
		return This._NNLImmutable("findmarker", [ p1 ])

	def FindMarkersQC()
		return This._NNLImmutable("findmarkers", [])

	def FindMarkersAsSectionsQC()
		return This._NNLImmutable("findmarkersassections", [])

	def FindMarquerQC(p1)
		return This._NNLImmutable("findmarquer", [ p1 ])

	def FindMarquersQC()
		return This._NNLImmutable("findmarquers", [])

	def FindMarquersAsSectionsQC()
		return This._NNLImmutable("findmarquersassections", [])

	def FindNamedObjectsQC()
		return This._NNLImmutable("findnamedobjects", [])

	def FindNonDuplicatedItemsQC()
		return This._NNLImmutable("findnonduplicateditems", [])

	def FindNonNumbersQC()
		return This._NNLImmutable("findnonnumbers", [])

	def FindNonStzObjectsQC()
		return This._NNLImmutable("findnonstzobjects", [])

	def FindNthLargestQC(p1)
		return This._NNLImmutable("findnthlargest", [ p1 ])

	def FindNthMarquerQC(p1)
		return This._NNLImmutable("findnthmarquer", [ p1 ])

	def FindNthSmallestQC(p1)
		return This._NNLImmutable("findnthsmallest", [ p1 ])

	def FindNumbersQC()
		return This._NNLImmutable("findnumbers", [])

	def FindNumbersAsSectionsQC()
		return This._NNLImmutable("findnumbersassections", [])

	def FindNumbersZZQC()
		return This._NNLImmutable("findnumberszz", [])

	def FindObjectQC(p1)
		return This._NNLImmutable("findobject", [ p1 ])

	def FindObjectsQC()
		return This._NNLImmutable("findobjects", [])

	def FindObjectsAsSectionsQC()
		return This._NNLImmutable("findobjectsassections", [])

	def FindObjectsZZQC()
		return This._NNLImmutable("findobjectszz", [])

	def FindPairsQC()
		return This._NNLImmutable("findpairs", [])

	def FindPositionsQC(p1)
		return This._NNLImmutable("findpositions", [ p1 ])

	def FindRegexQC(p1)
		return This._NNLImmutable("findregex", [ p1 ])

	def FindSinglesQC()
		return This._NNLImmutable("findsingles", [])

	def FindSmallestQC()
		return This._NNLImmutable("findsmallest", [])

	def FindSpacesQC()
		return This._NNLImmutable("findspaces", [])

	def FindStringsAsSectionsQC()
		return This._NNLImmutable("findstringsassections", [])

	def FindStringsZZQC()
		return This._NNLImmutable("findstringszz", [])

	def FindStzListsQC()
		return This._NNLImmutable("findstzlists", [])

	def FindStzNumbersQC()
		return This._NNLImmutable("findstznumbers", [])

	def FindStzObjectsQC()
		return This._NNLImmutable("findstzobjects", [])

	def FindStzStringsQC()
		return This._NNLImmutable("findstzstrings", [])

	def FindSubListQC(p1)
		return This._NNLImmutable("findsublist", [ p1 ])

	def FindSubStringQC(p1)
		return This._NNLImmutable("findsubstring", [ p1 ])

	def FindSubStringBoundsQC(p1)
		return This._NNLImmutable("findsubstringbounds", [ p1 ])

	def FindSubStringBoundsZZQC(p1)
		return This._NNLImmutable("findsubstringboundszz", [ p1 ])

	def FindSubStringsWZZQC(p1)
		return This._NNLImmutable("findsubstringswzz", [ p1 ])

	def FindTheseAdjacentItemsQC(p1)
		return This._NNLImmutable("findtheseadjacentitems", [ p1 ])

	def FindTrailingCharsQC()
		return This._NNLImmutable("findtrailingchars", [])

	def FindTrailingCharsZZQC()
		return This._NNLImmutable("findtrailingcharszz", [])

	def FindUnnamedObjectsQC()
		return This._NNLImmutable("findunnamedobjects", [])

	def FindWordsQC()
		return This._NNLImmutable("findwords", [])

	def FindZQC(p1)
		return This._NNLImmutable("findz", [ p1 ])

	def FindZZQC(p1)
		return This._NNLImmutable("findzz", [ p1 ])

	def FirstListQC()
		return This._NNLImmutable("firstlist", [])

	def FirstMarkerQC()
		return This._NNLImmutable("firstmarker", [])

	def FirstMarquerQC()
		return This._NNLImmutable("firstmarquer", [])

	def FirstNumberComingAfterQC(p1)
		return This._NNLImmutable("firstnumbercomingafter", [ p1 ])

	def FirstOccurrenceQC(p1)
		return This._NNLImmutable("firstoccurrence", [ p1 ])

	def FirstZQC(p1)
		return This._NNLImmutable("firstz", [ p1 ])

	def FirstZZQC(p1)
		return This._NNLImmutable("firstzz", [ p1 ])

	def FlattenQC()
		return This._NNLImmutable("flatten", [])

	def FormatQC()
		return This._NNLImmutable("format", [])

	def FractionalPartQC()
		return This._NNLImmutable("fractionalpart", [])

	def FromBinaryQC(p1)
		return This._NNLImmutable("frombinary", [ p1 ])

	def FromBinaryFormQC(p1)
		return This._NNLImmutable("frombinaryform", [ p1 ])

	def FromHexQC()
		return This._NNLImmutable("fromhex", [])

	def FromHexFormQC(p1)
		return This._NNLImmutable("fromhexform", [ p1 ])

	def FromOctalQC(p1)
		return This._NNLImmutable("fromoctal", [ p1 ])

	def FromOctalFormQC(p1)
		return This._NNLImmutable("fromoctalform", [ p1 ])

	def FromUrlQC(p1)
		return This._NNLImmutable("fromurl", [ p1 ])

	def GCDQC(p1)
		return This._NNLImmutable("gcd", [ p1 ])

	def GreatestCommonDividorQC(p1)
		return This._NNLImmutable("greatestcommondividor", [ p1 ])

	def GroupByQC(p1)
		return This._NNLImmutable("groupby", [ p1 ])

	def HeadQC(p1)
		return This._NNLImmutable("head", [ p1 ])

	def HowManyQC(p1)
		return This._NNLImmutable("howmany", [ p1 ])

	def HtmlDecodeQC()
		return This._NNLImmutable("htmldecode", [])

	def HtmlEncodeQC()
		return This._NNLImmutable("htmlencode", [])

	def HundredsQC()
		return This._NNLImmutable("hundreds", [])

	def HyperbolicTangentQC()
		return This._NNLImmutable("hyperbolictangent", [])

	def HypernymsQC()
		return This._NNLImmutable("hypernyms", [])

	def IncrementQC()
		return This._NNLImmutable("increment", [])

	def IndexCSQC(p1)
		return This._NNLImmutable("indexcs", [ p1 ])

	def InfereMethodQC(p1)
		return This._NNLImmutable("inferemethod", [ p1 ])

	def InitialContentQC()
		return This._NNLImmutable("initialcontent", [])

	def InnQC(p1)
		return This._NNLImmutable("inn", [ p1 ])

	def InterleavedWithQC(p1)
		return This._NNLImmutable("interleavedwith", [ p1 ])

	def InterleaveWithQC(p1)
		return This._NNLImmutable("interleavewith", [ p1 ])

	def IntersectionQC(p1)
		return This._NNLImmutable("intersection", [ p1 ])

	def IntersectionWithQC(p1)
		return This._NNLImmutable("intersectionwith", [ p1 ])

	def IntersectWithQC(p1)
		return This._NNLImmutable("intersectwith", [ p1 ])

	def InvertCharsCaseQC()
		return This._NNLImmutable("invertcharscase", [])

	def InvisibleCharsQC()
		return This._NNLImmutable("invisiblechars", [])

	def ItemQC(p1)
		return This._NNLImmutable("item", [ p1 ])

	def ItemAtQC(p1)
		return This._NNLImmutable("itemat", [ p1 ])

	def ItemAtPositionQC(p1)
		return This._NNLImmutable("itematposition", [ p1 ])

	def ItemsAreQC(p1)
		return This._NNLImmutable("itemsare", [ p1 ])

	def ItemsAreEqualToQC(p1)
		return This._NNLImmutable("itemsareequalto", [ p1 ])

	def ItemsAtQC(p1)
		return This._NNLImmutable("itemsat", [ p1 ])

	def ItemsAtPositionsQC(p1)
		return This._NNLImmutable("itemsatpositions", [ p1 ])

	def ItemsExceptQC(p1)
		return This._NNLImmutable("itemsexcept", [ p1 ])

	def ItemsHaveSameOrderAsQC(p1)
		return This._NNLImmutable("itemshavesameorderas", [ p1 ])

	def ItemsThatArePairsQC()
		return This._NNLImmutable("itemsthatarepairs", [])

	def JaroSimilarityWithQC(p1)
		return This._NNLImmutable("jarosimilaritywith", [ p1 ])

	def JoinQC(p1)
		return This._NNLImmutable("join", [ p1 ])

	def KeepFirstQC(p1)
		return This._NNLImmutable("keepfirst", [ p1 ])

	def KeyPhrasesQC(p1)
		return This._NNLImmutable("keyphrases", [ p1 ])

	def KlassQC(p1)
		return This._NNLImmutable("klass", [ p1 ])

	def KlassSFQC(p1)
		return This._NNLImmutable("klasssf", [ p1 ])

	def LastMarquerQC()
		return This._NNLImmutable("lastmarquer", [])

	def LCMQC(p1)
		return This._NNLImmutable("lcm", [ p1 ])

	def LeadingCharQC()
		return This._NNLImmutable("leadingchar", [])

	def LeadingCharCSQC(p1)
		return This._NNLImmutable("leadingcharcs", [ p1 ])

	def LeadingCharIsQC(p1)
		return This._NNLImmutable("leadingcharis", [ p1 ])

	def LeadingCharsQC()
		return This._NNLImmutable("leadingchars", [])

	def LeadingCharsAsStringQC()
		return This._NNLImmutable("leadingcharsasstring", [])

	def LeadingCharsCSQC(p1)
		return This._NNLImmutable("leadingcharscs", [ p1 ])

	def LeadingNumberQC()
		return This._NNLImmutable("leadingnumber", [])

	def LeadingSubStringQC()
		return This._NNLImmutable("leadingsubstring", [])

	def LeadingSubStringCSQC(p1)
		return This._NNLImmutable("leadingsubstringcs", [ p1 ])

	def LeadingSubStringRemoveQC()
		return This._NNLImmutable("leadingsubstringremove", [])

	def LeadingSubStringZZQC()
		return This._NNLImmutable("leadingsubstringzz", [])

	def LeastCommonMultipleQC(p1)
		return This._NNLImmutable("leastcommonmultiple", [ p1 ])

	def LettersZQC()
		return This._NNLImmutable("lettersz", [])

	def LinesContainingQC(p1)
		return This._NNLImmutable("linescontaining", [ p1 ])

	def ListsQC()
		return This._NNLImmutable("lists", [])

	def ListsAtAnyLevelQC()
		return This._NNLImmutable("listsatanylevel", [])

	def ListsZQC()
		return This._NNLImmutable("listsz", [])

	def LocationsQC()
		return This._NNLImmutable("locations", [])

	def LowercaseQC()
		return This._NNLImmutable("lowercase", [])

	def MapQC(p1)
		return This._NNLImmutable("map", [ p1 ])

	def MarkerByPositionQC(p1)
		return This._NNLImmutable("markerbyposition", [ p1 ])

	def MarkerByPositionsQC(p1)
		return This._NNLImmutable("markerbypositions", [ p1 ])

	def MarkersQC()
		return This._NNLImmutable("markers", [])

	def MarkersAndSectionsQC()
		return This._NNLImmutable("markersandsections", [])

	def MarkersByPositionsQC(p1)
		return This._NNLImmutable("markersbypositions", [ p1 ])

	def MarkersPositionsQC()
		return This._NNLImmutable("markerspositions", [])

	def MarkersSortedUZQC()
		return This._NNLImmutable("markerssorteduz", [])

	def MarkersSortedUZZQC()
		return This._NNLImmutable("markerssorteduzz", [])

	def MarkersSortedZQC()
		return This._NNLImmutable("markerssortedz", [])

	def MarkersSortedZZQC()
		return This._NNLImmutable("markerssortedzz", [])

	def MarkersUZQC()
		return This._NNLImmutable("markersuz", [])

	def MarkersUZZQC()
		return This._NNLImmutable("markersuzz", [])

	def MarkersZQC()
		return This._NNLImmutable("markersz", [])

	def MarkersZZQC()
		return This._NNLImmutable("markerszz", [])

	def MarquerByPositionQC(p1)
		return This._NNLImmutable("marquerbyposition", [ p1 ])

	def MarquerByPositionsQC(p1)
		return This._NNLImmutable("marquerbypositions", [ p1 ])

	def MarquersQC()
		return This._NNLImmutable("marquers", [])

	def MarquersAndPositionsQC()
		return This._NNLImmutable("marquersandpositions", [])

	def MarquersAndSectionsQC()
		return This._NNLImmutable("marquersandsections", [])

	def MarquersByPositionsQC(p1)
		return This._NNLImmutable("marquersbypositions", [ p1 ])

	def MarquersPositionsQC()
		return This._NNLImmutable("marquerspositions", [])

	def MarquersSortedUZQC()
		return This._NNLImmutable("marquerssorteduz", [])

	def MarquersSortedUZZQC()
		return This._NNLImmutable("marquerssorteduzz", [])

	def MarquersSortedZQC()
		return This._NNLImmutable("marquerssortedz", [])

	def MarquersSortedZZQC()
		return This._NNLImmutable("marquerssortedzz", [])

	def MarquersUZQC()
		return This._NNLImmutable("marquersuz", [])

	def MarquersUZZQC()
		return This._NNLImmutable("marquersuzz", [])

	def MarquersZQC()
		return This._NNLImmutable("marquersz", [])

	def MarquersZZQC()
		return This._NNLImmutable("marquerszz", [])

	def MatchesRegexQC(p1)
		return This._NNLImmutable("matchesregex", [ p1 ])

	def MergeQC()
		return This._NNLImmutable("merge", [])

	def MergedWithQC(p1)
		return This._NNLImmutable("mergedwith", [ p1 ])

	def MergedWithManyQC(p1)
		return This._NNLImmutable("mergedwithmany", [ p1 ])

	def MergeWithQC(p1)
		return This._NNLImmutable("mergewith", [ p1 ])

	def MergeWithManyQC(p1)
		return This._NNLImmutable("mergewithmany", [ p1 ])

	def MillionsQC()
		return This._NNLImmutable("millions", [])

	def ModuloQC(p1)
		return This._NNLImmutable("modulo", [ p1 ])

	def MostFrequentCharsQC(p1)
		return This._NNLImmutable("mostfrequentchars", [ p1 ])

	def MostFrequentWordsQC(p1)
		return This._NNLImmutable("mostfrequentwords", [ p1 ])

	def MostSimilarSentenceToQC(p1)
		return This._NNLImmutable("mostsimilarsentenceto", [ p1 ])

	def MostSquareLikeFactorsQC()
		return This._NNLImmutable("mostsquarelikefactors", [])

	def MoveItemToEndQC(p1)
		return This._NNLImmutable("moveitemtoend", [ p1 ])

	def MoveItemToStartQC(p1)
		return This._NNLImmutable("moveitemtostart", [ p1 ])

	def MoveToEndQC(p1)
		return This._NNLImmutable("movetoend", [ p1 ])

	def MoveToStartQC(p1)
		return This._NNLImmutable("movetostart", [ p1 ])

	def MSLFQC()
		return This._NNLImmutable("mslf", [])

	def MultiplesQC(p1)
		return This._NNLImmutable("multiples", [ p1 ])

	def MultiplesUnderQC(p1)
		return This._NNLImmutable("multiplesunder", [ p1 ])

	def MultiplesUpToQC(p1)
		return This._NNLImmutable("multiplesupto", [ p1 ])

	def MultipliedByQC(p1)
		return This._NNLImmutable("multipliedby", [ p1 ])

	def MultipliedByManyQC(p1)
		return This._NNLImmutable("multipliedbymany", [ p1 ])

	def MultiplyByQC(p1)
		return This._NNLImmutable("multiplyby", [ p1 ])

	def MultiplyByManyQC(p1)
		return This._NNLImmutable("multiplybymany", [ p1 ])

	def NamedEntitiesQC()
		return This._NNLImmutable("namedentities", [])

	def NamedObjectsQC()
		return This._NNLImmutable("namedobjects", [])

	def NegativeSentencesQC()
		return This._NNLImmutable("negativesentences", [])

	def NestedSubStringsQC(p1)
		return This._NNLImmutable("nestedsubstrings", [ p1 ])

	def NextMarquersQC(p1)
		return This._NNLImmutable("nextmarquers", [ p1 ])

	def NoItemsAreDuplicatedCSQC(p1)
		return This._NNLImmutable("noitemsareduplicatedcs", [ p1 ])

	def NonDuplicatedItemsCSQC(p1)
		return This._NNLImmutable("nonduplicateditemscs", [ p1 ])

	def NonNumbersQC()
		return This._NNLImmutable("nonnumbers", [])

	def NthCharQC(p1)
		return This._NNLImmutable("nthchar", [ p1 ])

	def NthItemQC(p1)
		return This._NNLImmutable("nthitem", [ p1 ])

	def NthLargestQC(p1)
		return This._NNLImmutable("nthlargest", [ p1 ])

	def NthLineQC(p1)
		return This._NNLImmutable("nthline", [ p1 ])

	def NthMarkerQC(p1)
		return This._NNLImmutable("nthmarker", [ p1 ])

	def NthMarquerQC(p1)
		return This._NNLImmutable("nthmarquer", [ p1 ])

	def NthParagraphQC(p1)
		return This._NNLImmutable("nthparagraph", [ p1 ])

	def NthSentenceQC(p1)
		return This._NNLImmutable("nthsentence", [ p1 ])

	def NthSmallestQC(p1)
		return This._NNLImmutable("nthsmallest", [ p1 ])

	def NthToLastQC(p1)
		return This._NNLImmutable("nthtolast", [ p1 ])

	def NthWordQC(p1)
		return This._NNLImmutable("nthword", [ p1 ])

	def NumberAfterQC(p1)
		return This._NNLImmutable("numberafter", [ p1 ])

	def NumberComingAfterQC(p1)
		return This._NNLImmutable("numbercomingafter", [ p1 ])

	def NumbersQC()
		return This._NNLImmutable("numbers", [])

	def NumbersAfterQC(p1)
		return This._NNLImmutable("numbersafter", [ p1 ])

	def NumbersComingAfterQC(p1)
		return This._NNLImmutable("numberscomingafter", [ p1 ])

	def NumbersZQC()
		return This._NNLImmutable("numbersz", [])

	def NumbersZZQC()
		return This._NNLImmutable("numberszz", [])

	def NumberValueQC()
		return This._NNLImmutable("numbervalue", [])

	def NumericValueQC()
		return This._NNLImmutable("numericvalue", [])

	def ObjectifyQC()
		return This._NNLImmutable("objectify", [])

	def ObjectsQC()
		return This._NNLImmutable("objects", [])

	def ObjectsVarNamesQC()
		return This._NNLImmutable("objectsvarnames", [])

	def ObjectsVarNamesUQC()
		return This._NNLImmutable("objectsvarnamesu", [])

	def ObjectsZQC()
		return This._NNLImmutable("objectsz", [])

	def ObjectsZZQC()
		return This._NNLImmutable("objectszz", [])

	def OnlyCharsQC()
		return This._NNLImmutable("onlychars", [])

	def OnlyControlsQC()
		return This._NNLImmutable("onlycontrols", [])

	def OnlyDigitsQC()
		return This._NNLImmutable("onlydigits", [])

	def OnlyListsQC()
		return This._NNLImmutable("onlylists", [])

	def OnlyMarksQC()
		return This._NNLImmutable("onlymarks", [])

	def OnlyNonNumbersQC()
		return This._NNLImmutable("onlynonnumbers", [])

	def OnlyNumbersQC()
		return This._NNLImmutable("onlynumbers", [])

	def OnlyObjectsQC()
		return This._NNLImmutable("onlyobjects", [])

	def OnlyStringsQC()
		return This._NNLImmutable("onlystrings", [])

	def OrganizationsQC()
		return This._NNLImmutable("organizations", [])

	def PairsQC()
		return This._NNLImmutable("pairs", [])

	def PairsUQC()
		return This._NNLImmutable("pairsu", [])

	def PairsZQC()
		return This._NNLImmutable("pairsz", [])

	def PartitionQC(p1)
		return This._NNLImmutable("partition", [ p1 ])

	def PartsClassifiedUsingQC(p1)
		return This._NNLImmutable("partsclassifiedusing", [ p1 ])

	def PartsUsingQC(p1)
		return This._NNLImmutable("partsusing", [ p1 ])

	def PartsUsingZZQC(p1)
		return This._NNLImmutable("partsusingzz", [ p1 ])

	def PerformQC(p1)
		return This._NNLImmutable("perform", [ p1 ])

	def PersonNamesQC()
		return This._NNLImmutable("personnames", [])

	def PopQC()
		return This._NNLImmutable("pop", [])

	def PopFirstQC()
		return This._NNLImmutable("popfirst", [])

	def PositionAfterQC(p1)
		return This._NNLImmutable("positionafter", [ p1 ])

	def PositionBeforeQC(p1)
		return This._NNLImmutable("positionbefore", [ p1 ])

	def PositionsQC(p1)
		return This._NNLImmutable("positions", [ p1 ])

	def PositiveSentencesQC()
		return This._NNLImmutable("positivesentences", [])

	def PowerQC(p1)
		return This._NNLImmutable("power", [ p1 ])

	def PrependedWithQC(p1)
		return This._NNLImmutable("prependedwith", [ p1 ])

	def PrependWithQC(p1)
		return This._NNLImmutable("prependwith", [ p1 ])

	def PreviousMarkerZQC(p1)
		return This._NNLImmutable("previousmarkerz", [ p1 ])

	def PreviousMarquersQC(p1)
		return This._NNLImmutable("previousmarquers", [ p1 ])

	def PreviousMarquerZQC(p1)
		return This._NNLImmutable("previousmarquerz", [ p1 ])

	def PrintQC()
		return This._NNLImmutable("print", [])

	def PronounsQC()
		return This._NNLImmutable("pronouns", [])

	def ProperNounsQC()
		return This._NNLImmutable("propernouns", [])

	def RandomiseNumbersQC()
		return This._NNLImmutable("randomisenumbers", [])

	def RandomiseStringsQC()
		return This._NNLImmutable("randomisestrings", [])

	def RandomItemExceptQC(p1)
		return This._NNLImmutable("randomitemexcept", [ p1 ])

	def RandomizeQC()
		return This._NNLImmutable("randomize", [])

	def RandomizeNumbersQC()
		return This._NNLImmutable("randomizenumbers", [])

	def RandomizeStringsQC()
		return This._NNLImmutable("randomizestrings", [])

	def RandomPositionAfterQC(p1)
		return This._NNLImmutable("randompositionafter", [ p1 ])

	def RandomPositionExceptQC(p1)
		return This._NNLImmutable("randompositionexcept", [ p1 ])

	def RandomPositionLessThanQC(p1)
		return This._NNLImmutable("randompositionlessthan", [ p1 ])

	def RandomRemoveItemsQC()
		return This._NNLImmutable("randomremoveitems", [])

	def RangesQC(p1)
		return This._NNLImmutable("ranges", [ p1 ])

	def RangesAndAntiRangesQC(p1)
		return This._NNLImmutable("rangesandantiranges", [ p1 ])

	def RankedKeywordsQC(p1)
		return This._NNLImmutable("rankedkeywords", [ p1 ])

	def RedoQC()
		return This._NNLImmutable("redo", [])

	def ReduceNoInitQC(p1)
		return This._NNLImmutable("reducenoinit", [ p1 ])

	def RegexMatchesQC(p1)
		return This._NNLImmutable("regexmatches", [ p1 ])

	def RemoveQC(p1)
		return This._NNLImmutable("remove", [ p1 ])

	def RemoveAllQC(p1)
		return This._NNLImmutable("removeall", [ p1 ])

	def RemoveAllExceptQC(p1)
		return This._NNLImmutable("removeallexcept", [ p1 ])

	def RemoveAllExceptNumbersQC()
		return This._NNLImmutable("removeallexceptnumbers", [])

	def RemoveAllItemsQC()
		return This._NNLImmutable("removeallitems", [])

	def RemoveAnyCharFromLeftQC(p1)
		return This._NNLImmutable("removeanycharfromleft", [ p1 ])

	def RemoveAnyCharFromRightQC(p1)
		return This._NNLImmutable("removeanycharfromright", [ p1 ])

	def RemoveAnyItemFromEndQC(p1)
		return This._NNLImmutable("removeanyitemfromend", [ p1 ])

	def RemoveAnyItemFromStartQC(p1)
		return This._NNLImmutable("removeanyitemfromstart", [ p1 ])

	def RemoveAnyLeadingCharQC()
		return This._NNLImmutable("removeanyleadingchar", [])

	def RemoveAtPositionQC(p1)
		return This._NNLImmutable("removeatposition", [ p1 ])

	def RemoveBlankLinesQC()
		return This._NNLImmutable("removeblanklines", [])

	def RemoveBoundedSubStringQC(p1)
		return This._NNLImmutable("removeboundedsubstring", [ p1 ])

	def RemoveBoundingCharsQC()
		return This._NNLImmutable("removeboundingchars", [])

	def RemoveBoundsQC()
		return This._NNLImmutable("removebounds", [])

	def RemoveCharQC(p1)
		return This._NNLImmutable("removechar", [ p1 ])

	def RemoveCharAtQC(p1)
		return This._NNLImmutable("removecharat", [ p1 ])

	def RemoveCharFromLeftQC(p1)
		return This._NNLImmutable("removecharfromleft", [ p1 ])

	def RemoveCharFromRightQC(p1)
		return This._NNLImmutable("removecharfromright", [ p1 ])

	def RemovedFromEndQC(p1)
		return This._NNLImmutable("removedfromend", [ p1 ])

	def RemoveDiacriticsQC()
		return This._NNLImmutable("removediacritics", [])

	def RemoveDupCharsQC()
		return This._NNLImmutable("removedupchars", [])

	def RemoveDuplicatedCharsQC()
		return This._NNLImmutable("removeduplicatedchars", [])

	def RemoveDuplicatedItemsQC()
		return This._NNLImmutable("removeduplicateditems", [])

	def RemoveDuplicatesQC()
		return This._NNLImmutable("removeduplicates", [])

	def RemoveDuplicatesCSQC(p1)
		return This._NNLImmutable("removeduplicatescs", [ p1 ])

	def RemoveDupOriginsQC()
		return This._NNLImmutable("removeduporigins", [])

	def RemoveDupSecutiveItemQC(p1)
		return This._NNLImmutable("removedupsecutiveitem", [ p1 ])

	def RemoveDupSecutiveItemsQC()
		return This._NNLImmutable("removedupsecutiveitems", [])

	def RemoveEmptyLinesQC()
		return This._NNLImmutable("removeemptylines", [])

	def RemoveEmptyStringsQC()
		return This._NNLImmutable("removeemptystrings", [])

	def RemoveFirstQC(p1)
		return This._NNLImmutable("removefirst", [ p1 ])

	def RemoveFirstCharQC()
		return This._NNLImmutable("removefirstchar", [])

	def RemoveFirstCharCSQC(p1)
		return This._NNLImmutable("removefirstcharcs", [ p1 ])

	def RemoveFirstItemQC()
		return This._NNLImmutable("removefirstitem", [])

	def RemoveFirstOccurrenceQC(p1)
		return This._NNLImmutable("removefirstoccurrence", [ p1 ])

	def RemoveFromEndQC(p1)
		return This._NNLImmutable("removefromend", [ p1 ])

	def RemoveFromLeftQC(p1)
		return This._NNLImmutable("removefromleft", [ p1 ])

	def RemoveFromRightQC(p1)
		return This._NNLImmutable("removefromright", [ p1 ])

	def RemoveFromStartQC(p1)
		return This._NNLImmutable("removefromstart", [ p1 ])

	def RemoveItemAtPositionQC(p1)
		return This._NNLImmutable("removeitematposition", [ p1 ])

	def RemoveItemsAtPositionsQC(p1)
		return This._NNLImmutable("removeitemsatpositions", [ p1 ])

	def RemoveItemsOtherThanQC(p1)
		return This._NNLImmutable("removeitemsotherthan", [ p1 ])

	def RemoveLastQC(p1)
		return This._NNLImmutable("removelast", [ p1 ])

	def RemoveLastCharQC()
		return This._NNLImmutable("removelastchar", [])

	def RemoveLastItemQC()
		return This._NNLImmutable("removelastitem", [])

	def RemoveLeadingCharQC()
		return This._NNLImmutable("removeleadingchar", [])

	def RemoveLeadingCharsQC()
		return This._NNLImmutable("removeleadingchars", [])

	def RemoveLeadingSpacesQC()
		return This._NNLImmutable("removeleadingspaces", [])

	def RemoveLeadingSubStringQC()
		return This._NNLImmutable("removeleadingsubstring", [])

	def RemoveLeftOccurrenceQC(p1)
		return This._NNLImmutable("removeleftoccurrence", [ p1 ])

	def RemoveManyQC(p1)
		return This._NNLImmutable("removemany", [ p1 ])

	def RemoveManySectionsQC(p1)
		return This._NNLImmutable("removemanysections", [ p1 ])

	def RemoveNonDuplicatesQC()
		return This._NNLImmutable("removenonduplicates", [])

	def RemoveNonNumbersQC()
		return This._NNLImmutable("removenonnumbers", [])

	def RemoveNthCharQC(p1)
		return This._NNLImmutable("removenthchar", [ p1 ])

	def RemoveNthItemQC(p1)
		return This._NNLImmutable("removenthitem", [ p1 ])

	def RemoveNumbersQC()
		return This._NNLImmutable("removenumbers", [])

	def RemoveOnlyNonNumbersQC()
		return This._NNLImmutable("removeonlynonnumbers", [])

	def RemoveOnlyNumbersQC()
		return This._NNLImmutable("removeonlynumbers", [])

	def RemoveRangesQC(p1)
		return This._NNLImmutable("removeranges", [ p1 ])

	def RemoveRightOccurrenceQC(p1)
		return This._NNLImmutable("removerightoccurrence", [ p1 ])

	def RemoveSectionsQC(p1)
		return This._NNLImmutable("removesections", [ p1 ])

	def RemoveSignQC()
		return This._NNLImmutable("removesign", [])

	def RemoveSpacesQC()
		return This._NNLImmutable("removespaces", [])

	def RemoveTheseItemsQC(p1)
		return This._NNLImmutable("removetheseitems", [ p1 ])

	def RemoveThisBoundQC(p1)
		return This._NNLImmutable("removethisbound", [ p1 ])

	def RemoveThisCharFromEndQC(p1)
		return This._NNLImmutable("removethischarfromend", [ p1 ])

	def RemoveThisCharFromLeftQC(p1)
		return This._NNLImmutable("removethischarfromleft", [ p1 ])

	def RemoveThisFirstCharQC(p1)
		return This._NNLImmutable("removethisfirstchar", [ p1 ])

	def RemoveThisFirstItemQC(p1)
		return This._NNLImmutable("removethisfirstitem", [ p1 ])

	def RemoveThisLastCharQC(p1)
		return This._NNLImmutable("removethislastchar", [ p1 ])

	def RemoveThisLeadingCharQC(p1)
		return This._NNLImmutable("removethisleadingchar", [ p1 ])

	def RemoveThisTrailingCharQC(p1)
		return This._NNLImmutable("removethistrailingchar", [ p1 ])

	def RemoveTrailingCharQC()
		return This._NNLImmutable("removetrailingchar", [])

	def RemoveTrailingCharsQC()
		return This._NNLImmutable("removetrailingchars", [])

	def RemoveTrailingSpacesQC()
		return This._NNLImmutable("removetrailingspaces", [])

	def RemoveZerosQC()
		return This._NNLImmutable("removezeros", [])

	def RemoveZerosFromLeftQC()
		return This._NNLImmutable("removezerosfromleft", [])

	def RemoveZerosFromRightQC()
		return This._NNLImmutable("removezerosfromright", [])

	def RepeatQC(p1)
		return This._NNLImmutable("repeat", [ p1 ])

	def RepeatedLeadingCharQC()
		return This._NNLImmutable("repeatedleadingchar", [])

	def RepeatedLeadingCharsQC()
		return This._NNLImmutable("repeatedleadingchars", [])

	def RepeatedLeadingCharsCSQC(p1)
		return This._NNLImmutable("repeatedleadingcharscs", [ p1 ])

	def RepeatedLeadingItemQC()
		return This._NNLImmutable("repeatedleadingitem", [])

	def RepeatedLeadingItemCSQC(p1)
		return This._NNLImmutable("repeatedleadingitemcs", [ p1 ])

	def RepeatedLeadingItemsQC()
		return This._NNLImmutable("repeatedleadingitems", [])

	def RepeatedLeadingItemsCSQC(p1)
		return This._NNLImmutable("repeatedleadingitemscs", [ p1 ])

	def RepeatedTrailingCharQC()
		return This._NNLImmutable("repeatedtrailingchar", [])

	def RepeatedTrailingCharsQC()
		return This._NNLImmutable("repeatedtrailingchars", [])

	def RepeatedTrailingItemQC()
		return This._NNLImmutable("repeatedtrailingitem", [])

	def RepeatedTrailingItemCSQC(p1)
		return This._NNLImmutable("repeatedtrailingitemcs", [ p1 ])

	def RepeatedTrailingItemsQC()
		return This._NNLImmutable("repeatedtrailingitems", [])

	def ReplaceAllCharsQC(p1)
		return This._NNLImmutable("replaceallchars", [ p1 ])

	def ReplaceAllItemsQC(p1)
		return This._NNLImmutable("replaceallitems", [ p1 ])

	def ReplaceEachLeadingCharQC(p1)
		return This._NNLImmutable("replaceeachleadingchar", [ p1 ])

	def ReplaceEmptyStringsQC(p1)
		return This._NNLImmutable("replaceemptystrings", [ p1 ])

	def ReplaceLeadingCharsQC(p1)
		return This._NNLImmutable("replaceleadingchars", [ p1 ])

	def ReplaceLeadingItemsQC(p1)
		return This._NNLImmutable("replaceleadingitems", [ p1 ])

	def ReplaceMarkersQC(p1)
		return This._NNLImmutable("replacemarkers", [ p1 ])

	def ReplaceMarquersQC(p1)
		return This._NNLImmutable("replacemarquers", [ p1 ])

	def ReplaceTrailingCharsQC(p1)
		return This._NNLImmutable("replacetrailingchars", [ p1 ])

	def ReplaceTrailingItemsQC(p1)
		return This._NNLImmutable("replacetrailingitems", [ p1 ])

	def RetrieveQC(p1)
		return This._NNLImmutable("retrieve", [ p1 ])

	def RetrieveManyQC(p1)
		return This._NNLImmutable("retrievemany", [ p1 ])

	def ReturnNumberQC()
		return This._NNLImmutable("returnnumber", [])

	def ReverseQC()
		return This._NNLImmutable("reverse", [])

	def ReversedCopyQC()
		return This._NNLImmutable("reversedcopy", [])

	def ReversedDigitsQC()
		return This._NNLImmutable("reverseddigits", [])

	def ReverseDigitsQC()
		return This._NNLImmutable("reversedigits", [])

	def ReverseWordsQC()
		return This._NNLImmutable("reversewords", [])

	def rndRemoveItemsQC()
		return This._NNLImmutable("rndremoveitems", [])

	def RotatedLeftQC(p1)
		return This._NNLImmutable("rotatedleft", [ p1 ])

	def RotatedRightQC(p1)
		return This._NNLImmutable("rotatedright", [ p1 ])

	def RotateLeftQC(p1)
		return This._NNLImmutable("rotateleft", [ p1 ])

	def RotateRightQC(p1)
		return This._NNLImmutable("rotateright", [ p1 ])

	def RoundDownQC()
		return This._NNLImmutable("rounddown", [])

	def RoundedToQC(p1)
		return This._NNLImmutable("roundedto", [ p1 ])

	def RoundToQC(p1)
		return This._NNLImmutable("roundto", [ p1 ])

	def RoundToMaxQC()
		return This._NNLImmutable("roundtomax", [])

	def RoundToSameRoundAsQC(p1)
		return This._NNLImmutable("roundtosameroundas", [ p1 ])

	def RoundUpQC()
		return This._NNLImmutable("roundup", [])

	def RPartitionQC(p1)
		return This._NNLImmutable("rpartition", [ p1 ])

	def SameContentAsQC(p1)
		return This._NNLImmutable("samecontentas", [ p1 ])

	def ScriptIsQC(p1)
		return This._NNLImmutable("scriptis", [ p1 ])

	def SearchTokensQC()
		return This._NNLImmutable("searchtokens", [])

	def SectionsQC(p1)
		return This._NNLImmutable("sections", [ p1 ])

	def SectionsZQC(p1)
		return This._NNLImmutable("sectionsz", [ p1 ])

	def SectionsZZQC(p1)
		return This._NNLImmutable("sectionszz", [ p1 ])

	def SentencesThatAreQC(p1)
		return This._NNLImmutable("sentencesthatare", [ p1 ])

	def SetDefaultFormatQC()
		return This._NNLImmutable("setdefaultformat", [])

	def SetReturnTypeQC(p1)
		return This._NNLImmutable("setreturntype", [ p1 ])

	def SetReturnTypeAsQC(p1)
		return This._NNLImmutable("setreturntypeas", [ p1 ])

	def SetReturnTypeToQC(p1)
		return This._NNLImmutable("setreturntypeto", [ p1 ])

	def SetRoundQC(p1)
		return This._NNLImmutable("setround", [ p1 ])

	def ShortenQC()
		return This._NNLImmutable("shorten", [])

	def ShortenedUsingQC(p1)
		return This._NNLImmutable("shortenedusing", [ p1 ])

	def ShowQC()
		return This._NNLImmutable("show", [])

	def ShowEntitiesQC()
		return This._NNLImmutable("showentities", [])

	def ShowSentimentQC()
		return This._NNLImmutable("showsentiment", [])

	def ShowShortQC()
		return This._NNLImmutable("showshort", [])

	def ShrinkQC(p1)
		return This._NNLImmutable("shrink", [ p1 ])

	def ShrinkToQC(p1)
		return This._NNLImmutable("shrinkto", [ p1 ])

	def ShuffleQC()
		return This._NNLImmutable("shuffle", [])

	def ShuffleNumbersQC()
		return This._NNLImmutable("shufflenumbers", [])

	def ShuffleStringsQC()
		return This._NNLImmutable("shufflestrings", [])

	def SignQC()
		return This._NNLImmutable("sign", [])

	def SimilarityWithQC(p1)
		return This._NNLImmutable("similaritywith", [ p1 ])

	def SimplifyQC()
		return This._NNLImmutable("simplify", [])

	def SimplifyExceptQC(p1)
		return This._NNLImmutable("simplifyexcept", [ p1 ])

	def SinglesQC()
		return This._NNLImmutable("singles", [])

	def SinglesUQC()
		return This._NNLImmutable("singlesu", [])

	def SinglesZQC()
		return This._NNLImmutable("singlesz", [])

	def SlidingWindowQC(p1)
		return This._NNLImmutable("slidingwindow", [ p1 ])

	def SortQC()
		return This._NNLImmutable("sort", [])

	def SortAscendingQC()
		return This._NNLImmutable("sortascending", [])

	def SortByQC(p1)
		return This._NNLImmutable("sortby", [ p1 ])

	def SortByDescendingQC(p1)
		return This._NNLImmutable("sortbydescending", [ p1 ])

	def SortCSQC(p1)
		return This._NNLImmutable("sortcs", [ p1 ])

	def SortDownQC()
		return This._NNLImmutable("sortdown", [])

	def SortedByQC(p1)
		return This._NNLImmutable("sortedby", [ p1 ])

	def SortedCSQC(p1)
		return This._NNLImmutable("sortedcs", [ p1 ])

	def SortedOnDownQC(p1)
		return This._NNLImmutable("sortedondown", [ p1 ])

	def SortingOrderQC()
		return This._NNLImmutable("sortingorder", [])

	def SortLinesQC()
		return This._NNLImmutable("sortlines", [])

	def SortLinesCSQC(p1)
		return This._NNLImmutable("sortlinescs", [ p1 ])

	def SortOnDownQC(p1)
		return This._NNLImmutable("sortondown", [ p1 ])

	def SortUpQC()
		return This._NNLImmutable("sortup", [])

	def SortWordsQC()
		return This._NNLImmutable("sortwords", [])

	def SortWordsCSQC(p1)
		return This._NNLImmutable("sortwordscs", [ p1 ])

	def SpacifiedUsingQC(p1)
		return This._NNLImmutable("spacifiedusing", [ p1 ])

	def SpacifyQC()
		return This._NNLImmutable("spacify", [])

	def SpacifyCharsQC()
		return This._NNLImmutable("spacifychars", [])

	def SpacifyCharsUsingQC(p1)
		return This._NNLImmutable("spacifycharsusing", [ p1 ])

	def SpacifyItRQC()
		return This._NNLImmutable("spacifyitr", [])

	def SpacifySectionsQC(p1)
		return This._NNLImmutable("spacifysections", [ p1 ])

	def SpacifySubStringsQC(p1)
		return This._NNLImmutable("spacifysubstrings", [ p1 ])

	def SpacifyTheseSubStringsQC(p1)
		return This._NNLImmutable("spacifythesesubstrings", [ p1 ])

	def SpacifyUsingQC(p1)
		return This._NNLImmutable("spacifyusing", [ p1 ])

	def SplitQC(p1)
		return This._NNLImmutable("split", [ p1 ])

	def SplitAfterQC(p1)
		return This._NNLImmutable("splitafter", [ p1 ])

	def SplitAfterPositionQC(p1)
		return This._NNLImmutable("splitafterposition", [ p1 ])

	def SplitAfterPositionsQC(p1)
		return This._NNLImmutable("splitafterpositions", [ p1 ])

	def SplitAroundQC(p1)
		return This._NNLImmutable("splitaround", [ p1 ])

	def SplitAroundPositionQC(p1)
		return This._NNLImmutable("splitaroundposition", [ p1 ])

	def SplitAroundPositionsQC(p1)
		return This._NNLImmutable("splitaroundpositions", [ p1 ])

	def SplitAroundSectionsQC(p1)
		return This._NNLImmutable("splitaroundsections", [ p1 ])

	def SplitAroundSubStringQC(p1)
		return This._NNLImmutable("splitaroundsubstring", [ p1 ])

	def SplitAroundSubStringsQC(p1)
		return This._NNLImmutable("splitaroundsubstrings", [ p1 ])

	def SplitAtQC(p1)
		return This._NNLImmutable("splitat", [ p1 ])

	def SplitAtPositionQC(p1)
		return This._NNLImmutable("splitatposition", [ p1 ])

	def SplitAtPositionsQC(p1)
		return This._NNLImmutable("splitatpositions", [ p1 ])

	def SplitAtPositionsZZQC(p1)
		return This._NNLImmutable("splitatpositionszz", [ p1 ])

	def SplitAtPositionZZQC(p1)
		return This._NNLImmutable("splitatpositionzz", [ p1 ])

	def SplitAtSectionsQC(p1)
		return This._NNLImmutable("splitatsections", [ p1 ])

	def SplitAtZZQC(p1)
		return This._NNLImmutable("splitatzz", [ p1 ])

	def SplitBeforeQC(p1)
		return This._NNLImmutable("splitbefore", [ p1 ])

	def SplitBeforePositionQC(p1)
		return This._NNLImmutable("splitbeforeposition", [ p1 ])

	def SplitBeforePositionsQC(p1)
		return This._NNLImmutable("splitbeforepositions", [ p1 ])

	def SplitByRegexQC(p1)
		return This._NNLImmutable("splitbyregex", [ p1 ])

	def SplitsQC(p1)
		return This._NNLImmutable("splits", [ p1 ])

	def SplitsZQC(p1)
		return This._NNLImmutable("splitsz", [ p1 ])

	def SplitsZZQC(p1)
		return This._NNLImmutable("splitszz", [ p1 ])

	def SplittedAfterPositionQC(p1)
		return This._NNLImmutable("splittedafterposition", [ p1 ])

	def SplittedAfterPositionsQC(p1)
		return This._NNLImmutable("splittedafterpositions", [ p1 ])

	def SplittedAtQC(p1)
		return This._NNLImmutable("splittedat", [ p1 ])

	def SplittedAtPositionQC(p1)
		return This._NNLImmutable("splittedatposition", [ p1 ])

	def SplittedAtPositionsQC(p1)
		return This._NNLImmutable("splittedatpositions", [ p1 ])

	def SplittedAtPositionsZZQC(p1)
		return This._NNLImmutable("splittedatpositionszz", [ p1 ])

	def SplittedAtPositionZZQC(p1)
		return This._NNLImmutable("splittedatpositionzz", [ p1 ])

	def SplittedAtZZQC(p1)
		return This._NNLImmutable("splittedatzz", [ p1 ])

	def SplittedBeforePositionQC(p1)
		return This._NNLImmutable("splittedbeforeposition", [ p1 ])

	def SqueezeQC()
		return This._NNLImmutable("squeeze", [])

	def StartingNumberQC()
		return This._NNLImmutable("startingnumber", [])

	def StringifyQC()
		return This._NNLImmutable("stringify", [])

	def StringifyAndLowerQC()
		return This._NNLImmutable("stringifyandlower", [])

	def StringifyAndUpperQC()
		return This._NNLImmutable("stringifyandupper", [])

	def StringifyLowercaseQC()
		return This._NNLImmutable("stringifylowercase", [])

	def StringifyUppercaseQC()
		return This._NNLImmutable("stringifyuppercase", [])

	def StringsQC()
		return This._NNLImmutable("strings", [])

	def StringsZQC()
		return This._NNLImmutable("stringsz", [])

	def StripNullsQC()
		return This._NNLImmutable("stripnulls", [])

	def StructureQC()
		return This._NNLImmutable("structure", [])

	def SubstractQC(p1)
		return This._NNLImmutable("substract", [ p1 ])

	def SubstractedManyQC(p1)
		return This._NNLImmutable("substractedmany", [ p1 ])

	def SubstractManyQC(p1)
		return This._NNLImmutable("substractmany", [ p1 ])

	def SubStringBoundsQC(p1)
		return This._NNLImmutable("substringbounds", [ p1 ])

	def SubStringsBoundedByQC(p1)
		return This._NNLImmutable("substringsboundedby", [ p1 ])

	def SubStringsBoundedByUQC(p1)
		return This._NNLImmutable("substringsboundedbyu", [ p1 ])

	def SubStringsBoundedByZZQC(p1)
		return This._NNLImmutable("substringsboundedbyzz", [ p1 ])

	def SubStringsCSQC(p1)
		return This._NNLImmutable("substringscs", [ p1 ])

	def SubStructQC(p1)
		return This._NNLImmutable("substruct", [ p1 ])

	def SubstructedManyQC(p1)
		return This._NNLImmutable("substructedmany", [ p1 ])

	def SubStructManyQC(p1)
		return This._NNLImmutable("substructmany", [ p1 ])

	def SubtractQC(p1)
		return This._NNLImmutable("subtract", [ p1 ])

	def SubtractedManyQC(p1)
		return This._NNLImmutable("subtractedmany", [ p1 ])

	def SubtractManyQC(p1)
		return This._NNLImmutable("subtractmany", [ p1 ])

	def SubtructQC(p1)
		return This._NNLImmutable("subtruct", [ p1 ])

	def SubtructedManyQC(p1)
		return This._NNLImmutable("subtructedmany", [ p1 ])

	def SubtructManyQC(p1)
		return This._NNLImmutable("subtructmany", [ p1 ])

	def SummaryQC(p1)
		return This._NNLImmutable("summary", [ p1 ])

	def SummarySentencesQC(p1)
		return This._NNLImmutable("summarysentences", [ p1 ])

	def SwapContentWithQC(p1)
		return This._NNLImmutable("swapcontentwith", [ p1 ])

	def SwapFirstAndLastQC()
		return This._NNLImmutable("swapfirstandlast", [])

	def SwapWithQC(p1)
		return This._NNLImmutable("swapwith", [ p1 ])

	def SynonymsQC()
		return This._NNLImmutable("synonyms", [])

	def TailQC(p1)
		return This._NNLImmutable("tail", [ p1 ])

	def TakeQC(p1)
		return This._NNLImmutable("take", [ p1 ])

	def TakeLastQC(p1)
		return This._NNLImmutable("takelast", [ p1 ])

	def TheseCharsZQC(p1)
		return This._NNLImmutable("thesecharsz", [ p1 ])

	def TheseItemsZQC(p1)
		return This._NNLImmutable("theseitemsz", [ p1 ])

	def TheseObjectsZQC(p1)
		return This._NNLImmutable("theseobjectsz", [ p1 ])

	def TheseSubstringsZQC(p1)
		return This._NNLImmutable("thesesubstringsz", [ p1 ])

	def TheseSubstringsZZQC(p1)
		return This._NNLImmutable("thesesubstringszz", [ p1 ])

	def ThousandsQC()
		return This._NNLImmutable("thousands", [])

	def TimesQC(p1)
		return This._NNLImmutable("times", [ p1 ])

	def ToBinaryNumberQC()
		return This._NNLImmutable("tobinarynumber", [])

	def ToBytesQC()
		return This._NNLImmutable("tobytes", [])

	def ToCompactFormQC()
		return This._NNLImmutable("tocompactform", [])

	def ToHashListQC()
		return This._NNLImmutable("tohashlist", [])

	def ToHexNumberQC()
		return This._NNLImmutable("tohexnumber", [])

	def ToOctalNumberQC()
		return This._NNLImmutable("tooctalnumber", [])

	def ToStzHashListQC()
		return This._NNLImmutable("tostzhashlist", [])

	def ToStzStringQC()
		return This._NNLImmutable("tostzstring", [])

	def ToStzTableQC()
		return This._NNLImmutable("tostztable", [])

	def ToStzTextQC()
		return This._NNLImmutable("tostztext", [])

	def TrailingCharQC()
		return This._NNLImmutable("trailingchar", [])

	def TrailingCharCSQC(p1)
		return This._NNLImmutable("trailingcharcs", [ p1 ])

	def TrailingCharIsQC(p1)
		return This._NNLImmutable("trailingcharis", [ p1 ])

	def TrailingCharsQC()
		return This._NNLImmutable("trailingchars", [])

	def TrailingCharsAsStringQC()
		return This._NNLImmutable("trailingcharsasstring", [])

	def TrailingCharsCSQC(p1)
		return This._NNLImmutable("trailingcharscs", [ p1 ])

	def TrailingNumberQC()
		return This._NNLImmutable("trailingnumber", [])

	def TrailingSubStringQC()
		return This._NNLImmutable("trailingsubstring", [])

	def TrailingSubStringCSQC(p1)
		return This._NNLImmutable("trailingsubstringcs", [ p1 ])

	def TrailingSubStringZZQC()
		return This._NNLImmutable("trailingsubstringzz", [])

	def TrillionsQC()
		return This._NNLImmutable("trillions", [])

	def TrimQC()
		return This._NNLImmutable("trim", [])

	def TrimCharQC(p1)
		return This._NNLImmutable("trimchar", [ p1 ])

	def TrimCSQC(p1)
		return This._NNLImmutable("trimcs", [ p1 ])

	def TrimEndQC()
		return This._NNLImmutable("trimend", [])

	def TrimItemQC(p1)
		return This._NNLImmutable("trimitem", [ p1 ])

	def TrimItemFromLeftQC(p1)
		return This._NNLImmutable("trimitemfromleft", [ p1 ])

	def TrimItemFromRightQC(p1)
		return This._NNLImmutable("trimitemfromright", [ p1 ])

	def TrimLeftQC()
		return This._NNLImmutable("trimleft", [])

	def TrimLeftCharQC(p1)
		return This._NNLImmutable("trimleftchar", [ p1 ])

	def TrimLeftCSQC(p1)
		return This._NNLImmutable("trimleftcs", [ p1 ])

	def TrimmedCSQC(p1)
		return This._NNLImmutable("trimmedcs", [ p1 ])

	def TrimmedToSizeQC(p1)
		return This._NNLImmutable("trimmedtosize", [ p1 ])

	def TrimRightQC()
		return This._NNLImmutable("trimright", [])

	def TrimRightCharQC(p1)
		return This._NNLImmutable("trimrightchar", [ p1 ])

	def TrimRightCSQC(p1)
		return This._NNLImmutable("trimrightcs", [ p1 ])

	def TrimStartQC()
		return This._NNLImmutable("trimstart", [])

	def TrimToSizeQC(p1)
		return This._NNLImmutable("trimtosize", [ p1 ])

	def TruncateToQC(p1)
		return This._NNLImmutable("truncateto", [ p1 ])

	def UnamedObjectsQC()
		return This._NNLImmutable("unamedobjects", [])

	def UndoQC()
		return This._NNLImmutable("undo", [])

	def UndoStackQC()
		return This._NNLImmutable("undostack", [])

	def UnicodeCompareWithQC(p1)
		return This._NNLImmutable("unicodecomparewith", [ p1 ])

	def UnicodeNameQC()
		return This._NNLImmutable("unicodename", [])

	def UnionWithQC(p1)
		return This._NNLImmutable("unionwith", [ p1 ])

	def UniqueCSQC(p1)
		return This._NNLImmutable("uniquecs", [ p1 ])

	def UniqueItemsCSQC(p1)
		return This._NNLImmutable("uniqueitemscs", [ p1 ])

	def UniqueLinesQC()
		return This._NNLImmutable("uniquelines", [])

	def UniqueLinesCSQC(p1)
		return This._NNLImmutable("uniquelinescs", [ p1 ])

	def UniqueNumbersQC()
		return This._NNLImmutable("uniquenumbers", [])

	def UniqueWordsCSQC(p1)
		return This._NNLImmutable("uniquewordscs", [ p1 ])

	def UnnamedObjectsQC()
		return This._NNLImmutable("unnamedobjects", [])

	def UnspacifyQC()
		return This._NNLImmutable("unspacify", [])

	def UpdateQC(p1)
		return This._NNLImmutable("update", [ p1 ])

	def UpdateByQC(p1)
		return This._NNLImmutable("updateby", [ p1 ])

	def UpdatedByQC(p1)
		return This._NNLImmutable("updatedby", [ p1 ])

	def UpdatedUsingQC(p1)
		return This._NNLImmutable("updatedusing", [ p1 ])

	def UpdatedWithQC(p1)
		return This._NNLImmutable("updatedwith", [ p1 ])

	def UpdateUsingQC(p1)
		return This._NNLImmutable("updateusing", [ p1 ])

	def UpdateWithQC(p1)
		return This._NNLImmutable("updatewith", [ p1 ])

	def UppercaseQC()
		return This._NNLImmutable("uppercase", [])

	def UppercaseSubStringQC(p1)
		return This._NNLImmutable("uppercasesubstring", [ p1 ])

	def UpToQC(p1)
		return This._NNLImmutable("upto", [ p1 ])

	def UrlDecodeQC()
		return This._NNLImmutable("urldecode", [])

	def UrlEncodeQC()
		return This._NNLImmutable("urlencode", [])

	def VerbsQC()
		return This._NNLImmutable("verbs", [])

	def VizDeepFindQC(p1)
		return This._NNLImmutable("vizdeepfind", [ p1 ])

	def VizDeepFindAllQC(p1)
		return This._NNLImmutable("vizdeepfindall", [ p1 ])

	def VizFindQC(p1)
		return This._NNLImmutable("vizfind", [ p1 ])

	def VizFindAllQC(p1)
		return This._NNLImmutable("vizfindall", [ p1 ])

	def VizFindAllOccurrencesQC(p1)
		return This._NNLImmutable("vizfindalloccurrences", [ p1 ])

	def VizFindManyQC(p1)
		return This._NNLImmutable("vizfindmany", [ p1 ])

	def VizFindZZQC(p1)
		return This._NNLImmutable("vizfindzz", [ p1 ])

	def WalkAccumulatingQC(p1)
		return This._NNLImmutable("walkaccumulating", [ p1 ])

	def WalkedItemsQC(p1)
		return This._NNLImmutable("walkeditems", [ p1 ])

	def WalkedLastItemQC(p1)
		return This._NNLImmutable("walkedlastitem", [ p1 ])

	def WalkedLastPositionQC(p1)
		return This._NNLImmutable("walkedlastposition", [ p1 ])

	def WalkedPositionsQC(p1)
		return This._NNLImmutable("walkedpositions", [ p1 ])

	def WalkersQC()
		return This._NNLImmutable("walkers", [])

	def WalkEveryNthQC(p1)
		return This._NNLImmutable("walkeverynth", [ p1 ])

	def WalkSkippingQC(p1)
		return This._NNLImmutable("walkskipping", [ p1 ])

	def WalkWhileQC(p1)
		return This._NNLImmutable("walkwhile", [ p1 ])

	def WalkZigZagQC(p1)
		return This._NNLImmutable("walkzigzag", [ p1 ])

	def WithoutDuplicationCSQC(p1)
		return This._NNLImmutable("withoutduplicationcs", [ p1 ])

	def WordFrequencyQC(p1)
		return This._NNLImmutable("wordfrequency", [ p1 ])

	def WordsThatAreQC(p1)
		return This._NNLImmutable("wordsthatare", [ p1 ])

	def YieldQC(p1)
		return This._NNLImmutable("yield", [ p1 ])

	def YieldPairsQC(p1)
		return This._NNLImmutable("yieldpairs", [ p1 ])

	def ZippedWithQC(p1)
		return This._NNLImmutable("zippedwith", [ p1 ])

	def ZipWithQC(p1)
		return This._NNLImmutable("zipwith", [ p1 ])
	# </nnl-generated-surface>
