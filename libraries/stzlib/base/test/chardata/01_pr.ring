# Narrative
# --------
# pr()
#
# Extracted from stzchardatatest.ring, block #1.

load "../../stzBase.ring"


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
# Executed in almost 0 second(s) in Ring 1.26 (Backed by StzEngine)
# Executed in 0.15 second(s) in Ring 1.23
# Executed in 0.28 second(s) in Ring 1.21
