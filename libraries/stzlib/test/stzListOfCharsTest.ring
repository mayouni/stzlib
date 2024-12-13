load "../max/stzmax.ring"

/*-----------------

profon()

o1 = new stzListOfChars([ 945, 946, 947 ])

? @@( o1.Content() ) + NL
#--> [ "α", "β", "γ" ]

? @@( Unicodes([ "α", "β", "γ" ]) ) + NL
#--> [ 945, 946, 947 ]

? @@( MathChars() )
#--> [
#	"¬", "°", "±", "¼", "½", "¾", "×", "÷",
#	"Γ", "Δ", "Θ", "Λ", "Ξ", "Π", "Σ", "Υ",
#	"Φ", "Ψ", "Ω", "α", "β", "γ", "δ", "ε",
#	"ζ", "η", "θ", "ι", "κ", "λ", "μ", "ν",
#	"ξ", "ο", "π", "ρ", "σ", "τ", "υ", "φ",
#	"χ", "ψ", "ω", "⅓", "⅔", "∀", "∂", "∃",
#	"∅", "∇", "∈", "∉", "∏", "∑", "√",
#	"∝", "∞", "∠", "∧", "∨", "∫", "∲", "∴",
#	"≈", "≠", "≡", "≤", "≥"
# ]

proff()
#--> Executed in 0.08 second(s)

/*-----------------

profon()

? NumberOfMathChars()
#--> 68

? MathCharsQR(:stzListOfChars).CharsAndTheirNames()
#--> [
#	[ "¬", "NOT SIGN" ], [ "°", "DEGREE SIGN" ], [ "±", "PLUS-MINUS SIGN" ],
#	[ "¼", "VULGAR FRACTION ONE QUARTER" ], [ "½", "VULGAR FRACTION ONE HALF" ],
#	[ "¾", "VULGAR FRACTION THREE QUARTERS" ], [ "×", "MULTIPLICATION SIGN" ],
#	[ "÷", "DIVISION SIGN" ], [ "Γ", "GREEK CAPITAL LETTER GAMMA" ],
#	[ "Δ", "GREEK CAPITAL LETTER DELTA" ], [ "Θ", "GREEK CAPITAL LETTER THETA" ],
#	[ "Λ", "GREEK CAPITAL LETTER LAMDA" ], [ "Ξ", "GREEK CAPITAL LETTER XI" ],
#	[ "Π", "GREEK CAPITAL LETTER PI" ], [ "Σ", "GREEK CAPITAL LETTER SIGMA" ],
#	[ "Υ", "GREEK CAPITAL LETTER UPSILON" ], [ "Φ", "GREEK CAPITAL LETTER PHI" ],
#	[ "Ψ", "GREEK CAPITAL LETTER PSI" ], [ "Ω", "GREEK CAPITAL LETTER OMEGA" ],
#	[ "α", "GREEK SMALL LETTER ALPHA" ], [ "β", "GREEK SMALL LETTER BETA" ],
#	[ "γ", "GREEK SMALL LETTER GAMMA" ], [ "δ", "GREEK SMALL LETTER DELTA" ],
#	[ "ε", "GREEK SMALL LETTER EPSILON" ], [ "ζ", "GREEK SMALL LETTER ZETA" ],
#	[ "η", "GREEK SMALL LETTER ETA" ], [ "θ", "GREEK SMALL LETTER THETA" ],
#	[ "ι", "GREEK SMALL LETTER IOTA" ], [ "κ", "GREEK SMALL LETTER KAPPA" ],
#	[ "λ", "GREEK SMALL LETTER LAMDA" ], [ "μ", "GREEK SMALL LETTER MU" ],
#	[ "ν", "GREEK SMALL LETTER NU" ], [ "ξ", "GREEK SMALL LETTER XI" ],
#	[ "ο", "GREEK SMALL LETTER OMICRON" ], [ "π", "GREEK SMALL LETTER PI" ],
#	[ "ρ", "GREEK SMALL LETTER RHO" ], [ "σ", "GREEK SMALL LETTER SIGMA" ],
#	[ "τ", "GREEK SMALL LETTER TAU" ], [ "υ", "GREEK SMALL LETTER UPSILON" ],
#	[ "φ", "GREEK SMALL LETTER PHI" ], [ "χ", "GREEK SMALL LETTER CHI" ],
#	[ "ψ", "GREEK SMALL LETTER PSI" ], [ "ω", "GREEK SMALL LETTER OMEGA" ],
#	[ "⅓", "VULGAR FRACTION ONE THIRD" ], [ "⅔", "VULGAR FRACTION TWO THIRDS" ],
#	[ "∀", "FOR ALL" ], [ "∂", "PARTIAL DIFFERENTIAL" ], [ "∃", "THERE EXISTS" ],
#	[ "∅", "EMPTY SET" ], [ "∇", "NABLA" ], [ "∈", "ELEMENT OF" ],
#	[ "∉", "NOT AN ELEMENT OF" ], [ "∏", "N-ARY PRODUCT" ], [ "∑", "N-ARY SUMMATION" ],
#	[ "√", "SQUARE ROOT" ], [ "∝", "PROPORTIONAL TO" ], [ "∞", "INFINITY" ],
#	[ "∠", "ANGLE" ], [ "∧", "LOGICAL AND" ], [ "∨", "LOGICAL OR" ],
#	[ "∫", "INTEGRAL" ], [ "∲", "CLOCKWISE CONTOUR INTEGRAL" ], [ "∴", "THEREFORE" ],
#	[ "≈", "ALMOST EQUAL TO" ], [ "≠", "NOT EQUAL TO" ], [ "≡", "IDENTICAL TO" ],
#	[ "≤", "LESS-THAN OR EQUAL TO" ], [ "≥", "GREATER-THAN OR EQUAL TO" ]
# ]

proff()
# Executed in 1.65 second(s) in Ring 1.21
# Executed in 5.90 second(s) in Ring 1.17

/*-----------------

profon()

o1 = new stzListOfChars([ "1", "2", "♥", "4", "5", "♥", "7", "8", "♥" ])

? o1.FindAll("♥")
#--> [3, 6, 9]

#NOTE: the following functions work the same for stzString, 
# stzList, and stzListOfStrings, because they are abstracted in stzObject

? o1.NFirstOccurrences(2, :Of = "♥") 
#--> [3, 6]

? o1.NFirstOccurrencesST(2, :Of = "♥", :StartingAt = 1)
#--> [3, 6]

? o1.NLastOccurrences(2, :Of = "♥")
#--> [6, 9]

? o1.NLastOccurrencesST(2, "♥", :StartingAt = 1)
#--> [6, 9]

? o1.NFirstOccurrencesST(2, :Of = "♥", :StartingAt = 6)
#--> [6, 9]

? o1.LastNOccurrencesST(1, :Of = "♥", :StartingAt = 9)
#--> [ 9 ]

proff()
# Executed in 0.10 second(s).

/*----------------

profon()

? StzListOfCharsQ("A":"E").IsContiguous()
#--> _TRUE_

? StzListOfCharsQ("1":"5").IsContiguous()
#--> _TRUE_

? StzListOfCharsQ('"ا":"ج"').IsContiguous()
#--> _TRUE_	TODO: ERROR!

proff()
# Executed in 0.07 second(s).

/*-------------

profon()

o1 = new stzListOfChars([ "a", "b", "c" ])

? o1.Unicodes()
#--> [ 97, 98, 99 ]

? CharsUnicodes([ "a", "b", "c" ])
#--> [ 97, 98, 99 ]

proff()
# Executed in 0.05 second(s).

/*============

profon()

SetHilightChar("♥")

? StzListOfCharsQ("TEXT").BoxedXT([
	:Line = :Solid,	# or :Dashed
		
	:AllCorners = :Round, # can also be :Rectangualr

	# Or you can specify evey corner like this:

	:Corners = [ :Round, :Rectangular, :Round, :Rectangular ],

	:Hilighted = [ 3 ] # The 3rd char is hilighted
		
])

#-->
# ╭───┬───┬───┬───┐
# │ T │ E │ X │ T │
# └───┴───┴─♥─┴───╯

proff()
# Executed in 0.09 second(s).

/*-------------

profon()

? StzListOfCharsQ("A":"E").BoxedXT([
	:AllCorners = :Round,
	:Hilighted = [ 1, 2, 5, 3, 7 ],
	:Numbered = _TRUE_
])
#-->
# ╭───┬───┬───┬───┬───╮
# │ A │ B │ C │ D │ E │
# ╰───┴─•─┴─•─┴───┴─•─╯
#   1   2   3       5 

proff()
# Executed in 0.09 second(s).

/*-------------

profon()

? StzListOfCharsQ("A":"E").BoxedXT([ :Line = :Dashed, :AllCorners = :Round ])
#-->
# ╭╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌╮
# ┊ A ┊ B ┊ C ┊ D ┊ E ┊
# ╰╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌╯

proff()
# Executed in 0.04 second(s).

/*-------------

profon()

? StzListOfCharsQ("SOFTANZA").Boxed()
#-->
# ┌───┬───┬───┬───┬───┬───┬───┬───┐
# │ S │ O │ F │ T │ A │ N │ Z │ A │
# └───┴───┴───┴───┴───┴───┴───┴───┘

proff()
# Executed in 0.03 second(s).

/*=========

profon()

? @@( L('"ا":"ج"') )
#o--> [ "ا", "ب", "ة", "ت", "ث", "ج" ]

proff()
# Executed in 0.07 second(s).

/*-------------

profon()

? StzListOfCharsQ(L('"ا":"ج"')).BoxedXT([ :Line = :Dashed, :AllCorners = :Round ])
#-->
#  ╭╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌╮
#o ┊ ا ┊ ب ┊ ة ┊ ت ┊ ث ┊ ج ┊
#  ╰╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌╯
#o 

#NOTE to get a correct boxing, you should use a fixed font

proff()
# Executed in 0.10 second(s).

/*-------------

profon()

? StzListOfCharsQ("منصوريات").Boxed()
#-->
#  ┌───┬───┬───┬───┬───┬───┬───┬───┐
#o │ م │ ن │ ص │ و │ ر │ ي │ ا │ ت │
#  └───┴───┴───┴───┴───┴───┴───┴───┘

proff()
# Executed in 0.04 second(s).

/*-------

profon()

? BothEndWithANumber( "day1", "day3" )
#--> _TRUE_

proff()
# Executed in 0.01 second(s).

/*-------

profon()

? Q("[1, 2, 3 ]").ToList() # Or L("[1, 2, 3 ]")
#--> [ 1, 2, 3 ]

? Q("1:3").ToList() # Or ? L("1:3")
#--> [ 1, 2, 3 ]

? Q('"A":"C"').ToList() # Or L('"A":"C"')
#--> [ "A", "B", "C"]

? Q(" 'A' : 'C' ").ToList() # Or ? L(" 'A' : 'C' ")

? Q("#1 : #3").ToList() # Or L("#1 : #3")
#--> [ "#1", "#2", "#3" ]

? Q("#21 : #23").ToList() # Or L("#21 : #23")
#--> [ #21, #22, #23 ]

? Q("day1 : day3").ToList() # Or L("day1 : day3")
#--> [ "day1", "day2", "day3" ]

? @@( Q('softanza').ToList() ) # Or @@( L('softanza') )
#--> [ "softanza" ]

proff()
# Executed in 0.22 second(s).
