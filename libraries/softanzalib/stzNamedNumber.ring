
func StzNamedNumberQ(paNameAndNumber)
	return new stzNamedNumber(paNameAndNumber)

class stzNamedNumber from stzNumber
	@cName
	@cContent

	def init(paNameAndNumber)
		if NOT 	( isList(paNameAndNumber) and
			  ( Q(paNameAndNumber).IsPairOfStringAndNumber() or
			    Q(paNameAndNumber).IsPairOfStrings() )
			)

			StzRaise("Can't create the stzNamedNumber object!" + NL +
				  "You must provide a pair of a string and number, or a pair of strings, specifying the name along with the number value.")

		ok

		@cName = paNameAndNumber[1]
		if StzHashListQ(@).ContainsKey(@cName)
			StzRaise("The name you provided (:" + @cName + ") is already used by an other object!")
		ok

		@cContent = paNameAndNumber[2]
		if isString(@cContent)
			@cContent = '"' + @cContent + '"'
		ok

		cCode = 'obj = new stzNumber(' + @cContent + ')'

		eval(cCode)
		@ + [ @cName, obj ]
		@C + [ @cName, obj.Content() ]

	def ObjectName()
		return @cName
