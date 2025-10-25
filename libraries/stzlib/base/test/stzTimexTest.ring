load "../stzbase.ring"

/*=========================================#
#   NUMBREX - PATTERN LANGUAGE FOR NUMBERS #
#=========================================*/

/*--- BASIC PROPERTY MATCHING

pr()

oNx = new stzNumbrex("{@Property(Prime)}")
? oNx.Match(17)  #--> TRUE
? oNx.Match(18)  #--> FALSE

pf()

/*--- PERFECT NUMBERS

pr()

oPerfect = Nx("{@Property(Perfect)}")
? oPerfect.Match(6)   #--> TRUE
? oPerfect.Match(28)  #--> TRUE
? oPerfect.Match(12)  #--> FALSE

pf()

/*--- FIBONACCI SEQUENCE MEMBERS

pr()

oFib = Nx("{@Property(Fibonacci)}")
? oFib.Match(13)  #--> TRUE
? oFib.Match(21)  #--> TRUE
? oFib.Match(22)  #--> FALSE

pf()

/*--- PALINDROMIC NUMBERS

pr()

oPalin = Nx("{@Property(Palindrome)}")
? oPalin.Match(121)   #--> TRUE
? oPalin.Match(1221)  #--> TRUE
? oPalin.Match(123)   #--> FALSE

pf()

/*--- PERFECT SQUARES

pr()

oSquare = Nx("{@Property(Square)}")
? oSquare.Match(16)  #--> TRUE
? oSquare.Match(25)  #--> TRUE
? oSquare.Match(26)  #--> FALSE

pf()

/*--- EXACT DIGIT COUNT

pr()

oNx3 = Nx("{@Digit3}")
? oNx3.Match(123)    #--> TRUE	#ERR
? oNx3.Match(1234)   #--> FALSE
? oNx3.Match(12)     #--> FALSE

pf()

/*--- DIGITS WITHIN RANGE

pr()

oNx = Nx("{@Digit(1-5)+}")
? oNx.Match(1234)  #--> TRUE
? oNx.Match(1256)  #--> FALSE
? oNx.Match(543)   #--> TRUE

pf()

/*--- DIGITS FROM SPECIFIC SET

pr()

oNx = Nx("{@Digit({1;3;5;7})+}")
? oNx.Match(1357)  #--> TRUE
? oNx.Match(135)   #--> TRUE
? oNx.Match(1358)  #--> FALSE

pf()

/*--- ALL DIGITS UNIQUE

pr()

oNx = Nx("{@Digit(:unique)+}") #TODO Check sensitivity to case "Unique"
? oNx.Match(1234)    #--> TRUE
? oNx.Match(1223)    #--> FALSE
? oNx.Match(987654)  #--> TRUE

pf()

/*--- DIGIT COUNT RANGE

pr()

oNx = Nx("{@Digit2-4}")
? oNx.Match(12)     #--> TRUE	#ERR
? oNx.Match(1234)   #--> TRUE	#ERR
? oNx.Match(1)      #--> FALSE	#ERR
? oNx.Match(12345)  #--> FALSE

pf()

/*--- FACTOR COUNT

pr()

oNx4 = Nx("{@Factor4}")
? oNx4.Match(6)   #--> TRUE	#ERR
? oNx4.Match(8)   #--> TRUE	#ERR
? oNx4.Match(12)  #--> FALSE

pf()

/*--- FACTOR COUNT IN RANGE

pr()

oNx = Nx("{@Factor2-5}")
? oNx.Match(6)   #--> TRUE	#ERR
? oNx.Match(12)  #--> FALSE
? oNx.Match(4)   #--> TRUE	#ERR

pf()

/*--- ALTERNATION: EVEN OR PRIME

pr()

oNx = Nx("{@Property(Even) | @Property(Prime)}")
? oNx.Match(2)  #--> TRUE
? oNx.Match(4)  #--> TRUE
? oNx.Match(7)  #--> TRUE
? oNx.Match(9)  #--> FALSE

pf()

/*--- ALTERNATION: MULTIPLE PROPERTIES

pr()

oNx = Nx("{@Property(Perfect) | @Property(Fibonacci) | @Property(Palindrome)}")
? oNx.Match(6)    #--> TRUE
? oNx.Match(13)   #--> TRUE
? oNx.Match(121)  #--> TRUE
? oNx.Match(10)   #--> FALSE

pf()

/*--- CONJUNCTION: EVEN AND PRIME

pr()

oNx = Nx("{@Property(Even) & @Property(Prime)}")
? oNx.Match(2)  #--> TRUE
? oNx.Match(4)  #--> FALSE
? oNx.Match(3)  #--> FALSE

pf()

/*--- CONJUNCTION: PALINDROME AND SQUARE

pr()

oNx = Nx("{@Property(Palindrome) & @Property(Square)}")
? oNx.Match(121)  #--> TRUE
? oNx.Match(144)  #--> FALSE
? oNx.Match(131)  #--> FALSE

pf()

/*--- CONJUNCTION: MULTIPLE CONDITIONS

pr()

oNx = Nx("{@Property(Even) & @Digit3 & @Property(Palindrome)}")
? oNx.Match(212)  #--> TRUE	#ERR
? oNx.Match(222)  #--> TRUE	#ERR
? oNx.Match(213)  #--> FALSE

pf()

/*--- NEGATION: NOT PRIME

pr()

oNx = Nx("{@!Property(Prime)}")
? oNx.Match(4)  #--> TRUE
? oNx.Match(9)  #--> TRUE
? oNx.Match(7)  #--> FALSE	#ERR

pf()

/*--- NEGATION: NOT PERFECT

pr()

oNx = Nx("{@!Property(Perfect)}")
? oNx.Match(10)  #--> TRUE
? oNx.Match(28)  #--> FALSE	#ERR

pf()

/*--- NEGATION: NOT EVEN (ODD)

pr()

oNx = Nx("{@!Property(Even)}")
? oNx.Match(7)  #--> TRUE
? oNx.Match(8)  #--> FALSE	#ERR

pf()

/*--- RELATION: DIVISIBLE BY 5

pr()

oNx = Nx("{@Relation(Mod:5=0)}")
? oNx.Match(10)  #--> TRUE	#ERR
? oNx.Match(25)  #--> TRUE	#ERR
? oNx.Match(13)  #--> FALSE	#ERR

pf()

/*--- RELATION: SPECIFIC REMAINDER

pr()

oNx = Nx("{@Relation(Mod:3=1)}")
? oNx.Match(10)  #--> TRUE	#ERR
? oNx.Match(7)   #--> TRUE	#ERR
? oNx.Match(9)   #--> FALSE

pf()

/*--- RELATION: DIVISIBLE BY 10

pr()

oNx = Nx("{@Relation(Mod:5=0) & @Property(Even)}")
? oNx.Match(10)  #--> TRUE	#ERR
? oNx.Match(20)  #--> TRUE	#ERR
? oNx.Match(15)  #--> FALSE

pf()

/*--- EXTRACTING DIGIT LIST

pr()

oNx = Nx("{@Digit+}")
? oNx.Match(1234) #--> TRUE

? @@NL( oNx.MatchedParts() )
#-->
'
[
	[ "Digits", [ 1, 2, 3, 4 ] ],
	[ "Factors", [ 	1, 2, 617, 1234 ] ],
	[ "Properties", [ "Even" ] ],
	[ "Value", 1234 ]
]
'

pf()

/*--- EXTRACTING FACTOR LIST

pr()

oNx = Nx("{@Factor+}")
? oNx.Match(42) #--> TRUE
? oNx.MatchedParts()[:Factors]
#--> [ 1, 2, 3, 6, 7, 14, 21, 42 ]

pf()

/*--- EXTRACTING PROPERTIES

pr()

oNx = Nx("{@Property(Even)}")
? oNx.Match(6)
? @@NL( oNx.MatchedParts() )
#-->
'
[
	[
		"Digits",
		[ 6 ]
	],
	[
		"Factors",
		[
			1,
			2,
			3,
			6
		]
	],
	[
		"Properties",
		[ "Even", "Perfect", "Palindrome" ]
	],
	[ "Value", 6 ]
]
'

pf()

/*--- APPLICATION: PIN CODE VALIDATION

pr()

oPinValidator = Nx("{@Digit4:unique}")
? oPinValidator.Match(1234)  #--> TRUE	#ERR
? oPinValidator.Match(1123)  #--> FALSE
? oPinValidator.Match(9876)  #--> TRUE	#ERR

pf()

/*--- APPLICATION: CRYPTO KEY VALIDATION

pr()

oKeyValidator = Nx("{@Property(Prime) & @Digit3+}")
? oKeyValidator.Match(101)  #--> TRUE
? oKeyValidator.Match(103)  #--> TRUE
? oKeyValidator.Match(100)  #--> FALSE
? oKeyValidator.Match(97)   #--> FALSE	#ERR

pf()

/*--- APPLICATION: GAME SCORE VALIDATION

pr()

oScoreValidator = Nx("{@Property(Even) & @Digit2-4 & @Relation(Mod:10=0)}")
? oScoreValidator.Match(100)   #--> TRUE	#ERR
? oScoreValidator.Match(1230)  #--> TRUE	#ERR
? oScoreValidator.Match(125)   #--> FALSE
? oScoreValidator.Match(10)    #--> TRUE	#ERR

pf()

/*--- APPLICATION: LOTTERY NUMBER VALIDATION

pr()

oLottery = Nx("{@Digit(1-9)6:unique}")
? oLottery.Match(123456)  #--> TRUE	#ERR
? oLottery.Match(123455)  #--> FALSE
? oLottery.Match(123450)  #--> FALSE

pf()

/*--- PATTERN EXPLANATION

pr()

oNx = Nx("{@Property(Prime)}")
? @@NL( oNx.Explain() )
#-->
'
[
	[ "Pattern", "{@Property(Prime)}" ],
	[ "TokenCount", 1 ],
	[
		"Tokens",
		[
			[
				[ "type", "property" ],
				[ "value", "Prime" ],
				[ "constraints", [  ] ],
				[ "min", 1 ],
				[ "max", 1 ],
				[ "negated", 0 ]
			]
		]
	]
]
'

pf()

/*--- COMPLEX PATTERN EXPLANATION

pr()

oNx = Nx("{@Property(Even) & @Digit3 & @Relation(Mod:5=0)}")
? @@NL( oNx.Explain() )
#-->
'
[
	[
		"Pattern",
		"{@Property(Even) & @Digit3 & @Relation(Mod:5=0)}"
	],
	[ "TokenCount", 1 ],
	[
		"Tokens",
		[
			[
				[ "type", "conjunction" ],
				[
					"conditions",
					[
						[
							[ "type", "property" ],
							[ "value", "Even" ],
							[ "constraints", [  ] ],
							[ "min", 1 ],
							[ "max", 1 ],
							[ "negated", 0 ]
						],
						[
							[ "type", "digit" ],
							[ "value", "" ],
							[ "constraints", [  ] ],
							[ "min", 1 ],
							[ "max", 1 ],
							[ "negated", 0 ]
						],
						[
							[ "type", "relation" ],
							[ "value", "" ],
							[ "constraints", [  ] ],
							[ "min", 1 ],
							[ "max", 1 ],
							[ "negated", 0 ]
						]
					]
				],
				[ "negated", 0 ]
			]
		]
	]
]
'

pf()

/*--- DEBUG MODE TRACING

pr()

oNx = Nx("{@Property(Prime)}")
oNx.EnableDebug()
? oNx.Match(17)
#--> TRUE (with debug trace)
#ERR the output is correct but No debug has been dispalyed

pf()
