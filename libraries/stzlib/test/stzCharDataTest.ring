load "../max/stzmax.ring"

/*---

pr()

# Softanza knows all the 54 invisible chars available in Unicode:
? len( InvisibleUnicodes() )
#--> 54

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
 #--> Executed in 0.28 second(s)

/*-----------
//[ 9, 4447, 8194, 8201, 10240 ]
/*-----------

? Q( CircledDigitUnicodes() ).MergedWith( CircledLatinLetterUnicodes() )

/*------------

# Do you knwo how many punctuation chars are theer in Unicode?
? NumberOfPunctuationChars() #--> 250

# See them all:
//? PunctuationChars()

# Unciode classifies them in two blocks: General and Supplemental.
# Let's see...

? NumberOfGeneralPunctuationChars() #--> 111

# They are liste here:
//? GeneralPunctuationChars()

? NumberOfSupplementalPunctuationChars() #--> 138

# You can see them here:
? SupplementalPunctuationChars()

/*--------------

? UnicodeDirectionsXT()[5][3]
