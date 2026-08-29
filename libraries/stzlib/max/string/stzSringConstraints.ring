

class stzStringConstraints

	@aConstraints

	def EnforcedConstraints()
		return @aConstraints

		def Constraints()
			return This.EnforcedConstraints()

	def VerifyConstraint(pcConstraintName)

		@str = This.Content()

		cCondition = Constraints()[ :OnStzString ][ pcConstraintName ]

		if cCondition = ""
			stzRaise("Inexsitant contraint!")
		ok

		CompileConstraint(cCondition)

		StzStringQ(cCondition) {

			ReplaceCS("@string", @str,  0)
			Simplify()
			RemoveTheseBounds("{", "}")

			cCondition = Content()
		}

		cCode  = 'bResult = ""+ (' + cCondition + ')'
		eval(cCode)

		if bResult = 0
			stzRaise([
				:Where = "stzString.ring > VerifyCondition()",
				:What  = "Execution is cancelled by Softanza",
				:Why   = "A constraint on the string object is not verified!",
				:Todo  = "Check that constraint (" + pcName + ") and adjust your logic accordingly ;)"

			])
		ok

	def VerifyConstraints()
		bResult = 1

		_aAPair194_ = This.Constraints()
		_nAPair194_ = len(_aAPair194_)
		for _iAPair194_ = 1 to _nAPair194_
			aPair = _aAPair194_[_iAPair194_]
			cConstraintName = aPair[1]
			This.VerifyConstraint(cConstraintName) = 0
			
		next
