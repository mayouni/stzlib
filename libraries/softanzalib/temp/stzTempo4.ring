load "guilib.ring"

o1 = new stzString(["1250"])
? o1.LeftNChars(5)

class stzString
	
	// The public region of the class contains nothing else than
	// a QString object relative to the main string provided
	oMainQString = new QString()

	func init(paStr)
		if len(paStr) = 0
			// Do nothing
		else
			@cContent = ""+ paStr[1]
			oMainQString.Append(paStr[1])
		
		ok

	func NLeftChars(paStr,n)
		oTempQString = pvtQSTringToWorkOn(paStr)
		return oTempQString.left(n)

	PRIVATE

	@cContent

	func pvtQStringToWorkOn(paStr)
		if len(paStr) = 0
			oQStringToWorkOn = oMainQString
		else
			oQStringToWorkOn = pvtOtherQString(paStr[1])
		ok
		return oQStringToWorkOn

	 func pvtOtherQString(pcStr)
		oQString = new QString()
		oQString.Append(""+ pcStr)
		return oQString

	func pvtIsUnaryList(paList)	// --> should be implemented in stzList
		if len(paList) = 1
			return TRUE
		else
			return FALSE
		ok

	func pvtIsEmptyList(paList)	// --> should be implemented in stzList
		if len(paList) = 0
			return TRUE
		else
			return FALSE
		ok

/*
stzList --> creating a list wit ha defined number of items
