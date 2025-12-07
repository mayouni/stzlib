load "../stzbase.ring"

/*---

pr()

# Softanza knows all the 26 invisible chars available in Unicode:
? len( InvisibleUnicodes() )
#--> 26

# Let's see some of them:
? ShowShort( InvisibleUnicodes() )
#--> [ 9, 32, 173, "...", 119160, 119161, 119162 ]

# And then take randomly 5 of them:
anSomeUnicodes = NRandomNumbersIn( 5, InvisibleUnicodes() )
? @@( anSomeUnicodes ) + NL
#--> [ 6069, 8199, 8207, 8287, 10240 ]

# Softanza can "display" them of course, but unfortunately, you won't see anything,
# Let's see their Unicode names then:
? UnicodesNames(anSomeUnicodes)
#--> [
#	"KHMER VOWEL INHERENT AA",
#	"FIGURE SPACE",
#	"RIGHT-TO-LEFT MARK",
#	"MEDIUM MATHEMATICAL SPACE",
#	"BRAILLE PATTERN BLANK"
# ]

 pf()
# Executed in 0.15 second(s) in Ring 1.23
# Executed in 0.28 second(s) in Ring 1.21

/*-----------

pr()

? ShowShort(
	Q( CircledDigitUnicodes() ).
	MergedWith( CircledLatinLetterUnicodes() )
)
#--> [ 9312, 9313, 9314, "...", 9447, 9448, 9449 ]

pf()
# Executed in 0.01 second(s) in Ring 1.23

/*------------

# Do you knwo how many punctuation chars are theer in Unicode?
? NumberOfPunctuationChars()
#--> 250

# See them all:
? ShowShort(PunctuationChars()) + NL
#--> [ " ", " ", " ", "...", "⹽", "⹾", "⹿" ]

# Unciode classifies them in two blocks: General and Supplemental.
# Let's see...

? NumberOfGeneralPunctuationChars()
#--> 111

# They are liste here:
? ShowShort(GeneralPunctuationChars()) + NL
#--> [ " ", " ", " ", "...", "⁭", "⁮", "⁯" ]

? NumberOfSupplementalPunctuationChars()
#--> 138

# You can see them here:
? ShowShort(SupplementalPunctuationChars())
#--> [ "ⷶ", "ⷷ", "ⷸ", "...", "⹽", "⹾", "⹿" ]

pf()
# Executed in 1.85 second(s) in Ring 1.23

/*--------------

pr()

? UnicodeDirectionsXT()[5][3]
#--> europeannumberterminator

pf()
# Executed in almost 0 second(s) in Ring 1.23
