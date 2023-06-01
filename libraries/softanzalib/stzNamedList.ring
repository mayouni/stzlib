
func StzNamedListQ(paNameAndList)
	return new stzNamedList(paNameAndList)

class stzNamedList from stzList
	@cName
	@aContent

	def init(paNameAndList)
		if NOT 	( isList(paNameAndList) and
			  Q(paNameAndList).IsPairOfStringAndList()
			)

			StzRaise("Can't create the stzNamedList object!" + NL +
				  "You must provide a pair of a string and list, specifying the name along with the list value.")

		ok

		@cName = paNameAndList[1]
		if StzHashListQ(@).ContainsKey(@cName)
			StzRaise("The name you provided (:" + @cName + ") is already used by an other object!")
		ok

		@aContent = paNameAndList[2]

		cCode = 'obj = new stzList(' + Q(paNameAndList[2]).ToCode() + ')'
		eval(cCode)

		@ + [ @cName, obj ]
		@C + [ @cName, obj.Content() ]

	def ObjectName()
		return @cName