// Reference of stzString functions

CREATE
	new stzString --> init()
	stzAppend()
	stzPrepend()

	TODO
	str = new stzString( ["Mansour","Ayouni" , :Template="Name: #1. Prename: #2."] )
		str --> "Name: Mansour. Prename: Ayouni."

	TODO
	str = new stzString( ["Mali","Niger","Burkina", :Sep=", " , :AtStart="{ " , :AtEnd=" }" , :UPPER )
		str --> { MALI, NIGER, BURKINA }

	TODO

	strlst = new stzStringList([ "Mali","Niger","Burkina" , :stzFunc=:StringNumberOfChars, :Params=[] ])
		aList --> [4, 4, 6]

	strlst = new stzStringList( "Mali", "Niger", "Burkina",
				    :stzFunc   = [ :stzSection , :stzLeft , :stzUPPER ],
				    :Params    = [    [2,4]    ,    [2]   ,     []    ],
				    :Executed  = :Sequentially,
				    :Executed  = :Independently,
				    :Optimised = TRUE
				  )

READ
	stzText()	stzText(:All)	stzText(:OnlyLetters)	stzText(:OnlyNumbers)	stzText(:OnlyNonLetters)
			stzText(:OnlySpecialChars)
LIST
	strToListOf(:Chars)		TODO
	strToListOf(:Letters)		TODO
	strToListOf(:Words)		TODO	strToListOf(:Words,:WithOrientation)
	strToListOf(:Sentences)		TODO	strToListOf(:Sentences,:WithoutOrientation)
	strToListOf(:Lines)		TODO	strToListOf(:Lines,:WithOrientation)

	strToListOf(:Parahraphs)	TODO
	strToListOf(:Paragraphs, :WithOrientation, :WithSizeInWords = strLen(:InWords) )
		--> aList = [
				[ :ID = "P1", :Paragraph = ".....", :Orientation = "RTL", :SizeInWords = 1250 ],
				[ :ID = "P2", :Paragraph = ".....", :Orientation = "LTR", :SizeInWords = 300 ],
				[ :ID = "P3", :Paragraph = ".....", :Orientation = "LTR", :SizeInWords = 800 ]
			    ]

	strToListOf(:Stats)	TODO	Analytics

ORIENTATION
	stzOrientation()
	stzIsRightToLeft()
	stzIsLeftToRight()	TODO
	stzIsHybridOrientation()

POSITION
	*stzAt(n)	stzAt(:Letter,n) stzAt(:StartOfWord,n) stzAt(:EndOfWord,n)
			stzAt(:StartOfSentence,n) stzAt(:EndOfSentence,n) stzAt(:StartOfLine,n) stzAt(:EndOfLine,n)
	*NRightChars(n)	NRightChars(n,:Letters) NRightChars(n,:Words) NRightChars(n,:Sentences) NRightChars(n,:Lines) NRightChars(n,:Paragraphs)
	*NLeftChars(n)	NLeftChars(n,:Letters) NLeftChars(n,:Words) NLeftChars(n,:Sentences) NLeftChars(n,:Lines) NLeftChars(n,:Paragraphs)

	*strStartsWith(pcSubStr)
	*strEndsWith(pcSubStr)

	*strFindFirstFromPsoition(pSubStr,pnFromPos)
	FindAllFromPosition(pSubStr,pnFromPos)
	*strFindAll(pcSubStr)

	*stzFind(pStr,n)

	*stzContains(pSubStr)

	stzCenterAsLetter()
	stzCenterAsNumber()
	stzCenterAsWord()	TODO

	*stzMiddle(n)	stzMiddle(n,:Letters)	stzMiddle(n,:Words) TODO
	*stzRadius(n)

LENGHT
	*stzLen()
	*stzDistanceBetween(:Start,"C",:InLetters)	// TODO
			  ("Hi",:End,:InWords)
COMPARE
	+stzIsEqualTo(pOtherStr)
	+stzCompareWith(pOtherStr)
	
TRANSFORM
	*stzReversed()
	*stzRepeated(n)

	*stzResize(n)
	*stzFill(n,cCaract)

	*stzDivide(p)

	stzToHtmlEscaped()

UPDATE
	stzUpdate(pNewText)

CLEAR
	*stzClear()
	*stzIsEmpty()
	stzIsOnlyWhiteSpaces()

DROP AND TRIM
	////////////////

REPLACE
	*stzReplaceSection(n1,n2,pNewSubStr)
	*stzReplace(pSubStr,pNewSubStr)
	*stzReplaceSome(pSubStr,pNewSubStr,aPos)	TODO
	*stzReplace(pSubStr,pNewSubStr,n)	TODO
	*stzReplaceLast(pSubStr,pNewSubStr,pStartPos)	TODO
	*stzReplaceFirst(pSubStr,pNewSubStr,pStartPos)
	
REMOVE
	*stzRemove(pnPosStart, pnPosEnd)
	
EXTRACT
	*stzSection(n1,n2)
	*stzExtract(pSep1,pSep2)
	*stzOnlyNumbers()
	
ADD
	*stzAdd(pSubStr)	TODO
	*stzAddAt(pSubStr,n)	TODO
	
INSERT
	*stzInsertAt(pSubStr,n)
	*stzInsertManyAt(aSubStr,n,aFormat)
	*stzInsertAtStartOf(pcSubStr,pcWhere)
	*stzInsertManyWhere(pSubstr,pWhere,aFormat)	TODO

FIND 
	*stzFindFirst(pSubStr,pnFromPos)
	*stzFindAll(pcSubStr)
	*stzFindByForamt(paFormat) TODO
	*stzWhere(pSubStr,n)	<=>	stzFind(pSubStr,n)
	
OPERATORS
	ACCESS
	  *oStzStr[n]
	  *oStzStr["SubStr"]

	APPEND
	  *oStr << "SubStr"	stzAppend("SubStr")
	 * oStr >> "SubStr"	stzPrepend("SubStr")
	
	ASSIGN
	  *oStr <= "Hi"	--> oStr = "Hi"	TODO

	  *oStr <= 12	--> Gives "Twelve" by default	TODO

	  *oStr <= [12 , :InEnglish, :Caml]	Give "Twelve"	TODO 
	  *oStr <= [12 , :InEnglish, :UPPER]	Give "TWELVE"	TODO 

	  oStr <= ["a","b","c",Sep=" "] 	--> str = "a b c"	TODO
	  oStr <= [1,2,3, :ToEnglish,Sep=" ",:lowerCase, :AtStart="{" , :AtEnd="}" ]	--> str = "one two three'	TODO 
	  oStr <= ["1","2","3",Sep"-"] 	: str = "1-2-3"

	COMPARE
	  oStr = "str"	--> TRUE or FALSE
	  oStr < "str"	--> If TRUE : oStr is contained in "str"
	  oStr > "str"	--> If TRUE : oStr contains "str"

	ADD
	  oStr + "str"
	  oStr + n
	  oStr + [List]		oStr + [ "Abc" , "Cde" , "Bjx" , :Sep=" " , :AtStart = "{ " , :AtEnd = " }" ]

	MULTIPLY
	  *oStr * n
	  *oStr * "str"
	  *oStr * [List]

	DEVIDE
	  *oStr / n
	  *oStr / "str"
	  *oStr / [List]

	

	
