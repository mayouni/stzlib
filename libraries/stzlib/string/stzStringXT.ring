
func StzStringXTQ(paNameAndString)
	return new stzStringXT(paNameAndString)

class stzStringXT from stzString
	@cName


	def init(paNameAndString)
		if isList(paNameAndString) and Q(paNameAndString).IsPairOfStrings()
			@cName = paNameAndString[1]

		else
			StzRaise("Can't create the stzStringXT object. paNameAndString must be a pair of strings.")
		ok


