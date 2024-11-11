

func StzNaturalQ()
	return new stzNatural

	func Naturally()
		return new stzNatural

class stzNatural
	
	nothing 	= "NULL"

	stzString 	= "StzStringQ(@)"
	append 		= "Append(@)"
	show 		= "Print()"

	#--

	uppercase 	= "Uppercase()"
	spacify 	= "Spacify()"s
	box 		= "Box()"
	box@ 		= "BoxXT(@)"
	rounded 	= [ "rounded", true ]

	#--

	replace		= "Replace()"
	first		= "1"
	second		= "2"
	third		= "3"
	fourth		= "4"
	fifth		= "5"
	sixth		= "6"
	seventh		= "7"
	eighth		= "8"
	nineth		= "9"
	tenth		= "10"

	the = "↑" this_ = "↑" that = "↑" these = "↑" those = "↑"

	@aValues = []
	@aUndefined = []

	def braceExprEval value
		if NOT( isString(value) and (value = NULL or value = "__@Ignore__") )
			@aValues + value
		ok

	def braceError

		# RING ERROR MESSAGE:
		# Error (R24) : Using uninitialized variable: home

		if left(cCatchError,11) = "Error (R24)"
			cUndefinded = trim(split(cCatchError, ":")[3])
			@aUndefined + cUndefinded
		ok

	def Values()
		aResult = []
		nLen = len(@aValues)
		for i = 1 to nLen

			if i > 3
				if @aValues[i-1] = "↑" and
				   @aValues[i] = @aValues[i-2]
					loop
				ok
			ok

			if @aValues[i] != "↑"
				aResult + @aValues[i]
			ok
		next

		return aResult

	def Undefined()
		return @aUndefined

	def braceEnd
		Run()

	def Code()
		aValues = This.Values()
		aValues[1] += "{"
		cCode = ""
		nLenValues = len(aValues)

		for i = 1 to nLenValues
			
			oValue = new stzString(aValues[i])

			if NOT oValue.Contains("@")
				# Adding the line to the code

				cCode += oValue.Content()
			else
				# Composingng the params

				nLen@ = oValue.NumberOfOccurrence("@")
				c@ = ""

				cParams = ""
				for j = 1 to nLen@

					if aValues[i+j] = "NULL"
						cParam = "NULL"
					else
						cParam = @@(aValues[i+j])
					ok

					cParams += cParam + ","
					c@ += "@"
				next
				cParams = StzStringQ(cParams).LastCharRemoved()
			
				# Replacing the params inside the line
			
				oValue.Replace(c@, cParams)

				# Adding the line to the code

				cCode += oValue.Content()
				i += j-1

			ok
		next

		cCode += "}"
? ccode
		return cCode

	def Run()
		eval(This.Code())
