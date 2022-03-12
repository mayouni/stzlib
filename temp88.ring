load "stzlib.ring"

char = "‎"			# char contains an INViSIBLE char!

? StzStringQ(char).IsEmpty() 	# Returns FALSE

? StringToUnicodes(char) 	# Returns [ 8206 ], other invisble chars may
				# return more unicodes!

? StzCharQ(char).Name()  + NL	# -> Left to Right Mark

? NamesOfInvisibleChars()



















/* 9 8282 119162
_aInvisibleChars = [

	# Unicode > Name

	[ 9, :Tabulation ],
	[ 32, :Space ],
	[ 173, :SoftHyphen ],
	[ 847, :CombiningGrphemJoiner ],
	
	[ 1564, :ArabicLetterMark ],
	
	[ 4447, :HangulChoseongFiller ],
	[ 4448, :HangulJungseongFiller ],
	
	[ 6068, :KhmerVowelInherentAQ ],
	[ 6069, :KhmerVowelInherentAA ],
	
	[ 6158, :MongolianVowelSeparator ],
	
	[ 8192, :EnQuad ],
	[ 8193, :EmQuad ],
	
	[ 8194, :EnSpace ],
	[ 8195, :EmSpace ],
	[ 8196, :ThreePerEmSpace ],
	[ 8197, :FourPerEmSpace ],
	[ 8198, :SixPerEmSpace ],
	[ 8199, :FigureSpace ],
	[ 8200, :PunctuationSpace ],
	[ 8201, :ThinSpace ],
	[ 8202, :HairSpace ],
	[ 8203, :ZeroWidthSpace ],
	[ 8204, :ZeroWidthNonJoiner ],
	[ 8205, :ZeroWidthJoiner ],
	[ 8206, :LeftToRightMark ],
	[ 8207, :RightoLeftMark ],
	
	[ 8239, :NarrowNoBreakSpace ],
	
	[ 8287, :MediumMathematicalSpace ],
	[ 8288, :WordJoiner ],
	[ 8289, :FunctionApplication ],
	[ 8290, :InvisibleTimes ],
	[ 8291, :InvisibleSpearator ],
	[ 8292, :InvisiblePlus ],
	
	[ 8298, :InhibitSymmetricSwapping ],
	[ 8299, :ActivateSymmetricSwapping ],
	[ 8300, :InhibitArabicFormShaping ],
	[ 8301, :ActivateArabicFormShaping ],
	[ 8302, :NationalDigitShapes ],
	[ 8303, :NominalDigitShapes ],
	
	[ 12288, :IdeographicSpace ],
	[ 10240, :BraillePatternBlank ],
	[ 12644, :HangulFiller ],
	
	[ 65279, :ZeroWidthNoBreakSpace ],
	
	[ 65440, :HalfWidthHangulFiller ],
	
	[ 119129, :MusicalSymbolNullNotehead ],
	[ 119155, :MusicalSymbolBeginBeam ],
	[ 119156, :MusicalSymbolEndBeam ],
	[ 119157, :MusicalSymbolBeginTie ],
	[ 119158, :MusicalSymbolEndTie ],
	[ 119159, :MusicalSymbolBeginSlur ],
	[ 119160, :MusicalSymbolEndSlur ],
	[ 119161, :MusicalSymbolBeginPhrase ],
	[ 119162, :MusicalSymbolEndPhrase ]
	
]



/*

# Function-style

	? StringToUnicodes("salem")
	# Returns [115, 97, 108, 101, 109]
	
	? UnicodesToString([115, 97, 108, 101, 109])
	# Returns "salem"

# Object-style

	? StzStringQ("salem").Unicodes()
	# Returns [115, 97, 108, 101, 109]

	? StzListOfUnicodesQ([115, 97, 108, 101, 109]).String()
	# Returns "salem"


