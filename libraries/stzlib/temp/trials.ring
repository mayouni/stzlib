load "../max/stzmax.ring"

_$aCLOSING_SUBSTRINGS_ = [

	#---------------------------------#
	#  BASIC BRACKETS AND PARENTHESES #
	#---------------------------------#

	:Basic = [
		[ "[", "]" ],
		[ "(", ")" ],
		[ "{", "}" ],
		[ "<", ">" ]
	],

	#---------------------#
	#  SOFTANZA-SPECIFIC  #
	#---------------------#

	:Softanza = [
		[ "profon()", "proff()" ]
	],

	#-----------------#
	#  RING LANGUAGE  #
	#-----------------#

	#TODO Add them all

	:Ring = [
		[ "see", "done" ],
		[ "load", "again" ]
	],

	#--------------------------#
	#  PSEUDO-CODE CONSTRUCTS  #
	#--------------------------#

	:PseudoCode = [
		[ "begin", "end" ],
		[ "function", "endfunction" ],
		[ "if", "endif" ],
		[ "while", "endwhile" ],
		[ "for", "next" ],
		[ "class", "endclass" ],
		[ "try", "endtry" ],
		[ "switch", "endswitch" ]
	],

	#-------------------------------#
	#  MARKUP LANGUAGES (XML/HTML)  #
	#-------------------------------#

	:Markup = [
		[ "<div>", "</div>" ],
		[ "<p>", "</p>" ],
		[ "<span>", "</span>" ],
		[ "<body>", "</body>" ],
		[ "<html>", "</html>" ],
		[ "<script>", "</script>" ],
		[ "<style>", "</style>" ]
	],

	#-----------------------#
	#  DOCUMENT PROCESSING  #
	#-----------------------#

	:Document = [
		[ "\begin{document}", "\end{document}" ],
		[ "\begin{table}", "\end{table}" ],
		[ "\begin{figure}", "\end{figure}" ]
	],

	#---------------------#
	#  STRING DELIMITERS  #
	#---------------------#

	:StringDelimiter = [
		[ "'", "'" ],
		[ '"', '"' ],
		[ "`", "`" ],
		[ "'''", "'''" ],	# Multiline strings
		[ "```", "```" ]	# Markdown code blocks
	],

	#------------------#
	#  COMMENT BLOCKS  #
	#------------------#

	:Comment = [
		[ "/*", "*/" ],
		[ "<!--", "-->" ],
		[ "#{", "#}" ]
	],

	#--------------------#
	#  TEMPLATE ENGINES  #
	#--------------------#

	:Template = [
		[ "<%", "%>" ],
		[ "{{", "}}" ],
		[ "{%", "%}" ]
	],

	#------------------#
	#  SQL CONSTRUCTS  #
	#------------------#

	:SQL = [
		[ "BEGIN TRANSACTION", "END TRANSACTION" ],
		[ "CASE", "END CASE" ]
	],

	#-----------------------#
	#  SHELL SCRIPT BLOCKS  #
	#-----------------------#

	:Shell = [
		[ "#!/bin/bash", "exit 0" ],
		[ "<<EOF", "EOF" ]
	],

	#-----------------#
	#  MATH NOTATION  #
	#-----------------#

	:Math = [
		[ "|", "|" ],	# Absolute value
		[ "⌈", "⌉" ],	# Ceiling
		[ "⌊", "⌋" ]	# Floor
	],

	#-----------------#
	#  SPECIAL CHARS  #
	#-----------------#

	:SpecialChar = [
		[ "«", "»" ],	# French quotes
		[ "„", "“" ]	# German quotes
	],

	#------------#
	#  MARKDOWN  #
	#------------#

	:Markdown = [
		[ "**", "**" ],        	# Bold
		[ "*", "*" ],          	# Italic
		[ "__", "__" ],        	# Bold alternative
		[ "~~", "~~" ]         	# Strikethrough
	],

	#-----------------------#
	#  REGULAR EXPRESSIONS  #
	#-----------------------#

	:RegExp = [
		[ "/", "/" ],          	# Basic delimiters
		[ "m{", "}" ],         	# Perl match
		[ "s/", "/g" ]		# Substitution
	]
]


? ClosingSubStringXT(:Of = "**", :In = :Markdown)
#--> **

#----

cListInStr = '[ [ 1, 2, 3 ], [ "B", [ 1, 2, 3 ] ], [ "C", "D", [ 1, 2, 3 ] ], [ 1, 2, 3 ] ]'

? @@( FindInStrList("[ 1, 2, 3 ]", cListInStr) )
#--> [ 1, [ 2, 2 ], [ 3, 3 ], 4 ]

? @@( FindInStrList("", "") )
#--> []

? @@( FindInStrList([1], "str") )
#--> []

_input1_ = '[ [ 1, 2, 3 ] ,    [ "B", [ 1, 2, 3 ] ],[ "C", "D", [ 1, 2, 3 ] ] , [ 1, 2, 3 ] ]'
? @@( FindInStrList("[ 1, 2, 3 ]", _input1_) )  # Should handle extra spaces
#--> [ 1, [ 2, 2 ], [ 3, 3 ], 4 ]

# Nested edge cases
_input2_ = '[[[[1, 2, 3]]]]'
? @@( FindInStrList("[ 1, 2, 3 ]", _input2_) ) # Should handle deep nesting

# Malformed but recoverable
_input3_ = '[ [ 1, 2, 3 ] , [ "B", [ 1, 2, 3 ] '  # Missing closing brackets
? @@( FindInStrList("[ 1, 2, 3 ]", _input3_) ) # Should return partial results
#--> [ 1 ]

#######

func ClosingSubStrings()
	return _$aCLOSING_SUBSTRINGS_

func ClosingSubStringXT(pcSubStr, pcDomain)
	if CheckParams()
		if isList(pcSubStr) and len(pcSubStr) = 2 and
		   isString(pcSubStr[1]) and pcSubStr[1] = :Of

			pcSubStr = pcSubStr[2]
		ok

		if NOT isString(pcSubStr)
			StzRaise("Incorrect param type! pcSubStr must be a string.")
		ok

		if isList(pcDomain) and len(pcDomain) = 2 and
		   isString(pcDomain[1]) and pcDomain[1] = :In

			pcDomain = pcDomain[2]
		ok
	ok

	_cResult_ = ClosingSubStrings()[pcDomain][pcSubStr]
	return _cResult_

func FindInStrList(pcItemProvidedAsStr, pcListProvidedAsStr)
	_positions_ = []
    	_nLenItemProvidedAsStr_ = len(pcItemProvidedAsStr)
	_nLenListProvidedAsStr_ = len(pcListProvidedAsStr)

	# Main parsing loop

	_rootPos_ = 1  # Track position at current depth
	_currentIndex_ = 1
    
	while _currentIndex_ <= len(pcListProvidedAsStr)

		# Check for direct match at current position

		if ExistsAt(pcItemProvidedAsStr, pcListProvidedAsStr, _currentIndex_)

			_positions_ + _rootPos_  # Simply add the current position
			_currentIndex_ += _nLenItemProvidedAsStr_ 

        	else

            		# Check for nested lists

			if substr(pcListProvidedAsStr, _currentIndex_, 1) = "["
 
               			_subEnd_ = FindMatchingBracket(pcListProvidedAsStr, _currentIndex_)

                		if _subEnd_ > _currentIndex_ + 1

                    			_subStr_ = substr(pcListProvidedAsStr, _currentIndex_ + 1, _subEnd_ - _currentIndex_ - 1)
                    			_subPositions_ = FindInStrList(pcItemProvidedAsStr, _subStr_)
					_nLenSubPositions_ = len(_subPositions_)

                        		# Create proper nested structure [parent_pos, child_pos]

					for @i = 1 to _nLenSubPositions_

		                           	 if isList(_subPositions_[@i])
		                                	_positions_ + _subPositions_[@i]

		                           	 else

							if _rootPos_ = 1
								_positions_ + _subPositions_[@i]
							else
		                                		_positions_ + [_rootPos_, _subPositions_[@i]]
							ok

		                            	ok

		                        next

                		ok

                		_currentIndex_ = _subEnd_

            		ok

            		_currentIndex_++

       	 	ok
        
	        # Move to next item at current level

	        if _currentIndex_ <= _nLenListProvidedAsStr_ and 
		   substr(pcListProvidedAsStr, _currentIndex_, 1) = ","

			_rootPos_++
			_currentIndex_++
	        ok

    	end
    
    	return _positions_

func FindMatchingBracket(pcStr, _startPos_)
	_openCount_ = 1
	@i = _startPos_ + 1
    	_nLenStr_ = len(pcStr)

	while @i <= _nLenStr_

		if substr(pcStr, @i, 1) = "["
			_openCount_++

		but substr(pcStr, @i, 1) = "]"

			_openCount_--
			if _openCount_ = 0
				return @i
			ok

		ok

		@i++
	end
    
	return _nLenStr_

func ExistsAt(pcSearchStr, pcMainStr, pnStartPos)
	if pnStartPos + len(pcSearchStr) - 1 > len(pcMainStr)
		return false
	ok
    
	return substr(pcMainStr, pnStartPos, len(pcSearchStr)) = pcSearchStr

/*----- #todo #narration STRINGIFY VS DEEP-STRINGIFY

profon()

# Define a nested list with a mix of strings, numbers, and sublists

aList1 = [
	"A",
	[ "B", "♥" ],
	[ "C", "D", [ 1, 2, [ "str", 7:9, 10 ],  3 ], "♥" ],
	"♥"
]

o1 = new stzList(aList1)

# Stringified(): Converts top-level elements to strings, preserving
# nested sublists as string representations

? @@SP( o1.Stringified() ) + NL
#--> [
#	"A",
#	'[ "B", "♥" ]',
#	'[ "C", "D", [ 1, 2, [ "E", [ 7, 8, 9 ], 10 ], 3 ], "♥" ]',
#	"♥"
#]

# DeepStringified(): Recursively converts all elements into strings,
# retaining the structural hierarchy

? @@SP( o1.DeepStringified() )
#--> [
#	"A",
#	[ "B", "♥" ],
#	[ "C", "D", [ "1", "2", [ "E", [ "7", "8", "9" ], "10" ], "3" ], "♥" ],
#	"♥"
# ]

# NOTE: These are used internally by Softanza in Find() and DeepFind() functions
# to allow them search for items other then lists.

# Other possible use cases of Stringify() and DeepStringify()
# - 
proff()
# Executed in 0.01 second(s) in Ring 1.22

/*---------

profon()

aList1 = [
	"A",
	[ "B", "♥" ],
	[ "C", "D", "♥" ],
	"♥"
]
? @@(DeepFind(aList1, "♥")) + NL
#--> [ [ 2, 2 ], [ 3, 3 ], 4 ]

aList2 = [
	"X",
	["Y", ["Z", "♥", ["W", "♥"]], "♥"],
	"V"
]
? @@(DeepFind(aList2, "♥"))
#--> [ [ 2, [ 2, 2 ] ], [ 2, [ 2, [ 3, 2 ] ] ], [ 2, 3 ] ]

proff()
# Executed in almost 0 second(s) in Ring 1.22

/*---------

profon()

o1 = new stzList([
	1,
	"UP",
	[ "UP", 2, "UP" ],
	[ 1, 2, [ "UP" ], 3, [ [ 4, "UP", 5 ] ] ],
	"UP"
])

? @@NL( o1.Lowercased() ) + NL
#--> [
#	1,
#	"up",
#	[ "UP", 2, "UP" ],
#	[ 1, 2, [ "UP" ], 3, [ [ 4, "UP", 5 ] ] ],
#	"up"
# ]

? @@NL( o1.DeepLowercased() )
#--> [
#	1,
#	"up",
#	[ "up", 2, "up" ],
#	[ 1, 2, [ "up" ], 3, [ [ 4, "up", 5 ] ] ],
#	"up"
# ]

proff()
# Executed in 0.01 second(s) in Ring 1.22

/*---------

profon()

o1 = new stzList([
	1,
	"up",
	[ "up", 2, "up" ],
	[ 1, 2, [ "up" ], 3, [ [ 4, "up", 5 ] ] ],
	"up"
])

? @@NL( o1.Uppercased() ) + NL
#--> [
#	1,
#	"UP",
#	[ "up", 2, "up" ],
#	[ 1, 2, [ "up" ], 3, [ [ 4, "up", 5 ] ] ],
#	"UP"
# ]

? @@NL( o1.DeepUppercased() )
#--> [
#	1,
#	"UP",
#	[ "UP", 2, "UP" ],
#	[ 1, 2, [ "UP" ], 3, [ [ 4, "UP", 5 ] ] ],
#	"UP"
# ]
proff()
# Executed in 0.01 second(s) in Ring 1.22

/*--------- #todo add #quicker

profon()

o1 = Q('[ [ 1, 2, 3 ], [ "B", [ 1, 2, 3 ] ], [ "C", "D", [ 1, 2, 3 ] ], [ 1, 2, 3 ] ]')

acTemp = o1.AllRemovedExcept([ "[", "]" ])
#--> "[[][[]][[]][]]"
#--> [ 1, 3, 13, 16, 23, 33, 35, 38, 50, 60, 62, 65, 75, 77 ]

proff()
# Executed in 0.08 second(s) in Ring 1.22

/*-----------

profon()
/*
o1 = new stzList([
	"A",
	[ "B", "♥" ],
	[ "C", "D", "♥" ],
	"♥"
])

? @@(o1.DeepFind("♥")) + NL
#--> [ [ 2, 2 ], [ 3, 3 ], 4 ]

/*----

o1 = new stzList([
	1:3,
	[ "B", 1:3 ],
	[ "C", "D", 1:3 ],
	1:3
])

? @@(o1.DeepFind(1:3))
#--> [ [ 2, 2 ], [ 3, 3 ], 4 ]

proff()

/*-------

aList2 = [
	"X",
	["Y", ["Z", "♥", ["W", "♥"]], "♥"],
	"V"
]
? @@(DeepFind(aList2, "♥"))
#--> [ [ 2, [ 2, 2 ] ], [ 2, [ 2, [ 3, 2 ] ] ], [ 2, 3 ] ]

proff()

/*---

profon()

o1 = new stzString("RIxxNxG")
? o1.@All("x").@Removed()
#--> RING

? o1.@All("z").@Removed()
#--> RIxxNxG

proff()

/*----

profon()

? isNull("")
#--> TRUE

? isNull(_NULL_)

? isTrue("") #TODO // Should rerurn TRUE

proff()

/*----

profon()


o1 = new stzString("abracadabra")

o1.ReplaceManyNthSubStrings([
	[ 1, 'a', :with = 'A' ],
	[ 2, 'a', :with = 'B' ],
	[ 4, 'a', :with = 'C' ],
	[ 5, 'a', :with = 'D' ],

	[ 1, 'b', :with = 'E' ],
		[ 2, 'r', :with = 'F' ]
])


? o1.Content()
# AErBcadCbFD


proff()
# Executed in 0.04 second(s) in Ring 1.22

/*---

profon()

# Given the string: "abracadabra", replace programatically:
#
#	the first 'a' with 'A'
#	the second 'a' with 'B'
#	the fourth 'a' with 'C'
#	the fifth 'a' with 'D'
#	the first 'b' with 'E'
#	the second 'r' with 'F'
#
# The answer should, of course, be : "AErBcadCbFD".

Q("abracadabra") {

	ReplaceNth(5, 'a', :with = 'D')
	ReplaceNth(4, 'a', :with = 'C')
	ReplaceNth(2, 'a', :with = 'B')
	ReplaceNth(1, 'a', :with = 'A')

	ReplaceNth(1, 'b', :with = 'E')
	ReplaceNth(2, 'r', :with = 'F')

	? Content()
	#--> AErBcadCbFD
}

proff()
# Executed in 0.01 second(s) in Ring 1.21

/*---

profon()

Q("abracadabra") {
	ReplaceManyNthSubStrings([
		[ 1, 'a', :with = 'A' ],
		[ 2, 'a', :with = 'B' ],
		[ 4, 'a', :with = 'C' ],
		[ 5, 'a', :with = 'D' ],
	
		[ 1, 'b', :with = 'E' ],
		[ 2, 'r', :with = 'F' ]
	])

	? Content()
}

proff()

/*---

profon()

Naturally() {
	Given the string "abracadabra" replace programatically

		the first 'a' with 'A'
		the second 'a' with 'B'
		the fourth 'a' with 'C'
		the fifth 'a' with 'D'
		the first 'b' with 'E'
		the second 'r' with 'F'

	The answer should of course be "AErBcadCbFD"
}

proff()

