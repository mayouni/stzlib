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
		bResult = _TRUE_

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



		//if StzStringQ( This.Code() ).ContainsCS("until(", _FALSE_) OR
		   

	def EndPoint()
		// TODO
