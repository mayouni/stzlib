

func StzNamedStringQ(paNameAndString)
	return new stzNamedString(paNameAndString)

class stzNamedString from stzString
	@cName
	@cContent

	def init(paNameAndString)
		if NOT ( isList(paNameAndString) and Q(paNameAndString).IsPairOfStrings() )

			StzRaise("Can't create the stzNamedString object!" + NL +
				  "You must provide a pair of strings specifying the name along with the string value.")

		ok

		@cName = paNameAndString[1]
		if StzHashListQ(@).ContainsKey(@cName)
			StzRaise("The name you provided (:" + @cName + ") is already used by an other object!")
		ok

		@cContent = paNameAndString[2]
		
		cBound = '"'
		if Q(@cContent).IsBoundedBy('"')
			cBound = "'"
		ok

		cCode = 'obj = new stzString(' + cBound + @cContent + cBound + ')'

		eval(cCode)
		@ + [ @cName, obj ]
