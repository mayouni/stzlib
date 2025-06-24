load "stdlib.ring"

func BoxedString(str)
	oStr = new stkBoxedString(str)
	return oStr.Boxed()

func BoxedChars(str)
	oStr = new stkBoxedString(str)
	return oStr.BoxedChars()

class stzBoxedString
	@content

	def init(str)
		if not isString(str)
			raise("ERR-" + StkError(:IncorrectParamType))
		ok

		@content = str

	def Boxed()

		lines = split(@content, nl)
		maxLength = 0

		for line in lines
			if len(line) > maxLength
				maxLength = len(line)
        		ok
		next

		result = "╭" + copy("─", (maxLength + 2)) + "╮" + nl
    
		for line in lines
			result += "│ " + line + copy(" ", (maxLength - len(line))) + " │" + nl
		next
    
		result += "╰" + copy("─", (maxLength + 2)) + "╯"
    
		return result

	def BoxedChars()
		if @content = ""
			return This.Boxed()
		ok

		# Unicode box-drawing characters
		topLeft     = "╭"
		topRight    = "╮"
		bottomLeft  = "╰"
		bottomRight = "╯"
		horizontal  = "─"
		vertical    = "│"
		topLine	= "┬"
		bottomLine	= "┴"
    
		# Constructing the middle line

		nLenStr = len(@content)
		cMiddle = vertical + " "
		
		for i = 1 to nLenStr
			cMiddle += @content[i] + " " + vertical
			if i < nLenStr
				cMiddle += " "
			ok
		next

		# Constructing the top line

		nLen = len(cMiddle) - 2
		cTop = topLeft
		
		n = 0
		j = 0
		nLenMax = nLenStr * 2
		
		for i = 2 to nLen-2 step 3
			j++
			n++
			if n = 2
				if j < nLenMax
					n = 0
					cTop += topLine
				else
					cTop += topRight
				ok
			else
				cTop += copy(horizontal, 3)
			ok
		next

		# Constructing the bottom line

		cBottom = bottomLeft

		n = 0
		j = 0

		for i = 2 to nLen-2 step 3
			j++
			n++
			if n = 2
				if j < nLenMax
					n = 0
					cBottom += bottomLine
				else
					cBottom += bottomRight
				ok
			else
				cBottom += copy(horizontal, 3)
			ok
		  next

		# Composing the result

		cResult = cTop + NL + cMiddle + NL + cBottom

		return cResult



