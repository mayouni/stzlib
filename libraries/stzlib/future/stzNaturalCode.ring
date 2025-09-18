#TODO

func StzNaturalCodeQ()
	return new stzNaturalCode

class stzNaturalCode from stzString
	@cCode
	@EndPoint

	def Say(pcCode)
		@cCode = StzStringQ(cCode).RemoveTheseBoundsQ("{","}").Simplified()

	def Code()
		return @cCode

	def IsWellFormed()
		bResult = 1

		# Check for mistakes

		return bResult

	def CodeExecute()
		if NOT This.IsWellFormed()
			StzRaise("Can't parse it! Check for mistakes.")
		ok

		eval( This.Code() )

	def ContainsEndPoint()
		if NOT This.IsWellFormed()
			StzRaise("Can't parse it! Check for mistakes.")
		ok



		//if StzStringQ( This.Code() ).ContainsCS("until(", 0) OR
		   

	def EndPoint()
		// TODO
