
func StzNamedStringQ(paPair)
	return new stzNamedString(paPair)

class stzNamedString
	@ObjectName
	@oStzObject

	def init(paPair)
		
		if NOT isList(paPair) and Q(paPair).IsPair() and isString(paPair[1])
			StzRaise("Can't create the named object! You must provide a pair, " +
			         "containing the name of the object and its content." + NL +
				 "Content can be a string, a stzString object or QString object.")
		ok

		@ObjectName = paPair[1]

		if isString(paPair[2])
			@oStzObject = new stzString(paPair[2])

		but IsStzString(paPair[2])
			@oStzObject = paPair[2]

		but IsQString(paPair[2])
			@oStzObject  = QStringToStzStringObject(paPair[2])
		ok

	def ObjectName()
		return @ObjectName

		def StzStringName()
			return This.ObjectName()

	def StzObject()
		return @oStzObject

		def StzStringObjectName()
			return StzObject()
