load "../stzbase.ring"

/*=========================================#
#   NUMBREX - PATTERN LANGUAGE FOR NUMBERS #
#   COMPREHENSIVE TEST SUITE               #
#==========================================#


/*--- BASIC PROPERTY MATCHING

pr()

Nx = new stzNumbrex("{@Property(Prime)}")
? Nx.Match(17)  #--> TRUE
? Nx.Match(18)  #--> FALSE

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

Nx3 = Nx("{@Digit3}")
? Nx3.Match(123)    #--> TRUE
? Nx3.Match(1234)   #--> FALSE
? Nx3.Match(12)     #--> FALSE

pf()

/*--- DIGITS WITHIN Section

pr()

Nx = Nx("{@Digit(1-5)+}")
? Nx.Match(1234)  #--> TRUE
? Nx.Match(1256)  #--> FALSE
? Nx.Match(543)   #--> TRUE
pf()

/*--- DIGITS FROM SPECIFIC SET

pr()

Nx = Nx("{@Digit({1;3;5;7})+}")
? Nx.Match(1357)  #--> TRUE
? Nx.Match(135)   #--> TRUE
? Nx.Match(1358)  #--> FALSE

pf()

/*--- ALL DIGITS UNIQUE

pr()

Nx = Nx("{@Digit(:unique)+}")
? Nx.Match(1234)    #--> TRUE
? Nx.Match(1223)    #--> FALSE
? Nx.Match(987654)  #--> TRUE

pf()

/*--- DIGIT COUNT Section

pr()

Nx = Nx("{@Digit2-4}")
? Nx.Match(12)     #--> TRUE
? Nx.Match(1234)   #--> TRUE
? Nx.Match(1)      #--> FALSE
? Nx.Match(12345)  #--> FALSE

pf()

/*--- FACTOR COUNT

pr()

Nx4 = Nx("{@Factor4}")
? Nx4.Match(6)   #--> TRUE (factors: 1,2,3,6)
? Nx4.Match(8)   #--> TRUE (factors: 1,2,4,8)
? Nx4.Match(12)  #--> FALSE (factors: 1,2,3,4,6,12 = 6 factors)

pf()

/*--- FACTOR COUNT IN Section

pr()

Nx = Nx("{@Factor2-5}")
? Nx.Match(6)   #--> TRUE (4 factors)
? Nx.Match(12)  #--> FALSE (6 factors)
? Nx.Match(4)   #--> TRUE (3 factors)

pf()

/*--- ALTERNATION: EVEN OR PRIME

pr()

Nx = Nx("{@Property(Even) | @Property(Prime)}")
? Nx.Match(2)  #--> TRUE (both even and prime)
? Nx.Match(4)  #--> TRUE (even)
? Nx.Match(7)  #--> TRUE (prime)
? Nx.Match(9)  #--> FALSE (neither)

pf()

/*--- ALTERNATION: MULTIPLE PROPERTIES

pr()

Nx = Nx("{@Property(Perfect) | @Property(Fibonacci) | @Property(Palindrome)}")
? Nx.Match(6)    #--> TRUE (perfect)
? Nx.Match(13)   #--> TRUE (fibonacci)
? Nx.Match(121)  #--> TRUE (palindrome)
? Nx.Match(10)   #--> FALSE (none)

pf()

/*--- CONJUNCTION: EVEN AND PRIME

pr()

Nx = Nx("{@Property(Even) & @Property(Prime)}")
? Nx.Match(2)  #--> TRUE (only even prime)
? Nx.Match(4)  #--> FALSE (even but not prime)
? Nx.Match(3)  #--> FALSE (prime but not even)

pf()

/*--- CONJUNCTION: PALINDROME AND SQUARE

pr()

Nx = Nx("{@Property(Palindrome) & @Property(Square)}")
? Nx.Match(121)  #--> TRUE (11^2 = 121)
? Nx.Match(144)  #--> FALSE (palindrome check: 144 != 441)
? Nx.Match(131)  #--> FALSE (not a square)

pf()

/*--- CONJUNCTION: MULTIPLE CONDITIONS

pr()

Nx = Nx("{@Property(Even) & @Digit3 & @Property(Palindrome)}")
? Nx.Match(212)  #--> TRUE
? Nx.Match(222)  #--> TRUE
? Nx.Match(213)  #--> FALSE (not palindrome)

pf()

/*--- NEGATION: NOT PRIME

pr()

Nx = Nx("{@!Property(Prime)}")
? Nx.Match(4)  #--> TRUE (composite)
? Nx.Match(9)  #--> TRUE (composite)
? Nx.Match(7)  #--> FALSE (is prime)

pf()

/*--- NEGATION: NOT PERFECT

pr()

Nx = Nx("{@!Property(Perfect)}")
? Nx.Match(10)  #--> TRUE (not perfect)
? Nx.Match(28)  #--> FALSE (is perfect)

pf()

/*--- NEGATION: NOT EVEN (ODD)

pr()

Nx = Nx("{@!Property(Even)}")
? Nx.Match(7)  #--> TRUE (odd)
? Nx.Match(8)  #--> FALSE (is even)
pf()

/*--- RELATION: DIVISIBLE BY 5

pr()

Nx = Nx("{@Relation(Mod:5=0)}")
? Nx.Match(10)  #--> TRUE
? Nx.Match(25)  #--> TRUE
? Nx.Match(13)  #--> FALSE

pf()

/*--- RELATION: SPECIFIC REMAINDER

pr()

Nx = Nx("{@Relation(Mod:3=1)}")
? Nx.Match(10)  #--> TRUE (10 % 3 = 1)
? Nx.Match(7)   #--> TRUE (7 % 3 = 1)
? Nx.Match(9)   #--> FALSE (9 % 3 = 0)

pf()

/*--- RELATION: DIVISIBLE BY 10

pr()

Nx = Nx("{@Relation(Mod:5=0) & @Property(Even)}")
? Nx.Match(10)  #--> TRUE
? Nx.Match(20)  #--> TRUE
? Nx.Match(15)  #--> FALSE (not even)

pf()

/*--- EXTRACTING DIGIT LIST

pr()

Nx = Nx("{@Digit+}")
? Nx.Match(1234) #--> TRUE
? @@NL( Nx.MatchedParts() )
#-->
'
[
	[ "Digits", [ 1, 2, 3, 4 ] ],
	[ "Factors", [ 1, 2, 617, 1234 ] ],
	[ "Properties", [ "Even", "Deficient", "Composite" ] ],
	[ "Value", 1234 ]
]
'

pf()

/*--- EXTRACTING FACTOR LIST

pr()

Nx = Nx("{@Factor+}")
? Nx.Match(42) #--> TRUE
? @@( Nx.Factors() )
#--> [ 1, 2, 3, 6, 7, 14, 21, 42 ]

pf()

/*--- EXTRACTING PROPERTIES

pr()

Nx = Nx("{@Property(Even)}")

? Nx.Match(6)
#--> TRUE

? @@( Nx.Properties() )
#--> [ "Even", "Perfect", "Palindrome", "Triangular", "Composite" ]

? Nx.Value()
#--> 6

pf()

/*--- APPLICATION: PIN CODE VALIDATION

pr()

oPinValidator = Nx("{@Digit4:unique}")
? oPinValidator.Match(1234)  #--> TRUE
? oPinValidator.Match(1123)  #--> FALSE (not unique)
? oPinValidator.Match(9876)  #--> TRUE

pf()

/*--- APPLICATION: CRYPTO KEY VALIDATION

pr()

oKeyValidator = Nx("{@Property(Prime) & @Digit3+}")
? oKeyValidator.Match(101)  #--> TRUE (prime, 3 digits)
? oKeyValidator.Match(103)  #--> TRUE (prime, 3 digits)
? oKeyValidator.Match(100)  #--> FALSE (not prime)
? oKeyValidator.Match(97)   #--> FALSE (only 2 digits)

pf()

/*--- APPLICATION: GAME SCORE VALIDATION

pr()

oScoreValidator = Nx("{@Property(Even) & @Digit2-4 & @Relation(Mod:10=0)}")
? oScoreValidator.Match(100)   #--> TRUE
? oScoreValidator.Match(1230)  #--> TRUE
? oScoreValidator.Match(125)   #--> FALSE (not even)
? oScoreValidator.Match(10)    #--> TRUE

pf()

/*---

pr()

Nx = Nx("{@Digit(1-9)6}")
? Nx.Match(123456) #--> TRUE

pf()

/*--- APPLICATION: LOTTERY NUMBER VALIDATION

pr()

oLottery = Nx("{@Digit(1-9)6:unique}")
? oLottery.Match(123456)  #--> TRUE
? oLottery.Match(123455)  #--> FALSE (not unique)
? oLottery.Match(123450)  #--> FALSE (contains 0)

pf()

/*--- PATTERN EXPLANATION

pr()

Nx = Nx("{@Property(Prime)}")
? @@NL( Nx.Explain() )
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

Nx = Nx("{@Property(Even) & @Digit3 & @Relation(Mod:5=0)}")
? @@NL( Nx.Explain() )
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
							[ "min", 3 ],
							[ "max", 3 ],
							[ "negated", 0 ]
						],
						[
							[ "type", "relation" ],
							[ "value", "Mod:5=0" ],
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

/*--- NEW FEATURES: ADDITIONAL PROPERTIES

pr()

Nx = Nx("{@Property(Triangular)}")
? Nx.Match(1)   #--> TRUE
? Nx.Match(3)   #--> TRUE
? Nx.Match(6)   #--> TRUE
? Nx.Match(10)  #--> TRUE
? Nx.Match(11)  #--> FALSE

pf()

/*---

pr()

Nx = Nx("{@Property(Cube)}")
? Nx.Match(1)   #--> TRUE
? Nx.Match(8)   #--> TRUE
? Nx.Match(27)  #--> TRUE
? Nx.Match(10)  #--> FALSE

pf()

/*---

pr()

Nx = Nx("{@Property(Abundant)}")
? Nx.Match(12)  #--> TRUE (1+2+3+4+6 = 16 > 12)
? Nx.Match(18)  #--> TRUE
? Nx.Match(10)  #--> FALSE

pf()

/*---

pr()

Nx = Nx("{@Property(Deficient)}")
? Nx.Match(8)   #--> TRUE (1+2+4 = 7 < 8)
? Nx.Match(10)  #--> TRUE (1+2+5 = 8 < 10)
? Nx.Match(6)   #--> FALSE (perfect)
pf()

/*--- NEW FEATURES: PART MATCHING

pr()

Nx = Nx("{@Part(Integer)}")
? Nx.Match(5)     #--> TRUE
? Nx.Match(5.7)   #--> FALSE

pf()

/*---

pr()

Nx = Nx("{@Part(Fractional)}")
? Nx.Match(5)     #--> FALSE
? Nx.Match(5.7)   #--> TRUE

pf()

/*--- NEW FEATURES: DIVISOR/MULTIPLE

pr()

Nx = Nx("{@Divisor(3)}")
? Nx.Match(9)   #--> TRUE
? Nx.Match(15)  #--> TRUE
? Nx.Match(10)  #--> FALSE

pf()

/*---

pr()

Nx = Nx("{@Multiple(5)}")
? Nx.Match(10)  #--> TRUE
? Nx.Match(15)  #--> TRUE
? Nx.Match(12)  #--> FALSE

pf()

/*--- NEW FEATURES: FIND METHODS

pr()

# Get Next Matching Number

Nx = Nx("{@Property(Prime) & @Digit2}")
? Nx.MatchingNumberAfter(10)  #--> 11 (first 2-digit prime >= 10)

pf()

/*---

pr()

# Get matching numbers in between two numbers

Nx = Nx("{@Property(Perfect)}")
aResults = Nx.MatchingNumbersBetween(1, :And = 100)
? @@(aResults)  #--> [6, 28]

pf()

/*---

pr()

# Count matching numbers between two given numbers

Nx = Nx("{@Property(Prime) & @Digit2}")
? Nx.CountMatchingNumbersBetween(10, :And = 99)
#--> 21

pf()

/*--- CASE INSENSITIVITY

pr()

# Case Insensitive Keywords

Nx = Nx("{@PROPERTY(PRIME)}")
? Nx.Match(17)  #--> TRUE

Nx = Nx("{@property(prime)}")
? Nx.Match(17)  #--> TRUE

Nx = Nx("{@Property(Prime)}")
? Nx.Match(17)  #--> TRUE

pf()
