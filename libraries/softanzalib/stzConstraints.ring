func Constraints()
	return _aConstraints

func ConstraintsOn(pcType)
	if NOT isString(pcType)
		StzRaise("Invalid param type! pcType should be a string containing the name of a softanza class.")
	ok

	if StringIsStzClassName(pcType)
		return Constraints()[ pcType ]
	else
		StzRaise([
			:Where 	= "stzGeneralFunctions > ConstraintsOn()",
			:What	= "Can't return the list of constraints!",
			:Why	= "Type of the param you provided is not valid?",
			:Todo	= "Provide a name of a softanza object (like :stzString)."
		])
	ok

func ConstraintsOnStzString()
	return Constraints([ :OnStzString ])

	func ConstraintsOnStrings()
		return ConstraintsOnStzString()

func ConstraintsOnStzNumbers()
	return Constraints([ :OnStzNumber ])

	func ConstraintsOnNumbers()
		return ConstraintsOnStzNumber()

func ConstraintsOnStzLists()
	return Constraints([ :OnStzList ])

	func ConstraintsOnLists()
		return ConstraintsOnStzList()

func ConstraintsOnStzObjects()
	return Constraints([ :OnStzObject ])

	func ConstraintsOnObjects()
		return ConstraintsOnStzObject()

