
func Objekt(cObjectName)
	return "@[:" + cObjectName + "]"

	func Obj(cObjectName)
		return Objekt(cObjectName)

func StzNamedObjectQ(paNameAndObject)
	return new stzNamedObject(paNameAndObject)

class stzNamedObject from stzObject
	@cName
	@oContent

	def init(paNameAndObject)
		if NOT 	( isList(paNameAndObject) and
			  ( Q(paNameAndObject).IsPairOfStringAndObject() or
			    Q(paNameAndObject).IsPairOfStrings()
			  )
			)

			StzRaise("Can't create the stzNamedObject object!" +
				  "You must provide:" + NL + NL +

				  "- a pair of a string and object, " +
				  "specifying the name along with the list value, or," + NL + NL +

				  "- a pair of strings specifying the name along with the code" +
				  "of creation of a new object hosted inside a string."
			)

		ok

		@cName = paNameAndObject[1]
		if StzHashListQ(@).ContainsKey(@cName)
			StzRaise("The name you provided (:" + @cName + ") is already used by an other object!")
		ok

		if isString(paNameAndObject[2])

			# Case where the code of creation of object is hosted in the string
			cCode = 'obj = ' + paNameAndObject[2]

			eval(cCode)
			if isObject(obj)
				@oContent = new stzObject(obj)
			else
				StzRaise("Type error! The code you provided must return an object.") 
			ok

		else # It's an object

			@oContent = new stzObject(paNameAndObject[2])
		ok

		@ + [ @cName, @oContent ]
		@C + [ @cName, @oContent.Content() ]

	def ObjectName()
		return @cName
