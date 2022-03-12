
func IsListOfValues(paValues)
	oStzList = new stzList(paLvalues)
	return ostzList.IsListOfValues()

class stzListOfValues from stzObject
	aListOfValues

	def init(paList)
		if IsListOfValues(paList)
			aListOfValues = paList
		ok

	def Content()
		return aListOfValues
