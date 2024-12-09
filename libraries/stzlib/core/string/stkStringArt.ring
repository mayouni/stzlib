load "qtcore.ring"

#NOTE This class is dedicatd to Mahmoud for the effors he deployed
# in delivering the 1.21 version of Ring

# It provides several string art font styles (3 for the mean time).
# These styles can be rounded and background-shaded.



$DEFAULT_STR_ART_STYLE = :retro

#-------------------------------#
#  STRING ART STYLES FUNCTIONS  #
#-------------------------------#

func StringArtStylesXT()
	return $STZ_STR_ART_STYLES_XT

func StringArtStyles()
	aStylesXT = StringArtStylesXT()
	nLen = len(aStylesXT)

	acResult = []

	for i = 1 to nLen
		acResult + aStylesXT[i][1]
	next

	return acResult

func IsStringArtStyle(str)
	if find(StringArtStyles(), str) > 0
		return TRUE
	else
		return FALSE
	ok

func DefaultStringArtStyle()
	return $DEFAULT_STR_ART_STYLE

	func StringArtStyle()
		return return $DEFAULT_STR_ART_STYLE

func SetDefaultStringArtStyle(cStyle)
	bFound = find(StringArtStyles(), lower(cStyle))
	if bFound = 0
		raise("ERR-" + StkError(:IncorrectParamValue))
	ok

	$DEFAULT_STR_ART_STYLE = cStyle

	def SetStringArtStyle(cStyle)
		SetDefaultStringArtStyle(cStyle)

func StringArtXT(str, pcStyle)
	oArt = new stkStringArt(str)
	oArt.SetStyle(pcStyle)
	return oArt.Artify()

func StringArt(str)

	# Checking if the art painting syntax is used
	# Example: StringArt("#{Tree}")

	oQStr = new QString2()
	oQStr.append(str)

	bOk = FALSE

	if oQStr.mid(0, 2) = "#{"
		nLen = oQStr.size()
		if oQStr.mid(nLen-1, 1) = "}"
			bOk = TRUE
		ok
	ok

	if bOk
		return StringArtPainting(str)
	ok

	# Artifying the text provided

	oStrArt = new stkStringArt(str)
	oStrArt.SetStyle(DefaultStringArtStyle())
	return oStrArt.Artify()

func StringArtBoxified(str)

	# Checking if the art painting syntax is used
	# Example: StringArt("#{Tree}")

	oQStrArt = new QString2()
	oQStrArt.append(str)

	bOk = FALSE

	if oQStrArt.mid(0, 2) = "#{"
		nLen = oQStrArt.size()
		if oQStrArt.mid(nLen-1, 1) = "}"
			bOk = TRUE
		ok
	ok

	if bOk
		raise("Painting Arts can't be boxified!")
	ok

	oStrArt = new stkStringArt(str)
	oStrArt.SetStyle(DefaultStringArtStyle())
	return oStrArt.Boxify()

	func StringArtBoxed(str)
		return StringArtBoxified(str)

func DefaultCharArt()
	return @cDefaultCharArt = ""

func CharArtLayers(c)
	if NOT (isString(c) and len(c) = 1)
		raise("ERR-" + StkError(:IncorrectParamType))
	ok

	c = upper(c)

	# Getting the data about all the chars in the default style

	aDataXT = StringArtStylesXT()[DefaultStringArtStyle()]

	# Finding the char c in the list 

	nLen = len(aDataXT)
	nPos = 0

	for i = 1 to nLen
		if aDataXT[i][1] = c
			nPos = i
			exit
		ok
	next

	return aDataXT[nPos][2]

#---------------------------------#
#  STRING ART PAINTINGS FUNCTION  #
#---------------------------------#

#NOTE Use in the background by the StringArt('#{tree}) function

func StringArtPainting(cPaintingName)

	oQStr = new QString2()
	oQStr.append(cPaintingName)
	oQStr.replace_2(" ", "", 0)
	

	bOk = FALSE

	if oQStr.mid(0, 2) = "#{"
		nLen = oQStr.size()
		if oQStr.mid(nLen-1, 1) = "}"
			bOk = TRUE
		ok
	ok

	if bOk
		str = oQStr.mid(2, nLen-3)
	ok

	#--

	cResult = ""
	cCode = "cResult = $STZ_STR_ART_" + str
	eval(cCode)
	return cResult

#==========================#
#  STRING ART STYLE CLASS  #
#==========================#

class stkStringArt
	@cContent
	@cStyle = DefaultStringArtStyle()

	def init(str)
		if not isString(str)
			raise("ERR-" + StkError(:IncorrectParamType))
		ok

		@cContent = upper(str)

	def Content()
		return @cContent

		def String()
			return @cContent

	def Style()
		return @cStyle

	def SetStyle(cStyle)

		# Early check of default style

		if isString(cStyle) and cStyle = :Default
			@cStyle = DefaultStringArtStyle()
			return
		ok

		# Param type check

		if NOT isString(cStyle)
			raise("ERR-" + StkError(:IncorrectParamType))
		ok

		# Param value check

		nFound = find(StringArtStyles(), lower(cStyle))
		if nFound = 0
			raise("ERR-" + StkError(:IncorrectParamValue))
		ok

		# Setting the style

		@cStyle = cStyle

	def Artify()
 
		cSpacified = pvtSpacify(@cContent)
		nLenStr = len(@cContent) // #NOTE: work only for latin

		aCharSetXT = StringArtStylesXT()[This.Style()]

		nLenCharSet = len(aCharSetXT)
		#--> [
		# 	[ "A", [ ... ] ],
		# 	[ "B", [ ... ] ],
		# 	...
		# 	[ "O", [
		# 		"╭───╮",
		# 		"│╭─╮│", 
		# 		"││ ││", 
		# 		"│╰─╯│", 
		# 		"╰───╯" ],
		# 	...
		# ]

		nHight = len(aCharSetXT[1][2])

		cResult = ""
		
		for i = 1 to nHight
			for j = 1 to nLenStr
				c = @cContent[j]
				cResult += pvtCharArtLayers(c)[i] + " "	
			next

			# Adding the line (without space at the end)

			cResult = left(cResult, len(cResult) - 1) + NL
		next

		cResult = left(cResult, len(cResult) - 1)  // Remove the last newline
		return cResult

	def Boxify()

		# First, convert the input string to string art

	    	oQStrArt = new QString2()
		oQStrArt.append(This.Artify())

		# Split the string art into lines

		oQStrList = oQStrArt.split(NL, 0, 0)
				
		acLines = []
		for i = 0 to oQStrList.size()-1
			acLines + oQStrList.at(i)	
		next

		nLen = len(acLines)

		# Find the maximum line length

		anLenLines = []

		for i = 1 to nLen
			oQStr = new QString2()
			oQStr.append(acLines[i])
			anLenLines + oQStr.size()
		next

		anLenLines = sort(anLenLines)
		nLenMax = anLenLines[nLen]

		# Create the boxed result

		cResult = "╭" + copy("─", (nLenMax + 2)) + "╮" + NL
	    
		for i = 1 to nLen
	        	cResult += "│ " + acLines[i] + " │" + NL
		next
	    
		cResult += "╰" + copy("─", (nLenMax + 2)) + "╯"
	    
		return cResult


	PRIVATE

	func pvtSpacify(str)

		nLen = len(str)
		cResult = ""

		for i = 1 to nLen
			cResult += str[i] + " "
		next
	    
		return stktrim(cResult)

	func pvtCharArtLayers(c)
		if NOT (isString(c) and len(c) = 1)
			raise("ERR-" + StkError(:IncorrectParamType))
		ok
	
		c = upper(c)
	
		# Getting the data about all the chars in the default style
	
		aDataXT = StringArtStylesXT()[This.Style()]
	
		# Finding the char c in the list 
	
		nLen = len(aDataXT)
		nPos = 0
	
		for i = 1 to nLen
			if aDataXT[i][1] = c
				nPos = i
				exit
			ok
		next
	
		return aDataXT[nPos][2]
	
