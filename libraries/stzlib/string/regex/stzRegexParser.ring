

class stzRegexParser
	# Token types
	aTokenTypes = [
		:charClass,	# [abc], [a-z]
		:group,		# (abc)
		:quantifier,	# *, +, ?, {n}, {n,m}
		:alternation,	# |
		:anchor,		# ^, $
		:escape,	# \d, \w, etc
		:literal	# Normal chars
	]

	# Special character classes
	aSpecialClasses = [
		"\d": "0-9",
		"\w": "a-zA-Z0-9_",
		"\s": " \t\r\n"
	]

	aTokens = []
	cCurrentPattern = ""
	nPos = 0

	def init(cPattern)
		cCurrentPattern = cPattern
		tokenize()
	
	def tokenize()
		aTokens = []
		nPos = 1
		
		while nPos <= len(cCurrentPattern)
			cChar = substr(cCurrentPattern, nPos, 1)
			
			if cChar = "[" 
				nPos = parseCharClass(nPos)
			but cChar = "("
				nPos = parseGroup(nPos)
			but cChar = "\"
				nPos = parseEscape(nPos)
			but cChar = "{" or cChar = "*" or cChar = "+" or cChar = "?"
				nPos = parseQuantifier(nPos)
			but cChar = "|"
				add(aTokens, token(:alternation, "|"))
				nPos++
			but cChar = "^" or cChar = "$"
				add(aTokens, token(:anchor, cChar))
				nPos++
			else
				add(aTokens, token(:literal, cChar))
				nPos++
			ok
		end
		
		return [aTokens]
	
	def parseCharClass(nStartPos)
		nPos = nStartPos + 1
		cClass = ""
		bNegated = false
		
		if substr(cCurrentPattern, nPos, 1) = "^"
			bNegated = true
			nPos++
		ok
		
		while nPos <= len(cCurrentPattern)
			cChar = substr(cCurrentPattern, nPos, 1)
			if cChar = "]" and len(cClass) > 0
				add(aTokens, token(:charClass, [cClass, bNegated]))
				return nPos + 1
			ok
			
			cClass += cChar
			nPos++
		end
		
		return nPos
	
	def parseGroup(nStartPos)
		nPos = nStartPos + 1
		cGroup = ""
		nNestLevel = 1
		
		while nPos <= len(cCurrentPattern)
			cChar = substr(cCurrentPattern, nPos, 1)
			
			if cChar = "("
				nNestLevel++
			but cChar = ")"
				nNestLevel--
				if nNestLevel = 0
					add(aTokens, token(:group, cGroup))
					return nPos + 1
				ok
			ok
			
			cGroup += cChar
			nPos++
		end
		
		return nPos
	
	def parseQuantifier(nStartPos)
		cChar = substr(cCurrentPattern, nStartPos, 1)
		
		if cChar = "{"
			nPos = nStartPos + 1
			cQuant = ""
			
			while nPos <= len(cCurrentPattern)
				cChar = substr(cCurrentPattern, nPos, 1)
				if cChar = "}"
					add(aTokens, token(:quantifier, cQuant))
					return nPos + 1
				ok
				cQuant += cChar
				nPos++
			end
			
			return nPos
		else
			add(aTokens, token(:quantifier, cChar))
			return nStartPos + 1
		ok
	
	def parseEscape(nStartPos)
		cEscape = substr(cCurrentPattern, nStartPos, 2)
		
		if aSpecialClasses[cEscape] != NULL
			add(aTokens, token(:escape, cEscape))
		else
			add(aTokens, token(:literal, substr(cCurrentPattern, nStartPos + 1, 1)))
		ok
		
		return nStartPos + 2
	
	def token(cType, xValue)
		return [cType, xValue]
	
	def parse()
		# Reset state
		aSequences = []
		
		for i = 1 to len(aTokens)
			token = aTokens[i]
			cType = token[1]
			xValue = token[2]
			
			if cType = :charClass
				aClass = xValue
				cClass = aClass[1]
				bNegated = aClass[2]
				
				# Look ahead for quantifier
				cQuant = ""
				if i < len(aTokens) and aTokens[i+1][1] = :quantifier
					cQuant = aTokens[i+1][2]
					i++
				ok
				
				add(aSequences, translateCharClass(cClass, bNegated, cQuant))
				
			but cType = :group
				cGroupContent = xValue
				
				# Look ahead for quantifier
				cQuant = ""
				if i < len(aTokens) and aTokens[i+1][1] = :quantifier
					cQuant = aTokens[i+1][2]
					i++
				ok
				
				add(aSequences, translateGroup(cGroupContent, cQuant))
				
			but cType = :escape
				cEscapeClass = aSpecialClasses[xValue]
				
				# Look ahead for quantifier
				cQuant = ""
				if i < len(aTokens) and aTokens[i+1][1] = :quantifier
					cQuant = aTokens[i+1][2]
					i++
				ok
				
				add(aSequences, translateCharClass(cEscapeClass, false, cQuant))
			ok
		next
		
		return [aSequences]
	
	def translateCharClass(cClass, bNegated, cQuant)
		# Parse the character class content and create appropriate sequence
		oMaker = new stzRegexMaker
 ? @@(cClass)
		if substr(cClass, "-") > 0
			# Range like A-Z or 0-9

			cStart = cClass[1]
			cEnd = cClass[3]

? @@([ cStart, cEnd ])
			
			if IsNumberInString(cStart) and IsNumberInString(cEnd)
				oMaker.addDigitsRange(cStart + "-" + cEnd, translateQuantifier(cQuant))
			else
? "ici"
				oMaker.addCharsRange(cStart + "-" + cEnd, translateQuantifier(cQuant))
			ok
		else
			# List of chars
			aChars = []
			for i = 1 to len(cClass)
				add(aChars, substr(cClass, i, 1))
			next
			oMaker.addAmongChars(aChars, translateQuantifier(cQuant))
		ok
		
		return [oMaker]
	
	def translateQuantifier(cQuant)
		if cQuant = ""
			return [ :repeatedExactly, 1, 0 ]
		ok
		
		if cQuant = "?"
			return [ :repeatedAtMost, 1, 0 ]
		ok
		
		if cQuant = "+"
			return [ :repeatedAtLeast, 1, 0 ]
		ok
		
		if cQuant = "*"
			return [ :repeatedSeveral, 0, 0 ]
		ok
		
		if substr(cQuant, ",") > 0
			aValues = split(cQuant, ",")
			return [ :repeatedBetween, 0 + aValues[1], 0 + aValues[2] ]
		else
			return [ :repeatedExactly, 0 + cQuant, 0 ]
		ok
	
	private
	
	def isDigit(c)
		if NOT (isString(c) and IsNumberInString(c))
			return _FALSE_
		ok

		return (0+c) >= 0 and (0+c) <= 9
	
	def split(cStr, cDelim)
		aResult = []
		nStart = 1
		nPos = substr(cStr, cDelim)
		
		while nPos > 0
			add(aResult, substr(cStr, nStart, nPos - nStart))
			nStart = nPos + 1
			nPos = substr(cStr, cDelim, nStart)
		end
		
		add(aResult, substr(cStr, nStart))
		return [aResult]
